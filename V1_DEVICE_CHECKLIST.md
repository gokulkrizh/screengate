# ScreenDiet v1 — Device & Release Checklist

> Everything below requires a **physical device** unless noted. The simulator is UI-only.
> Date: 2026-10-08 · Branch: `v1-integration`

## 1. Manual / external prerequisites (not doable from the repo)

- [ ] **Revoke the two `.p8` keys** (App Store Connect / Superwall dashboard) — they were untracked
      and gitignored on this branch, but they remain in git history. Rotation is the real fix.
- [ ] Decide on the **history purge** (`git filter-repo --path-glob '*.p8' --invert-paths` + force-push).
- [ ] **App Store Connect**: subscription group "ScreenDiet Premium" with
      `screendiet.premium.yearly` ($29.99, 7-day trial), `.monthly` ($4.99), optional `.lifetime`.
- [ ] **Superwall**: dashboard placements (`onboarding_complete`, `feature_night_fast`,
      `feature_strict_mode`, `feature_custom_plan`, `feature_widgets`, `cheat_out`, `weekly_report`,
      `day_3_trial_reminder`) + API key. Then replace the two TODOs in `EntitlementManager`.
- [ ] **Family Controls distribution entitlement** for all 6 targets:
      app, Device Activity Monitor, Shield Configuration, Shield Action, NutritionReport,
      ScreenDietWidgets. Request in Week 1 — Apple review can take weeks.
- [ ] Accept signing updates in Xcode once (new targets + Time Sensitive capability).
- [ ] Widgets/Live Activity: verify `NSSupportsLiveActivities` passes review (already set).

## 2. Device test matrix (from the plan §5)

| # | Scenario | Expected | Pass |
|---|---|---|---|
| T1 | Open a carb app before the window | Kitchen Closed shield + correct countdown | |
| T2 | Use carbs up to the portion | portion.half + last-5 / Plate's Empty shield; Fats still open | |
| T3 | Cheat from shield (2 taps), then kill the app | unlocked for the cheat duration, re-blocked on time | |
| T4 | Cheat during Night Fast | option not shown (no secondary button) | |
| T5 | Window ends while Night Fast active | Fats remain blocked (night store stacks) | |
| T6 | Start a fast from the widget (app not running) | blocks applied + Live Activity appears | |
| T7 | Start a fast from Control Center / Siri | same as T6 | |
| T8 | Midnight, app closed | counters reset, streak +1/0, morning recap correct | |
| T9 | Sunday | check-in notification, grade appears in the report tab | |
| T10 | Premium expires (debug toggle off) | downgrade notice, Night Fast/strict removed, nothing stuck | |
| T11 | Strict mode ON | can't delete the app, can't change the clock; loosening waits 24 h | |
| T12 | Reinstall | migration/clean state, no stale counters | |
| T13 | Reduce Motion ON | animations fall back to fades; confetti off | |
| T14 | Detox plan | activates, carbs always blocked, no window schedule | |

Extra device checks:

- [ ] Shield **cheat starts `diet.cheat` from the extension** (T3 depends on it; if the system rejects
      `startMonitoring` from a shield action, move the schedule start to the next app foreground).
- [ ] Monitor extension memory stays within budget (no crashes on repeated thresholds).
- [ ] Widget reload budget: countdowns tick via `Text(timerInterval:)`; numbers refresh on events.
- [ ] Live Activity: Fast Now from widget/Siri starts it; Night Fast appears when the app is opened
      during the fast; Cheat Meal countdown shows for app-started cheats.
- [ ] Notifications: time-sensitive (`portion.last5`, `night.soon`), START_FAST action, SEE_LABEL action.
- [ ] Report extension: Nutrition Label + grade populate with real data; Hook B falls back to the quiz
      estimate on a fresh phone.

## 3. TestFlight (one full week)

- [ ] 10–20 users, one full week (needs a Sunday check-in + midnight rollovers).
- [ ] Watch for: stuck shields, missing rolls, widget staleness, Live Activity dismissal.

## 4. App Store

- [ ] Privacy nutrition label: no data collected (Superwall analytics disclosed per their docs).
- [ ] Screenshots: Kitchen ring, shield, Nutrition Label, Live Activity, widgets.
- [ ] Release build has production durations (45/90/30) — verified by `DebugConfig` (`#if DEBUG`).

## 5. Known deviations from the plan (deliberate)

1. **Cheat duration in DEBUG is ≥ 15 min** (not 6): DeviceActivity one-off schedules cannot be
   shorter than 15 minutes. Production remains 30 min.
2. **`streak.risk` fires at the 80 % threshold crossing** (extension) rather than window-end −30 min —
   threshold events are more reliable than a conditional scheduled notification.
3. **`trial.ending`** is not scheduled yet — it needs Superwall's trial status.
4. **A3/A6/A11 animations** (icons flying into the bowl, plate bites, grade flip) are light-touch —
   the animated dial, hold-to-confirm, slide-to-fast, confetti and streak flame are done.
5. **Notification START_FAST action** starts a 60-minute fast; Phase 7's `StartFastIntent` can take
   over the notification action when the intents are wired to categories.
6. **Pending (24 h) profile changes apply on the next app foreground** — extensions can't rebuild
   schedules safely from the rollover callback.
