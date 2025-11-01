import Foundation
import UserNotifications
import FamilyControls
import Combine

@MainActor
class NotificationService: NSObject, ObservableObject {

    // MARK: - Published Properties
    @Published var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined
    @Published var isNotificationAuthorized = false

    // MARK: - Private Properties
    private let notificationCenter = UNUserNotificationCenter.current()
    private var screenTimeService: ScreenTimeService

    // MARK: - Notification Identifiers
    private let intentionNotificationIdentifier = "com.gia.screengate.intention"
    private let restrictionStartIdentifier = "com.gia.screengate.restriction.start"
    private let restrictionEndIdentifier = "com.gia.screengate.restriction.end"
    private let reminderIdentifier = "com.gia.screengate.reminder"

    // MARK: - Shared Instance
    static let shared = NotificationService()

    @MainActor
    init(screenTimeService: ScreenTimeService = .shared) {
        self.screenTimeService = screenTimeService
        super.init()
        notificationCenter.delegate = self
        checkNotificationPermissions()
    }

    // MARK: - Permission Management

    /// Request notification permissions
    func requestNotificationPermissions() async throws {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]

        let granted = try await notificationCenter.requestAuthorization(options: options)

        DispatchQueue.main.async {
            self.notificationPermissionStatus = granted ? .authorized : .denied
            self.isNotificationAuthorized = granted
        }

        if !granted {
            throw NotificationError.permissionDenied
        }
    }

    /// Check current notification permission status
    func checkNotificationPermissions() {
        Task {
            let settings = await notificationCenter.notificationSettings()
            DispatchQueue.main.async {
                self.notificationPermissionStatus = settings.authorizationStatus
                self.isNotificationAuthorized = (settings.authorizationStatus == .authorized)
            }
        }
    }

    // MARK: - Intention Notifications

    /// Send intention notification when shield is triggered
    func sendIntentionNotification(
        appName: String,
        appBundleIdentifier: String,
        intentionType: String = "mindfulness"
    ) {
        let content = UNMutableNotificationContent()
        content.title = "Mindful Pause Required"
        content.body = "Take a moment to reflect before opening \(appName)"
        content.sound = .default
        content.userInfo = [
            "type": "intention",
            "appName": appName,
            "appBundleIdentifier": appBundleIdentifier,
            "intentionType": intentionType,
            "timestamp": Date().timeIntervalSince1970
        ]

        // Create deep link to intention screen
        content.targetContentIdentifier = "screengate://intention"

        // Configure trigger (immediate)
        let request = UNNotificationRequest(
            identifier: "\(intentionNotificationIdentifier).\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule intention notification: \(error)")
            } else {
                print("Intention notification scheduled successfully")
            }
        }
    }

    /// Send notification when restrictions start
    func sendRestrictionStartNotification(restrictionName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Restrictions Active"
        content.body = "Screen Time restrictions for \(restrictionName) are now active"
        content.sound = .default
        content.userInfo = [
            "type": "restrictionStart",
            "restrictionName": restrictionName
        ]

        let request = UNNotificationRequest(
            identifier: "\(restrictionStartIdentifier).\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )

        notificationCenter.add(request)
    }

    /// Send notification when restrictions end
    func sendRestrictionEndNotification(restrictionName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Restrictions Lifted"
        content.body = "Screen Time restrictions for \(restrictionName) have ended"
        content.sound = .default
        content.userInfo = [
            "type": "restrictionEnd",
            "restrictionName": restrictionName
        ]

        let request = UNNotificationRequest(
            identifier: "\(restrictionEndIdentifier).\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )

        notificationCenter.add(request)
    }

    // MARK: - Scheduled Notifications

    /// Schedule intention reminder notifications
    func scheduleIntentionReminder(
        title: String,
        body: String,
        scheduledTime: Date,
        intentionType: String
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = [
            "type": "reminder",
            "intentionType": intentionType
        ]

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: scheduledTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "\(reminderIdentifier).\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule reminder notification: \(error)")
            } else {
                print("Reminder notification scheduled for \(scheduledTime)")
            }
        }
    }

    /// Schedule daily intention check-in
    func scheduleDailyCheckIn(at time: DateComponents) {
        let content = UNMutableNotificationContent()
        content.title = "Daily Mindful Check-in"
        content.body = "How are you feeling today? Take a moment for yourself."
        content.sound = .default
        content.userInfo = [
            "type": "dailyCheckIn"
        ]

        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)

        let request = UNNotificationRequest(
            identifier: "dailyCheckIn",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule daily check-in: \(error)")
            } else {
                print("Daily check-in scheduled")
            }
        }
    }

    // MARK: - Notification Management

    /// Cancel specific notification
    func cancelNotification(identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    /// Cancel all notifications
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        print("All notifications cancelled")
    }

    /// Get pending notifications
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }

    // MARK: - Deep Link Handling

    /// Handle notification tap and navigate to appropriate screen
    func handleNotificationTap(_ response: UNNotificationResponse) -> DeepLinkDestination? {
        let userInfo = response.notification.request.content.userInfo
        guard let type = userInfo["type"] as? String else {
            return nil
        }

        switch type {
        case "intention":
            if let appName = userInfo["appName"] as? String,
               let appBundleIdentifier = userInfo["appBundleIdentifier"] as? String,
               let intentionType = userInfo["intentionType"] as? String {
                return .intention(
                    appName: appName,
                    appBundleIdentifier: appBundleIdentifier,
                    intentionType: intentionType
                )
            }
        case "dailyCheckIn":
            return .intentionLibrary
        case "reminder":
            if let intentionType = userInfo["intentionType"] as? String {
                return .intention(
                    appName: "Reminder",
                    appBundleIdentifier: "",
                    intentionType: intentionType
                )
            }
        default:
            return nil
        }

        return nil
    }

    // MARK: - Helper Methods

    /// Generate personalized notification content based on user preferences
    private func generatePersonalizedContent(
        for intentionType: String,
        appName: String
    ) -> (title: String, body: String) {
        switch intentionType.lowercased() {
        case "breathing":
            return (
                "🫁 Breathing Exercise",
                "Take a deep breath before opening \(appName)"
            )
        case "mindfulness":
            return (
                "🧘 Mindful Moment",
                "Pause and be present before using \(appName)"
            )
        case "reflection":
            return (
                "💭 Quick Reflection",
                "Take a moment to reflect before \(appName)"
            )
        case "movement":
            return (
                "🤸 Quick Movement",
                "Stretch and move before \(appName)"
            )
        default:
            return (
                "✨ Mindful Pause",
                "Take a moment before opening \(appName)"
            )
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification tap here if needed
        // The actual navigation will be handled by the app's deep link system
        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
}

// MARK: - Deep Link Destination

enum DeepLinkDestination {
    case intention(appName: String, appBundleIdentifier: String, intentionType: String)
    case intentionLibrary
    case settings
    case restrictions
}

// MARK: - Error Types

enum NotificationError: LocalizedError {
    case permissionDenied
    case schedulingFailed
    case invalidContent

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Notification permission was denied. Please enable notifications in Settings."
        case .schedulingFailed:
            return "Failed to schedule notification."
        case .invalidContent:
            return "Invalid notification content."
        }
    }
}