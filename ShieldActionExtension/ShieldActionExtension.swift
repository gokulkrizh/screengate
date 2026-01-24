//
//  ShieldActionExtension.swift
//  ShieldActionExtension
//
//  Created by Gokul on 2025/11/05.
//

import ManagedSettings
import UserNotifications
import Foundation

// Override the functions below to customize the shield actions used in various situations.
// The system provides a default response for any functions that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldActionExtension: ShieldActionDelegate {
    private var manager = DeviceActivityManager()
    private let userDefaults = UserDefaults(suiteName: "group.com.gia.screengate")
    private let jsonDecoder = JSONDecoder()

    // MARK: - Helpers
    
    /// Get active block's strict mode from UserDefaults
    private func getStrictMode() -> String {
        guard let userDefaults = userDefaults,
              let activeBlockData = userDefaults.data(forKey: "activeBlock") else {
            return "medium" // Default to medium
        }
        
        do {
            let decoded = try jsonDecoder.decode([String: AnyCodable].self, from: activeBlockData)
            let strictMode = (decoded["strictMode"] as? String) ?? "medium"
            return strictMode
        } catch {
            print("Error decoding strict mode: \(error)")
            return "medium"
        }
    }
    
    /// Check if block is currently paused
    private func isCurrentlyPaused() -> Bool {
        guard let userDefaults = userDefaults,
              let activeBlockData = userDefaults.data(forKey: "activeBlock") else {
            return false
        }
        
        do {
            let decoded = try jsonDecoder.decode([String: AnyCodable].self, from: activeBlockData)
            let pausedUntil = decoded["pausedUntil"] as? Date
            
            if let pausedUntil = pausedUntil {
                return pausedUntil > Date()
            }
            return false
        } catch {
            print("Error checking pause state: \(error)")
            return false
        }
    }
    
    /// Send notification for shield action
    private func sendNotification(title: String, body: String, withAction: Bool = false) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        if withAction {
            let action = UNNotificationAction(
                identifier: "DISMISS_ACTION",
                title: "Dismiss",
                options: [.foreground]
            )
            let category = UNNotificationCategory(
                identifier: "SHIELD_ACTION_CATEGORY",
                actions: [action],
                intentIdentifiers: [],
                options: []
            )
            UNUserNotificationCenter.current().setNotificationCategories([category])
            content.categoryIdentifier = "SHIELD_ACTION_CATEGORY"
        }
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending shield notification: \(error)")
            }
        }
    }

    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handleAction(action: action, completionHandler: completionHandler)
    }
    
    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Handle the action as needed.
        handleAction(action: action, completionHandler: completionHandler)
    }
    
    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Handle the action as needed.
        handleAction(action: action, completionHandler: completionHandler)
    }
    
    
    private func handleAction(action: ShieldAction, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        let strictMode = getStrictMode()
        let isPaused = isCurrentlyPaused()
        
        // If paused, allow access
        if isPaused {
            completionHandler(.close)
            sendNotification(title: "Pause Active", body: "Restrictions temporarily lifted during pause period")
            return
        }
        
        switch action {
        case .primaryButtonPressed:
            handlePrimaryButtonPress(with: strictMode, completionHandler: completionHandler)
            
        case .secondaryButtonPressed:
            handleSecondaryButtonPress(with: strictMode, completionHandler: completionHandler)
            
        @unknown default:
            fatalError()
        }
    }
    
    private func handlePrimaryButtonPress(with strictMode: String, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch strictMode {
        case "easy":
            // Easy mode: dismiss immediately with acknowledgment
            sendNotification(title: "Acknowledged", body: "Shield dismissed. Get back to focus!")
            completionHandler(.close)
            
        case "medium":
            // Medium mode: require confirmation - already confirmed if got here
            sendNotification(title: "Confirmed", body: "Shield will close after you verify your choice")
            completionHandler(.close)
            
        case "hard":
            // Hard mode: cannot dismiss - keep shield open
            sendNotification(
                title: "Cannot Dismiss",
                body: "Hard mode active. You cannot dismiss this shield. Wait for the block to end or contact support.",
                withAction: true
            )
            completionHandler(.none)
            
        default:
            // Default to medium behavior
            completionHandler(.close)
        }
    }
    
    private func handleSecondaryButtonPress(with strictMode: String, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch strictMode {
        case "easy":
            // Easy mode: can close without consequence
            sendNotification(title: "Shield Removed", body: "You chose to end your focus session")
            completionHandler(.close)
            
        case "medium":
            // Medium mode: send notification to ask for confirmation
            sendNotification(
                title: "Remove Restrictions?",
                body: "Tap to confirm removal of restrictions",
                withAction: true
            )
            completionHandler(.none)
            
        case "hard":
            // Hard mode: cannot remove - must wait or type forfeit
            sendNotification(
                title: "Hard Mode Active",
                body: "You cannot remove restrictions in hard mode. Wait for the session to end.",
                withAction: true
            )
            completionHandler(.none)
            
        default:
            completionHandler(.none)
        }
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

