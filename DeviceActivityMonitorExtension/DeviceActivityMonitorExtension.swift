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
    
    /// Read active block from UserDefaults
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
    
    /// Get active block info including creation time, duration, and pre-calculated flags
    private func getActiveBlockInfo() -> (id: String, createdAt: Date?, duration: TimeInterval?, type: String, isShortBlock: Bool) {
        logger.info("getActiveBlockInfo called")
        guard let userDefaults = userDefaults else {
            logger.warning("No UserDefaults available")
            return (id: "", createdAt: nil, duration: nil, type: "", isShortBlock: false)
        }
        
        // Try to read from activeBlockMetadata first (simpler format)
        if let metadata = userDefaults.dictionary(forKey: "activeBlockMetadata") as? [String: Any] {
            logger.info("Found activeBlockMetadata in UserDefaults")
            let id = (metadata["id"] as? String) ?? ""
            let type = (metadata["type"] as? String) ?? ""
            let createdAt = (metadata["createdAt"] as? Date)
            let duration = (metadata["duration"] as? TimeInterval)
            let isShortBlock = (metadata["isShortBlock"] as? Bool) ?? false
            
            logger.info("Block info from metadata: id=\(id), type=\(type), duration=\(duration ?? 0), isShortBlock=\(isShortBlock)")
            return (id: id, createdAt: createdAt, duration: duration, type: type, isShortBlock: isShortBlock)
        }
        
        // Fallback: parse from blocks array if metadata not available
        logger.info("activeBlockMetadata not found, falling back to blocks array parsing")
        
        guard let activeBlockIdString = userDefaults.string(forKey: "activeBlockId") else {
            logger.warning("No activeBlockId in UserDefaults")
            return (id: "", createdAt: nil, duration: nil, type: "", isShortBlock: false)
        }
        
        guard let blocksData = userDefaults.data(forKey: "blocks") else {
            logger.warning("No blocks array in UserDefaults")
            return (id: "", createdAt: nil, duration: nil, type: "", isShortBlock: false)
        }
        
        do {
            // Decode as array of dictionaries
            let blocksArray = try jsonDecoder.decode([[String: AnyCodable]].self, from: blocksData)
            
            // Find the active block by matching the id field
            guard let activeBlockDict = blocksArray.first(where: { blockDict in
                // Extract id as string from AnyCodable
                if let idValue = blockDict["id"] {
                    if let idString = idValue as? String {
                        return idString == activeBlockIdString
                    } else if let idDict = idValue as? [String: AnyCodable],
                              let uuidValue = idDict["uuid"] as? String {
                        // Handle case where UUID might be encoded as nested object
                        return uuidValue == activeBlockIdString
                    }
                }
                return false
            }) else {
                logger.warning("Active block id not found in blocks array")
                return (id: "", createdAt: nil, duration: nil, type: "", isShortBlock: false)
            }
            
            let id = (activeBlockDict["id"] as? String) ?? activeBlockIdString
            let type = (activeBlockDict["type"] as? String) ?? ""
            
            // Get createdAt
            var createdAt: Date? = nil
            if let createdAtData = activeBlockDict["createdAt"] {
                createdAt = createdAtData as? Date
            }
            
            // Get schedule info
            var duration: TimeInterval? = nil
            if let schedule = activeBlockDict["schedule"] as? [String: AnyCodable],
               let durationVal = schedule["duration"] {
                if let timeInterval = durationVal as? TimeInterval {
                    duration = timeInterval
                } else if let doubleVal = durationVal as? Double {
                    duration = TimeInterval(doubleVal)
                }
            }
            
            // Calculate isShortBlock for fallback case
            let isShortBlock = (type == "blockNow" && duration != nil && duration! < 15 * 60)
            
            logger.info("Block info from array: id=\\(id), type=\\(type), duration=\\(duration?.description ?? \"none\"), isShortBlock=\\(isShortBlock)")
            return (id: id, createdAt: createdAt, duration: duration, type: type, isShortBlock: isShortBlock)
        } catch {
            logger.error("Error decoding blocks array: \(error.localizedDescription)")
            print("Error decoding blocks: \(error)")
            return (id: "", createdAt: nil, duration: nil, type: "", isShortBlock: false)
        }
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
        logger.info("sendNotification called: title=\(title)")
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
                self.logger.error("Error sending notification: \(error.localizedDescription)")
                print("Error sending notification: \(error)")
            } else {
                self.logger.info("Notification sent successfully")
            }
        }
    }
    
    // MARK: - Block Type Handlers
    
    /// Clear active block from UserDefaults (centralized cleanup)
    private func clearActiveBlockData() {
        guard let userDefaults = userDefaults else { return }
        userDefaults.removeObject(forKey: "activeBlockId")
        userDefaults.removeObject(forKey: "pausedUntil")
        userDefaults.removeObject(forKey: "activeBlockMetadata")
        userDefaults.synchronize()
        logger.info("Cleared active block data from UserDefaults")
    }
    
    /// Handle short blockNow completion (<15 min) - called from intervalWillEndWarning
    private func handleShortBlockNowCompletion() {
        logger.info("Handling short blockNow completion")
        
        if isCurrentlyPaused() {
            logger.warning("Block is paused, skipping cleanup")
            return
        }
        
        manager.removeRestrictions()
        clearActiveBlockData()
        sendNotification(title: "Focus Session Complete", body: "Your focus block has ended!")
        logger.info("Short blockNow cleanup completed")
    }
    
    /// Handle long blockNow completion (≥15 min) - called from intervalDidEnd
    private func handleLongBlockNowCompletion() {
        logger.info("Handling long blockNow completion")
        
        if isCurrentlyPaused() {
            logger.warning("Block is paused, skipping cleanup")
            return
        }
        
        manager.removeRestrictions()
        clearActiveBlockData()
        sendNotification(title: "Focus Session Complete", body: "Your focus block has ended!")
        logger.info("Long blockNow cleanup completed")
    }
    
    /// Handle scheduled block completion - called from intervalDidEnd
    private func handleScheduledBlockCompletion() {
        logger.info("Handling scheduled block completion")
        
        if isCurrentlyPaused() {
            logger.warning("Block is paused, skipping cleanup")
            return
        }
        
        manager.removeRestrictions()
        clearActiveBlockData()
        sendNotification(title: "Focus Block Ended", body: "Your scheduled block has completed!")
        logger.info("Scheduled block cleanup completed")
    }
    
    /// Handle app time limit threshold reached - called from eventDidReachThreshold
    private func handleAppTimeLimitReached() {
        logger.info("Handling app time limit threshold reached")
        
        if isCurrentlyPaused() {
            logger.warning("Block is paused, skipping threshold action")
            return
        }
        
        // App time limit uses threshold to trigger restrictions
        // Restrictions stay until intervalDidEnd
        sendNotification(title: "App Limit Reached", body: "You've reached your daily app usage limit!")
        logger.info("App time limit threshold action completed")
    }
        
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        logger.info("intervalDidStart called for activity")
        
        // Check if paused - if so, don't apply restrictions
        if isCurrentlyPaused() {
            logger.warning("Block is paused, skipping restrictions")
            print("Block is paused, skipping restrictions for \(activity)")
            return
        }
        
        // Handle the start of the interval.
        // if the threshold is 0, the eventDidReachThreshold is not be triggered correctly sometimes.
        let events = manager.getEvents(activityName: activity, details: true)
        logger.info("Found \(events.count) events for activity")
        for (_, event) in events {
            if event.threshold.hour == 0 && event.threshold.minute == 0 {
                logger.info("Applying immediate restrictions for zero threshold")
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
        logger.info("intervalDidEnd called")
        
        let (_, _, _, blockType, isShortBlock) = getActiveBlockInfo()
        logger.info("Block type: \(blockType), isShortBlock: \(isShortBlock)")
        
        // Route to appropriate handler based on block type
        switch blockType {
        case "blockNow":
            if isShortBlock {
                // Short blocks already cleaned up in intervalWillEndWarning
                logger.info("Short blockNow - already handled, skipping")
            } else {
                // Long blocks clean up here
                handleLongBlockNowCompletion()
            }
            
        case "scheduled":
            handleScheduledBlockCompletion()
            
        case "appTimeLimit":
            handleScheduledBlockCompletion() // Same cleanup as scheduled
            
        default:
            logger.warning("Unknown block type: \(blockType)")
        }
        
        logger.info("intervalDidEnd completed")
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        logger.info("eventDidReachThreshold fired")
        
        let (_, _, _, blockType, _) = getActiveBlockInfo()
        logger.info("Block type: \(blockType)")
        
        // Route to appropriate handler based on block type
        switch blockType {
        case "appTimeLimit":
            handleAppTimeLimitReached()
            
        case "blockNow":
            // blockNow uses warningTime for cleanup, not threshold
            logger.info("blockNow uses warningTime callback, ignoring threshold")
            
        default:
            logger.info("No threshold action for block type: \(blockType)")
        }
    }
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        logger.info("intervalWillStartWarning called")
        
        // Handle the warning before the interval starts.
        sendNotification(title: "Focus Block Starting Soon", body: "Your focus block will start in 1 minute")
        logger.info("intervalWillStartWarning completed")
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        logger.info("intervalWillEndWarning called")
        
        let (_, _, _, blockType, isShortBlock) = getActiveBlockInfo()
        logger.info("Block type: \(blockType), isShortBlock: \(isShortBlock)")
        
        // Only short blockNow uses this callback for cleanup
        if blockType == "blockNow" && isShortBlock {
            handleShortBlockNowCompletion()
        } else {
            // All other blocks: just send warning notification
            logger.info("Standard warning - no cleanup")
            sendNotification(title: "Focus Block Ending Soon", body: "Your focus block will end soon")
        }
        
        logger.info("intervalWillEndWarning completed")
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        logger.info("eventWillReachThresholdWarning called")
        
        // Handle the warning before the event reaches its threshold.
        sendNotification(title: "Daily Limit Warning", body: "You're approaching your usage limit!")
        logger.info("eventWillReachThresholdWarning completed")
    }
}

// Helper to decode AnyCodable values
struct AnyCodable: Codable {
    let value: Any
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intVal = try? container.decode(Int.self) {
            value = intVal
        } else if let boolVal = try? container.decode(Bool.self) {
            value = boolVal
        } else if let stringVal = try? container.decode(String.self) {
            value = stringVal
        } else if let doubleVal = try? container.decode(Double.self) {
            value = doubleVal
        } else if let dateVal = try? container.decode(Date.self) {
            value = dateVal
        } else if let dictVal = try? container.decode([String: AnyCodable].self) {
            value = dictVal
        } else if let arrayVal = try? container.decode([AnyCodable].self) {
            value = arrayVal
        } else {
            value = NSNull()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let intVal as Int:
            try container.encode(intVal)
        case let boolVal as Bool:
            try container.encode(boolVal)
        case let stringVal as String:
            try container.encode(stringVal)
        case let doubleVal as Double:
            try container.encode(doubleVal)
        case let dateVal as Date:
            try container.encode(dateVal)
        case let dictVal as [String: AnyCodable]:
            try container.encode(dictVal)
        case let arrayVal as [AnyCodable]:
            try container.encode(arrayVal)
        default:
            try container.encodeNil()
        }
    }
    

}


