//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitorExtension
//
//  Background enforcement + usage-driven notifications:
//  portion.half, portion.last5, portion.empty, streak.risk, morning.recap,
//  cheat.ending. The fixed-time notifications (kitchen.*, night.soon,
//  sunday.checkin) are scheduled by the app.
//

import DeviceActivity
import Foundation
import UserNotifications
import OSLog
import WidgetKit

class DeviceActivityMonitorExtension: DeviceActivityMonitor {

    private let manager = DeviceActivityManager()
    private let store = SharedStore.shared
    private let logger = Logger(subsystem: "com.gia.screendiet", category: "DeviceActivityMonitor")

    // MARK: - Helpers

    private func scheduleName(_ activity: DeviceActivityName) -> String? {
        let prefix = "com.gia.screendiet."
        guard activity.rawValue.hasPrefix(prefix) else {
            logger.warning("Unexpected activity: \(activity.rawValue)")
            return nil
        }
        return String(activity.rawValue.dropFirst(prefix.count))
    }

    private func parseUsageMinutes(from eventName: String) -> Int? {
        guard eventName.hasPrefix("usage-"),
              let minutes = Int(eventName.dropFirst("usage-".count)) else { return nil }
        return minutes
    }

    private func reconcile(_ state: SharedState) {
        manager.reconcile(state: state)
        // Keep widget numbers fresh; countdowns tick on their own.
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func sendNotification(
        _ id: NotificationID,
        title: String,
        body: String,
        category: String? = nil,
        route: NotificationRoute = .kitchen,
        identifier: String? = nil,
        in state: SharedState
    ) {
        guard state.isNotificationEnabled(id) else { return }

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

        UNUserNotificationCenter.current().add(
            UNNotificationRequest(
                identifier: identifier ?? "\(id.rawValue).\(UUID().uuidString)",
                content: content,
                trigger: nil
            )
        ) { error in
            if let error {
                self.logger.error("Notification error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Interval callbacks

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        logger.info("[intervalDidStart] \(activity.rawValue)")

        guard let name = scheduleName(activity) else { return }

        switch name {
        case ScheduleNames.windowWeekday, ScheduleNames.windowWeekend:
            let state = store.load()
            reconcile(state)

            // Morning recap at night end (window start).
            if state.profile?.nightFast.isEnabled == true {
                let fastedMinutes = state.profile?.nightFast.durationMinutes ?? 0
                let hours = fastedMinutes / 60
                let streakText = state.streak > 0 ? " Streak: 🔥 \(state.streak)" : ""
                sendNotification(
                    .morningRecap,
                    title: "Morning recap",
                    body: "You fasted \(hours)h.\(streakText)",
                    in: state
                )
            }

        case ScheduleNames.night:
            reconcile(store.load())

        case ScheduleNames.cheat:
            reconcile(store.load())
            scheduleCheatEnding(state: store.load())

        case ScheduleNames.fast:
            reconcile(store.load())

        case ScheduleNames.rollover:
            let updated = store.mutate { state in
                DietRules.rolloverIfNeeded(&state)
            }
            reconcile(updated)

        default:
            logger.warning("[intervalDidStart] Unknown schedule: \(name)")
        }
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        logger.info("[intervalDidEnd] \(activity.rawValue)")

        guard let name = scheduleName(activity) else { return }

        switch name {
        case ScheduleNames.cheat:
            let updated = store.mutate { state in state.cheat = nil }
            reconcile(updated)

        case ScheduleNames.fast:
            let updated = store.mutate { state in state.fast = nil }
            reconcile(updated)

        case ScheduleNames.windowWeekday, ScheduleNames.windowWeekend, ScheduleNames.night:
            reconcile(store.load())

        default:
            break
        }
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        logger.info("[eventDidReachThreshold] \(event.rawValue) in \(activity.rawValue)")

        guard scheduleName(activity) == ScheduleNames.windowWeekday || scheduleName(activity) == ScheduleNames.windowWeekend,
              let usageMinutes = parseUsageMinutes(from: event.rawValue) else { return }

        let previous = store.load()
        let previousMinutes = previous.counters.carbMinutes

        let updated = store.mutate { state in
            state.counters.carbMinutes = max(state.counters.carbMinutes, usageMinutes)
            if let portion = state.profile?.portionMinutes,
               portion > 0,
               usageMinutes >= portion {
                state.counters.portionHit = true
            }
        }
        reconcile(updated)

        guard let portion = updated.profile?.portionMinutes, portion > 0 else { return }

        // Half portion crossed?
        if previousMinutes < portion / 2, usageMinutes >= portion / 2, usageMinutes < portion {
            let remaining = max(0, portion - usageMinutes)
            sendNotification(
                .portionHalf,
                title: "Half your plate's gone",
                body: "\(remaining) min of carbs left.",
                in: updated
            )
        }

        // Streak risk at 80% (approximates the plan's window-end check).
        if previousMinutes < portion * 8 / 10,
           usageMinutes >= portion * 8 / 10,
           usageMinutes < portion,
           updated.streak > 0 {
            sendNotification(
                .streakRisk,
                title: "Streak at risk",
                body: "Stay under to keep your 🔥 \(updated.streak) streak.",
                in: updated
            )
        }

        // Plate's empty.
        if usageMinutes == portion {
            sendNotification(
                .portionEmpty,
                title: "Plate's empty",
                body: "Back tomorrow 🍽️",
                category: NotificationCategoryID.label,
                route: .report,
                in: updated
            )
        }
    }

    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)

        guard scheduleName(activity) == ScheduleNames.windowWeekday || scheduleName(activity) == ScheduleNames.windowWeekend,
              let usageMinutes = parseUsageMinutes(from: event.rawValue) else { return }

        let state = store.load()
        if usageMinutes == state.profile?.portionMinutes {
            sendNotification(
                .portionLast5,
                title: "Last bites",
                body: "About 5 minutes of carbs left.",
                in: state
            )
        }
    }

    // MARK: - Cheat ending

    /// Schedule the "cheat ends in 2 min" notification from the extension too,
    /// so shield-started cheat meals are covered even if the app never runs.
    private func scheduleCheatEnding(state: SharedState) {
        guard let cheat = state.cheat, cheat.endsAt > Date() else { return }
        guard state.isNotificationEnabled(.cheatEnding) else { return }

        let content = UNMutableNotificationContent()
        content.title = "Cheat meal ends in 2 min"
        content.body = "Carbs go back on the shelf."
        content.sound = .default

        let fireDate = cheat.endsAt.addingTimeInterval(-120)
        guard fireDate > Date() else { return }

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        // Same identifier the app uses, so the two never double-fire.
        let identifier = "diet.cheat.ending.\(Int(cheat.endsAt.timeIntervalSince1970))"

        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        )
    }
}
