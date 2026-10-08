import Foundation
import UserNotifications

/// Registers notification categories and routes taps into the app.
final class NotificationRouter: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationRouter()

    func registerCategories() {
        let startFast = UNNotificationAction(
            identifier: NotificationActionID.startFast,
            title: "Start fast now",
            options: []
        )
        let seeLabel = UNNotificationAction(
            identifier: NotificationActionID.seeLabel,
            title: "See my label",
            options: [.foreground]
        )

        let nightSoon = UNNotificationCategory(
            identifier: NotificationCategoryID.nightSoon,
            actions: [startFast],
            intentIdentifiers: [],
            options: []
        )
        let label = UNNotificationCategory(
            identifier: NotificationCategoryID.label,
            actions: [seeLabel],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([nightSoon, label])
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let route = (userInfo[NotificationRoute.userInfoKey] as? String)
            .flatMap(NotificationRoute.init(rawValue:)) ?? .kitchen

        switch response.actionIdentifier {
        case NotificationActionID.startFast:
            post(.startFast)
        case NotificationActionID.seeLabel:
            post(.report)
        default:
            post(route)
        }

        completionHandler()
    }

    private func post(_ route: NotificationRoute) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .dietNotificationRoute,
                object: nil,
                userInfo: ["route": route.rawValue]
            )
        }
    }
}
