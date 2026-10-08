# ScreenDiet — AI Agent Guide

> This file historically described the pre-refactor "Block Now / Focus Session" app architecture, which no
> longer matches this repository. The accurate, maintained guide is **[`CLAUDE.md`](CLAUDE.md)** — read it
> first. The v1 product/integration plan is **[`concept/v1-integration-plan.md`](concept/v1-integration-plan.md)**.

## Quick facts

| Fact | Value |
|---|---|
| Project / scheme | `screendiet.xcodeproj` / scheme `screengate` |
| Bundle IDs | `com.gia.screendiet` + `.ShieldConfigurationExtension`, `.ShieldActionExtension`, `.DeviceActivityMonitorExtension` |
| App Group | `group.com.gia.screendiet` |
| Min iOS | 26.0 · SwiftUI · Swift 5.0+ · `@Observable` |
| Current branch | `v1-integration` — full Phase 0→10 integration in progress |

## Current targets

`screendiet` (app) + `ShieldConfigurationExtension` + `ShieldActionExtension` +
`DeviceActivityMonitorExtension` + `NutritionReportExtension` (DeviceActivityReport) +
`ScreenDietWidgets` (WidgetKit/Live Activity/Controls) + `ScreenDietTests` (unit tests for `DietRules`).
Device and launch prerequisites live in `V1_DEVICE_CHECKLIST.md`.

## Build

```bash
# Debug
xcodebuild -project screendiet.xcodeproj -scheme screengate -configuration Debug \
  -destination 'generic/platform=iOS Simulator' build
# Release (must not contain DebugConfig test durations)
xcodebuild -project screendiet.xcodeproj -scheme screengate -configuration Release \
  -destination 'generic/platform=iOS Simulator' build
```

## Ground rules

1. Only claim what the APIs can measure — live numbers are approximate; exact numbers live in the report
   extension.
2. One ManagedSettingsStore per rule (`carbs`, `night`, `fast`, `strict`) so blocks stack.
3. The system is the source of truth: schedules re-apply blocks, never main-app timers.
4. All shared state goes through the app group (`SharedState` in v1).
5. Family Controls requires a **physical device** for every real test; simulator is UI-only.
6. Test durations live only in `Shared/DebugConfig.swift` (`#if DEBUG`); release defaults are 45/90/30 min.
7. Never commit `.p8` keys (they are gitignored; existing ones must stay revoked).
