# AI Coding Agent Instructions for ScreenGate

ScreenGate is an iOS digital wellness app using **Family Controls framework** for screen time management with a 4-target architecture: main app + 3 extensions for background monitoring, restriction handling, and shield customization.

## Architecture: Multi-Target Extension System

**Core Principle**: Main app configures rules → Extensions enforce them independently via system callbacks.

| Target | Role | Key File |
|--------|------|----------|
| **screengate** (main) | User interface, authorization, monitor management | `screengate/screengateApp.swift`, `Views/ContentView.swift` |
| **DeviceActivityMonitorExtension** | Background threshold monitoring & auto-enforcement | Runs independently, receives system callbacks |
| **ShieldActionExtension** | Handles user interactions with blocked content | User acknowledgment/restriction removal |
| **ShieldConfigurationExtension** | Visual customization of blocking screens | Shield appearance & messaging |

**Data Flow**: All targets share data via `UserDefaults(suiteName: "group.com.gia.screengate")` with JSON serialization for complex objects. The `DeviceActivityManager` (@Observable) coordinates main app logic; extensions read shared UserDefaults to access selections.

## State Management & Key Dependencies

- **@Observable pattern** (iOS 17+): `DeviceActivityManager` uses `@Observable` instead of `@ObservableObject`
- **Environment injection**: Views access manager via `@Environment(DeviceActivityManager.self)`
- **Family Controls**: Requires explicit user authorization through `AuthorizationCenter.shared`
- **Framework stack**: `FamilyControls`, `ManagedSettings`, `DeviceActivity`, `UserNotifications`

## Development Workflows

### Building & Running (Always use XcodeBuildMCP tools)

**⚠️ CRITICAL: Always use physical device for building and running**

DeviceActivity threshold events (used for block expiry) do NOT work reliably on simulator. All development and testing must be done on physical device.

```bash
# Discover projects
mcp__XcodeBuildMCP__discover_projs({ workspaceRoot: "/Users/gokul/Work/apps/screengate" })

# Build & run on physical device (REQUIRED - not optional)
mcp__XcodeBuildMCP__build_run_device()

# List connected devices (if needed)
mcp__XcodeBuildMCP__list_devices()
```

**❌ DO NOT USE SIMULATOR** - Threshold events will not fire correctly, blocks will not expire, and restrictions will not be removed.

### Development Workflow with XcodeBuildMCP
When making code changes, always follow this workflow:

1. **Make code changes** to the desired file(s)
2. **Build the app** using XcodeBuildMCP on **physical device**:
   ```bash
   mcp__XcodeBuildMCP__build_run_device()
   ```
3. **Verify build success** - Check for any compilation errors
4. **Test the changes** - Interact with the app on physical device

**Important**: 
- Physical device is **MANDATORY** for proper testing
- DeviceActivity threshold events (block expiry, app time limits) only work on real devices
- Simulator can be used only for UI layout verification, never for functional testing

### Current Testing Status
No test infrastructure exists. Manual testing on physical device required.

## Key Component Patterns

### DeviceActivityManager (Shared/DeviceActivityManager.swift)
Central coordinator—do NOT create duplicate managers:
- Manages `DeviceActivityCenter` and `ManagedSettingsStore`
- Saves activity selections to shared UserDefaults with JSON encoding
- Methods: `startMonitor()`, `stopMonitor()`, `applyImmediateRestrictions()`, `removeRestrictions()`
- **Note**: Threshold field has known simulator bug (see comment at line ~82: "On Simulator, Threshold other than 0 not triggering...")

### Authorization Flow (Views/ContentView.swift)
Three-state pattern based on `AuthorizationCenter.authorizationStatus`:
1. `.notDetermined` → Show request button
2. `.denied` → Show settings redirect
3. `.approved` → Show MonitorView (main UI)

### Theme System (screengate/Theme/)
Custom centralized theme (not SwiftUI's native `.preferredColorScheme`):
- `AppTheme.shared` singleton with `ColorTheme`, `FontTheme`, `SpacingTheme`
- Accessed via environment: `@Environment(\.theme)`
- **Always use theme values** for colors/fonts—hardcoded colors are discouraged

### Onboarding (screengate/Onboarding/)
Screen-based multi-step flow controlled by `OnboardingData`:
- Screens numbered (OnboardingScreen2 through OnboardingScreen18)
- `OnboardingData.hasCompletedOnboarding()` persisted to skip on app relaunch
- Shows before main app authorization flow (see `screengateApp.swift` conditional)

## Code Conventions & Project-Specific Patterns

| Pattern | Rule |
|---------|------|
| **Activity naming** | All DeviceActivity names prefixed with `com.gia.screengate` to avoid conflicts with system |
| **Time handling** | Thresholds converted to `DateComponents` (see `createThreshold()` method) |
| **Date formatting** | Use `DateComponents` for schedules; `repeatDaily` flag controls interval behavior |
| **Extension communication** | ONLY via shared UserDefaults with app group—no other IPC mechanisms |
| **Entitlements** | All targets require `com.apple.developer.family-controls` + app group entitlements |

## Known Limitations & Workarounds

1. **CRITICAL - Simulator Not Supported**: DeviceActivity threshold events (block expiry) do NOT work on simulator—**ALWAYS use physical device** for development and testing
2. **Token fields empty**: `deviceActivityCenter.events(for:)` returns empty token arrays—must read from saved UserDefaults selection
3. **No error recovery**: Limited error handling in extension methods
4. **No test suite**: Manual testing only; physical device required for all functional testing
5. **Hardcoded strings**: Shield configuration has UI strings not localized
6. **Minimum schedule interval**: DeviceActivity requires 15-minute minimum schedule—use threshold for shorter durations

## File Organization Reference

```
screengate/
├── screengateApp.swift          # App entry + notification delegation
├── Onboarding/                  # Multi-screen onboarding flow
├── Views/                        # Main UI (ContentView, MonitorView, etc.)
├── Theme/                        # Centralized theming system
├── Extensions/                   # Helper extensions (DateComponents, DeviceActivity, etc.)
└── Models/                       # Data models (mostly empty)

Shared/
└── DeviceActivityManager.swift   # CORE: Central coordinator for all FamilyControls logic

DeviceActivityMonitorExtension/
├── DeviceActivityMonitorExtension.swift  # System callback handler
└── .entitlements                         # Family Controls + app group

ShieldActionExtension/
└── ShieldActionExtension.swift           # User interaction handler

ShieldConfigurationExtension/
└── ShieldConfigurationExtension.swift    # Shield appearance customization
```

## Entitlements Configuration

All `.entitlements` files MUST include:
```xml
<key>com.apple.developer.family-controls</key><true/>
<key>com.apple.security.application-groups</key>
<array><string>group.com.gia.screengate</string></array>
```

Main app + ShieldActionExtension also require:
```xml
<key>aps-environment</key><string>development</string>
```

## When Modifying Code

- **Adding screens**: Create new onboarding screen in `OnboardingScreens.swift`, add case to `OnboardingView.swift` switch
- **Changing persistence**: Maintain app group `group.com.gia.screengate` consistency across targets
- **New restrictions**: Add methods to `DeviceActivityManager` and call via environment injection
- **Theme updates**: Modify `AppTheme.swift`; use `@Environment(\.theme)` in views, never hardcode colors
- **Testing**: Must use physical iOS device—simulator Family Controls support is unreliable
