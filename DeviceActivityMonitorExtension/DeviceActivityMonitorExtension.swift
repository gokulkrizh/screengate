//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitorExtension
//
//  Created by Gokul on 2025/11/05.
//

import DeviceActivity
import Foundation
import UserNotifications
import OSLog

// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private var manager = DeviceActivityManager()
    private let userDefaults = UserDefaults(suiteName: "group.com.gia.screendiet")
    private let jsonDecoder = JSONDecoder()
    private let logger = Logger(subsystem: "com.gia.screendiet", category: "DeviceActivityMonitor")
    
    // MARK: - Cached instances for memory efficiency
    private lazy var activityCenter = DeviceActivityCenter()
    private lazy var calendar = Calendar.current
    
    // MARK: - Helpers
    
    /// Extract block ID from DeviceActivityName
    /// Format: "com.gia.screendiet.{BLOCK_ID}.dayN"
    private func extractBlockId(from activity: DeviceActivityName) -> String? {
        let activityString = activity.rawValue
        let prefix = "com.gia.screendiet."
        
        guard activityString.hasPrefix(prefix) else {
            logger.warning("[extractBlockId] Activity name doesn't match expected format: \(activityString)")
            return nil
        }
        
        let blockId = String(activityString.dropFirst(prefix.count))
        logger.info("[extractBlockId] Extracted block ID: \(blockId) from activity: \(activityString)")
        return blockId
    }
    
    /// Read active block from UserDefaults (legacy - for backwards compatibility)
    private func getActiveBlock() -> (id: String, isPaused: Bool, pausedUntil: Date?) {
        logger.info("getActiveBlock called")
        guard let userDefaults = userDefaults else {
            logger.warning("No UserDefaults available")
            return (id: "", isPaused: false, pausedUntil: nil)
        }
        
        // Get active block ID
        guard let activeBlockId = userDefaults.string(forKey: "activeBlockId") else {
            logger.warning("No active block ID in UserDefaults")
            return (id: "", isPaused: false, pausedUntil: nil)
        }
        
        // Get paused until time
        let pausedUntil = userDefaults.object(forKey: "pausedUntil") as? Date
        let isPaused = pausedUntil != nil && pausedUntil! > Date()
        
        logger.info("Active block retrieved: id=\(activeBlockId), isPaused=\(isPaused)")
        return (id: activeBlockId, isPaused: isPaused, pausedUntil: pausedUntil)
    }
    
    /// Get block type info from event names (no UserDefaults dependency)
    /// Event names format: "blocknow-short", "blocknow-long", "scheduled-short", "scheduled-long", "apptimelimit"
    private func getBlockTypeFromEvents(activity: DeviceActivityName) -> (type: String, isShortBlock: Bool)? {
        let events = manager.getEvents(activityName: activity, details: false)
        
        // Check event names to determine block type
        for (eventName, _) in events {
            let eventString = eventName.rawValue
            logger.info("[getBlockTypeFromEvents] Found event: \(eventString)")
            
            // Parse event name to extract type and duration strategy
            if eventString == "blocknow-short" {
                return (type: "blockNow", isShortBlock: true)
            } else if eventString == "blocknow-long" {
                return (type: "blockNow", isShortBlock: false)
            } else if eventString == "scheduled-short" {
                return (type: "scheduled", isShortBlock: true)
            } else if eventString == "scheduled-long" {
                return (type: "scheduled", isShortBlock: false)
            } else if eventString == "apptimelimit" {
                return (type: "appTimeLimit", isShortBlock: false)
            }
        }
        
        logger.warning("[getBlockTypeFromEvents] No recognized event found for activity")
        return nil
    }
    
    /// Check if block is currently paused (pausedUntil > now)
    private func isCurrentlyPaused() -> Bool {
        logger.info("isCurrentlyPaused called")
        let (_, _, pausedUntil) = getActiveBlock()
        guard let pausedUntil = pausedUntil else {
            logger.info("Block is not paused (pausedUntil is nil)")
            return false
        }
        let isPaused = pausedUntil > Date()
        logger.info("Block pause status: \(isPaused)")
        return isPaused
    }
    
    /// Send notification for block event
    private func sendNotification(title: String, body: String) {
        logger.info("[sendNotification] sendNotification called: title=\(title)")
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                self.logger.error("[sendNotification] Error sending notification: \(error.localizedDescription)")
                print("Error sending notification: \(error)")
            } else {
                self.logger.info("[sendNotification] Notification sent successfully")
            }
        }
    }
    
    // MARK: - Block Type Handlers
    
    /// Clear specific block data from UserDefaults (supports multiple concurrent blocks)
    private func clearActiveBlockData(blockId: String) {
        guard let userDefaults = userDefaults else { return }
        
        // Remove from active blocks array
        if var activeBlockIds = userDefaults.array(forKey: "activeBlockIds") as? [String] {
            activeBlockIds.removeAll { $0 == blockId }
            if activeBlockIds.isEmpty {
                userDefaults.removeObject(forKey: "activeBlockIds")
                // Also clear legacy keys when no blocks are active
                userDefaults.removeObject(forKey: "activeBlockId")
                userDefaults.removeObject(forKey: "pausedUntil")
            } else {
                userDefaults.set(activeBlockIds, forKey: "activeBlockIds")
            }
        }
        
        // Mark block as inactive using per-block key (O(1) lookup)
        let blockKey = "block_\(blockId)"
        if let blockData = userDefaults.data(forKey: blockKey),
           var blockDict = try? JSONSerialization.jsonObject(with: blockData) as? [String: Any] {
            
            blockDict["isActive"] = false
            logger.info("[clearActiveBlockData] Marked block as inactive: \(blockId)")
            
            if let updatedData = try? JSONSerialization.data(withJSONObject: blockDict, options: []) {
                userDefaults.set(updatedData, forKey: blockKey)
            }
        } else {
            logger.warning("[clearActiveBlockData] Could not find block with key: \(blockKey)")
        }
        
        userDefaults.synchronize()
        logger.info("[clearActiveBlockData] Cleared block data for blockId: \(blockId)")
    }
    
    /// Handle short blockNow completion (<15 min) - called from intervalWillEndWarning
    private func handleShortBlockNowCompletion(blockId: String) {
        logger.info("[handleShortBlockNowCompletion] Handling short blockNow completion for blockId: \(blockId)")
        
        // Note: Pause check removed - each block is independent
        
        manager.removeRestrictions()
        clearActiveBlockData(blockId: blockId)
        
        // ✅ Broadcast change to main app via Darwin notification
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName("com.gia.screendiet.blocksChanged" as CFString),
            nil,
            nil,
            true
        )
        logger.info("[handleShortBlockNowCompletion] Posted Darwin notification for block state change")
        
       // sendNotification(title: "Focus Session Complete", body: "Your focus block has ended!")
        logger.info("[handleShortBlockNowCompletion] Short blockNow cleanup completed for blockId: \(blockId)")
    }
    
    /// Handle long blockNow completion (≥15 min) - called from intervalDidEnd
    private func handleLongBlockNowCompletion(blockId: String) {
        logger.info("[handleLongBlockNowCompletion] Handling long blockNow completion for blockId: \(blockId)")
        
        // Note: Pause check removed - each block is independent
        
        manager.removeRestrictions()
        clearActiveBlockData(blockId: blockId)
        
        // ✅ Broadcast change to main app via Darwin notification
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName("com.gia.screendiet.blocksChanged" as CFString),
            nil,
            nil,
            true
        )
        logger.info("[handleLongBlockNowCompletion] Posted Darwin notification for block state change")
        
        //sendNotification(title: "Focus Session Complete", body: "Your focus block has ended!")
        logger.info("[handleLongBlockNowCompletion] Long blockNow cleanup completed for blockId: \(blockId)")
    }
    
    /// Handle scheduled block completion - called from intervalDidEnd
    private func handleScheduledBlockCompletion(blockId: String) {
        logger.info("[handleScheduledBlockCompletion] Handling scheduled block completion for blockId: \(blockId)")
        
        // Note: Pause check removed - each block is independent
        
        manager.removeRestrictions()
        clearActiveBlockData(blockId: blockId)
       // sendNotification(title: "Focus Block Ended", body: "Your scheduled block has completed!")
        logger.info("[handleScheduledBlockCompletion] Scheduled block cleanup completed for blockId: \(blockId)")
    }
    
    /// Handle app time limit threshold reached - called from eventDidReachThreshold
    private func handleAppTimeLimitReached() {
        logger.info("[handleAppTimeLimitReached] Handling app time limit threshold reached")
        
        if isCurrentlyPaused() {
            logger.warning("[handleAppTimeLimitReached] Block is paused, skipping threshold action")
            return
        }
        
        // App time limit uses threshold to trigger restrictions
        // Restrictions stay until intervalDidEnd
        //sendNotification(title: "App Limit Reached", body: "You've reached your daily app usage limit!")
        logger.info("[handleAppTimeLimitReached] App time limit threshold action completed")
    }
    
    // MARK: - Overlapping Block Logic
    
    /// Find the activity with the longest duration among all currently overlapping activities
    /// Memory-optimized: uses cached instances, early exit, minimal allocations
    private func shouldApplyRestrictions(for currentActivity: DeviceActivityName) -> Bool {
        logger.info("[shouldApplyRestrictions] Checking activity: \(currentActivity.rawValue)")
        
        // Use cached activity center
        let allActivities = activityCenter.activities
        
        // Fast path: no other activities
        guard allActivities.count > 1 else {
            logger.info("[shouldApplyRestrictions] Only 1 activity registered, applying restrictions")
            return true
        }
        
        logger.info("[shouldApplyRestrictions] Found \(allActivities.count) total activities")
        
        // Get current time (reuse calendar instance)
        let now = Date()
        let currentComponents = calendar.dateComponents([.hour, .minute, .weekday], from: now)
        
        guard let currentHour = currentComponents.hour,
              let currentMinute = currentComponents.minute,
              let currentWeekday = currentComponents.weekday else {
            logger.error("[shouldApplyRestrictions] Failed to get time components")
            return true
        }
        
        let currentTime = currentHour * 60 + currentMinute
        logger.info("[shouldApplyRestrictions] Current time: \(currentHour):\(currentMinute) (\(currentTime) mins)")
        
        // Get current activity's end time
        let currentSchedule = activityCenter.schedule(for: currentActivity)
        guard let currentEnd = getEndTimeMinutes(from: currentSchedule, weekday: currentWeekday) else {
            logger.warning("[shouldApplyRestrictions] Could not determine current activity end time")
            return true
        }
        
        logger.info("[shouldApplyRestrictions] Current activity ends at: \(currentEnd) mins")
        
        // Check if any other activity has a longer end time
        // Early exit optimization: stop as soon as we find a longer one
        for activityName in allActivities {
            guard activityName != currentActivity else { continue }
            
            let schedule = activityCenter.schedule(for: activityName)
            
            // Check overlap and end time in one pass
            if let (startMinutes, endMinutes) = getScheduleTimeRange(schedule, weekday: currentWeekday) {
                let isOverlapping = currentTime >= startMinutes && currentTime < endMinutes
                
                if isOverlapping {
                    logger.info("[shouldApplyRestrictions] Overlapping: \(activityName.rawValue) ends at \(endMinutes) mins")
                }
                
                // Early exit: found a longer overlapping block
                if isOverlapping && endMinutes > currentEnd {
                    logger.warning("[shouldApplyRestrictions] Found longer block: \(activityName.rawValue) (ends \(endMinutes) vs \(currentEnd)), skipping restrictions")
                    return false
                }
            }
        }
        
        // No longer block found
        logger.info("[shouldApplyRestrictions] Current activity is longest, applying restrictions")
        return true
    }
    
    /// Extract end time in minutes from schedule for given weekday
    private func getEndTimeMinutes(from schedule: DeviceActivitySchedule?, weekday: Int) -> Int? {
        guard let schedule = schedule else { return nil }
        
        // Check if activity should run on this weekday
        if schedule.repeats {
            // For repeating schedules, check if current weekday matches
            let activityWeekday = extractWeekdayFromActivityName(schedule: schedule)
            if let activityWeekday = activityWeekday, activityWeekday != weekday {
                return nil // Activity doesn't run on this weekday
            }
        }
        
        guard let endHour = schedule.intervalEnd.hour,
              let endMinute = schedule.intervalEnd.minute else {
            return nil
        }
        
        return endHour * 60 + endMinute
    }
    
    /// Get both start and end times in minutes from schedule for given weekday
    private func getScheduleTimeRange(_ schedule: DeviceActivitySchedule?, weekday: Int) -> (start: Int, end: Int)? {
        guard let schedule = schedule else { return nil }
        
        // Check if activity should run on this weekday
        if schedule.repeats {
            let activityWeekday = extractWeekdayFromActivityName(schedule: schedule)
            if let activityWeekday = activityWeekday, activityWeekday != weekday {
                return nil // Activity doesn't run on this weekday
            }
        }
        
        guard let startHour = schedule.intervalStart.hour,
              let startMinute = schedule.intervalStart.minute,
              let endHour = schedule.intervalEnd.hour,
              let endMinute = schedule.intervalEnd.minute else {
            return nil
        }
        
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute
        
        return (startMinutes, endMinutes)
    }
    
    /// Extract weekday from activity name (e.g., "com.gia.screendiet.blockId.day2" -> 2)
    private func extractWeekdayFromActivityName(schedule: DeviceActivitySchedule) -> Int? {
        // This is a placeholder - we'd need to access the activity name
        // For now, return nil to allow all weekdays
        return nil
    }
        
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        logger.info("[intervalDidStart] intervalDidStart called for activity: \(activity.rawValue)")
        
        // Check if paused - if so, don't apply restrictions
        if isCurrentlyPaused() {
            logger.warning("[intervalDidStart] Block is paused, skipping restrictions")
            print("Block is paused, skipping restrictions for \(activity)")
            return
        }
        
        // Check if this activity has the longest duration among overlapping blocks
        guard shouldApplyRestrictions(for: activity) else {
            logger.warning("[intervalDidStart] Another longer block is active, skipping restrictions for \(activity.rawValue)")
            return
        }
        
        // CRITICAL: Remove any existing restrictions first to ensure clean state
        // This handles the case where a longer block takes over from a shorter one
        logger.info("[intervalDidStart] Removing any previous restrictions before applying new ones")
        manager.removeRestrictions()
        
        // Handle the start of the interval.
        // if the threshold is 0, the eventDidReachThreshold is not be triggered correctly sometimes.
        let events = manager.getEvents(activityName: activity, details: true)
        logger.info("[intervalDidStart] Found \(events.count) events for activity")
        for (_, event) in events {
            if event.threshold.hour == 0 && event.threshold.minute == 0 {
                logger.info("[intervalDidStart] Applying immediate restrictions for zero threshold")
                manager.applyImmediateRestrictions(
                    applicationTokens: event.applications,
                    categoryTokens: event.categories,
                    webDomainTokens: event.webDomains
                )
                
                // Send notification for block start
                //sendNotification(title: "Focus Block Started", body: "Your focus session has begun!")
            }
        }
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        logger.info("[intervalDidEnd] intervalDidEnd called for activity: \(activity.rawValue)")
        
        // Extract block ID from activity name
        guard let blockId = extractBlockId(from: activity) else {
            logger.error("[intervalDidEnd] Failed to extract block ID from activity")
            return
        }
        
        // Get block type from event names (no UserDefaults dependency)
        guard let (blockType, isShortBlock) = getBlockTypeFromEvents(activity: activity) else {
            logger.warning("[intervalDidEnd] Could not determine block type from events - stale monitor, ignoring")
            return
        }
        
        logger.info("[intervalDidEnd] Block type: \(blockType), isShortBlock: \(isShortBlock), blockId: \(blockId)")
        
        // Check if this activity was the one applying restrictions (longest duration)
        // If another longer block is still active, don't remove restrictions
        guard shouldApplyRestrictions(for: activity) else {
            logger.warning("[intervalDidEnd] Another longer block is still active, skipping cleanup for \(activity.rawValue)")
            return
        }
        
        // Route to appropriate handler based on block type
        switch blockType {
        case "blockNow":
            if isShortBlock {
                // Short blocks already cleaned up in intervalWillEndWarning
                logger.info("[intervalDidEnd] Short blockNow - already handled, skipping")
            } else {
                // Long blocks clean up here
                handleLongBlockNowCompletion(blockId: blockId)
            }
            
        case "scheduled":
            if isShortBlock {
                // Short scheduled blocks already cleaned up in intervalWillEndWarning
                logger.info("[intervalDidEnd] Short scheduled block - already handled, skipping")
            } else {
                // Long scheduled blocks clean up here
                handleScheduledBlockCompletion(blockId: blockId)
            }
            
        case "appTimeLimit":
            handleScheduledBlockCompletion(blockId: blockId) // Same cleanup as scheduled
            
        default:
            logger.warning("[intervalDidEnd] Unknown block type: \(blockType)")
        }
        
        logger.info("[intervalDidEnd] intervalDidEnd completed for blockId: \(blockId)")
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        logger.info("[eventDidReachThreshold] eventDidReachThreshold fired for activity: \(activity.rawValue)")
        
        // Extract block ID from activity name
        guard let blockId = extractBlockId(from: activity) else {
            logger.error("[eventDidReachThreshold] Failed to extract block ID from activity")
            return
        }
        
        // Get block type from event names (no UserDefaults dependency)
        guard let (blockType, _) = getBlockTypeFromEvents(activity: activity) else {
            logger.warning("[eventDidReachThreshold] Could not determine block type from events")
            return
        }
        logger.info("[eventDidReachThreshold] Block type: \(blockType), blockId: \(blockId)")
        
        // Check if this activity has the longest duration among overlapping blocks
        guard shouldApplyRestrictions(for: activity) else {
            logger.warning("[eventDidReachThreshold] Another longer block is active, skipping threshold action for \(activity.rawValue)")
            return
        }
        
        // Route to appropriate handler based on block type
        switch blockType {
        case "appTimeLimit":
            handleAppTimeLimitReached()
            
        case "blockNow":
            // blockNow uses warningTime for cleanup, not threshold
            logger.info("[eventDidReachThreshold] blockNow uses warningTime callback, ignoring threshold")
            
        default:
            logger.info("[eventDidReachThreshold] No threshold action for block type: \(blockType)")
        }
    }
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        logger.info("[intervalWillStartWarning] intervalWillStartWarning called for activity: \(activity.rawValue)")
        
        // Check if this activity will be the longest when it starts
        guard shouldApplyRestrictions(for: activity) else {
            logger.warning("[intervalWillStartWarning] Another longer block will be active, skipping warning for \(activity.rawValue)")
            return
        }
        
        // Handle the warning before the interval starts.
       // sendNotification(title: "Focus Block Starting Soon", body: "Your focus block will start in 1 minute")
        logger.info("[intervalWillStartWarning] intervalWillStartWarning completed")
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        logger.info("[intervalWillEndWarning] intervalWillEndWarning called for activity: \(activity.rawValue)")
        
        // Extract block ID from activity name
        guard let blockId = extractBlockId(from: activity) else {
            logger.error("[intervalWillEndWarning] Failed to extract block ID from activity")
            return
        }
        
        // Get block type from event names (no UserDefaults dependency)
        guard let (blockType, isShortBlock) = getBlockTypeFromEvents(activity: activity) else {
            logger.warning("[intervalWillEndWarning] Could not determine block type from events")
            return
        }
        logger.info("[intervalWillEndWarning] Block type: \(blockType), isShortBlock: \(isShortBlock), blockId: \(blockId)")
        
        // Check if this activity was the one applying restrictions (longest duration)
        // If another longer block is still active, don't clean up
        guard shouldApplyRestrictions(for: activity) else {
            logger.warning("[intervalWillEndWarning] Another longer block is still active, skipping cleanup for \(activity.rawValue)")
            return
        }
        
        // Only short blockNow uses this callback for cleanup
        if blockType == "blockNow" && isShortBlock {
            handleShortBlockNowCompletion(blockId: blockId)
        } else if blockType == "scheduled" && isShortBlock {
            handleScheduledBlockCompletion(blockId: blockId)
        } else {
            // All other blocks: just send warning notification
            logger.info("[intervalWillEndWarning] Standard warning - no cleanup")
           // sendNotification(title: "Focus Block Ending Soon", body: "Your focus block will end soon")
        }
        
        logger.info("[intervalWillEndWarning] intervalWillEndWarning completed for blockId: \(blockId)")
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        logger.info("[eventWillReachThresholdWarning] eventWillReachThresholdWarning called for activity: \(activity.rawValue)")
        
        // Check if this activity is the longest among overlapping blocks
        guard shouldApplyRestrictions(for: activity) else {
            logger.warning("[eventWillReachThresholdWarning] Another longer block is active, skipping warning for \(activity.rawValue)")
            return
        }
        
        // Handle the warning before the event reaches its threshold.
       // sendNotification(title: "Daily Limit Warning", body: "You're approaching your usage limit!")
        logger.info("[eventWillReachThresholdWarning] eventWillReachThresholdWarning completed")
    }
}

