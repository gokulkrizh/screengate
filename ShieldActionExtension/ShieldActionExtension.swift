//
//  ShieldActionExtension.swift
//  ShieldActionExtension
//
//  Created by Gokul on 2025/11/05.
//

import ManagedSettings
import UserNotifications

/// Handles user actions on shield screens (acknowledge, emergency bypass, etc.)
class ShieldActionExtension: ShieldActionDelegate {
    
    private let sharedManager = SharedContainerManager.shared
    
    // MARK: - Action Handling
    
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handleShieldAction(action, completionHandler: completionHandler)
    }
    
    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handleShieldAction(action, completionHandler: completionHandler)
    }
    
    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handleShieldAction(action, completionHandler: completionHandler)
    }
    
    // MARK: - Private Methods
    
    private func handleShieldAction(_ action: ShieldAction, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            // User acknowledged the shield
            print("✓ Shield acknowledged - closing")
            completionHandler(.close)
            
        case .secondaryButtonPressed:
            // User requested a break
            print("⏱️ Break requested - showing break timer")
            sendBreakPermissionNotification()
            completionHandler(.close)
            
        @unknown default:
            print("⚠️ Unknown shield action")
            completionHandler(.close)
        }
    }
    
    /// Send notification allowing user to grant a break from focus session
    private func sendBreakPermissionNotification() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "Focus Club"
                content.body = "Take a break?"
                content.sound = .default
                content.badge = NSNumber(value: 1)
                content.userInfo = ["action": "requestBreak"]
                
                // Create action buttons
                let yesAction = UNNotificationAction(
                    identifier: "GRANT_BREAK",
                    title: "Grant Break",
                    options: [.foreground]
                )
                
                let noAction = UNNotificationAction(
                    identifier: "DENY_BREAK",
                    title: "Stay Focused",
                    options: .authenticationRequired
                )
                
                let category = UNNotificationCategory(
                    identifier: "BREAK_REQUEST_CATEGORY",
                    actions: [yesAction, noAction],
                    intentIdentifiers: [],
                    options: []
                )
                
                center.setNotificationCategories([category])
                content.categoryIdentifier = "BREAK_REQUEST_CATEGORY"
                
                let request = UNNotificationRequest(
                    identifier: UUID().uuidString,
                    content: content,
                    trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                )
                
                center.add(request) { error in
                    if let error = error {
                        print("❌ Error sending break notification: \(error)")
                    } else {
                        print("✓ Break notification sent")
                    }
                }
            }
        }
    }
}
