import ManagedSettings
import FamilyControls
import UserNotifications
import UIKit
import Foundation

// Use NSLog for shield extension logging
func shieldLog(_ message: String) {
    NSLog("[ShieldAction] \(message)")
}

// MARK: - Shield Action Data Manager
class ShieldActionDataManager {
    static let shared = ShieldActionDataManager()

    let sharedDefaults = UserDefaults(suiteName: "group.com.gia.screengate")
    private let metadataKey = "ShieldMetadata"
    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Metadata Retrieval
    func getShieldMetadata(for bundleIdentifier: String) -> ShieldMetadata? {
        // First try to get from ShieldMetadata (created by ShieldConfigurationExtension)
        if let data = sharedDefaults?.data(forKey: metadataKey),
           let allMetadata = try? JSONDecoder().decode([String: ShieldMetadata].self, from: data),
           let metadata = allMetadata[bundleIdentifier] {
            return metadata
        }

        // Fallback: Create metadata from SavedRestrictions (created by ScreenTimeService)
        if let data = sharedDefaults?.data(forKey: "SavedRestrictions"),
           let restrictions = try? JSONDecoder().decode([SimpleRestriction].self, from: data),
           let restriction = restrictions.first(where: { $0.bundleIdentifier == bundleIdentifier }) {

            return ShieldMetadata(
                bundleIdentifier: restriction.bundleIdentifier,
                appName: restriction.appName,
                selectedIntention: IntentionInfo(
                    id: restriction.intentionId,
                    name: restriction.intentionName,
                    category: restriction.intentionCategory,
                    duration: restriction.intentionDuration
                )
            )
        }

        return nil
    }
}

// MARK: - Enhanced Shield Action Extension
class ShieldActionExtension: ShieldActionDelegate {

    private let dataManager = ShieldActionDataManager.shared

    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        let bundleIdentifier = String(describing: application)

        shieldLog("🛡️ SHIELD ACTION TRIGGERED for app: \(bundleIdentifier)")
        shieldLog("🛡️ Action type: \(action)")
        shieldLog("🛡️ Timestamp: \(Date())")

        switch action {
        case .primaryButtonPressed:
            shieldLog("🔵 PRIMARY BUTTON PRESSED - Continue to App")
            handlePrimaryButtonPress(for: bundleIdentifier, completionHandler: completionHandler)
        case .secondaryButtonPressed:
            shieldLog("🟢 SECONDARY BUTTON PRESSED - Start Intention")
            handleSecondaryButtonPress(for: bundleIdentifier, completionHandler: completionHandler)
        default:
            shieldLog("❌ Unknown shield action received: \(String(describing: action))")
            completionHandler(.defer)
        }
    }

    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        let domain = String(describing: webDomain)

        shieldLog("🛡️ Shield action received for web domain: \(domain)")

        switch action {
        case .primaryButtonPressed:
            shieldLog("🔵 Primary button pressed for web domain")
            sendSimpleNotification(title: "ScreenGate Focus Mode", body: "You stayed strong! Continuing to website")
            completionHandler(.close)
        case .secondaryButtonPressed:
            shieldLog("🟢 Secondary button pressed for web domain")
            sendSimpleNotification(title: "ScreenGate Intention Started", body: "Starting mindfulness exercise for website access")
            completionHandler(.close)
        default:
            shieldLog("❌ Unknown shield action received for web domain")
            completionHandler(.defer)
        }
    }

    // MARK: - Button Action Handlers
    private func handlePrimaryButtonPress(
        for identifier: String,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        shieldLog("🔵 HANDLING PRIMARY BUTTON PRESS")
        shieldLog("🔵 Identifier: \(identifier)")
        shieldLog("🔵 Response: CLOSE (will close shield)")

        // Save interaction data for main app to process
        saveShieldInteraction(for: identifier, action: "continue_to_app")

        // Send simple notification that works
        sendSimpleNotification(title: "ScreenGate Focus Mode", body: "You stayed strong! Continuing to app")

        completionHandler(.close)
    }

    private func handleSecondaryButtonPress(
        for identifier: String,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        shieldLog("🟢 HANDLING SECONDARY BUTTON PRESS")
        shieldLog("🟢 Identifier: \(identifier)")
        shieldLog("🟢 Starting intention flow")

        // Get shield metadata for intention information
        guard let metadata = dataManager.getShieldMetadata(for: identifier) else {
            shieldLog("❌ No shield metadata found for identifier: \(identifier)")
            shieldLog("🟢 FALLBACK: Using generic notification")

            // Save interaction data anyway
            saveShieldInteraction(for: identifier, action: "start_intention")
            sendSimpleNotification(title: "ScreenGate Intention Started", body: "Starting your mindfulness exercise")
            completionHandler(.close)
            return
        }

        shieldLog("🟢 Found metadata for \(metadata.appName ?? "unknown app")")
        shieldLog("🟢 Selected intention: \(metadata.selectedIntention?.name ?? "none")")

        // Save shield interaction for main app to process
        saveShieldInteraction(for: identifier, metadata: metadata)

        // Send intention notification with specific details
        if let intention = metadata.selectedIntention {
            sendSimpleNotification(
                title: "ScreenGate Intention Started",
                body: "Starting '\(intention.name)' to continue to \(metadata.appName ?? "the app")",
                intentionInfo: intention,
                appBundleId: metadata.bundleIdentifier
            )
        } else {
            sendSimpleNotification(title: "ScreenGate Intention Started", body: "Starting your mindfulness exercise")
        }

        shieldLog("🟢 Response: CLOSE (will close shield)")
        completionHandler(.close)
    }

    private func saveShieldInteraction(for identifier: String, metadata: ShieldMetadata) {
        let interactionData: [String: Any] = [
            "appBundleId": metadata.bundleIdentifier,
            "appName": metadata.appName ?? "",
            "intentionId": metadata.selectedIntention?.id ?? "",
            "intentionName": metadata.selectedIntention?.name ?? "",
            "intentionCategory": metadata.selectedIntention?.category ?? "",
            "intentionDuration": metadata.selectedIntention?.duration ?? 0,
            "timestamp": Date().timeIntervalSince1970,
            "action": "start_intention"
        ]

        // Save to shared UserDefaults for main app to detect
        dataManager.sharedDefaults?.set(interactionData, forKey: "PendingShieldInteraction")
        dataManager.sharedDefaults?.synchronize()

        shieldLog("💾 Saved shield interaction for main app: \(metadata.appName ?? "")")
    }

    private func saveShieldInteraction(for identifier: String, action: String) {
        let interactionData: [String: Any] = [
            "appBundleId": identifier,
            "appName": getAppName(from: identifier),
            "timestamp": Date().timeIntervalSince1970,
            "action": action
        ]

        // Save to shared UserDefaults for main app to detect
        dataManager.sharedDefaults?.set(interactionData, forKey: "PendingShieldInteraction")
        dataManager.sharedDefaults?.synchronize()

        shieldLog("💾 Saved shield interaction for main app: \(getAppName(from: identifier))")
    }

    private func sendSimpleNotification(title: String, body: String, intentionInfo: IntentionInfo? = nil, appBundleId: String? = nil) {
        shieldLog("🔔 Sending simple notification...")

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = [
            "type": "shield_interaction",
            "timestamp": Date().timeIntervalSince1970
        ]

        // Add intention-specific user info and actions if intention is provided
        if let intention = intentionInfo, let bundleId = appBundleId {
            content.userInfo["intentionId"] = intention.id
            content.userInfo["intentionName"] = intention.name
            content.userInfo["intentionCategory"] = intention.category
            content.userInfo["intentionDuration"] = String(intention.duration)
            content.userInfo["appBundleId"] = bundleId
            content.userInfo["sourceApp"] = bundleId
            content.userInfo["sourceAppName"] = getAppName(from: bundleId)
            content.userInfo["isFromCategory"] = "false"
            content.userInfo["deepLinkURL"] = "screengate://intention/\(intention.id)?intentionId=\(intention.id)&intentionName=\(intention.name)&category=\(intention.category)&sourceApp=\(bundleId)&sourceAppName=\(getAppName(from: bundleId))&isFromCategory=false&duration=\(String(intention.duration))"

            // Add CTA actions for intention notifications
            let startAction = UNNotificationAction(
                identifier: "START_INTENTION",
                title: "Start '\(intention.name)'",
                options: [.foreground]
            )

            let laterAction = UNNotificationAction(
                identifier: "START_LATER",
                title: "Start Later",
                options: []
            )

            let category = UNNotificationCategory(
                identifier: "INTENTION_NOTIFICATION",
                actions: [startAction, laterAction],
                intentIdentifiers: [],
                options: .customDismissAction
            )

            content.categoryIdentifier = "INTENTION_NOTIFICATION"
            UNUserNotificationCenter.current().setNotificationCategories([category])
        } else {
            content.categoryIdentifier = "SHIELD_INTERACTION"
        }

        // Trigger immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "shield-notification-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                shieldLog("❌ Failed to send shield notification: \(error.localizedDescription)")
            } else {
                shieldLog("✅ Shield notification sent successfully!")
            }
        }
    }

    private func getAppName(from bundleIdentifier: String) -> String {
        // Extract app name from bundle identifier
        let components = bundleIdentifier.components(separatedBy: ".")
        return components.last ?? bundleIdentifier
    }
}

// MARK: - Shield Metadata Model (Matching Shield Configuration)
struct ShieldMetadata: Codable {
    let bundleIdentifier: String
    let appName: String?
    let category: String?
    let selectedIntention: IntentionInfo?
    let timestamp: Date
    let isFromCategory: Bool

    init(
        bundleIdentifier: String,
        appName: String? = nil,
        category: String? = nil,
        selectedIntention: IntentionInfo? = nil,
        isFromCategory: Bool = false
    ) {
        self.bundleIdentifier = bundleIdentifier
        self.appName = appName
        self.category = category
        self.selectedIntention = selectedIntention
        self.timestamp = Date()
        self.isFromCategory = isFromCategory
    }
}

// MARK: - Simplified Intention Model
struct IntentionInfo: Codable {
    let id: String
    let name: String
    let category: String
    let duration: TimeInterval
}

// MARK: - Simplified Restriction Model for Shield Extension
struct SimpleRestriction: Codable {
    let bundleIdentifier: String
    let appName: String
    let intentionId: String
    let intentionName: String
    let intentionCategory: String
    let intentionDuration: TimeInterval
}
