//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitorExtension
//
//  Created by Gokul on 2025/11/05.
//

import DeviceActivity
import Foundation
import UserNotifications
import OSLog

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private var manager = DeviceActivityManager()
    private let userDefaults = UserDefaults(suiteName: "group.com.gia.screendiet")
    private let jsonDecoder = JSONDecoder()
    private let logger = Logger(subsystem: "com.gia.screendiet", category: "DeviceActivityMonitor")

    // MARK: - Helpers

    /// Extract the diet activity type from DeviceActivityName
    /// Format: "com.gia.screendiet.diet.carbs.window", "com.gia.screendiet.diet.nightlock", etc.
    private func extractActivityType(from activity: DeviceActivityName) -> String? {
        let raw = activity.rawValue
        let prefix = "com.gia.screendiet."

        guard raw.hasPrefix(prefix) else {
            logger.warning("[extractActivityType] Activity doesn't match prefix: \(raw)")
            return nil
        }

        let suffix = String(raw.dropFirst(prefix.count))
        logger.info("[extractActivityType] Activity type: \(suffix)")
        return suffix
    }

    /// Check if cheat meal is currently active
    private func isCheatMealActive() -> Bool {
        guard let userDefaults = userDefaults else { return false }
        let active = userDefaults.bool(forKey: "cheatMealActive")
        if active, let expires = userDefaults.object(forKey: "cheatMealExpires") as? Date {
            return expires > Date()
        }
        return false
    }

    /// Update the shield type in shared UserDefaults
    private func updateShieldType(_ type: String) {
        userDefaults?.set(type, forKey: "currentShieldType")
        userDefaults?.synchronize()
        logger.info("[updateShieldType] Set shield type to: \(type)")
    }

    /// Set carb usage counter in UserDefaults
    /// NOTE: Only writes the integer key. Does NOT re-encode todayLog because
    /// NutritionLogLight is missing the `date` field, which would corrupt the
    /// main app's NutritionLog decode. The main app syncs carbsUsedToday into
    /// todayLog.carbsMinutes when it loads from UserDefaults.
    private func setCarbsUsed(minutes: Int) {
        guard let userDefaults = userDefaults else { return }
        userDefaults.set(minutes, forKey: "carbsUsedToday")
        logger.info("[setCarbsUsed] Carbs used set to: \(minutes)")
    }

    /// Get daily carb limit from profile
    private func getDailyCarbLimit() -> Int {
        guard let userDefaults = userDefaults,
              let data = userDefaults.data(forKey: "dietProfile"),
              let profile = try? jsonDecoder.decode(DietProfileLight.self, from: data) else {
            return DebugConfig.defaultPortionMinutes
        }
        return profile.eatingWindow.dailyCarbLimitMinutes
    }

    /// Get current carbs used today
    private func getCarbsUsedToday() -> Int {
        return userDefaults?.integer(forKey: "carbsUsedToday") ?? 0
    }

    /// Parse usage minutes from an incremental event name like "usage-5", "usage-10", etc.
    private func parseUsageMinutes(from eventName: String) -> Int? {
        guard eventName.hasPrefix("usage-"),
              let minutes = Int(eventName.dropFirst("usage-".count)) else {
            return nil
        }
        return minutes
    }

    /// Send notification
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                self.logger.error("[sendNotification] Error: \(error.localizedDescription)")
            }
        }
    }

    /// Post Darwin notification to sync with main app
    private func postDietChangedNotification() {
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName("com.gia.screendiet.dietChanged" as CFString),
            nil, nil, true
        )
        logger.info("[postDietChangedNotification] Posted Darwin notification")
    }

    // MARK: - Interval Callbacks

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        logger.info("[intervalDidStart] Activity: \(activity.rawValue)")

        guard let activityType = extractActivityType(from: activity) else { return }

        // Skip if cheat meal is active
        if isCheatMealActive() {
            logger.info("[intervalDidStart] Cheat meal active, skipping restrictions")
            return
        }

        switch activityType {
        case "diet.carbs.window":
            // Carb eating window just opened - remove carb restrictions and reset daily counter
            logger.info("[intervalDidStart] Carb window opened - removing carb restrictions")
            manager.removeRestrictions()
            setCarbsUsed(minutes: 0)  // Reset daily counter at window open
            updateShieldType("portionTimer")
            sendNotification(title: "Kitchen Open", body: "Your carb window is now open. Enjoy responsibly!")
            postDietChangedNotification()

        case "diet.nightlock":
            // Night lock started - apply all restrictions except protein
            logger.info("[intervalDidStart] Night lock started - applying night restrictions")
            updateShieldType("nightLock")
            let events = manager.getEvents(activityName: activity, details: true)
            for (_, event) in events {
                manager.applyImmediateRestrictions(
                    applicationTokens: event.applications,
                    categoryTokens: event.categories,
                    webDomainTokens: event.webDomains
                )
            }
            sendNotification(title: "Night Lock Active", body: "Only protein apps are available. Rest well.")
            postDietChangedNotification()

        case "diet.fats.window":
            // Fats tracking window started - no action needed, just tracking
            logger.info("[intervalDidStart] Fats tracking window started")

        default:
            logger.warning("[intervalDidStart] Unknown activity type: \(activityType)")
        }
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        logger.info("[intervalDidEnd] Activity: \(activity.rawValue)")

        guard let activityType = extractActivityType(from: activity) else { return }

        switch activityType {
        case "diet.carbs.window":
            // Carb eating window closed - apply carb restrictions (fasting resumes)
            logger.info("[intervalDidEnd] Carb window closed - applying carb restrictions")
            updateShieldType("kitchenClosed")
            let events = manager.getEvents(activityName: activity, details: true)
            for (_, event) in events {
                manager.applyImmediateRestrictions(
                    applicationTokens: event.applications,
                    categoryTokens: event.categories,
                    webDomainTokens: event.webDomains
                )
            }
            sendNotification(title: "Kitchen Closed", body: "Carb window has ended. Fasting period begins.")
            postDietChangedNotification()

        case "diet.nightlock":
            // Night lock ended - remove night restrictions (eating window opens or fasting continues)
            logger.info("[intervalDidEnd] Night lock ended - removing night restrictions")
            manager.removeRestrictions()
            // Shield type will be set by the carb window starting or staying as fasting
            updateShieldType("kitchenClosed")
            postDietChangedNotification()

        case "diet.fats.window":
            // Fats tracking window ended
            logger.info("[intervalDidEnd] Fats tracking window ended")

        default:
            logger.warning("[intervalDidEnd] Unknown activity type: \(activityType)")
        }
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        logger.info("[eventDidReachThreshold] Event: \(event.rawValue), Activity: \(activity.rawValue)")

        guard let activityType = extractActivityType(from: activity) else { return }

        let cheatActive = isCheatMealActive()

        switch activityType {
        case "diet.carbs.window":
            // Always track carb usage (even during cheat meals) so actual usage is recorded.
            // Only apply restrictions when cheat meal is NOT active.
            if let usageMinutes = parseUsageMinutes(from: event.rawValue) {
                let limit = getDailyCarbLimit()
                setCarbsUsed(minutes: usageMinutes)

                if cheatActive {
                    logger.info("[eventDidReachThreshold] Cheat meal active - tracked carb usage \(usageMinutes)/\(limit) min (no restrictions)")
                } else if usageMinutes >= limit {
                    // Daily carb limit reached - apply restrictions
                    logger.info("[eventDidReachThreshold] Daily carb limit reached at \(usageMinutes)/\(limit) min")
                    updateShieldType("dailyLimitReached")
                    let events = manager.getEvents(activityName: activity, details: true)
                    for (_, eventDetail) in events {
                        manager.applyImmediateRestrictions(
                            applicationTokens: eventDetail.applications,
                            categoryTokens: eventDetail.categories,
                            webDomainTokens: eventDetail.webDomains
                        )
                    }
                    sendNotification(
                        title: "Daily Carb Limit Reached",
                        body: "\(limit)/\(limit) minutes consumed. Try protein or fiber apps."
                    )
                } else {
                    // Incremental update - just sync the usage to the main app
                    logger.info("[eventDidReachThreshold] Carb usage: \(usageMinutes)/\(limit) min")
                }
                postDietChangedNotification()
            } else if event.rawValue == "carb-limit" {
                // Legacy single-threshold event
                let limit = getDailyCarbLimit()
                setCarbsUsed(minutes: limit)
                if !cheatActive {
                    updateShieldType("dailyLimitReached")
                    let events = manager.getEvents(activityName: activity, details: true)
                    for (_, eventDetail) in events {
                        manager.applyImmediateRestrictions(
                            applicationTokens: eventDetail.applications,
                            categoryTokens: eventDetail.categories,
                            webDomainTokens: eventDetail.webDomains
                        )
                    }
                    sendNotification(
                        title: "Daily Carb Limit Reached",
                        body: "\(limit)/\(limit) minutes consumed. Try protein or fiber apps."
                    )
                }
                postDietChangedNotification()
            }

        case "diet.fats.window":
            // Fats limit reached - skip if cheat meal active
            if cheatActive {
                logger.info("[eventDidReachThreshold] Cheat meal active - skipping fats restriction")
            } else {
                logger.info("[eventDidReachThreshold] Fats limit reached")
                let events = manager.getEvents(activityName: activity, details: true)
                for (_, eventDetail) in events {
                    manager.applyImmediateRestrictions(
                        applicationTokens: eventDetail.applications,
                        categoryTokens: eventDetail.categories,
                        webDomainTokens: eventDetail.webDomains
                    )
                }
                postDietChangedNotification()
            }

        default:
            logger.info("[eventDidReachThreshold] No threshold action for: \(activityType)")
        }
    }

    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        logger.info("[intervalWillStartWarning] Activity: \(activity.rawValue)")

        guard let activityType = extractActivityType(from: activity) else { return }

        switch activityType {
        case "diet.carbs.window":
            sendNotification(title: "Kitchen Opening Soon", body: "Your carb window opens in 15 minutes.")
        case "diet.nightlock":
            sendNotification(title: "Night Lock Starting Soon", body: "Night lock activates in 15 minutes. Wrap up!")
        default:
            break
        }
    }

    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        logger.info("[intervalWillEndWarning] Activity: \(activity.rawValue)")

        guard let activityType = extractActivityType(from: activity) else { return }

        switch activityType {
        case "diet.carbs.window":
            sendNotification(title: "Kitchen Closing Soon", body: "Your carb window closes in 5 minutes.")
        case "diet.nightlock":
            logger.info("[intervalWillEndWarning] Night lock ending soon")
        default:
            break
        }
    }

    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        logger.info("[eventWillReachThresholdWarning] Event: \(event.rawValue), Activity: \(activity.rawValue)")

        guard let activityType = extractActivityType(from: activity) else { return }

        if activityType == "diet.carbs.window" {
            let used = getCarbsUsedToday()
            let limit = getDailyCarbLimit()
            let remaining = max(0, limit - used)
            sendNotification(
                title: "Carb Limit Warning",
                body: "Only ~\(remaining) minutes of carb budget remaining today."
            )
        }
    }
}

// MARK: - Lightweight Codable for Extension

private struct DietProfileLight: Codable {
    var dietType: String
    var eatingWindow: EatingWindowLight
    var nightLockHour: Int
    var nightLockMinute: Int
    var weeklyCheatMeals: Int
    var cheatsUsedThisWeek: Int
    var isActive: Bool

    enum CodingKeys: String, CodingKey {
        case dietType, eatingWindow, nightLockHour, nightLockMinute
        case weeklyCheatMeals, cheatsUsedThisWeek, isActive
    }
}

private struct EatingWindowLight: Codable {
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    var dailyCarbLimitMinutes: Int
}

private struct NutritionLogLight: Codable {
    var dateKey: String
    var proteinMinutes: Int
    var carbsMinutes: Int
    var fatsMinutes: Int
    var fiberMinutes: Int
    var cheatsUsed: Int
}
