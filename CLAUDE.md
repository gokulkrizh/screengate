# CLAUDE.md

Guidance for AI agents working in this repository.

## Project Overview

**ScreenDiet** is an iOS digital wellness app. The repo folder is `screengate`, the Xcode project is
`screendiet.xcodeproj`, and the app scheme is `screengate`. It uses Apple's Family Controls framework to
classify apps into food groups and enforces eating windows, portions, night fasts and cheat meals with
ManagedSettings shields and DeviceActivity monitors.

| Fact | Value |
|---|---|
| Project | `screendiet.xcodeproj` |
| App scheme | `screengate` |
| Bundle IDs | `com.gia.screendiet` (+ `.ShieldConfigurationExtension`, `.ShieldActionExtension`, `.DeviceActivityMonitorExtension`) |
| App Group | `group.com.gia.screendiet` |
| DeviceActivity prefix | `com.gia.screendiet.` |
| Darwin notification | `com.gia.screendiet.stateChanged` |
| Min iOS | 26.0 · arm64 · Swift 5.0+ · SwiftUI + `@Observable` |

> **v1 integration is in progress** on branch `v1-integration`. The authoritative plan is
> `concept/v1-integration-plan.md`; the v1 target architecture is described at the bottom of this file.

## Build & Test

```bash
# Debug build (fast compile check)
xcodebuild -project screendiet.xcodeproj -scheme screengate -configuration Debug \
  -destination 'generic/platform=iOS Simulator' build

# Release build (must never contain DebugConfig test durations)
xcodebuild -project screendiet.xcodeproj -scheme screengate -configuration Release \
  -destination 'generic/platform=iOS Simulator' build
```

- **Family Controls / DeviceActivity behavior requires a physical device.** The simulator is for UI work only.
- `DeviceActivity` requires a 15-minute minimum schedule interval; threshold firing has ~±1 min variance.
- Unit tests: `xcodebuild test -project screendiet.xcodeproj -scheme ScreenDietTests -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`.
- Short durations for on-device testing live in `Shared/DebugConfig.swift` (`#if DEBUG` only).

## Current Targets

| Target | Product | Role |
|---|---|---|
| `screendiet` | `screengate.app` | Main SwiftUI app (onboarding, kitchen, report, pantry, settings, intents) |
| `ShieldConfigurationExtension` | `.appex` | Five state-driven shield designs (`ShieldConfigurationDataSource`) |
| `ShieldActionExtension` | `.appex` | 2-tap cheat meal, token-scoped pending confirmation |
| `DeviceActivityMonitorExtension` | `.appex` | Interval/threshold callbacks; applies stores; usage notifications |
| `NutritionReportExtension` | `.appex` | DeviceActivityReport scenes: hook insight, today, label, grade |
| `ScreenDietWidgets` | `.appex` | Widgets, Live Activity, Control, interactive Fast Now |
| `ScreenDietTests` | `.xctest` | Unit tests for pure rules (DietRules, Entitlement, ShieldPending) |

### Xcode synchronized folders (important)

The project uses Xcode 16 folder synchronization:
- `screengate/` is synchronized into the app target. `ShieldActionExtension` and
  `DeviceActivityMonitorExtension` get individual files from it via membership exception sets.
- `Shared/` is synchronized into `DeviceActivityMonitorExtension` (whole folder) and into the app and
  `ShieldActionExtension` via per-file `membershipExceptions` in `PBXFileSystemSynchronizedBuildFileExceptionSet`.
- **New files added to `Shared/` must be added to those exception lists** (or they won't compile in the app /
  shield action targets). See `/tmp` build errors like "cannot find X in scope" if missed.

## Current Architecture (v1 engine — Phase 1 landed)

```
SwiftUI View → DietManager ──► SharedStore (SharedState.json, app group)
                    │                    ▲
                    ▼                    │
            DeviceActivityManager   Monitor / Shield extensions
            (named stores +          compute state via DietRules,
             schedules)              reconcile stores themselves
```

Rules are pure (`DietRules`), state is one file (`SharedState.json`), and every process reconciles the
same named `ManagedSettingsStore`s from it. No timers, no scattered UserDefaults.

### Models (`screengate/Models/`)
| File | Purpose |
|---|---|
| `DietManager.swift` | `@Observable` façade over `SharedState`: schedule registration, cheat/fast sessions, store sync |
| `NutritionLog.swift` | Approximate daily counters for live UI (carbs only; exact numbers in the report extension) |

### Shared (`Shared/`) — member of app + extensions (see exception sets above)
| File | Purpose |
|---|---|
| `SharedState.swift` | Codable state: profile, selections, counters, week, cheat, fast, streak, premium, onboarding |
| `SharedStore.swift` | `SharedState.json` (atomic + file-coordinated); pre-v1 migration; posts Darwin `stateChanged` |
| `DietProfile.swift` | `DietPlan` (lean/keto/detox/custom), `EatingWindow`, `NightFast`, `DietProfile` |
| `DietRules.swift` | Pure rules: state precedence, store plans, thresholds, validation, midnight rollover |
| `FoodGroup.swift` | 3 groups: 🍩 carbs (portioned), 🥑 fats (fasts only), 🥩 protein (free) |
| `Stores.swift` | Named stores `carbs`, `night`, `fast`, `strict` (+ legacy cleanup) |
| `ScheduleNames.swift` | `diet.window.weekday`, `diet.night`, `diet.cheat`, `diet.fast`, `diet.daily.rollover` |
| `DeviceActivityManager.swift` | Store reconciliation, schedule registration, selection union helpers |
| `DebugConfig.swift` | Debug-only short durations; release defaults 45/90/30 min |
| `Entitlement.swift` | Free/premium gates (stubbed until Phase 5 wires Superwall) |

### Extension behavior
- **Monitor extension**: interval callbacks reconcile stores; `usage-N` thresholds update
  `counters.carbMinutes` / `portionHit`; `diet.daily.rollover` resets counters, updates the streak.
- **Shield config/action**: compute the kind from state (`fastNow > nightFast > portionHit > kitchenClosed`).
  Cheat meals lift only the `.carbs` store; `.night` / `.fast` keep stacking.
- Darwin `stateChanged` is only for the main app to refresh its observable state; extensions re-read the
  file on every callback and ignore their own writes via `writerID` + `revision`.

## v1 Architecture (integrated — see V1_DEVICE_CHECKLIST.md for device/launch items)

```
App Group: group.com.gia.screendiet — SharedState.json + Darwin notification stateChanged
Main app · Monitor ext · ShieldConfig ext · ShieldAction ext · NutritionReportExtension · ScreenDietWidgets
```

- **3 food groups**: 🍩 Carbs (portion-limited), 🥑 Fats (blocked only during fasts), 🥩 Protein (unlimited).
- **4 named ManagedSettingsStores**: `carbs`, `night`, `fast`, `strict` — blocks stack, nothing overwrites.
- **Schedules**: `diet.window.weekday`, `diet.night`, `diet.cheat`, `diet.fast`, `diet.daily.rollover`.
- **Shields**: 5 designs + 2-tap cheat (`ShieldPending`, 20 s TTL, token-scoped).
- **Report**: hook insight / today / label / weekly grade computed only in the extension.
- **Widgets**: Kitchen Status, Plate, Streak, Fast Now (intents), Live Activity (`FastActivityAttributes`),
  Control Center, App Shortcuts, focus filter.
- **Money**: entitlement plumbing + placements are wired with a seam; Superwall needs the API key +
  ASC products (single TODO in `EntitlementManager`), then purchases go live.
- **Still manual**: key revocation, FC distribution entitlement, ASC products, physical-device matrix.

## Product Source Docs

| Path | Purpose |
|---|---|
| `V1_DEVICE_CHECKLIST.md` | Device matrix, manual prerequisites, known deviations |
| `concept/v1-integration-plan.md` | v1 integration plan (phases, decisions, test matrix) |
| `concept/complete-app-flows.md` | Full user flows |
| `concept/ui-tab-screens.md` | Tab screen specs |
| `concept/detailed-flows_8.md`, `concept/app-flows_7.md` | Detailed interaction flows |
| `concept/device-activity-report.md` | Report extension notes |

## Known Limitations

- DeviceActivity thresholds are approximate; live in-app numbers are marked "≈" — exact numbers come from
  the report extension.
- Shields cannot animate; they are system UI.
- Live Activities cannot be started by extensions; user-initiated intents cover widget/Siri/Control paths.
