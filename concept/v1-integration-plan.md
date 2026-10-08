# ScreenDiet v1 — Integration Plan

> Status: plan · Date: 2026-10-08 · Branch base: `proteinapp`
> Scope: align the codebase with the v1 concept (3 food groups, 5 rules, honest tracking) and add
> **Paywall, Hook, Live Activities, Widgets, Notification hooks and Interactive animations**.

---

## 0. Guiding rules

1. **Only claim what the APIs can measure.** Live numbers in the app are approximate (5‑min steps). Exact numbers and grades live only in the DeviceActivityReport extension.
2. **One ManagedSettingsStore per rule.** Blocks stack; nothing overwrites anything else.
3. **The system is the source of truth.** Every restriction must survive the main app being killed: schedules re-apply blocks, not timers.
4. **Everything shared goes through the App Group** `group.com.gia.screendiet` via one `SharedState` type.
5. **Physical device for every Family Controls test.** Simulator is for UI only.

---

## 1. Current state → target state

| Area | Today | Target v1 |
|---|---|---|
| Food groups | 4 (protein, carbs, fats, fiber) | 3 — 🍩 Carbs, 🥑 Fats, 🥩 Protein (fiber merged into protein) |
| Block stores | 1 shared store, overwritten | 4 named stores: `carbs`, `night`, `fast`, `strict` |
| Cheat meal expiry | Main-app `Timer` (breaks when app is closed) | One-off DeviceActivity schedule; `intervalDidEnd` re-blocks |
| Fats | Time limit `ratio * 3` | No limit; blocked only during Night Fast |
| Usage tracking | Carbs thresholds + dead `incrementUsage` | Carbs thresholds only |
| Report / grade | Main app, carbs-only data (fake %) | **New DeviceActivityReport extension**, exact data |
| Paywall | SuperwallKit package added, unused | Superwall placements + StoreKit 2 entitlement |
| Widgets / Live Activity | None | **New WidgetKit extension** (widgets, Live Activity, Control) |
| Notifications | Fired from extension only | Scheduled local plan + extension thresholds + actionable categories |
| Testing values | 6‑min carb limit / 6‑min cheat hardcoded | `#if DEBUG` `DebugConfig` |
| Secrets | `.p8` keys committed | Revoked, removed from history, `*.p8` in `.gitignore` |

---

## 2. Target architecture

```
┌──────────────────────── App Group: group.com.gia.screendiet ────────────────────────┐
│  SharedState.json (profile, selections, counters, cheat, fast, entitlement, streak)  │
│  Darwin notification: com.gia.screendiet.stateChanged                                │
└──────────────────────────────────────────────────────────────────────────────────────┘
      ▲            ▲              ▲                ▲                 ▲              ▲
 ┌────┴────┐ ┌─────┴──────┐ ┌─────┴───────┐ ┌──────┴──────┐ ┌────────┴─────┐ ┌──────┴──────┐
 │ Main app│ │ Monitor ext│ │ ShieldConfig│ │ ShieldAction│ │ Report ext   │ │ Widget ext  │
 │ SwiftUI │ │ schedules, │ │ which screen│ │ cheat meal  │ │ Nutrition    │ │ widgets,    │
 │ Superwall│ │ thresholds │ │ to show     │ │ 2‑tap flow  │ │ Label, grade,│ │ Live Activity│
 │ Intents │ │ re-blocks  │ │             │ │             │ │ hook insight │ │ Control     │
 └─────────┘ └────────────┘ └─────────────┘ └─────────────┘ └──────────────┘ └─────────────┘
```

### 2.1 Targets

| Target | Status | Bundle ID |
|---|---|---|
| `screengate` (app) | exists | `com.gia.screendiet` |
| `DeviceActivityMonitorExtension` | exists | `…screendiet.DeviceActivityMonitorExtension` |
| `ShieldConfigurationExtension` | exists | `…screendiet.ShieldConfigurationExtension` |
| `ShieldActionExtension` | exists | `…screendiet.ShieldActionExtension` |
| **`NutritionReportExtension`** | **new** (DeviceActivityReport) | `…screendiet.NutritionReportExtension` |
| **`ScreenDietWidgets`** | **new** (WidgetKit + ActivityKit) | `…screendiet.ScreenDietWidgets` |

All new targets: Family Controls entitlement (report ext), App Group, iOS 26 deployment target.
Main app Info.plist: `NSSupportsLiveActivities = YES`.

### 2.2 Shared code (`Shared/`, member of all targets)

| File | Purpose |
|---|---|
| `SharedState.swift` | Codable struct + `SharedStore.load()/save()/mutate {}` with file coordination |
| `FoodGroup.swift` | moved from app; 3 cases |
| `DietProfile.swift` | moved from `Diet.swift`; plans, window, portion, night fast, cheats |
| `DietRules.swift` | **pure** functions: `state(at:profile:counters:)`, `shieldKind(...)`, next boundaries |
| `Stores.swift` | `ManagedSettingsStore.Name` constants: `.carbs`, `.night`, `.fast`, `.strict` |
| `ScheduleNames.swift` | `DeviceActivityName` constants (below) |
| `Entitlement.swift` | `isPremium` cached flag + feature gates |
| `DebugConfig.swift` | test overrides under `#if DEBUG` |
| `ActivityAttributes.swift` | `FastActivityAttributes` for Live Activity (app + widget ext) |

Extensions must stay tiny (Monitor ext ≈ 6 MB memory) — `Shared/` must not import SwiftUI-heavy code.

### 2.3 SharedState schema

```swift
struct SharedState: Codable {
    var version: Int = 2
    var profile: DietProfile?                 // plan, window, portion, nightFast, weekendWindow, cheatsPerWeek
    var selections: [FoodGroup: FamilyActivitySelection]
    var counters: DayCounters                 // dateKey, carbMinutes (≈), cheatsUsedToday, portionHit
    var week: WeekCounters                    // weekStart, cheatsUsed, daysOverPortion, daysCompleted
    var cheat: CheatSession?                  // startedAt, endsAt, source (.shield/.app)
    var fast: FastSession?                    // startedAt, endsAt, source (.button/.siri/.focus/.widget)
    var streak: Int                           // consecutive days within portion
    var isPremium: Bool                       // cached from StoreKit / Superwall
    var shieldPending: ShieldPending?         // 2‑tap cheat confirm state (token-scoped, 20 s TTL)
    var onboarding: OnboardingAnswers?        // quiz answers for hook + plan suggestion
}
```

Migration (`version` 1 → 2): read legacy keys (`dietProfile`, `foodGroup_*`, `carbsUsedToday`, `cheatsUsedThisWeek`, …), drop `fiber` selection (it becomes Protein = unrestricted), write `SharedState.json`, delete legacy keys.

### 2.4 Schedules (DeviceActivity budget ≈ 20)

| Name | Type | Interval | Events | Purpose |
|---|---|---|---|---|
| `diet.window.weekday` | repeating, Mon–Fri* | window start→end | `usage-5 … usage-N` (≤20) | open carbs, count portion |
| `diet.window.weekend` | repeating, Sat–Sun* | weekend window | same | weekend refeed (premium) |
| `diet.night` | repeating daily | nightStart→nightEnd | none | Night Fast |
| `diet.cheat` | one-off | now→now+15/30 min | none | cheat meal, re-block on end |
| `diet.fast` | one-off | now→fast end | none | Fast Now |
| `diet.daily.rollover` | repeating daily | 00:00→00:15 | none | reset counters, streak, week rollover |

\* DeviceActivitySchedule repeats on matching `DateComponents`; weekday-specific schedules use one schedule per weekday (`diet.window.1` … `.7`) — 7 schedules max, still in budget. Start with a single daily schedule for v1.0; add per-weekday in v1.2.

Constraint checks in `DietRules.validate(profile)`:
- every interval ≥ 15 min (cheat meal min = 15 min),
- window and night fast must not overlap (UI prevents it),
- Detox = no window schedule at all (fix the current zero-length bug),
- threshold count ≤ 20; step = max(5, ceil(portion / 12)) so post-portion tracking still fits.

### 2.5 Stores and shield precedence

| Store | Blocks | Set by | Cleared by |
|---|---|---|---|
| `.carbs` | Carbs selection | window end, portion hit, cheat end | window start, cheat start |
| `.night` | Carbs + Fats | `diet.night` start | `diet.night` end |
| `.fast` | Carbs + Fats | `diet.fast` start / intent | `diet.fast` end |
| `.strict` | `denyAppRemoval`, `requireAutomaticDateAndTime` | diet activation (premium) | deactivation after cooldown |

Shield Configuration picks the message by precedence: **fast > night > portion hit > kitchen closed**, computed with `DietRules` from `SharedState` + current time (not a single cached string).

---

## 3. Phased plan

Estimates assume 1 iOS developer. Each phase ends with a device test pass.

### Phase 0 — Hygiene (0.5 day)
- [ ] Revoke both App Store Connect `.p8` keys; create new ones; store only in Superwall dashboard / password manager.
- [ ] `git rm --cached *.p8`, add `*.p8` to `.gitignore`, purge history (`git filter-repo --path-glob '*.p8' --invert-paths`), force-push after team agreement.
- [ ] Move testing values (6‑min portion, 6‑min cheat) into `DebugConfig` (`#if DEBUG`), production defaults 45/90 min and 30 min.
- [ ] Delete stray root `timeline.swift`; update `CLAUDE.md` (screendiet IDs, 3 groups, new targets).

**Done when:** release build has production values; `git log --all -- '*.p8'` is empty.

### Phase 1 — Core engine refactor (4–5 days)
1. Create `Shared/` files from §2.2; move `FoodGroup`, `DietProfile`, `EatingWindow` there.
2. `FoodGroup` → 3 cases; remove `monitorCount`, `thresholdMinutes`, macro ratios, `DietType.defaultRatios`.
3. `SharedStore` with migration (§2.3). Replace scattered UserDefaults keys in app + 3 extensions.
4. `DietRules` pure functions + unit-testable (add a `ScreenDietTests` target — first tests in the project).
5. Named stores (§2.5). `DeviceActivityManager` gets `apply(_ store:, selection:)` / `clear(_ store:)`.
6. Rewrite `DietManager.startDietMonitoring()` to register schedules in §2.4; delete fats-limit monitor and `incrementUsage`.
7. Cheat meal = `diet.cheat` schedule. `intervalDidStart` → clear `.carbs`; `intervalDidEnd` → recompute state → re-apply `.carbs` if needed. Remove `cheatTimer`.
8. Fast Now = `diet.fast` schedule + `.fast` store.
9. `diet.daily.rollover` handles counters/streak/week reset in the extension (works with app closed).
10. Darwin notification: rename to `stateChanged`; fix self-loop by comparing a `writerID` + monotonic `revision` in `SharedState` instead of the `isSavingToUserDefaults` flag.
11. `NutritionLog`: strip protein/fats/fiber minutes; keep `carbMinutes`, `cheatsUsed`, `portionHit`.

**Acceptance tests (device):**
- Portion hit during window → carbs blocked; Fats unaffected.
- Night Fast active, carb window ends → Fats **still** blocked.
- Cheat from shield, kill app, wait 15 min → carbs re-blocked.
- Midnight with app closed → counters reset, streak updated.
- Detox activates without error.

### Phase 2 — Shields (2 days)
- Shield Configuration: 5 designs (Kitchen Closed, Plate's Empty, Fasting, Focus Fast, No cheats left), using `application.localizedDisplayName`, countdown text computed at render ("opens at 12:00 · 2h 14m").
- Shield Action 2‑tap cheat:
  1. Secondary button "Cheat meal" → write `shieldPending(token, expires: +20 s)` → return `.defer` → shield re-renders: "Cheat meal? 2 left this week. Tap again to confirm."
  2. Second tap within 20 s → start `diet.cheat` → `.close`.
  - Not offered during Night Fast / Fast Now / zero cheats left (premium can set cheats=0 for "hardcore").
- Free tier: 1 cheat/week; premium: 0–7.

### Phase 3 — Nutrition Report extension (3–4 days)
New target `NutritionReportExtension` with `DeviceActivityReportScene`s:

| Context | Used in | Content |
|---|---|---|
| `.hookInsight` | Onboarding hook | last 7 days total, junk share for the just-picked Carbs, yearly projection |
| `.today` | Kitchen tab card | today's Carbs / Fats / Protein split, pickups, first pickup |
| `.nutritionLabel` | Report tab | week split with %, top 5 junk apps (icons via `Label(token)`), late-night minutes (22:00–06:00 by hourly segments), pickups/day |
| `.weeklyGrade` | Report tab + Sunday screen | A–F grade computed here |

Filters: `DeviceActivityFilter(segment: .daily/.hourly, applications:, categories:)` built from Carbs and Fats selections; "Protein" = everything else (total − carbs − fats).

Grade formula (inside extension only):
```
score = 40·(1 − carbShare/target)  + 25·(daysWithinPortion/7)
      + 20·(1 − lateNightMin/120)  + 15·(1 − pickups/150)     (each term clamped 0…1)
A ≥ 85, B ≥ 70, C ≥ 55, D ≥ 40, F < 40
```
The app never reads these numbers. App-side logic (streak, Sunday suggestion) uses only `SharedState` counters.

Delete `MetabolicScoreCalculator`, `WeeklyNutritionSummary`; `NutritionReportView` becomes a host for `DeviceActivityReport(.nutritionLabel, filter:)`.

### Phase 4 — Hook & onboarding (3 days)
Flow (≈ 90 s, every screen 1 decision):

| # | Screen | Notes |
|---|---|---|
| 1 | Splash | existing |
| 2 | **Hook A — "You'd never eat junk 6 hours a day."** | animated plate filling with app icons (generic SF Symbols, no real data yet) |
| 3 | Quiz: daily hours · worst time · goal | stored in `onboarding` |
| 4 | Screen Time permission | existing `PermissionsView`, add pre-prompt explainer |
| 5 | Pick 🍩 Carbs | `FamilyActivityPicker` |
| 6 | **Hook B — First Insight (real data)** | `DeviceActivityReport(.hookInsight)`: "Last week you ate **18h 40m** of junk. That's **40 days a year**." |
| 7 | Pick 🥑 Fats (skippable) | |
| 8 | Plan suggestion | quiz → Lean / Keto / Detox, editable |
| 9 | Eating window dial | interactive dial (§7) |
| 10 | Notification permission pre-prompt | shows a mock "Kitchen Open" banner, then system prompt |
| 11 | **Paywall** (`onboarding_complete` placement) | trial offer |
| 12 | Diet Activated celebration | confetti plate, "Kitchen opens at 12:00" |

Rules: Hook B appears only after permission + Carbs picked (it needs both). If report shows < 1h (new phone), fall back to quiz-based estimate copy.

### Phase 5 — Paywall (Superwall + StoreKit 2) (2–3 days)
**Products** (App Store Connect, one subscription group "ScreenDiet Premium"):
- `screendiet.premium.yearly` — $29.99, 7‑day free trial
- `screendiet.premium.monthly` — $4.99
- (optional) `screendiet.premium.lifetime` — non-consumable $59.99

**Integration**
- `Superwall.configure(apiKey:)` in `screengateApp.init` (public API key — fine in app; never commit `.p8`).
- Purchase controller: let Superwall handle purchases with StoreKit 2; listen to `Superwall.shared.subscriptionStatus` → write `SharedState.isPremium` → reload widgets.
- On launch also verify with `Transaction.currentEntitlements` (offline fallback).
- Restore button on every paywall + Settings.

**Placements**

| Placement | Trigger | Gate |
|---|---|---|
| `onboarding_complete` | onboarding step 11 | soft (skippable → free tier) |
| `feature_night_fast` | enabling Night Fast | premium |
| `feature_strict_mode` | toggling strict mode | premium |
| `feature_custom_plan` | Custom / Detox plan | premium |
| `feature_widgets` | tapping a locked widget (deep link) | premium |
| `cheat_out` | user out of cheats in app | upsell more cheats |
| `weekly_report` | opening full Nutrition Label on free tier | premium |
| `day_3_trial_reminder` | app open on day 3 of trial (Superwall audience rule) | info |

**Free vs Premium** (from concept §8): Free = 1 plan (Lean), carbs only, window + portion, 1 cheat/week, Today card. Premium = everything else.

**Downgrade handling:** when premium ends → keep diet running on free rules (disable night fast, strict mode cleared, cheats → 1), show one-time "You're back on Lean" sheet. Never leave a user blocked by a feature they can no longer edit.

### Phase 6 — Notification hooks (2 days)
Two sources:
- **Scheduled by app** (reliable, known times) — rebuilt whenever the profile changes, rolling 7 days, stay under the 64 pending limit.
- **Fired by Monitor extension** (usage-driven) — thresholds, cheat end.

| ID | When | Copy | Action buttons | Source |
|---|---|---|---|---|
| `kitchen.opening` | window start −10 min | "🍳 Kitchen opens in 10 min" | — | scheduled |
| `kitchen.open` | window start | "Kitchen's open. 45 min on your plate." | — | scheduled |
| `portion.half` | 50% portion | "Half your plate's gone. 22 min left." | — | extension |
| `portion.last5` | portion −5 min | "Last bites — 5 min of carbs left." | — | extension (threshold warning) |
| `portion.empty` | portion hit | "Plate's empty. Back tomorrow 🍽️" | "See my label" | extension |
| `kitchen.closing` | window end −10 min | "Kitchen closes in 10 min." | — | scheduled |
| `night.soon` | night start −15 min | "🌙 Night Fast in 15 min. Wrap up." | "Start fast now" | scheduled |
| `cheat.ending` | cheat end −2 min | "Cheat meal ends in 2 min." | — | scheduled at cheat start (app) / extension |
| `morning.recap` | night end | "You fasted 9h. Streak: 🔥 6" | "Open Kitchen" | scheduled, body updated by rollover |
| `streak.risk` | window end −30 min, if ≥ 80% portion | "Stay under to keep your 🔥 6 streak." | — | extension |
| `sunday.checkin` | Sun 18:00 | "Your weekly label is ready. Grade: ?" | "See label" | scheduled |
| `trial.ending` | trial day 5 | "Your trial ends in 2 days." | — | scheduled |

- Categories: `NIGHT_SOON` (action `START_FAST` → runs `StartFastIntent`), `LABEL` (opens Report tab).
- Interruption level: `.timeSensitive` only for `portion.last5` and `night.soon` (requires Time Sensitive capability); others `.active`.
- Settings → Notifications screen with per-type toggles (stored in `SharedState`).
- Replace current `NotificationDelegate` deep-link handling with a router enum (`.kitchen`, `.report`, `.paywall(placement)`).

### Phase 7 — Widgets, Live Activity, Controls (4 days)
New target `ScreenDietWidgets` (WidgetKit + ActivityKit). Reads `SharedState` (read-only).

**Widgets**

| Widget | Families | Content |
|---|---|---|
| Kitchen Status | small, systemMedium, accessoryCircular, accessoryRectangular | Open/Closed/Fasting + `Text(timerInterval:)` countdown to next boundary |
| Plate | small, accessoryCircular | ring of approximate carbs left ("≈ 18 min") |
| Streak | small, accessoryInline | 🔥 6 · cheats left 2 |
| Fast Now (interactive) | small, medium | buttons 1h / 2h / Until morning → `StartFastIntent` |

- Timeline: entries at every known boundary (window start/end, night start/end, cheat end) + `.atEnd`. Countdown text self-updates without reloads.
- Monitor extension calls `WidgetCenter.shared.reloadAllTimelines()` on threshold / interval events (budgeted — verify on device).
- Free tier: widgets render a locked state that deep-links to `feature_widgets` paywall.

**Live Activity — `FastActivityAttributes`**
- Kinds: Fast Now, Night Fast, Cheat Meal (countdown "Cheat ends 12:45").
- Lock Screen: plate/moon illustration, countdown (`Text(timerInterval:)`), progress bar.
- Dynamic Island: compact = 🌙 + mm:ss; minimal = ring; expanded = countdown + "Ends 07:00" + streak.
- **Who starts it:** only an app process can start an Activity. So:
  - Fast Now / Cheat from app → app starts it directly.
  - Fast Now from widget, Siri, notification action, Control → `StartFastIntent: LiveActivityIntent` (runs in app process in background) → applies `.fast` + starts schedule + starts Activity.
  - Night Fast → started when app is foregrounded during/near night start, or via the `night.soon` notification action. (Extensions can't start activities; push-to-start would need a server — out of scope for v1.)
  - Cheat from shield → not shown as a Live Activity (extension can't start it); covered by `cheat.ending` notification.
- Duration: system limit ~8 h active; Night Fast sets `staleDate` = end; ending updated on `diet.night` end via app if running, otherwise it goes stale and the system dismisses it.

**Control Center / Action Button (iOS 18+ `ControlWidget`)**
- `StartFastControl` → `StartFastIntent` (default 1 h, configurable).
- App Shortcuts: "Start a fast in ScreenDiet", "How much carbs do I have left?" (read-only answer from `SharedState`).
- Focus filter: `SetFocusFilterIntent` — "When Work Focus is on, start Fast Now" (premium).

### Phase 8 — Interactive animations (3 days, parallel with 6–7)
All built with native SwiftUI (no Lottie/Rive dependency for v1). Every animation respects `accessibilityReduceMotion` (fallback: cross-fade).

| # | Where | Interaction | Implementation |
|---|---|---|---|
| A1 | Onboarding Hook A | app icons drop onto a plate and pile up as the hours counter climbs | `KeyframeAnimator` per icon + `contentTransition(.numericText())` |
| A2 | Hook B (real data) | "18h 40m" counts up, then the plate cracks into "40 days/year" | `PhaseAnimator` (count → crack → reveal) + `.sensoryFeedback(.impact)` |
| A3 | Carbs picking | picked apps fly into a 🍩 bowl | `matchedGeometryEffect` (picker result → bowl) |
| A4 | **Eating-window dial** | 24h circular dial; drag two handles for window start/end and a moon handle for night fast; arcs snap to 15 min; haptic tick per step; overlapping is blocked with a bounce | custom `Canvas` + `DragGesture`, angle→time mapping, `.sensoryFeedback(.selection, trigger: step)` |
| A5 | Kitchen status ring | ring morphs between Open (green arc draining as portion is used), Closed (lock), Fasting (moon, arc filling to morning) | `TimelineView(.periodic(from:by:60))` + `Shape` `animatableData`, `symbolEffect(.bounce)` on state change |
| A6 | Plate | plate with "bites" removed per 5 min used; tap plate → wobble + shows "≈ 18 min left" | `Canvas` mask circles, `.spring` |
| A7 | Cheat meal in app | **press-and-hold 2 s** to confirm (ring fills, rising haptics); release early cancels | `onLongPressGesture(minimumDuration:perform:onPressingChanged:)` + `.sensoryFeedback(.increase)` |
| A8 | Fast Now | slide-to-fast control (1h/2h/morning snap points) | `DragGesture` with snap + spring |
| A9 | Streak | flame grows per day; milestone (7/14/30) → particle burst | `Canvas` particles in `TimelineView(.animation)` |
| A10 | Diet Activated | plate fills with "protein" icons then confetti; CTA appears | `PhaseAnimator` + particles |
| A11 | Sunday grade reveal | card flips to show grade letter; grade ring sweeps | `rotation3DEffect` + `Shape` sweep |
| A12 | Tab/state changes | food-group chips, counters | `contentTransition(.numericText())`, `symbolEffect` |

Shields cannot animate (system UI) — keep them static and bold.

### Phase 9 — Strict mode, Settings, polish (2 days)
- Strict mode (premium): `.strict` store sets `application.denyAppRemoval = true`, `dateAndTime.requireAutomaticDateAndTime = true`.
- Loosening any rule (bigger portion, wider window, more cheats, deactivate) → 24 h cooldown queue (`pendingChanges` in `SharedState`, applied by rollover schedule). Tightening = instant.
- Settings: plan, window dial, night fast, groups, cheats, notifications, strict mode, restore purchases, privacy note ("Your diet never leaves your phone").

### Phase 10 — QA & release (3 days)
- Device test matrix (§5), TestFlight to 10–20 users for one full week (needs Sunday check-in + rollover).
- App Store: Family Controls distribution entitlement approved for **all** targets incl. the two new ones (request early — Apple review of this entitlement can take weeks).
- Privacy nutrition label: no data collected (Superwall analytics: disclose as per their docs).
- Screenshots: Kitchen ring, shield, Nutrition Label, Live Activity, widgets.

---

## 4. Timeline (1 developer)

| Week | Work |
|---|---|
| 1 | Phase 0, Phase 1 |
| 2 | Phase 1 finish, Phase 2 |
| 3 | Phase 3, Phase 4 |
| 4 | Phase 5, Phase 6 |
| 5 | Phase 7, Phase 8 (A4–A7) |
| 6 | Phase 8 rest, Phase 9 |
| 7 | Phase 10 (one real week of TestFlight) |

Critical path: **Family Controls distribution entitlement for new targets** — request in week 1.

---

## 5. Device test matrix

| # | Scenario | Expected |
|---|---|---|
| T1 | Open carb app before window | Kitchen Closed shield with correct countdown |
| T2 | Use carbs to portion | 50% + last‑5 notifications, Plate's Empty shield, Fats still open |
| T3 | Cheat from shield (2 taps), kill app | unlocked 15/30 min, re-blocked on time |
| T4 | Cheat during Night Fast | option not shown |
| T5 | Window end while Night Fast active | Fats remain blocked |
| T6 | Fast Now from widget, app not running | blocks + Live Activity appear |
| T7 | Fast Now from Control Center / Siri | same as T6 |
| T8 | Midnight, app closed | counters reset, streak +1 or 0, morning recap correct |
| T9 | Sunday | check-in notification, grade in report |
| T10 | Premium expires | downgrade sheet, night fast/strict removed, no stuck blocks |
| T11 | Strict mode | can't delete app, can't change time, loosening waits 24 h |
| T12 | Reinstall | migration/clean state, no stale counters |
| T13 | Reduce Motion on | all animations fall back to fades |
| T14 | Detox plan | activates, carbs always blocked |

---

## 6. Risks & mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Threshold callbacks delayed/missed | portion counter lags | show "≈", rely on report for exact; re-sync on app open |
| Monitor ext memory limit | silent crashes | keep `Shared/` lean, no JSON of large selections in ext hot path (cache tokens per store) |
| Widget reload budget | stale widget numbers | countdowns via `Text(timerInterval:)`; numbers marked "≈" |
| Live Activity can't start from extensions | no LA for shield cheats / unattended night fast | notification fallback; `LiveActivityIntent` for user-initiated paths |
| Family Controls distribution entitlement delay | blocks release | request in week 1 for all 6 targets |
| Users bypass via Screen Time settings / revoking permission | diet stops silently | detect `AuthorizationCenter.authorizationStatus` on launch → "Diet paused" banner + notification |
| Overly strict defaults → uninstall | churn | default plan Lean; cheats on; strict mode opt-in |

---

## 7. Files to delete / rename

- Delete: `timeline.swift`, `MetabolicScoreCalculator`, `WeeklyNutritionSummary`, fats-limit monitor, `incrementUsage`, `cheatTimer`, legacy UserDefaults keys after migration.
- Rename: Darwin notification `dietChanged` → `stateChanged`; app struct `DeviceActivityMonitorDemoApp` → `ScreenDietApp`.
- Move to `Shared/`: `FoodGroup`, `Diet.swift` (as `DietProfile.swift`), new `DietRules`.
