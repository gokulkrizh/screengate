import Foundation
import Combine
import DeviceActivity
import FamilyControls
import SwiftUI

/// Builds a timeline of blocks from DeviceActivityCenter schedules (source of truth)
@Observable
final class BlockTimelineBuilder {
    // MARK: - Published State
    
    var todayBlocks: [Block] = []
    var tomorrowBlocks: [Block] = []
    var weekBlocks: [Int: [Block]] = [:] // dayOffset -> blocks
    var currentActiveBlocks: [Block] = []
    
    // MARK: - Private Properties
    
    private let blockManager: BlockManager
    private let center = DeviceActivityCenter()
    private let calendar = Calendar.current
    private var cancellables = Set<AnyCancellable>()
    
    // Cache for activity metadata from UserDefaults (for display only)
    private var metadataCache: [String: BlockMetadata] = [:]
    
    // Re-entrance guard to prevent infinite loops
    private var isBuilding = false
    
    // MARK: - Metadata Structure
    
    private struct BlockMetadata {
        let name: String
        let icon: String
        let iconColor: String
        let blockType: Block.BlockType
        let appCount: Int?
    }
    
    // MARK: - Initialization
    
    init(blockManager: BlockManager) {
        self.blockManager = blockManager
        loadMetadataCache()
        
        // Listen for block changes to rebuild timeline
        setupNotificationObserver()
    }
    
    deinit {
        CFNotificationCenterRemoveEveryObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passUnretained(self).toOpaque()
        )
    }
    
    private func setupNotificationObserver() {
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let observer = Unmanaged.passUnretained(self).toOpaque()
        
        CFNotificationCenterAddObserver(
            center,
            observer,
            { center, observer, name, object, userInfo in
                guard let observer = observer else { return }
                let builder = Unmanaged<BlockTimelineBuilder>.fromOpaque(observer).takeUnretainedValue()
                DispatchQueue.main.async {
                    print("🔔 [BlockTimelineBuilder] Received blocks changed notification, rebuilding timeline")
                    builder.buildTimeline()
                }
            },
            "com.gia.screendiet.blocksChanged" as CFString,
            nil,
            .deliverImmediately
        )
        
        print("✅ [BlockTimelineBuilder] Darwin notification observer registered")
    }
    
    // MARK: - Timeline Building (DeviceActivityCenter as Source)
    
    /// Build complete timeline for the specified number of days
    func buildTimeline(days: Int = 7, referenceDate: Date = Date()) {
        // Prevent re-entrant calls that cause infinite loops
        guard !isBuilding else {
            print("⚠️ [BlockTimelineBuilder] Already building, skipping duplicate call")
            return
        }
        
        isBuilding = true
        defer { isBuilding = false }
        
        loadMetadataCache() // Refresh metadata before building
        
        var weekBlocksTemp: [Int: [Block]] = [:]
        
        // Get all registered activities from system (with error handling)
        let registeredActivities: Set<DeviceActivityName>
        do {
            // Wrap in do-catch to prevent crashes
            registeredActivities = Set(center.activities)
            print("✅ [BlockTimelineBuilder] Found \(registeredActivities.count) registered activities")
        } catch {
            print("❌ [BlockTimelineBuilder] Failed to get activities: \(error)")
            // Return empty timeline on error
            weekBlocks = [:]
            todayBlocks = []
            tomorrowBlocks = []
            currentActiveBlocks = []
            return
        }
        
        // If no activities registered, return empty timeline
        if registeredActivities.isEmpty {
            print("ℹ️ [BlockTimelineBuilder] No activities registered")
            weekBlocks = [:]
            todayBlocks = []
            tomorrowBlocks = []
            currentActiveBlocks = []
            return
        }
        
        for dayOffset in 0..<days {
            guard let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: referenceDate) else {
                continue
            }
            
            let blocksForDay = getBlocksForDate(targetDate, registeredActivities: registeredActivities, referenceDate: referenceDate)
            weekBlocksTemp[dayOffset] = blocksForDay
            
            // Cache today and tomorrow for quick access
            if dayOffset == 0 {
                todayBlocks = blocksForDay
            } else if dayOffset == 1 {
                tomorrowBlocks = blocksForDay
            }
        }
        
        weekBlocks = weekBlocksTemp
        updateActiveBlocks(referenceDate: referenceDate)
    }
    
    /// Get blocks that should run on a specific date by reading DeviceActivityCenter
    private func getBlocksForDate(_ date: Date, registeredActivities: Set<DeviceActivityName>, referenceDate: Date) -> [Block] {
        var blocksForDay: [Block] = []
        
        let dayOffset = calendar.dateComponents([.day], from: calendar.startOfDay(for: referenceDate), to: calendar.startOfDay(for: date)).day ?? 0
        
        // Iterate through all registered activities
        for activityName in registeredActivities {
            // Read schedule from system (source of truth) - with error handling
            guard let schedule = try? center.schedule(for: activityName) else {
                print("⚠️ [BlockTimelineBuilder] Could not read schedule for: \(activityName.rawValue)")
                continue
            }
            guard let events = try? center.events(for: activityName) else {
                print("⚠️ [BlockTimelineBuilder] Could not read events for: \(activityName.rawValue)")
                continue
            }
            
            print("✅ [BlockTimelineBuilder] Processing activity: \(activityName.rawValue)")
            
            // Check if this activity should run on this date
            if shouldActivityRunOnDate(schedule, activityName: activityName, date: date) {
                // Convert DeviceActivitySchedule to Block model
                if let block = createBlock(from: schedule, events: events, activityName: activityName, referenceDate: referenceDate) {
                    // For today, filter out blocks that have already ended
                    if dayOffset == 0 {
                        var currentComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: referenceDate)
                        currentComponents.second = 0
                        let normalizedNow = calendar.date(from: currentComponents) ?? referenceDate
                        
                        if let endTime = block.schedule.endTime, normalizedNow < endTime {
                            blocksForDay.append(block)
                        }
                    } else {
                        blocksForDay.append(block)
                    }
                }
            }
        }
        
        print("ℹ️ [BlockTimelineBuilder] Found \(blocksForDay.count) blocks for date: \(date)")
        
        // Sort by start time
        return blocksForDay.sorted { ($0.schedule.startTime ?? Date()) < ($1.schedule.startTime ?? Date()) }
    }
    
    /// Check if a DeviceActivitySchedule should run on a specific date
    private func shouldActivityRunOnDate(_ schedule: DeviceActivitySchedule, activityName: DeviceActivityName, date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        
        // For multi-day repeating schedules, activity name contains .dayN where N is the weekday
        if schedule.repeats {
            // Extract weekday from activity name (format: "UUID.dayN")
            let components = activityName.rawValue.split(separator: ".")
            if let dayComponent = components.last, dayComponent.hasPrefix("day"),
               let dayNumber = Int(dayComponent.dropFirst(3)) {
                return dayNumber == weekday
            }
            
            // If no day component in name, check schedule's weekday
            if let scheduledWeekday = schedule.intervalStart.weekday {
                return scheduledWeekday == weekday
            }
            
            // No weekday specified, runs every day
            return true
        } else {
            // One-time schedule: check if date matches
            if let year = schedule.intervalStart.year,
               let month = schedule.intervalStart.month,
               let day = schedule.intervalStart.day {
                let scheduleDate = calendar.date(from: DateComponents(year: year, month: month, day: day))
                return scheduleDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false
            }
            return false
        }
    }
    
    /// Convert DeviceActivitySchedule + events to Block model
    private func createBlock(from schedule: DeviceActivitySchedule, events: [DeviceActivityEvent.Name: DeviceActivityEvent], activityName: DeviceActivityName, referenceDate: Date) -> Block? {
        // Extract time components from schedule
        guard let startHour = schedule.intervalStart.hour,
              let startMinute = schedule.intervalStart.minute,
              let endHour = schedule.intervalEnd.hour,
              let endMinute = schedule.intervalEnd.minute else {
            return nil
        }
        
        // Build start and end times
        var startComponents = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        startComponents.hour = startHour
        startComponents.minute = startMinute
        startComponents.second = 0
        
        var endComponents = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        endComponents.hour = endHour
        endComponents.minute = endMinute
        endComponents.second = 0
        
        guard let startTime = calendar.date(from: startComponents),
              var endTime = calendar.date(from: endComponents) else {
            return nil
        }
        
        // Handle overnight schedules
        if endTime < startTime {
            endTime = calendar.date(byAdding: .day, value: 1, to: endTime) ?? endTime
        }
        
        // Get metadata from cache (for display purposes)
        let activityKey = activityName.rawValue
        let metadata = metadataCache[activityKey]
        
        // Determine block type from events
        let blockType = determineBlockType(from: events)
        
        // Build repeatDays if schedule repeats
        var repeatDays: Set<Int>? = nil
        if schedule.repeats {
            // Extract weekday from schedule if available
            if let weekday = schedule.intervalStart.weekday {
                repeatDays = [weekday]
            } else {
                // Assume daily repeat
                repeatDays = [1, 2, 3, 4, 5, 6, 7]
            }
        }
        
        // Create Block
        return Block(
            id: UUID(),
            name: metadata?.name ?? activityKey,
            icon: metadata?.icon ?? "app.fill",
            iconColor: metadata?.iconColor ?? "#66C5A8",
            type: metadata?.blockType ?? blockType,
            appSelection: FamilyActivitySelection(), // Tokens empty (known bug)
            schedule: Block.BlockSchedule(
                startTime: startTime,
                endTime: endTime,
                duration: nil,
                threshold: nil,
                repeatDays: repeatDays
            ),
            strictMode: .medium,
            activityName: activityName,
            appCount: metadata?.appCount
        )
    }
    
    /// Determine block type from DeviceActivityEvents
    private func determineBlockType(from events: [DeviceActivityEvent.Name: DeviceActivityEvent]) -> Block.BlockType {
        // Check if there are threshold events (indicates app time limit)
        if events.keys.contains(where: { $0.rawValue.contains("threshold") || $0.rawValue.contains("limit") }) {
            return .appTimeLimit
        }
        
        // Default to scheduled block
        return .scheduled
    }
    
    /// Load metadata from UserDefaults for display purposes only
    private func loadMetadataCache() {
        metadataCache.removeAll()
        
        // Read blocks from BlockManager (UserDefaults) for metadata
        for block in blockManager.blocks {
            if let activityName = block.activityName {
                metadataCache[activityName.rawValue] = BlockMetadata(
                    name: block.name,
                    icon: block.icon,
                    iconColor: block.iconColor,
                    blockType: block.type,
                    appCount: block.appCount
                )
            }
        }
    }
    
    // MARK: - Active Block Detection
    
    /// Update which blocks are currently active using DeviceActivityCenter schedules
    func updateActiveBlocks(referenceDate: Date = Date()) {
        var currentComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: referenceDate)
        currentComponents.second = 0
        let normalizedNow = calendar.date(from: currentComponents) ?? referenceDate
        
        print("🔍 [BlockTimelineBuilder] Updating active blocks from \(todayBlocks.count) today blocks")
        
        currentActiveBlocks = todayBlocks.filter { block in
            guard let activityName = block.activityName else {
                print("⚠️ [BlockTimelineBuilder] Block '\(block.name)' has no activityName")
                return false
            }
            let isActive = isBlockActiveInSystem(activityName: activityName, at: normalizedNow)
            if isActive {
                print("✅ [BlockTimelineBuilder] Block '\(block.name)' is ACTIVE")
            }
            return isActive
        }
        
        print("ℹ️ [BlockTimelineBuilder] Found \(currentActiveBlocks.count) active blocks")
    }
    
    /// Check if an activity is currently active in the system
    private func isBlockActiveInSystem(activityName: DeviceActivityName, at referenceTime: Date) -> Bool {
        // Step 1: Check if monitor is registered
        let registeredActivities: [DeviceActivityName]
        do {
            registeredActivities = center.activities
        } catch {
            print("❌ [BlockTimelineBuilder] Failed to get activities: \(error)")
            return false
        }
        
        guard registeredActivities.contains(activityName) else {
            print("ℹ️ [BlockTimelineBuilder] Activity '\(activityName.rawValue)' not registered")
            return false // Not registered = not active
        }
        
        // Step 2: Get actual system schedule
        guard let schedule = try? center.schedule(for: activityName) else {
            print("⚠️ [BlockTimelineBuilder] Could not get schedule for '\(activityName.rawValue)'")
            return false // No schedule = not active
        }
        
        // Step 3: Check if schedule is currently active
        return isScheduleActive(schedule, at: referenceTime)
    }
    
    /// Check if a DeviceActivitySchedule is currently active at given time
    private func isScheduleActive(_ schedule: DeviceActivitySchedule, at referenceTime: Date) -> Bool {
        let nowComponents = calendar.dateComponents([.hour, .minute], from: referenceTime)
        guard let nowHour = nowComponents.hour,
              let nowMinute = nowComponents.minute else {
            return false
        }
        
        let nowMinutes = nowHour * 60 + nowMinute
        
        // Get schedule start/end times
        guard let startHour = schedule.intervalStart.hour,
              let startMinute = schedule.intervalStart.minute,
              let endHour = schedule.intervalEnd.hour,
              let endMinute = schedule.intervalEnd.minute else {
            return false
        }
        
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute
        
        // Handle overnight schedules (e.g., 22:00 - 06:00)
        if startMinutes > endMinutes {
            return nowMinutes >= startMinutes || nowMinutes < endMinutes
        } else {
            return nowMinutes >= startMinutes && nowMinutes < endMinutes
        }
    }
    
    /// Check if a specific block is active at a given time
    func isBlockActive(_ block: Block, at referenceTime: Date) -> Bool {
        guard let activityName = block.activityName else { return false }
        return isBlockActiveInSystem(activityName: activityName, at: referenceTime)
    }
    
    // MARK: - Helper Methods
    
    /// Check if there are any blocks for the specified days
    func hasAnyBlocks(forDays days: Int) -> Bool {
        for dayOffset in 0..<days {
            if let blocks = weekBlocks[dayOffset], !blocks.isEmpty {
                return true
            }
        }
        return false
    }
    
    // MARK: - Debugging
    
    /// Debug method: Print all registered activities and their schedules
    func debugPrintRegisteredActivities() {
        let activities = center.activities
        print("📊 Registered Activities: \(activities.count)")
        
        for activityName in activities {
            if let schedule = try? center.schedule(for: activityName),
               let events = try? center.events(for: activityName) {
                print("  ✅ \(activityName.rawValue)")
                print("     Schedule: \(schedule.intervalStart) → \(schedule.intervalEnd)")
                print("     Repeats: \(schedule.repeats)")
                print("     Events: \(events.count)")
            } else {
                print("  ⚠️ \(activityName.rawValue) - Could not read schedule/events")
            }
        }
    }
}
