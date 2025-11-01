//
//  screengateApp.swift
//  screengate
//
//  Created by gokul on 01/11/25.
//

import SwiftUI
import FamilyControls
import UserNotifications

@main
struct screengateApp: App {
    @StateObject private var deepLinkManager = DeepLinkManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(deepLinkManager)
                .onOpenURL { url in
                    deepLinkManager.handleDeepLink(url)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    deepLinkManager.handleAppBecameActive()
                }
        }
    }
}

// MARK: - App Delegate for Notification Handling
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Configure notification center
        UNUserNotificationCenter.current().delegate = self

        // Request notification authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification authorization granted")
            } else if let error = error {
                print("Notification authorization error: \(error)")
            }
        }

        return true
    }

    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    // Handle notification tap when app is in background or closed
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        handleNotificationResponse(response)
        completionHandler()
    }

    private func handleNotificationResponse(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo

        // Check if this is an intention notification
        if userInfo["intentionId"] != nil {
            handleIntentionNotification(userInfo)
            return
        }

        // Handle deep link from notification
        if let deepLinkString = userInfo["deepLinkURL"] as? String,
           let deepLinkURL = URL(string: deepLinkString) {
            // Post notification to handle deep link
            NotificationCenter.default.post(
                name: .deepLinkReceived,
                object: deepLinkURL
            )
        }
    }

    private func handleIntentionNotification(_ userInfo: [AnyHashable: Any]) {
        guard let intentionId = userInfo["intentionId"] as? String,
              let intentionName = userInfo["intentionName"] as? String,
              let appBundleId = userInfo["appBundleId"] as? String else {
            print("Invalid intention notification data")
            return
        }

        // Create deep link URL from notification data
        var components = URLComponents()
        components.scheme = "screengate"
        components.host = "intention"
        components.path = "/\(intentionId)"

        components.queryItems = [
            URLQueryItem(name: "intentionId", value: intentionId),
            URLQueryItem(name: "intentionName", value: intentionName),
            URLQueryItem(name: "category", value: userInfo["intentionCategory"] as? String),
            URLQueryItem(name: "sourceApp", value: appBundleId),
            URLQueryItem(name: "sourceAppName", value: userInfo["appName"] as? String),
            URLQueryItem(name: "isFromCategory", value: userInfo["isFromCategory"] as? String),
            URLQueryItem(name: "duration", value: userInfo["duration"] as? String)
        ]

        if let deepLinkURL = components.url {
            // Post notification to handle deep link
            NotificationCenter.default.post(
                name: .deepLinkReceived,
                object: deepLinkURL
            )
        }
    }
}

// MARK: - Deep Link Manager
@MainActor
class DeepLinkManager: ObservableObject {
    @Published var pendingDeepLink: URL?
    @Published var shouldShowIntention = false
    @Published var currentIntention: IntentionActivity?
    @Published var sourceAppInfo: SourceAppInfo?

    init() {
        // Listen for deep link notifications
        NotificationCenter.default.publisher(for: .deepLinkReceived)
            .compactMap { $0.object as? URL }
            .sink { [weak self] url in
                self?.handleDeepLink(url)
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    func handleDeepLink(_ url: URL) {
        guard url.scheme == "screengate" else {
            print("Invalid deep link scheme: \(url.scheme ?? "unknown")")
            return
        }

        print("Handling deep link: \(url)")

        switch url.host {
        case "intention":
            handleIntentionDeepLink(url)
        case "settings":
            // Handle settings deep link if needed
            print("Settings deep link received")
        default:
            print("Unknown deep link host: \(url.host ?? "unknown")")
        }
    }

    private func handleIntentionDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let intentionId = components.path.replacingOccurrences(of: "/", with: "") as String? else {
            print("Invalid intention deep link format")
            return
        }

        print("Processing intention deep link for ID: \(intentionId)")

        // Extract query parameters
        let queryItems = components.queryItems ?? []
        let intentionName = queryItems.first(where: { $0.name == "intentionName" })?.value
        let categoryString = queryItems.first(where: { $0.name == "category" })?.value
        let sourceApp = queryItems.first(where: { $0.name == "sourceApp" })?.value
        let sourceAppName = queryItems.first(where: { $0.name == "sourceAppName" })?.value
        let isFromCategoryString = queryItems.first(where: { $0.name == "isFromCategory" })?.value
        let durationString = queryItems.first(where: { $0.name == "duration" })?.value

        // Create intention activity
        if let intentionName = intentionName,
           let categoryString = categoryString,
           let _ = IntentionCategory(rawValue: categoryString),
           let durationString = durationString,
           let duration = TimeInterval(durationString) {

            let intention = createIntentionActivity(
                id: intentionId,
                name: intentionName,
                category: categoryString,
                duration: duration
            )

            let sourceInfo = SourceAppInfo(
                bundleIdentifier: sourceApp ?? "",
                appName: sourceAppName,
                isFromCategory: isFromCategoryString == "true"
            )

            // Update state
            currentIntention = intention
            sourceAppInfo = sourceInfo
            shouldShowIntention = true

            print("Intention deep link processed successfully")
            print("Intention: \(intention.id)")
            print("Source app: \(sourceInfo.appName ?? "Unknown")")
        } else {
            print("Failed to parse intention deep link parameters")
        }
    }

    private func createIntentionActivity(
        id: String,
        name: String,
        category: String,
        duration: TimeInterval
    ) -> IntentionActivity {
        // Create a basic IntentionActivity from the simplified data
        let intentionCategory: IntentionCategory
        switch category.lowercased() {
        case "breathing":
            intentionCategory = .breathing
        case "mindfulness":
            intentionCategory = .mindfulness
        case "reflection":
            intentionCategory = .reflection
        case "movement":
            intentionCategory = .movement
        case "quick break":
            intentionCategory = .quickBreak
        default:
            intentionCategory = .breathing
        }

        let content: IntentionContent
        switch intentionCategory {
        case .breathing:
            content = .breathing(BreathingContent(
                pattern: .box,
                inhaleDuration: 4,
                holdDuration: 4,
                exhaleDuration: 4,
                pauseDuration: 4,
                cycles: Int(duration / 16),
                instructions: ["Follow the breathing pattern", "Inhale for 4 counts", "Hold for 4 counts", "Exhale for 4 counts", "Pause for 4 counts"]
            ))
        case .mindfulness:
            content = .mindfulness(MindfulnessContent(
                type: .presentMoment,
                script: ["Notice your breath", "Be present in this moment"],
                backgroundSound: .none
            ))
        case .reflection:
            content = .reflection(ReflectionContent(
                type: .gratitude,
                prompts: ["Take a deep breath", "Notice your thoughts", "Be kind to yourself"],
                journalingEnabled: false
            ))
        case .movement:
            content = .movement(MovementContent(
                type: .stretching,
                exercises: [
                    MovementExercise(
                        name: "Quick Stretch",
                        description: "Take a moment to stretch and move your body",
                        duration: duration,
                        repetitions: 1,
                        imageUrl: nil
                    )
                ]
            ))
        case .quickBreak:
            content = .quickBreak(QuickBreakContent(
                type: .walkAround,
                message: "Take a quick break to refresh your mind",
                action: "Step away from your screen for a moment",
                followUpSuggestions: ["Take a few deep breaths", "Stretch your arms", "Look out a window"]
            ))
        }

        return IntentionActivity(
            id: id,
            title: name,
            description: "Mindful intention to practice before continuing",
            category: intentionCategory,
            duration: duration,
            content: content,
            difficulty: .beginner,
            tags: ["shield-triggered"],
            isCustom: false,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    func handleAppBecameActive() {
        // Clear pending deep links when app becomes active
        if pendingDeepLink != nil {
            print("Processing pending deep link on app activation")
            if let url = pendingDeepLink {
                handleDeepLink(url)
                pendingDeepLink = nil
            }
        }
    }

    func clearIntentionState() {
        shouldShowIntention = false
        currentIntention = nil
        sourceAppInfo = nil
    }
}

// MARK: - Supporting Models

struct SourceAppInfo: Codable {
    let bundleIdentifier: String
    let appName: String?
    let isFromCategory: Bool
}

// MARK: - Notification Names

extension Notification.Name {
    static let deepLinkReceived = Notification.Name("deepLinkReceived")
}

// MARK: - Required Imports

import Combine
