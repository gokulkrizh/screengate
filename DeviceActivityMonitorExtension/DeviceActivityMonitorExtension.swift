//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitorExtension
//
//  Background enforcement: applies the named stores from SharedState on every
//  interval/threshold callback and records approximate usage.
//

import DeviceActivity
import Foundation
import UserNotifications
import OSLog

class DeviceActivityMonitorExtension: DeviceActivityMonitor {

    private let manager = DeviceActivityManager()
    private let store = SharedStore.shared
    private let logger = Logger(subsystem: "com.gia.screendiet", category: "DeviceActivityMonitor")

    // MARK: - Helpers

    /// Extract the short schedule name from a DeviceActivityName.
    private func scheduleName(_ activity: DeviceActivityName) -> String? {
        let prefix = "com.gia.screendiet."
        guard activity.rawValue.hasPrefix(prefix) else {
            logger.warning("Unexpected activity: \(activity.rawValue)")
            return nil
        }
        return String(activity.rawValue.dropFirst(prefix.count))
    }

    /// Parse "usage-5" -> 5.
    private func parseUsageMinutes(from eventName: String) -> Int? {
        guard eventName.hasPrefix("usage-"),
              let minutes = Int(eventName.dropFirst("usage-".count)) else { return nil }
        return minutes
    }

    private func reconcile(_ state: SharedState) {
        manager.reconcile(state: state)
    }

    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
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
            // Kitchen opens — carbs unblocked (unless a portion was already hit).
            let state = store.load()
            reconcile(state)
            if let portion = state.profile?.portionMinutes, portion > 0 {
                sendNotification(title: "Kitchen Open", body: "Your carb window is open — \(portion) min on your plate.")
            }

        case ScheduleNames.night:
            let state = store.load()
            reconcile(state)
            if let end = state.profile?.nightFast.endTimeString {
                sendNotification(title: "Night Fast", body: "Carbs and social apps are blocked until \(end).")
            }

        case ScheduleNames.cheat:
            // Cheat meal started — lift the carbs block.
            reconcile(store.load())

        case ScheduleNames.fast:
            // Fast Now started — block carbs + fats.
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
            sendNotification(title: "Cheat Meal Over", body: "Back on plan — carbs are blocked again.")

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

        let updated = store.mutate { state in
            state.counters.carbMinutes = max(state.counters.carbMinutes, usageMinutes)
            if let portion = state.profile?.portionMinutes,
               portion > 0,
               usageMinutes >= portion {
                state.counters.portionHit = true
            }
        }
        reconcile(updated)

        if let portion = updated.profile?.portionMinutes, usageMinutes == portion {
            sendNotification(
                title: "Plate's Empty",
                body: "You've used your \(portion) min of carbs. See you tomorrow 🍽️"
            )
        }
    }

    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        logger.info("[intervalWillStartWarning] \(activity.rawValue)")

        switch scheduleName(activity) {
        case ScheduleNames.windowWeekday, ScheduleNames.windowWeekend:
            sendNotification(title: "Kitchen Opening Soon", body: "Your carb window opens in 10 minutes.")
        case ScheduleNames.night:
            sendNotification(title: "Night Fast Soon", body: "Night Fast starts in 15 minutes. Wrap up.")
        default:
            break
        }
    }

    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        logger.info("[intervalWillEndWarning] \(activity.rawValue)")

        if scheduleName(activity) == ScheduleNames.windowWeekday || scheduleName(activity) == ScheduleNames.windowWeekend {
            sendNotification(title: "Kitchen Closing Soon", body: "Your carb window closes in 5 minutes.")
        }
    }

    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        logger.info("[eventWillReachThresholdWarning] \(event.rawValue)")

        guard scheduleName(activity) == ScheduleNames.windowWeekday || scheduleName(activity) == ScheduleNames.windowWeekend,
              let usageMinutes = parseUsageMinutes(from: event.rawValue),
              let portion = store.load().profile?.portionMinutes,
              usageMinutes == portion else { return }

        sendNotification(title: "Last Bites", body: "About 5 minutes of carbs left.")
    }
}
