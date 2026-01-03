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

### Development Workflow with XcodeBuildMCP
When making code changes, always follow this workflow:

1. **Make code changes** to the desired file(s)
2. **Build the app** using XcodeBuildMCP:
   ```bash
   mcp__XcodeBuildMCP__build_run_sim()  # or build_device() for physical device
   ```
3. **Verify build success** - Check for any compilation errors
4. **Test the changes** - Interact with the app in simulator/device
5. **Document changes** - Update relevant markdown documentation

### Device Selection Priority
1. **First Choice**: Physical device (preferred for testing Family Controls functionality)
2. **Second Choice**: iOS Simulator (note: some DeviceActivity features may not work reliably on simulator)

### Manual Commands (Legacy - Not Recommended)
```bash
# Only use if XcodeBuildMCP is unavailable
xcodebuild -scheme screengate -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
xcrun simctl install booted ./DerivedData/Build/Products/Debug-iphonesimulator/screengate.app
xcrun simctl launch booted com.gia.screendiet
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

### Reusable UI Components (screengate/Components/)
Modern, composable components for consistent UI across all screens:

**PrimaryButton.swift**
- Main call-to-action button with optional icon
- Green background (#13ec5b), dark text
- 56pt height, 14pt rounded corners
- Shadow effect and animation support
- Usage:
  ```swift
  PrimaryButton(title: "Get Started", icon: "arrow.right") {
      // Action here
  }
  ```

**SecondaryButton.swift**
- Alternative action button with subtle styling
- Transparent background with 5% white opacity
- 48pt height, 14pt rounded corners
- Consistent hover states
- Usage:
  ```swift
  SecondaryButton(title: "Already have an account? Log in") {
      // Action here
  }
  ```

**HeroImageView.swift**
- Displays images with consistent styling
- Customizable height (default: 280pt)
- 24pt rounded corners
- Proper padding and alignment
- Usage:
  ```swift
  HeroImageView(imageName: "welcomScreen", height: 280)
  ```

**DecorativeGradientBackground.swift**
- Animated gradient blob background
- Top-right circle (20% opacity)
- Bottom-left circle (10% opacity)
- Blur effect (100px, 80px)
- Usage:
  ```swift
  DecorativeGradientBackground()
  ```

**ScreenHeader.swift**
- Reusable title and subtitle combination
- Title: displayMedium font, bold weight
- Subtitle: titleLarge font, secondary color
- Centered alignment, responsive line wrapping
- Usage:
  ```swift
  ScreenHeader(
      title: "Screendiet",
      subtitle: "Reclaim your time. Master your focus."
  )
  ```

**StepProgressIndicator.swift**
- Shows current step progress with animated bars
- Active step: elongated capsule (32pt width)
- Inactive steps: small dots (8pt width)
- Smooth transitions between steps
- Usage:
  ```swift
  StepProgressIndicator(currentStep: 0, totalSteps: 10)
  ```

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

## Recent Updates

### Splash Screen Redesign (January 3, 2026)
Updated `screengate/Onboarding/SplashView.swift` to match new "Screendiet" branding:

**Changes Made:**
- Rebranded from "BRAIN DIET" to "Screendiet" with updated tagline "Digital Wellbeing"
- Changed logo icon from `brain.head.profile` to `smartphone`
- Added characteristic "bite" circle overlay on rounded square logo
- Implemented proper dark background (#102216)
- Added progress bar (60% fill) at bottom of splash screen
- Added "Loading your profile..." text below progress bar
- Added "v1.0" version info display
- Fully integrated AppTheme for colors, fonts, and spacing consistency

**AppTheme Integration Details:**
- **Colors**: Primary (#13ec5b), background, text, textSecondary from AppTheme
- **Fonts**: displayMedium (title), labelMedium (subtitle), labelSmall (loading text), bodySmall (version)
- **Spacing**: cornerRadiusLarge, small (8pt), large (24pt) values

**Build & Deployment:**
```bash
# After making changes to SplashView, build and run using:
mcp__XcodeBuildMCP__build_run_sim()
# or for device:
mcp__XcodeBuildMCP__build_device()
```

**Verification:**
- ✅ Builds successfully without errors
- ✅ All theme values properly integrated
- ✅ UI matches design specification
- ✅ Animations working (1s pulsing, 0.8s text fade-in)
- ✅ Auto-advances to onboarding after 2 seconds
- ✅ Tested on iPhone 17 Pro simulator

### Get Started Welcome Page (January 3, 2026)
Created `screengate/Onboarding/GetStartedView.swift` - the first onboarding screen after splash:

**Features:**
- Displayed immediately after 2-second splash screen
- Hero image area with welcome screen asset image from `Assets.xcassets/welcomScreen.imageset`
- Full tagline: "Reclaim your time. Master your focus. Digital fasting for a clearer mind."
- Primary "Get Started →" button with arrow icon (advances to onboarding flow)
- Secondary "Already have an account? Log in" button for existing users (future implementation)
- Decorative gradient blobs in background matching design spec
- Full AppTheme integration for consistency

**Design Details:**
- Background: Dark theme (#102216) with animated gradient effects (top-right: 20% opacity, bottom-left: 10% opacity)
- Hero Section: Rounded rectangle (24pt radius) with welcome screen image
  - Image asset: `welcomScreen` from Assets.xcassets
  - Scaled to fill with proper aspect ratio
  - Rounded corners for polished appearance
- Primary Button: Green background, dark text, 56pt height, rounded corners (14pt), press effect (0.98 scale)
- Secondary Button: Subtle background (5% white opacity), hover state, 48pt height
- Typography: Display large for title, body large for description
- Spacing & Colors: All from AppTheme for consistency

**Onboarding Flow:**
```
SplashView (2 sec) → GetStartedView (screen 0) → ProblemScreen (screen 1) → OnboardingScreen1 (screen 2) → ... → OnboardingScreen10
```

**Integration:**
- GetStartedView is screen 0 in OnboardingView
- Previous onboarding screens shifted to screens 2-11
- Tap "Get Started" button to proceed to full onboarding flow
- "Log In" button ready for future authentication implementation

**Build & Test:**
```bash
# Build and run after updating GetStartedView:
mcp__XcodeBuildMCP__build_run_sim()
```

**Verification:**
- ✅ Builds and runs without errors
- ✅ Shows after splash screen transitions
- ✅ Welcome screen image displays properly in hero area
- ✅ Buttons functional (Get Started advances flow, Log In ready for future)
- ✅ Design matches reference specification
- ✅ All visual elements and decorative blobs render properly
- ✅ Tested on iPhone 17 Pro simulator

### Problem Screen - "The Problem" (January 3, 2026)
Created `screengate/Onboarding/OnboardingScreen1Problem.swift` - First onboarding screen addressing the core problem:

**Features:**
- Step progress indicator (1 of 10)
- Hero image area with digital glitch effect visualization
- Floating notification icon element with subtle styling
- "THE PROBLEM" meta label in primary green
- Headline: "Your attention is being auctioned." (with highlighted "auctioned" word)
- Engaging body text about fragmented focus
- "Swipe to reflect" footer prompt with animated icon
- Primary "Next" button for navigation
- Decorative gradient blobs (subtle animations)
- Full AppTheme integration

**Design Details:**
- Background: Dark theme with gradient effects
- Step Progress: Visual indicator showing position in 10-step flow
- Hero Image: Digital glitch effect using horizontal scan lines
  - Gradient background with green-tinted lines
  - Overlay for depth and visual interest
- Floating Icon: Bell with badge (notification symbol) in semi-transparent box
- Typography:
  - Meta: labelSmall with 1.5em letter spacing
  - Headline: displaySmall, bold, with colored highlight word
  - Body: bodyLarge, secondary color
- Footer: Interactive swipe prompt with circular button and arrow icon
- Spacing & Colors: All from AppTheme

**Navigation:**
- Screen index: 1 (after GetStartedView at 0)
- Next button navigates to screen 2 (OnboardingScreen1)
- Part of 10-step onboarding sequence

**Build & Test:**
```bash
# Build and run after creating Problem screen:
mcp__XcodeBuildMCP__build_run_sim()
```

**Verification:**
- ✅ Builds and runs without errors
- ✅ Progress indicator displays correctly (1/10)
- ✅ Headline text with color highlighting renders properly
- ✅ Icon and button styling matches design spec
- ✅ Navigation button advances to next screen
- ✅ All decorative elements visible
- ✅ Tested on iPhone 17 Pro simulator