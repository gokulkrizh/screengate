//
//  ShieldActionExtension.swift
//  ShieldActionExtension
//
//  Created by gokul on 01/11/25.
//

import ManagedSettings
import FamilyControls
import UserNotifications
import UIKit

// MARK: - Shield Action Data Manager
class ShieldActionDataManager {
    static let shared = ShieldActionDataManager()

    private let sharedDefaults = UserDefaults(suiteName: "group.com.gia.screengate")
    private let metadataKey = "ShieldMetadata"
    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Metadata Retrieval
    func getShieldMetadata(for bundleIdentifier: String) -> ShieldMetadata? {
        guard let data = sharedDefaults?.data(forKey: metadataKey),
              let allMetadata = try? JSONDecoder().decode([String: ShieldMetadata].self, from: data) else {
            return nil
        }
        return allMetadata[bundleIdentifier]
    }

    // MARK: - Notification Management
    func requestNotificationAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func sendIntentionNotification(for metadata: ShieldMetadata, completion: @escaping (Bool) -> Void) {
        guard let intention = metadata.selectedIntention else {
            print("No intention found in shield metadata")
            completion(false)
            return
        }

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "ScreenGate Intention Ready"
        content.body = "Complete '\(intention.name)' to continue to \(metadata.appName ?? "the app")"
        content.sound = .default
        content.categoryIdentifier = "INTENTION_NOTIFICATION"
        content.userInfo = [
            "intentionId": intention.id,
            "intentionName": intention.name,
            "intentionCategory": intention.category,
            "appBundleId": metadata.bundleIdentifier,
            "appName": metadata.appName ?? "",
            "isFromCategory": metadata.isFromCategory.description,
            "timestamp": Date().timeIntervalSince1970
        ]

        // Create deep link URL
        let deepLinkURL = createDeepLinkURL(for: metadata, intention: intention)
        content.userInfo["deepLinkURL"] = deepLinkURL?.absoluteString

        // Create trigger (immediate)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // Create notification request
        let request = UNNotificationRequest(
            identifier: "intention-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        // Schedule notification
        notificationCenter.add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to schedule intention notification: \(error)")
                    completion(false)
                } else {
                    print("Intention notification scheduled successfully")
                    completion(true)
                }
            }
        }
    }

    func sendUsageAnalyticsNotification(for metadata: ShieldMetadata, action: ShieldAction) {
        let content = UNMutableNotificationContent()
        content.title = "ScreenGate Usage Tracked"
        content.body = "You attempted to open \(metadata.appName ?? "an app") but chose an alternative path"
        content.sound = .default
        content.userInfo = [
            "appBundleId": metadata.bundleIdentifier,
            "action": action.rawValue,
            "timestamp": Date().timeIntervalSince1970
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "analytics-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule analytics notification: \(error)")
            } else {
                print("Analytics notification scheduled successfully")
            }
        }
    }

    // MARK: - Deep Link Creation
    private func createDeepLinkURL(for metadata: ShieldMetadata, intention: IntentionInfo) -> URL? {
        var components = URLComponents()
        components.scheme = "screengate"
        components.host = "intention"
        components.path = "/\(intention.id)"

        components.queryItems = [
            URLQueryItem(name: "intentionId", value: intention.id),
            URLQueryItem(name: "intentionName", value: intention.name),
            URLQueryItem(name: "category", value: intention.category),
            URLQueryItem(name: "sourceApp", value: metadata.bundleIdentifier),
            URLQueryItem(name: "sourceAppName", value: metadata.appName),
            URLQueryItem(name: "isFromCategory", value: metadata.isFromCategory.description),
            URLQueryItem(name: "duration", value: String(intention.duration))
        ]

        return components.url
    }
}

// MARK: - Enhanced Shield Action Extension
class ShieldActionExtension: ShieldActionDelegate {

    private let dataManager = ShieldActionDataManager.shared

    // MARK: - Application Shield Actions
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        let bundleIdentifier = String(describing: application)

        print("Shield action received for app: \(bundleIdentifier)")

        switch action {
        case .primaryButtonPressed:
            handlePrimaryButtonPress(for: bundleIdentifier, completionHandler: completionHandler)
        case .secondaryButtonPressed:
            handleSecondaryButtonPress(for: bundleIdentifier, completionHandler: completionHandler)
        default:
            print("Unknown shield action received: \(action)")
            completionHandler(.defer)
        }
    }

    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        let domain = String(describing: webDomain)

        print("Shield action received for web domain: \(domain)")

        switch action {
        case .primaryButtonPressed:
            handlePrimaryButtonPress(for: domain, isWebDomain: true, completionHandler: completionHandler)
        case .secondaryButtonPressed:
            handleSecondaryButtonPress(for: domain, isWebDomain: true, completionHandler: completionHandler)
        default:
            print("Unknown shield action received for web domain")
            completionHandler(.defer)
        }
    }

    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        let categoryId = String(describing: category)

        print("Shield action received for category: \(categoryId)")

        switch action {
        case .primaryButtonPressed:
            handlePrimaryButtonPress(for: categoryId, isCategory: true, completionHandler: completionHandler)
        case .secondaryButtonPressed:
            handleSecondaryButtonPress(for: categoryId, isCategory: true, completionHandler: completionHandler)
        default:
            print("Unknown shield action received for category")
            completionHandler(.defer)
        }
    }

    // MARK: - Button Action Handlers
    private func handlePrimaryButtonPress(
        for identifier: String,
        isWebDomain: Bool = false,
        isCategory: Bool = false,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        // Get shield metadata
        guard let metadata = dataManager.getShieldMetadata(for: identifier) else {
            print("No shield metadata found for identifier: \(identifier)")
            completionHandler(.defer)
            return
        }

        print("Primary button pressed - sending intention notification")
        print("Selected intention: \(metadata.selectedIntention?.name ?? "Unknown")")

        // Request notification authorization if needed
        dataManager.requestNotificationAuthorization { [weak self] granted in
            if granted {
                // Send intention notification
                self?.dataManager.sendIntentionNotification(for: metadata) { success in
                    if success {
                        print("Intention notification sent successfully")
                    } else {
                        print("Failed to send intention notification")
                    }
                    completionHandler(.close)
                }
            } else {
                print("Notification authorization denied")
                completionHandler(.close)
            }
        }
    }

    private func handleSecondaryButtonPress(
        for identifier: String,
        isWebDomain: Bool = false,
        isCategory: Bool = false,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        // Get shield metadata for analytics
        guard let metadata = dataManager.getShieldMetadata(for: identifier) else {
            print("No shield metadata found for identifier: \(identifier)")
            completionHandler(.defer)
            return
        }

        print("Secondary button pressed - allowing app access")
        print("User chose to continue to \(metadata.appName ?? "the app")")

        // Send analytics notification for usage tracking
        dataManager.sendUsageAnalyticsNotification(for: metadata, action: .secondaryButtonPressed)

        // Allow app access
        completionHandler(.defer)
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

// MARK: - Extension Additions
extension Bool {
    var description: String {
        return self ? "true" : "false"
    }
}
