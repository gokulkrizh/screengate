//
//  ShieldActionExtension.swift
//  ShieldActionExtension
//
//  Created by Gokul on 2025/11/05.
//

import ManagedSettings
import UserNotifications

// Override the functions below to customize the shield actions used in various situations.
// The system provides a default response for any functions that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldActionExtension: ShieldActionDelegate {
    private var manager = DeviceActivityManager()

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
        switch action {
        case .primaryButtonPressed:
            completionHandler(.close)
        case .secondaryButtonPressed:
            manager.removeRestrictions()
            sendRestrictionRemovedNotification()
            completionHandler(.none)
        @unknown default:
            fatalError()
        }

    }

    private func sendRestrictionRemovedNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "ScreenGate"
                content.body = "Restrictions have been removed. Tap to view details!"
                content.sound = .default
                content.userInfo = ["showRestrictionLiftedView": true]

                // Set up a custom action button
                let openAppAction = UNNotificationAction(
                    identifier: "OPEN_RESTRICTION_LIFTED",
                    title: "View Break Time",
                    options: [.foreground]
                )

                let category = UNNotificationCategory(
                    identifier: "RESTRICTION_LIFTED_CATEGORY",
                    actions: [openAppAction],
                    intentIdentifiers: [],
                    options: []
                )

                center.setNotificationCategories([category])
                content.categoryIdentifier = "RESTRICTION_LIFTED_CATEGORY"

                let request = UNNotificationRequest(
                    identifier: UUID().uuidString,
                    content: content,
                    trigger: nil
                )

                center.add(request) { error in
                    if let error = error {
                        print("Error showing restriction removed notification: \(error)")
                    } else {
                        print("Notification sent successfully")
                    }
                }
            } else if let error = error {
                print("Error requesting notification authorization: \(error)")
            }
        }
    }

}
