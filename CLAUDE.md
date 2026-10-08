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
| Darwin notification | `com.gia.screendiet.dietChanged` (becomes `.stateChanged` in v1) |
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
- There is no test target yet; `ScreenDietTests` is added as part of the v1 integration.
- Short durations for on-device testing live in `Shared/DebugConfig.swift` (`#if DEBUG` only).

## Current Targets

| Target | Product | Role |
|---|---|---|
| `screendiet` | `screengate.app` | Main SwiftUI app (onboarding, kitchen, report, pantry, settings) |
| `ShieldConfigurationExtension` | `.appex` | Shield look & feel (`ShieldConfigurationDataSource`) |
| `ShieldActionExtension` | `.appex` | Shield button handling (cheat meal, emergency access) |
| `DeviceActivityMonitorExtension` | `.appex` | Background interval/threshold callbacks; applies shields |

### Xcode synchronized folders (important)

The project uses Xcode 16 folder synchronization:
- `screengate/` is synchronized into the app target. `ShieldActionExtension` and
  `DeviceActivityMonitorExtension` get individual files from it via membership exception sets.
- `Shared/` is synchronized into `DeviceActivityMonitorExtension` (whole folder) and into the app and
  `ShieldActionExtension` via per-file `membershipExceptions` in `PBXFileSystemSynchronizedBuildFileExceptionSet`.
- **New files added to `Shared/` must be added to those exception lists** (or they won't compile in the app /
  shield action targets). See `/tmp` build errors like "cannot find X in scope" if missed.

## Current Architecture

```
User action → SwiftUI View → DietManager → DeviceActivityManager → ManagedSettings / DeviceActivity
                                   ↓                                      ↓
                        group.com.gia.screendiet              Monitor extension callbacks
                        UserDefaults (JSON)                   apply shields, persist usage
```

### Models (`screengate/Models/`)
| File | Purpose |
|---|---|
| `FoodGroup.swift` | 4 groups today (protein, carbs, fats, fiber) → 3 in v1 (fiber merges into protein) |
| `Diet.swift` | `DietType` (keto/balanced/detox/custom), `EatingWindow`, `DietProfile`, shield/state enums |
| `DietManager.swift` | `@Observable` coordinator: profile, selections, cheat meal, scheduling, persistence |
| `NutritionLog.swift` | Daily counters + `WeeklyNutritionSummary` + `MetabolicScoreCalculator` (deleted in v1) |

### Shared (`Shared/`)
| File | Purpose |
|---|---|
| `DeviceActivityManager.swift` | ManagedSettings store + DeviceActivity scheduling + selection persistence |
| `DebugConfig.swift` | Debug-only short durations (6-min portion/cheat) vs production (45/90/30) |

### UserDefaults keys (today)
`dietProfile`, `foodGroup_*`, `todayLog`, `weeklyLogs`, `cheatMealActive`, `cheatMealExpires`,
`currentShieldType`, `carbsUsedToday`, `cheatsUsedThisWeek`, `cheatsUsedToday` — replaced by a single
`SharedState.json` in v1.

### Extensions
- Each extension decodes a `DietProfileLight` copy of the profile; keep those in sync with the model.
- The monitor extension reads event names like `usage-5`, `usage-10` and writes `carbsUsedToday`.
- Extensions post `com.gia.screendiet.dietChanged` Darwin notifications (extensions cannot run timers;
  main-app `cheatTimer` is not reliable across app death — v1 replaces it with a DeviceActivity schedule).

## v1 Target Architecture (in progress)

```
App Group: group.com.gia.screendiet — SharedState.json + Darwin notification stateChanged
Main app · Monitor ext · ShieldConfig ext · ShieldAction ext · NutritionReportExtension · ScreenDietWidgets
```

- **3 food groups**: 🍩 Carbs (portion-limited), 🥑 Fats (blocked only during fasts), 🥩 Protein (unlimited).
- **4 named ManagedSettingsStores**: `carbs`, `night`, `fast`, `strict` — blocks stack, nothing overwrites.
- **Schedules**: `diet.window.weekday/weekend`, `diet.night`, `diet.cheat`, `diet.fast`, `diet.daily.rollover`.
- **New targets**: `NutritionReportExtension` (DeviceActivityReport, exact numbers + weekly grade),
  `ScreenDietWidgets` (WidgetKit widgets, Live Activity, Controls), `ScreenDietTests` (first tests, for
  pure `DietRules`).
- **Paywall**: SuperwallKit package is linked but unused; v1 adds `Entitlement.swift` gates first, Superwall
  wiring second (needs App Store Connect products + Superwall dashboard placements).
- **Docs**: build one phase at a time and keep `concept/v1-integration-plan.md` as the checklist.

## Product Source Docs

| Path | Purpose |
|---|---|
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
