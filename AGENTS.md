# ScreenGate - AI Agent Guide

> This file provides comprehensive guidance for AI coding agents working on the ScreenGate iOS project.

## Project Overview

**ScreenGate** (also referred to as Screendiet) is an iOS digital wellness application built with SwiftUI that implements comprehensive screen time management and device monitoring capabilities. The app leverages Apple's Family Controls framework to create a sophisticated content filtering and time management system with automated device activity monitoring and restriction capabilities.

### Key Features
- **Block Now**: Immediate timer-based focus sessions (5 min to hours)
- **Scheduled Blocks**: Recurring or one-time scheduled restrictions
- **App Time Limits**: Daily usage limits with threshold-based enforcement
- **Strict Mode**: Three levels (easy/medium/hard) for shield dismissal difficulty
- **Pause/Resume**: Temporary relief with automatic resumption
- **Overlap Handling**: Smart conflict resolution when multiple blocks overlap

## Technology Stack

### Core Technologies
| Component | Technology |
|-----------|------------|
| Language | Swift 5.0+ |
| UI Framework | SwiftUI |
| State Management | `@Observable` (iOS 17+) |
| Minimum iOS | iOS 26.0 |
| Architecture | arm64 only |

### Apple Frameworks
- **FamilyControls**: Screen time authorization and app selection
- **ManagedSettings**: System-level restriction enforcement
- **DeviceActivity**: Background monitoring and threshold events
- **ManagedSettingsUI**: Shield configuration UI
- **UserNotifications**: Local notifications for block events

### Third-Party Dependencies
- **SuperwallKit**: In-app purchase and paywall management

## Project Structure

```
screengate/
├── screengate/                    # Main app target
│   ├── screengateApp.swift       # App entry point
│   ├── Models/                   # Data models & business logic
│   │   ├── Block.swift           # Block data model
│   │   ├── BlockManager.swift    # Block CRUD & session management
│   │   ├── AppList.swift         # App list model
│   │   └── BlockTimelineBuilder.swift
│   ├── Views/                    # UI Views
│   │   ├── HomeScreen.swift      # Main tab-based interface
│   │   ├── Onboarding/           # 10-step onboarding flow
│   │   ├── BlockCreation/        # Create block views
│   │   ├── FocusSession/         # Active session UI
│   │   ├── Components/           # Reusable UI components
│   │   ├── Plan/                 # Upcoming blocks
│   │   ├── Report/               # Usage reports
│   │   └── AppLists/             # App list management
│   ├── Theme/
│   │   └── AppTheme.swift        # Global design system
│   └── Extensions/               # Swift extensions
├── Shared/                       # Code shared with extensions
│   └── DeviceActivityManager.swift
├── DeviceActivityMonitorExtension/  # Background monitoring extension
│   └── DeviceActivityMonitorExtension.swift
├── ShieldActionExtension/        # Shield interaction handler
│   └── ShieldActionExtension.swift
├── ShieldConfigurationExtension/ # Shield UI customization
│   └── ShieldConfigurationExtension.swift
└── spec/                         # Design specifications
```

## Multi-Target Architecture

The project consists of **4 targets** that work together:

### 1. Main App (`screengate`)
- Bundle ID: `com.gia.screengate`
- Entry point: `screengateApp.swift`
- Primary user interface and monitor management
- Handles onboarding, block creation, and session management

### 2. DeviceActivityMonitorExtension
- Background device activity monitoring
- Triggers automatic restrictions when thresholds are reached
- Runs independently of main app (critical for reliability)
- Key callbacks: `intervalDidStart`, `intervalDidEnd`, `eventDidReachThreshold`

### 3. ShieldActionExtension
- Handles user interactions with app blocking screens
- Provides options to acknowledge or remove restrictions
- Implements strict mode behavior (easy/medium/hard)

### 4. ShieldConfigurationExtension
- Configures visual appearance of blocking screens
- Customizes shield messaging based on strict mode

### Shared Resources
- **App Group**: `group.com.gia.screengate` for cross-extension data sharing
- **UserDefaults**: Shared storage with JSON serialization
- **Darwin Notifications**: Cross-process communication (`com.gia.screendiet.blocksChanged`)

## Build System

### Xcode Project
- Project file: `screendiet.xcodeproj`
- Main scheme: `screengate`
- Build with: Xcode 16+ required for iOS 26.0 features

### Required Entitlements
All targets require:
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

### Build Commands
```bash
# Build for simulator
xcodebuild -scheme screengate -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Install to booted simulator
xcrun simctl install booted ./DerivedData/Build/Products/Debug-iphonesimulator/screengate.app

# Launch app
xcrun simctl launch booted com.gia.screengate
```

## Code Organization & Patterns

### State Management
- Uses `@Observable` (iOS 17+) instead of `@ObservableObject`
- Central state in `BlockManager` and `DeviceActivityManager`
- Environment injection: `@Environment(BlockManager.self)`

### Data Flow
```
User Action → View → BlockManager → DeviceActivityManager → System Frameworks
                                               ↓
UserDefaults ← Extension ← DeviceActivity Callbacks
```

### Key Components

#### BlockManager
Central coordinator for all screen time functionality:
- Block CRUD operations
- Session control (activate, pause, resume, cancel)
- UserDefaults persistence
- Darwin notification handling

#### DeviceActivityManager
Low-level wrapper for Family Controls:
- Authorization management
- Restriction application/removal
- Monitor scheduling

#### Block Model
```swift
struct Block: Codable, Identifiable {
    let id: UUID
    var name: String
    var type: BlockType        // .blockNow, .scheduled, .appTimeLimit, .openLimit
    var appSelection: FamilyActivitySelection
    var schedule: BlockSchedule
    var strictMode: StrictMode // .easy, .medium, .hard
    var isActive: Bool
    var isPaused: Bool
    // ...
}
```

### Naming Conventions
- Activity names prefixed with `com.gia.screendiet.{blockId}`
- Event names encode block type and duration strategy:
  - `blocknow-short`, `blocknow-long`
  - `scheduled-short`, `scheduled-long`
  - `apptimelimit`

## Design System

### AppTheme
Global design system in `Theme/AppTheme.swift`:

**Colors** (Neon Green on Dark):
- Primary: `#00FF63` (0, 255, 0.39)
- Background: `#0F1014` (0.06, 0.06, 0.07)
- Text: `#F5F5F5`
- Text Secondary: `#787879`

**Typography** (Manrope font):
- Display: 57pt, 45pt, 36pt (bold)
- Headline: 32pt, 28pt, 24pt (bold)
- Title: 22pt, 16pt, 14pt (semibold)
- Body: 16pt, 14pt, 12pt (regular)

**Spacing**:
- Small: 8pt, Medium: 16pt, Large: 24pt
- Corner radius: 8pt (small), 16pt (large), 20pt (extra large)

### Reusable Components
- `PrimaryButton` - Main CTA (56pt height, green bg)
- `SecondaryButton` - Alternative action (48pt height, subtle bg)
- `HeroImageView` - Rounded image display (24pt radius)
- `DecorativeGradientBackground` - Animated gradient blobs
- `StepProgressIndicator` - Onboarding progress (animated bars)
- `ScreenHeader` - Title + subtitle combination

## Block Types & Behavior

### 1. Block Now (Immediate Timer)
- Duration: User-defined (minutes to hours)
- Strategy depends on duration:
  - **< 15 minutes**: 15-min schedule with warningTime offset
  - **≥ 15 minutes**: Actual duration schedule
- Cleanup: `intervalWillEndWarning` (short) or `intervalDidEnd` (long)

### 2. Scheduled Block
- Time-based: Start time → End time
- Can repeat daily or weekly
- Same duration strategy as Block Now

### 3. App Time Limit
- Threshold-based daily usage limit
- Event fires when limit reached
- Opposite behavior: applies restrictions at threshold

### 4. Open Limit (Parked for v2)
- Count-based limit
- Not yet implemented

## Cross-Extension Communication

### UserDefaults Keys
```
blockIds              // [String] - Array of block UUIDs
block_{uuid}          // Data - Encoded Block object
activeBlockId         // String - Currently active block
activeBlockIds        // [String] - Active blocks array (for extension)
pausedUntil           // Date - Pause expiry timestamp
```

### Darwin Notifications
Extensions post to notify main app of changes:
```swift
CFNotificationCenterPostNotification(
    CFNotificationCenterGetDarwinNotifyCenter(),
    CFNotificationName("com.gia.screendiet.blocksChanged" as CFString),
    nil, nil, true
)
```

## Testing Strategy

### Current Status
- **No test infrastructure** is currently configured
- No test targets or test schemes exist
- Manual testing on physical device required

### Manual Testing Checklist
1. Create 30-second block for quick testing
2. Verify restrictions applied immediately
3. Close app before expiry
4. Reopen after duration
5. Verify "No Active Block" shown
6. Verify restrictions removed

### Testing Considerations
- **Physical device required** for Family Controls testing
- Simulator has limited DeviceActivity support
- Threshold events may not fire reliably on simulator

## Known Limitations

1. **Minimum Schedule Duration**: DeviceActivity requires 15-minute minimum schedule interval
2. **Threshold Variance**: ±1 minute variance in threshold firing
3. **Simulator Limitations**: Some features don't work on simulator
4. **No Unit Tests**: Test infrastructure needs to be added
5. **Hardcoded Strings**: Some UI strings in shield configurations

## Development Conventions

### Code Style
- Swift 5.0+ with modern SwiftUI patterns
- Use `@Observable` for state management
- Prefer `let` over `var` for immutability
- Comprehensive print/logging for debugging
- Async/await for asynchronous operations

### Error Handling
- Do-catch blocks with descriptive error messages
- State rollback on failure
- Graceful degradation when UserDefaults unavailable

### Documentation
- Inline comments for complex logic
- Doc comments for public methods
- Architecture documentation in separate markdown files

## Security Considerations

### Data Storage
- No sensitive user data stored
- App selection tokens managed by FamilyControls framework
- UserDefaults only stores block metadata and preferences

### Entitlements
- Family Controls entitlement required for all targets
- App group for secure cross-process communication
- Push notification entitlement for session notifications

### Extension Security
- Extensions run with limited privileges
- UserDefaults sandboxed to app group
- System manages extension lifecycle

## Documentation Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Comprehensive project guide |
| `THRESHOLD_ARCHITECTURE.md` | DeviceActivity threshold deep dive |
| `IMPLEMENTATION_SUMMARY.md` | Implementation details and comparisons |
| `BUG_FIXES.md` | Fixed issues and solutions |
| `BLOCK_LIFECYCLE.md` | Block state transitions and cleanup flow |
| `QUICK_REFERENCE.md` | Quick command reference |
| `tools.md` | Development tools documentation |

## Common Tasks

### Adding a New Block Type
1. Add case to `Block.BlockType` enum
2. Add creation view in `BlockCreation/`
3. Update `BlockManager.activateBlock()` with new logic
4. Update `DeviceActivityMonitorExtension` handlers
5. Update documentation

### Modifying Shield Behavior
1. Update `ShieldConfigurationExtension` for UI changes
2. Update `ShieldActionExtension` for interaction changes
3. Consider strict mode implications

### Adding New UserDefaults Keys
1. Add constant to `BlockManager`
2. Update `saveToUserDefaults()` and `loadFromUserDefaults()`
3. Consider extension access requirements
4. Document in comments

## Build & Release Notes

### Version History
- **v1.0** (Current): Initial release with Block Now, Scheduled Blocks, App Time Limits

### Recent Changes (January 2026)
- Splash screen redesign with new branding
- GetStartedView as onboarding entry point
- Problem Screen (The Problem) - onboarding step 1
- DeviceActivity threshold-based cleanup for short blocks
- Consolidated monitor scheduling (single monitor per block)
- Darwin notification-based cross-process communication
