# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ScreenGate is an iOS digital wellness application built with SwiftUI that implements comprehensive screen time management and device monitoring capabilities. The app leverages Apple's Family Controls framework to create a sophisticated content filtering and time management system with automated device activity monitoring and restriction capabilities.

## Build and Development Commands

### Building and Running with XcodeBuildMCP (Recommended)
The project should always be built and run using the XcodeBuildMCP tools for streamlined development:

```bash
# Discover project structure
mcp__XcodeBuildMCP__discover_projs({ workspaceRoot: "/Users/gokul/Work/apps/screengate" })

# List available schemes
mcp__XcodeBuildMCP__list_schemes({ projectPath: "/Users/gokul/Work/apps/screengate/screengate.xcodeproj" })

# Build and run on physical device (first choice)
mcp__XcodeBuildMCP__build_device({
    projectPath: "/Users/gokul/Work/apps/screengate/screengate.xcodeproj",
    scheme: "screengate"
})

# Alternative: Build and run on simulator if physical device not available
mcp__XcodeBuildMCP__build_run_sim({
    projectPath: "/Users/gokul/Work/apps/screengate/screengate.xcodeproj",
    scheme: "screengate",
    simulatorName: "iPhone 17 Pro"
})

# List available physical devices
mcp__XcodeBuildMCP__list_devices()

# List available simulators
mcp__XcodeBuildMCP__list_sims({ enabled: true })
```

### Device Selection Priority
1. **First Choice**: Physical device (preferred for testing Family Controls functionality)
2. **Second Choice**: iOS Simulator (note: some DeviceActivity features may not work reliably on simulator)

### Manual Commands (Legacy - Not Recommended)
```bash
# Only use if XcodeBuildMCP is unavailable
xcodebuild -scheme screengate -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
xcrun simctl install booted ./DerivedData/Build/Products/Debug-iphonesimulator/screengate.app
xcrun simctl launch booted com.gia.screengate
```

### Testing Infrastructure
Currently **no test infrastructure is configured**. The project lacks test targets and test schemes.

## Architecture Overview

### Multi-Target Structure
The project consists of **4 main targets** that work together:

1. **screengate** (Main App)
   - Bundle ID: `com.gia.screengate`
   - Entry point: `screengateApp.swift`
   - Primary user interface and monitor management

2. **DeviceActivityMonitorExtension**
   - Handles background device activity monitoring
   - Triggers automatic restrictions when thresholds are reached
   - Runs independently of main app

3. **ShieldActionExtension**
   - Handles user interactions with app blocking screens
   - Provides options to acknowledge or remove restrictions

4. **ShieldConfigurationExtension**
   - Configures visual appearance of blocking screens
   - Customizes shield messaging and branding

### Shared Components
- **Shared/DeviceActivityManager.swift**: Central business logic coordinator using `@Observable`
- **App Group**: `group.com.gia.screengate` for cross-extension data sharing

### Core Architecture Patterns

#### Extension-Based Workflow
- Main app configures monitoring schedules and restrictions
- Extensions operate independently in background to enforce rules
- Shared UserDefaults enables communication between targets
- DeviceActivityMonitorExtension receives system callbacks and applies shields automatically

#### Family Controls Integration
- Uses Apple's native Family Controls framework for screen time management
- ManagedSettings framework applies system-level restrictions
- DeviceActivity framework monitors usage patterns and thresholds
- AuthorizationCenter handles permission management

#### Data Persistence
- Shared UserDefaults with JSON serialization for complex data
- Activity selections persisted across app launches and extension boundaries
- Cross-target data synchronization via app groups

## Key Components

### DeviceActivityManager (Shared/DeviceActivityManager.swift)
Central coordinator for all screen time functionality:
- Family Controls authorization management
- Device activity scheduling and monitoring
- Restriction application via ManagedSettings
- Cross-extension data persistence

### Main Application Flow
- **ContentView**: Authorization status handler with three states (notDetermined/denied/approved)
- **MonitorView**: Main interface when authorized - lists and manages active monitors
- **AddActivityMonitorView**: Creates new monitoring rules with time thresholds
- **ActivityDetailView**: Shows monitor details and usage events
- **FamilyActivitySelectionView**: Native app/category selection interface

### Extension System
- **DeviceActivityMonitorExtension**: System callback handler for automatic enforcement
- **ShieldActionExtension**: User interaction handler for blocked content
- **ShieldConfigurationExtension**: Visual customization for blocking screens

## Required Entitlements

All targets require these entitlements:
```xml
<key>com.apple.developer.family-controls</key>
<true/>
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.gia.screengate</string>
</array>
```

Main app and ShieldActionExtension additionally include:
```xml
<key>aps-environment</key>
<string>development</string>
```

## Development Considerations

### iOS Deployment Target
- **Minimum**: iOS 26.0 (very recent - ensure simulator compatibility)
- **Architecture**: arm64 only
- **Swift Version**: 5.0+

### Key Technical Details
- Uses `@Observable` (iOS 17+) instead of `@ObservableObject` for state management
- Family Controls framework requires explicit user authorization
- Extensions use shared app group for data persistence
- ManagedSettings provides system-level restriction enforcement
- DeviceActivity thresholds may not work properly on simulator (known limitation)

### Common Development Patterns
- SwiftUI views use `@Environment` for shared DeviceActivityManager
- Authorization flow handled centrally in ContentView
- Extension communication via UserDefaults app group with JSON serialization
- Time thresholds converted to DateComponents for DeviceActivity framework
- All device activity names prefixed with `com.gia.screengate` to avoid conflicts

### Known Limitations
- No test infrastructure currently implemented
- DeviceActivity threshold events may not trigger reliably on iOS Simulator (use physical device for testing)
- Limited error handling in some extension methods
- Hardcoded UI strings in shield configurations
- Physical device required for full Family Controls functionality testing