import Foundation
import UserNotifications

/// Rebuilds the rolling 7-day notification plan. Called whenever the profile or
/// an in-flight session changes. Scheduled notifications all share the `diet.`
/// identifier prefix so rebuilds can cancel exactly their own.
final class NotificationScheduler {
    static let shared = NotificationScheduler()

    private let center = UNUserNotificationCenter.current()
    private let prefix = "diet."

    /// Rebuild the plan for the current state (app-side scheduler).
    func rebuild(state: SharedState) {
        cancelScheduled()
        guard let profile = state.profile, profile.isActive else { return }

        let calendar = Calendar.current
        let now = Date()
        var requests: [UNNotificationRequest] = []

        for offset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: now)) else { continue }

            let open = calendar.date(bySettingHour: profile.eatingWindow.startHour, minute: profile.eatingWindow.startMinute, second: 0, of: day)!
            var close = calendar.date(bySettingHour: profile.eatingWindow.endHour, minute: profile.eatingWindow.endMinute, second: 0, of: day)!
            if close <= open {
                close = calendar.date(byAdding: .day, value: 1, to: close)!
            }

            let portion = profile.portionMinutes
            add(&requests, id: .kitchenOpening, at: open.addingTimeInterval(-600), title: "🍳 Kitchen opens in 10 min", body: "Your eating window starts soon.", state: state, now: now)
            add(&requests, id: .kitchenOpen, at: open, title: "Kitchen's open", body: portion > 0 ? "\(portion) min on your plate today." : "Carbs are off the menu today.", state: state, now: now)
            add(&requests, id: .kitchenClosing, at: close.addingTimeInterval(-600), title: "Kitchen closes in 10 min", body: "Wrap up your portion.", state: state, now: now)

            // Night Fast soon (premium). The morning recap is sent by the monitor
            // extension when the window opens.
            if profile.nightFast.isEnabled {
                let nightStart = calendar.date(bySettingHour: profile.nightFast.startHour, minute: profile.nightFast.startMinute, second: 0, of: day)!
                add(
                    &requests,
                    id: .nightSoon,
                    at: nightStart.addingTimeInterval(-900),
                    title: "🌙 Night Fast in 15 min",
                    body: "Wrap up — carbs and social apps are about to sleep.",
                    category: NotificationCategoryID.nightSoon,
                    route: .startFast,
                    state: state,
                    now: now
                )
            }

            // Sunday check-in at 18:00.
            if calendar.component(.weekday, from: day) == 1 {
                let six = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: day)!
                add(
                    &requests,
                    id: .sundayCheckin,
                    at: six,
                    title: "Your weekly label is ready",
                    body: "See how this week went.",
                    category: NotificationCategoryID.label,
                    route: .report,
                    state: state,
                    now: now
                )
            }
        }

        // Cheat meal ending (in-flight session; stable id so app + extension agree).
        if let cheat = state.cheat, cheat.endsAt > now {
            add(
                &requests,
                id: .cheatEnding,
                at: cheat.endsAt.addingTimeInterval(-120),
                title: "Cheat meal ends in 2 min",
                body: "Carbs go back on the shelf.",
                identifier: "\(prefix)cheat.ending.\(Int(cheat.endsAt.timeIntervalSince1970))",
                state: state,
                now: now
            )
        }

        // Trial ending is scheduled once Superwall tracks trials (Phase 5 seam).

        for request in requests {
            center.add(request)
        }
    }

    func cancelScheduled() {
        center.getPendingNotificationRequests { [weak self] requests in
            guard let self else { return }
            let ids = requests.map(\.identifier).filter { $0.hasPrefix(self.prefix) }
            if !ids.isEmpty {
                self.center.removePendingNotificationRequests(withIdentifiers: ids)
            }
        }
    }

    // MARK: - Helpers

    private func add(
        _ requests: inout [UNNotificationRequest],
        id: NotificationID,
        at date: Date,
        title: String,
        body: String,
        category: String? = nil,
        route: NotificationRoute = .kitchen,
        identifier: String? = nil,
        state: SharedState,
        now: Date
    ) {
        guard date > now, state.isNotificationEnabled(id) else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        if id.isTimeSensitive {
            content.interruptionLevel = .timeSensitive
        }
        if let category {
            content.categoryIdentifier = category
        }
        content.userInfo = [NotificationRoute.userInfoKey: route.rawValue]

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let requestID = identifier ?? "\(prefix)\(id.rawValue).\(Int(date.timeIntervalSince1970))"
        requests.append(UNNotificationRequest(identifier: requestID, content: content, trigger: trigger))
    }
}
