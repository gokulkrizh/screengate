//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitorExtension
//
//  Created by Gokul on 2025/11/05.
//

import DeviceActivity
import Foundation
import UserNotifications

// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private var manager = DeviceActivityManager()
    private let userDefaults = UserDefaults(suiteName: "group.com.gia.screengate")
    private let jsonDecoder = JSONDecoder()
    
    // MARK: - Helpers
    
    /// Read active block from UserDefaults
    private func getActiveBlock() -> (id: String, isPaused: Bool, pausedUntil: Date?) {
        guard let userDefaults = userDefaults,
              let activeBlockData = userDefaults.data(forKey: "activeBlock") else {
            return (id: "", isPaused: false, pausedUntil: nil)
        }
        
        do {
            let decoded = try jsonDecoder.decode([String: AnyCodable].self, from: activeBlockData)
            let id = (decoded["id"] as? String) ?? ""
            let isPaused = (decoded["isPaused"] as? Bool) ?? false
            let pausedUntil = (decoded["pausedUntil"] as? Date)
            
            return (id: id, isPaused: isPaused, pausedUntil: pausedUntil)
        } catch {
            print("Error decoding active block: \(error)")
            return (id: "", isPaused: false, pausedUntil: nil)
        }
    }
    
    /// Check if block is currently paused (pausedUntil > now)
    private func isCurrentlyPaused() -> Bool {
        let (_, _, pausedUntil) = getActiveBlock()
        guard let pausedUntil = pausedUntil else { return false }
        return pausedUntil > Date()
    }
    
    /// Send notification for block event
    private func sendNotification(title: String, body: String) {
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
                print("Error sending notification: \(error)")
            }
        }
    }
        
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        // Check if paused - if so, don't apply restrictions
        if isCurrentlyPaused() {
            print("Block is paused, skipping restrictions for \(activity)")
            return
        }
        
        // Handle the start of the interval.
        // if the threshold is 0, the eventDidReachThreshold is not be triggered correctly sometimes.
        let events = manager.getEvents(activityName: activity, details: true)
        for (_, event) in events {
            if event.threshold.hour == 0 && event.threshold.minute == 0 {
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
        
        // Handle the end of the interval.
        manager.removeRestrictions()
        sendNotification(title: "Focus Block Ended", body: "Your focus session has completed!")
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        // Check if paused - if so, don't apply restrictions
        if isCurrentlyPaused() {
            print("Block is paused, skipping threshold restrictions for \(activity)")
            return
        }
        
        // Handle the event reaching its threshold.
        let events = manager.getEvents(activityName: activity, details: true)
        guard let event = events[event] else {
            return
        }
        manager.applyImmediateRestrictions(
            applicationTokens: event.applications,
            categoryTokens: event.categories,
            webDomainTokens: event.webDomains
        )
        
        sendNotification(title: "Daily Limit Reached", body: "You've reached your usage limit for this app!")
    }
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        
        // Handle the warning before the interval starts.
        sendNotification(title: "Focus Block Starting Soon", body: "Your focus block will start in 1 minute")
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        
        // Handle the warning before the interval ends.
        sendNotification(title: "Focus Block Ending Soon", body: "Your focus block will end in 1 minute")
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        
        // Handle the warning before the event reaches its threshold.
        sendNotification(title: "Daily Limit Warning", body: "You're approaching your usage limit!")
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


