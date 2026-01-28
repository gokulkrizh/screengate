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
    
    // MARK: - Helpers
    
    /// Extract block ID from DeviceActivityName
    /// Format: "com.gia.screendiet.com.gia.screengate.{BLOCK_ID}"
    private func extractBlockId(from activity: DeviceActivityName) -> String? {
        let activityString = activity.rawValue
        let prefix = "com.gia.screendiet.com.gia.screengate."
        
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
    
    /// Get active block info for a specific block ID (optimized for 5MB memory limit)
    /// Only reads block-specific metadata key - no JSON parsing
    private func getActiveBlockInfo(blockId: String) -> (id: String, createdAt: Date?, duration: TimeInterval?, type: String, isShortBlock: Bool) {
        guard let userDefaults = userDefaults else {
            return (id: "", createdAt: nil, duration: nil, type: "", isShortBlock: false)
        }
        
        // Direct key lookup - O(1), no JSON parsing
        let metadataKey = "activeBlockMetadata_\(blockId)"
        guard let metadata = userDefaults.dictionary(forKey: metadataKey) as? [String: Any] else {
            logger.warning("[getActiveBlockInfo] No metadata found for blockId: \(blockId)")
            return (id: "", createdAt: nil, duration: nil, type: "", isShortBlock: false)
        }
        
        // All values pre-calculated by main app - just read them
        return (
            id: (metadata["id"] as? String) ?? "",
            createdAt: metadata["createdAt"] as? Date,
            duration: metadata["duration"] as? TimeInterval,
            type: (metadata["type"] as? String) ?? "",
            isShortBlock: (metadata["isShortBlock"] as? Bool) ?? false
        )
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
        
        // Remove block-specific metadata
        userDefaults.removeObject(forKey: "activeBlockMetadata_\(blockId)")
        
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
        
        sendNotification(title: "Focus Session Complete", body: "Your focus block has ended!")
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
        
        sendNotification(title: "Focus Session Complete", body: "Your focus block has ended!")
        logger.info("[handleLongBlockNowCompletion] Long blockNow cleanup completed for blockId: \(blockId)")
    }
    
    /// Handle scheduled block completion - called from intervalDidEnd
    private func handleScheduledBlockCompletion(blockId: String) {
        logger.info("[handleScheduledBlockCompletion] Handling scheduled block completion for blockId: \(blockId)")
        
        // Note: Pause check removed - each block is independent
        
        manager.removeRestrictions()
        clearActiveBlockData(blockId: blockId)
        sendNotification(title: "Focus Block Ended", body: "Your scheduled block has completed!")
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
        sendNotification(title: "App Limit Reached", body: "You've reached your daily app usage limit!")
        logger.info("[handleAppTimeLimitReached] App time limit threshold action completed")
    }
        
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        logger.info("[intervalDidStart] intervalDidStart called for activity")
        
        // Check if paused - if so, don't apply restrictions
        if isCurrentlyPaused() {
            logger.warning("[intervalDidStart] Block is paused, skipping restrictions")
            print("Block is paused, skipping restrictions for \(activity)")
            return
        }
        
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
                let (_, _, _) = getActiveBlock()
                sendNotification(title: "Focus Block Started", body: "Your focus session has begun!")
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
        
        let (_, _, _, blockType, isShortBlock) = getActiveBlockInfo(blockId: blockId)
        
        // If no block type found, this is a stale monitor - ignore it
        guard !blockType.isEmpty else {
            logger.warning("[intervalDidEnd] No metadata for blockId: \(blockId) - stale monitor, ignoring")
            return
        }
        
        logger.info("[intervalDidEnd] Block type: \(blockType), isShortBlock: \(isShortBlock), blockId: \(blockId)")
        
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
        
        let (_, _, _, blockType, _) = getActiveBlockInfo(blockId: blockId)
        logger.info("[eventDidReachThreshold] Block type: \(blockType), blockId: \(blockId)")
        
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
        logger.info("[intervalWillStartWarning] intervalWillStartWarning called")
        
        // Handle the warning before the interval starts.
        sendNotification(title: "Focus Block Starting Soon", body: "Your focus block will start in 1 minute")
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
        
        let (_, _, _, blockType, isShortBlock) = getActiveBlockInfo(blockId: blockId)
        logger.info("[intervalWillEndWarning] Block type: \(blockType), isShortBlock: \(isShortBlock), blockId: \(blockId)")
        
        // Only short blockNow uses this callback for cleanup
        if blockType == "blockNow" && isShortBlock {
            handleShortBlockNowCompletion(blockId: blockId)
        } else if blockType == "scheduled" && isShortBlock {
            handleScheduledBlockCompletion(blockId: blockId)
        } else {
            // All other blocks: just send warning notification
            logger.info("[intervalWillEndWarning] Standard warning - no cleanup")
            sendNotification(title: "Focus Block Ending Soon", body: "Your focus block will end soon")
        }
        
        logger.info("[intervalWillEndWarning] intervalWillEndWarning completed for blockId: \(blockId)")
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        logger.info("[eventWillReachThresholdWarning] eventWillReachThresholdWarning called")
        
        // Handle the warning before the event reaches its threshold.
        sendNotification(title: "Daily Limit Warning", body: "You're approaching your usage limit!")
        logger.info("[eventWillReachThresholdWarning] eventWillReachThresholdWarning completed")
    }
}

