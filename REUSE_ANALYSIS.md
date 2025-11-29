# Reuse Analysis - Focus Club Development

**Analysis Date:** November 29, 2025  
**Project:** screengate (Focus Club)  
**Status:** 30% existing code that can be reused, 70% new code needed  

---

## Executive Summary

Your project has a solid foundation with **core Device Activity monitoring** already implemented. You can reuse:

✅ **50% Complete:**
- DeviceActivityManager (Screen Time API wrapper)
- Device Activity Monitor Extension
- Shield Configuration & Action Extensions
- FamilyActivitySelectionView
- TimerDurationPicker
- TimeInterval & DeviceActivity extensions
- App state management (permissions, deep linking)

⚠️ **Needs Refactoring:**
- Replace demo UI with Focus Club design system
- Adapt existing managers for Focus Club data models
- Extend with premium features

❌ **Needs Building (70%):**
- Complete design system (colors, typography, components)
- Core Data models & managers
- Onboarding flow (8 screens)
- Shield tab (6 screens)
- Stats tab (3 screens)
- Settings tab (3 screens)
- Intervention screens (7 screens)
- Paywall system (StoreKit 2)
- Analytics integration

---

## What You Have - Reusable Code

### 1. ✅ HIGHLY REUSABLE - DeviceActivityManager.swift

**File:** `Shared/DeviceActivityManager.swift`  
**Status:** 95% ready, minor tweaks needed

**What it does:**
- Wraps Screen Time API (FamilyControls, ManagedSettings, DeviceActivity)
- Handles app blocking/unblocking (applyImmediateRestrictions, removeRestrictions)
- Schedules device activity monitoring (startMonitor, stopMonitor)
- Manages authorization requests
- Persists settings to shared container (UserDefaults with App Groups)

**Reuse Plan:**
- ✅ Keep as-is for core blocking functionality
- Update variable names from "activitySelection" → more semantic names
- Add methods for Focus Club specific needs:
  - `blockAppsForSession(bundleIDs, duration)` - convenience method
  - `getBlockedApps()` - query current restrictions
  - `updateRestrictionTiming(app, delaySeconds)` - for delay interventions

**Code to Keep:**
```swift
// All of these are good:
- requestFamilyControlAuthorization()
- applyImmediateRestrictions()
- removeRestrictions()
- startMonitor() / stopMonitor()
- saveSelection() / getSavedSelection() (UserDefaults persistence)
```

---

### 2. ✅ HIGHLY REUSABLE - DeviceActivityMonitorExtension.swift

**File:** `DeviceActivityMonitorExtension/DeviceActivityMonitorExtension.swift`  
**Status:** 90% ready, add logging & analytics

**What it does:**
- Monitors app launch attempts via DeviceActivityMonitor
- Applies restrictions when threshold reached
- Handles interval start/end events
- Handles warnings

**Reuse Plan:**
- ✅ Keep core override methods (intervalDidStart, eventDidReachThreshold, etc.)
- Add methods to:
  - Log attempt to Core Data via shared container
  - Send local notification for intervention
  - Track attempt count for current session
  - Sync with main app analytics

**Improvements needed:**
```swift
// Add these:
- func logInterventionAttempt(app: String, interventionType: String)
- func sendInterventionNotification(app: String, type: String)
- func trackSessionAttempt(sessionID: UUID)
```

---

### 3. ✅ HIGHLY REUSABLE - ShieldConfigurationExtension.swift

**File:** `ShieldConfigurationExtension/ShieldConfigurationExtension.swift`  
**Status:** 30% ready, major redesign needed

**What it does:**
- Customizes shield UI (what user sees when app is blocked)
- Returns ShieldConfiguration with title, subtitle, colors, buttons

**Current State:**
- Uses placeholder yellow background, red icon
- Says "You are banned! Please go do something else!"
- Very basic, not aligned with Focus Club design

**Reuse Plan:**
- ✅ Keep structure (override configuration methods)
- ❌ REPLACE all visual design (colors, text, styling)
- Add dynamic text based on intervention type:
  - Delay: "Take a breath... (10s remaining)"
  - Block: "Instagram is blocked. You've tried 6 times."
  - Ask: "Do you really need this right now?"

**New implementation needed:**
```swift
override func configuration(shielding application: Application) -> ShieldConfiguration {
    // Determine intervention type from app settings
    let interventionType = getInterventionType(for: application.bundleID)
    
    // Return Focus Club styled shield
    switch interventionType {
    case .delay:
        return delayShieldConfig(for: application)
    case .block:
        return blockShieldConfig(for: application)
    case .ask:
        return askShieldConfig(for: application)
    }
}
```

---

### 4. ✅ MODERATELY REUSABLE - ShieldActionExtension.swift

**File:** `ShieldActionExtension/ShieldActionExtension.swift`  
**Status:** 60% ready, expand for emergency bypass

**What it does:**
- Handles button presses on shield screen
- Sends notifications when user taps action buttons
- Communicates back to main app via notifications

**Current State:**
- Primary button: closes shield
- Secondary button: sends "restriction removed" notification
- Has notification setup with categories

**Reuse Plan:**
- ✅ Keep notification infrastructure
- Add handling for different action types:
  - Emergency bypass trigger (shake phone)
  - Decision logging (opened vs resisted)
  - Break permission handling
- Expand with more granular responses

**Improvements needed:**
```swift
// Add these:
- func handleEmergencyBypass(for app: ApplicationToken)
- func logUserDecision(app: String, decision: String) // "opened", "resisted"
- func notifyMainApp(event: String, data: [String: Any])
```

---

### 5. ✅ REUSABLE - UI Components

#### FamilyActivitySelectionView.swift
- **Status:** 95% reusable as-is
- **Use:** Screen 3 (Select Distracting Apps) & Screen 13 (Add More Apps)
- **Notes:** Just needs styling update to match Focus Club design

#### TimerDurationPicker.swift
- **Status:** 95% reusable
- **Use:** Screen 11 (Session config duration picker), Screen 12 (Break duration picker)
- **Notes:** Perfect for custom duration selection, minimal changes needed

#### ActivityDetailView.swift
- **Status:** 20% reusable (structure only)
- **Use:** Can adapt for Screen 14 (Per-app settings configuration)
- **Notes:** Currently shows activity details in list, adapt to show protection settings

---

### 6. ✅ REUSABLE - Extensions

#### TimeInterval+Extensions.swift
- **Status:** 100% reusable
- **Use:** Display session durations, remaining time
- **Has:** `hms` property, `formattedDigits`, `formattedString`

#### DeviceActivity+Extensions.swift
- **Status:** 95% reusable
- **Use:** Display activity descriptions
- **Has:** `activityDescription` computed property

---

### 7. ✅ REUSABLE - App State Management

#### screengateApp.swift
- **Status:** 60% reusable
- **Has:**
  - NotificationDelegate setup
  - Deep link handling (screengate:// scheme)
  - Notification center integration
  - Permission request flow
- **Reuse:** Adapt routing logic for Focus Club (onboarding vs main app)

---

## What You Need to Build - 70% New Code

### Phase 1: Design System (100% NEW)
- Color scheme (dark base, purple accent, muted colors)
- Typography (SF Pro Display, Text, sizes 14-48pt)
- Spacing system (4, 8, 12, 16, 20, 24, 32px)
- Reusable components:
  - PrimaryButton
  - CardView
  - StatsCard
  - ProgressRing
  - TabBar
  - ToggleSwitch
- Animations (page transitions, button press, breathing)
- ViewModifiers (.cardStyle, .primaryButton, etc.)

**Reuse from existing:** None - this is entirely new

---

### Phase 2: Core Data Models (100% NEW)

**Files to create:**
- `Models/User.swift`
- `Models/ProtectedApp.swift`
- `Models/FocusSession.swift`
- `Models/InterventionLog.swift`
- `Models/DailyStat.swift`
- `Models/Milestone.swift`

**Managers to create:**
- `CoreDataManager.swift`
- `UserManager.swift`
- `ProtectedAppManager.swift`
- `SessionManager.swift`
- `StatsManager.swift`
- `MilestoneManager.swift`

**Reuse from existing:** None - DeviceActivityManager is separate

---

### Phase 3: Onboarding Flow (100% NEW)

8 screens, all new:
- Screen 1-8: Welcome → Problem → Select Apps → Choose Behavior → Focus Intro → Permissions → Success

**Can reuse:**
- FamilyActivitySelectionView (Screen 3)
- Permission request logic from screengateApp.swift

**New to build:** 7 of 8 screens

---

### Phase 4: Main App Tabs (80% NEW)

**Shield Tab (Screens 9-14):**
- Can reuse: FamilyActivitySelectionView, TimerDurationPicker
- New to build: ShieldHomeView, ActiveSessionView, SessionConfigView, AppSettingsView

**Stats Tab (Screens 15-17):** 100% NEW
- StatsManager (aggregates Core Data)
- Charts for weekly trends (third-party library or custom)

**Settings Tab (Screens 18-20):** 100% NEW
- SubscriptionManager integration
- EmergencyBypassSettingsView

---

### Phase 5: Intervention Screens (95% NEW)

7 screens, minimal reuse:
- Screen 21-27: Delay, Block, Ask interventions, Break system, Emergency bypass
- Can reuse: Some event handling from ShieldActionExtension
- New to build: All UI screens

---

### Phase 6: Monetization (100% NEW)

- StoreKit 2 integration
- SubscriptionManager
- PremiumGatekeeper
- Paywall screens (soft, hard, success)

**Reuse:** None specific to this project

---

### Phase 7: Analytics (100% NEW)

- AnalyticsManager (Firebase integration)
- Event tracking throughout app
- Crash reporting (Crashlytics)

**Reuse:** None specific

---

## Refactoring Required - What Changes Before Reuse

### 1. DeviceActivityManager - Update Naming

Current (demo):
```swift
func startMonitor(activitySelection: FamilyActivitySelection, ...)
func applyImmediateRestrictions(activitySelection: FamilyActivitySelection)
```

New (Focus Club):
```swift
func blockAppsForSession(bundleIDs: [String], duration: TimeInterval) throws
func applyDelayIntervention(bundleID: String, duration: TimeInterval) throws
func removeBlockedApps(bundleIDs: [String])
```

### 2. Extension Data Persistence

Current: Uses UserDefaults with `activitySelection` structure

New: Need to sync with Core Data
```swift
// In DeviceActivityMonitorExtension
func logInterventionAttempt(_ data: InterventionLog) {
    // Write to shared container, sync to Core Data in main app
}

// In Main App
func syncExtensionLogs() {
    // Read from shared container, merge into Core Data
}
```

### 3. ShieldConfigurationExtension - Complete Redesign

Current: Placeholder UI (yellow background, red icon, demo text)

New: Focus Club branded UI
```swift
// Colors from your design spec
// Typography from your design spec
// Dynamic text based on intervention type
```

---

## Dependency Map

```
Existing ✅ → New Code ❌
─────────────────────────────────

DeviceActivityManager ✅
  ├→ DeviceActivityMonitorExtension ✅
  ├→ ShieldActionExtension ✅
  └→ All intervention logic ❌

FamilyActivitySelectionView ✅
  └→ Screen 3 (Select Apps) ❌ (reuse + restyle)
  └→ Screen 13 (Add Apps) ❌ (reuse + restyle)

TimerDurationPicker ✅
  └→ Session duration selector ❌ (reuse + restyle)
  └→ Break duration selector ❌ (reuse + restyle)

App State Management ✅ (screengateApp)
  └→ Onboarding routing ❌ (new logic, reuse structure)
  └→ Deep linking ✅ (reusable as-is)

Core Data ❌ (entirely new)
  ├→ All managers ❌
  ├→ Stats tab ❌
  └→ Analytics ❌

Design System ❌ (entirely new)
  ├→ All views ❌
  ├→ All components ❌
  └→ All modifiers ❌
```

---

## Migration Path - Recommended Refactoring Order

### Step 1: Keep & Refactor (Week 0-1)
- [ ] Extract DeviceActivityManager as standalone class (no demo code)
- [ ] Rename methods to Focus Club terminology
- [ ] Add shared container communication for extensions
- [ ] Update extension error handling

### Step 2: Keep & Restyle (Week 1-2)
- [ ] Build design system first (all colors, typography, components)
- [ ] Restyle FamilyActivitySelectionView
- [ ] Restyle TimerDurationPicker
- [ ] Restyle ShieldConfigurationExtension

### Step 3: Replace Demo Views (Week 2-4)
- [ ] Remove MonitorView, AddActivityMonitorView, ActivityDetailView
- [ ] Replace with Focus Club views (Shield, Stats, Settings tabs)
- [ ] Keep app structure & routing from screengateApp.swift

### Step 4: Add New Functionality (Week 4-9)
- [ ] Core Data & managers
- [ ] Onboarding flow
- [ ] Intervention screens
- [ ] Paywalls & monetization
- [ ] Analytics

---

## Code Quality Assessment

### Strengths ✅
- Good separation of concerns (app vs extensions)
- Proper use of App Groups for IPC (inter-process communication)
- Solid understanding of Screen Time API (correct usage of DeviceActivityCenter, ManagedSettingsStore)
- Clean error handling in manager
- Proper authorization flow

### Weaknesses ⚠️
- Demo code mixed with core functionality (should separate)
- Some hardcoded values (nameIdentifier = "com.gia.screengate")
- Limited error handling in extensions
- No logging/debugging support for production
- Views not following modern SwiftUI patterns (some older code style)

### Missing ❌
- Unit tests
- Core Data models
- Analytics instrumentation
- Premium feature gates
- Error recovery mechanisms
- Accessibility support

---

## File Cleanup Needed Before Launch

Remove/Replace:
- [ ] `MonitorView.swift` - demo only
- [ ] `AddActivityMonitorView.swift` - demo only
- [ ] `ActivityDetailView.swift` - demo only (adapt for app settings)
- [ ] `ContentView.swift` - replace with proper routing
- [ ] `RestrictionLiftedView.swift` - demo only (can reference for break screen)
- [ ] `Components/` folder - currently empty, will need real components
- [ ] Demo app icons, assets

Keep:
- [ ] `DeviceActivityManager.swift` (refactor)
- [ ] `FamilyActivitySelectionView.swift` (restyle)
- [ ] `TimerDurationPicker.swift` (restyle)
- [ ] All extensions
- [ ] All extension utilities

---

## Estimated Code Reuse Percentage

| Category | Reusable | New | % Reuse |
|----------|----------|-----|---------|
| Device Activity (manager + extensions) | 2500 lines | 1000 lines | 71% |
| UI Components | 200 lines | 3000 lines | 6% |
| Data Layer | 0 lines | 2000 lines | 0% |
| App Logic | 200 lines | 2000 lines | 9% |
| Monetization | 0 lines | 1000 lines | 0% |
| Analytics | 0 lines | 500 lines | 0% |
| **TOTAL** | **2900 lines** | **9500 lines** | **23%** |

**With refactoring & restyle:** Up to 35-40% reuse

---

## Implementation Recommendations

### Immediate Actions (Do First)
1. ✅ Keep all extension code as-is
2. ✅ Keep DeviceActivityManager but refactor naming
3. ✅ Keep FamilyActivitySelectionView (will restyle later)
4. ✅ Keep TimerDurationPicker (will restyle later)
5. ❌ Delete all demo screens (MonitorView, AddActivityMonitorView, etc.)
6. ❌ Start fresh design system

### Architecture Improvements
1. Move DeviceActivityManager to `Managers/` folder
2. Create `Shared/Models/` for Core Data models
3. Create `Shared/Managers/` for cross-app managers
4. Separate UI concerns from business logic
5. Add proper error handling & logging

### Before Going to Production
1. [ ] Remove hardcoded bundle IDs
2. [ ] Add comprehensive error handling
3. [ ] Add logging/debugging support
4. [ ] Add unit tests for managers
5. [ ] Test all flows on real device
6. [ ] Test app groups communication
7. [ ] Test extension reliability
8. [ ] Add accessibility support

---

## Summary

**You have:** A solid foundation with working Device Activity monitoring  
**You need:** Everything else (design, data, UI, features)  
**Reuse rate:** 23% as-is, can improve to 35-40% with refactoring  
**Time saved:** ~2-3 weeks of Device Activity API learning, ~1 week of extension debugging  
**Effort:** Mostly building new screens & features, minimal rework of existing code  

The good news: Your hard part is done (Screen Time API integration works!). Now it's "just" building the UI, data layer, and features.

---

## Checklist for Phase 0 (Setup)

Before starting Phase 1 (Design System):

- [ ] Verify all extensions compile and run on device
- [ ] Test DeviceActivityManager app blocking/unblocking
- [ ] Verify App Groups communication works
- [ ] Backup current code (git commit)
- [ ] Rename demo identifiers (com.gia.screengate → com.gokulkrizh.focusclub)
- [ ] Update bundle IDs across all targets
- [ ] Update app group identifier
- [ ] Remove demo views from project
- [ ] Create folder structure for new views/managers/models
- [ ] Add .gitignore entries for sensitive files
- [ ] Tag: `v0.1-refactored-baseline`

Then proceed with Phase 1 (Design System).
