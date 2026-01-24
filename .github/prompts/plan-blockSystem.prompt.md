# Block System Implementation Plan

> **Status**: Planning Phase  
> **Created**: January 24, 2026  
> **App**: Screendiet (ScreenGate)

---

## Overview

Transform static UI into a fully functional block system using FamilyControls/DeviceActivity APIs. Users create blocks (Scheduled, Block Now, App Time Limit, Open Limit), which persist and display dynamically in UpcomingBlocksView. Active blocks show live timers in HomeScreen and FocusSessionScreen with pause/cancel functionality.

---

## Architecture Decisions

### 1. Open Limit (Count-Based Blocking)
- **Decision**: Park for later implementation
- **Reason**: DeviceActivity API doesn't natively support count-based app open tracking
- **Future Options**:
  - Use `DeviceActivityReport` API for daily usage stats
  - Custom tracking via app open notifications
  - Shortcuts/automations as workaround
- **Status**: UI will remain, but functionality deferred to v2

### 2. Day-of-Week Filtering
- **Decision**: Option A - Create separate monitors per day
- **Implementation**: 
  - For a block scheduled on Mon/Wed/Fri, create 3 separate `DeviceActivitySchedule` monitors
  - Naming convention: `com.gia.screengate.{blockId}.{dayNumber}` (e.g., `.day1`, `.day3`, `.day5`)
  - All monitors share the same app selection but have day-specific schedules
- **Trade-off**: More monitors to manage, but cleaner system integration

### 3. Pause State Persistence
- **Decision**: Store `pausedUntil` and block state in shared UserDefaults
- **App Group**: `group.com.gia.screengate`
- **Keys**:
  - `activeBlock` - JSON encoded current Block
  - `pausedUntil` - Date when pause expires (nil if not paused)
  - `blocks` - Array of all created blocks
- **Reason**: Extension needs access to re-apply restrictions after pause expires or app termination

---

## Data Models

### Block.swift (New File: `screengate/Models/Block.swift`)

```swift
import Foundation
import FamilyControls

struct Block: Codable, Identifiable {
    let id: UUID
    var name: String
    var type: BlockType
    var appSelection: FamilyActivitySelection
    var schedule: BlockSchedule
    var strictMode: StrictMode
    var isActive: Bool
    var isPaused: Bool
    var pausedUntil: Date?
    var createdAt: Date
    
    enum BlockType: String, Codable, CaseIterable {
        case scheduled      // Time-based recurring
        case blockNow       // Immediate timer
        case appTimeLimit   // Threshold-based daily limit
        case openLimit      // Count-based (parked for v2)
    }
    
    struct BlockSchedule: Codable {
        var startTime: Date?           // For scheduled blocks
        var endTime: Date?             // For scheduled blocks
        var duration: TimeInterval?    // For blockNow (seconds)
        var threshold: TimeInterval?   // For appTimeLimit (usage limit)
        var repeatDays: Set<Int>?      // 1=Mon, 2=Tue, ... 7=Sun
        var isRepeating: Bool          // Daily repeat flag
    }
}

enum StrictMode: String, Codable, CaseIterable {
    case easy    // Can dismiss shield easily
    case medium  // Requires confirmation
    case hard    // Cannot dismiss, must wait or type forfeit phrase
}
```

### BlockManager.swift (New File: `Shared/BlockManager.swift`)

```swift
@Observable
class BlockManager {
    // MARK: - Published State
    var blocks: [Block] = []
    var activeBlock: Block?
    var pausedUntil: Date?
    
    // MARK: - Computed
    var upcomingBlocks: [Block] { /* filter by date */ }
    var todayBlocks: [Block] { /* filter for today */ }
    var hasActiveSession: Bool { activeBlock != nil && !isPaused }
    var isPaused: Bool { pausedUntil != nil && pausedUntil! > Date() }
    
    // MARK: - Dependencies
    private let deviceActivityManager = DeviceActivityManager()
    private let userDefaults = UserDefaults(suiteName: "group.com.gia.screengate")
    
    // MARK: - CRUD Operations
    func createBlock(_ block: Block) { }
    func updateBlock(_ block: Block) { }
    func deleteBlock(_ block: Block) { }
    
    // MARK: - Session Control
    func activateBlock(_ block: Block) { }
    func pauseBlock(duration: TimeInterval) { }
    func resumeBlock() { }
    func cancelBlock() { }
    func extendBlock(by minutes: Int) { }
    
    // MARK: - Persistence
    func saveToUserDefaults() { }
    func loadFromUserDefaults() { }
}
```

---

## Implementation Steps

### Phase 1: Data Layer

| Step | File | Description |
|------|------|-------------|
| 1.1 | `Models/Block.swift` | Create Block struct with all properties |
| 1.2 | `Models/StrictMode.swift` | Create StrictMode enum (or include in Block.swift) |
| 1.3 | `Shared/BlockManager.swift` | Create BlockManager with persistence |
| 1.4 | `Shared/BlockManager.swift` | Add CRUD methods with UserDefaults sync |

### Phase 2: Block Creation Integration

| Step | File | Description |
|------|------|-------------|
| 2.1 | `Views/BlockCreation/CreateScheduledBlockView.swift` | Add `FamilyActivityPicker`, wire to BlockManager |
| 2.2 | `Views/BlockCreation/CreateBlockNowView.swift` | Add picker, immediate activation on create |
| 2.3 | `Views/BlockCreation/CreateAppTimeLimitView.swift` | Add picker, threshold-based monitor setup |
| 2.4 | `Views/BlockCreation/CreateOpenLimitView.swift` | Add picker, show "coming soon" for activation |

### Phase 3: Dynamic UI

| Step | File | Description |
|------|------|-------------|
| 3.1 | `Views/Plan/UpcomingBlocksView.swift` | Replace static blocks with `ForEach(blockManager.blocks)` |
| 3.2 | `Views/Plan/UpcomingBlocksView.swift` | Group by date, show active status |
| 3.3 | `Views/Plan/UpcomingBlocksView.swift` | Add swipe-to-delete, edit navigation |
| 3.4 | `Views/HomeScreen.swift` | Show active block card dynamically |
| 3.5 | `Views/HomeScreen.swift` | Live timer using `blockManager.activeBlock` |

### Phase 4: Focus Session

| Step | File | Description |
|------|------|-------------|
| 4.1 | `Views/FocusSession/FocusSessionScreen.swift` | Connect to BlockManager for timer state |
| 4.2 | `Views/FocusSession/FocusSessionScreen.swift` | Wire pause → `blockManager.pauseBlock()` |
| 4.3 | `Views/FocusSession/FocusSessionScreen.swift` | Wire cancel → `blockManager.cancelBlock()` |
| 4.4 | `Views/FocusSession/FocusSessionScreen.swift` | Wire +5min → `blockManager.extendBlock()` |
| 4.5 | `Views/FocusSession/SetCustomDurationModal.swift` | Return duration to extend session |

### Phase 5: Extension Integration

| Step | File | Description |
|------|------|-------------|
| 5.1 | `DeviceActivityMonitorExtension.swift` | Read block state from UserDefaults |
| 5.2 | `DeviceActivityMonitorExtension.swift` | Check `pausedUntil` before applying restrictions |
| 5.3 | `DeviceActivityMonitorExtension.swift` | Post local notification on block start |
| 5.4 | `ShieldActionExtension.swift` | Read `strictMode` from active block |
| 5.5 | `ShieldActionExtension.swift` | Return appropriate action based on mode |

### Phase 6: Day-of-Week Monitors

| Step | File | Description |
|------|------|-------------|
| 6.1 | `Shared/BlockManager.swift` | Create helper to generate day-specific monitor names |
| 6.2 | `Shared/BlockManager.swift` | On create scheduled block, create N monitors for N days |
| 6.3 | `Shared/BlockManager.swift` | On delete, remove all associated day monitors |
| 6.4 | `Shared/DeviceActivityManager.swift` | Update naming convention support |

---

## UserDefaults Keys (App Group)

| Key | Type | Description |
|-----|------|-------------|
| `blocks` | `Data` (JSON) | Array of all Block objects |
| `activeBlockId` | `String?` | UUID of currently active block |
| `pausedUntil` | `Date?` | When current pause expires |
| `{activityName}.{eventName}` | `Data` | FamilyActivitySelection per monitor (existing) |

---

## Monitor Naming Convention

```
com.gia.screengate.{blockId}                    // For non-repeating blocks
com.gia.screengate.{blockId}.day1               // Monday
com.gia.screengate.{blockId}.day2               // Tuesday
com.gia.screengate.{blockId}.day3               // Wednesday
com.gia.screengate.{blockId}.day4               // Thursday
com.gia.screengate.{blockId}.day5               // Friday
com.gia.screengate.{blockId}.day6               // Saturday
com.gia.screengate.{blockId}.day7               // Sunday
```

---

## Strict Mode Behavior

| Mode | Shield Dismissal | Cancel Session | UI Feedback |
|------|------------------|----------------|-------------|
| Easy | Tap anywhere | Immediate | Simple confirmation |
| Medium | Confirm button | 15s countdown | Warning message |
| Hard | Cannot dismiss | Type "I FORFEIT" | Streak loss warning |

---

## Testing Checklist

- [ ] Create scheduled block with app selection
- [ ] Create "Block Now" and verify immediate restriction
- [ ] Verify blocks appear in UpcomingBlocksView
- [ ] Verify active block shows in HomeScreen
- [ ] Verify FocusSessionScreen timer syncs with block
- [ ] Test pause functionality (restrictions removed temporarily)
- [ ] Test resume after pause expires
- [ ] Test cancel/give up flow
- [ ] Test app termination during pause → restrictions re-apply
- [ ] Test strict mode variations in ShieldActionExtension
- [ ] Test day-of-week scheduling (multiple monitors created)
- [ ] Test delete block (all monitors removed)

---

## Known Limitations

1. **Open Limit**: Parked for v2 - UI exists but activation disabled
2. **Simulator**: DeviceActivity thresholds don't trigger reliably - use physical device
3. **Extension Debugging**: Limited visibility - use `os_log` for debugging
4. **Token Persistence**: `FamilyActivitySelection` must be saved to UserDefaults for extension access

---

## Dependencies

- FamilyControls framework
- ManagedSettings framework  
- DeviceActivity framework
- UserNotifications framework
- App Group: `group.com.gia.screengate`
- Entitlement: `com.apple.developer.family-controls`
