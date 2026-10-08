//
//  ShieldActionExtension.swift
//  ShieldActionExtension
//
//  Created by Gokul on 2025/11/05.
//

import ManagedSettings
import UserNotifications
import Foundation

class ShieldActionExtension: ShieldActionDelegate {
    private var manager = DeviceActivityManager()
    private let userDefaults = UserDefaults(suiteName: "group.com.gia.screendiet")
    private let jsonDecoder = JSONDecoder()

    // MARK: - Helpers

    private func getCurrentShieldType() -> String {
        return userDefaults?.string(forKey: "currentShieldType") ?? "kitchenClosed"
    }

    private func isCheatMealActive() -> Bool {
        guard let userDefaults = userDefaults else { return false }
        let active = userDefaults.bool(forKey: "cheatMealActive")
        if active, let expires = userDefaults.object(forKey: "cheatMealExpires") as? Date {
            return expires > Date()
        }
        return false
    }

    private func getCheatsRemaining() -> Int {
        guard let userDefaults = userDefaults else { return 0 }

        // First check the dedicated key (written by both extension and main app)
        let cheatsUsed = userDefaults.integer(forKey: "cheatsUsedThisWeek")

        // Read weekly allowance from profile
        guard let data = userDefaults.data(forKey: "dietProfile"),
              let profile = try? jsonDecoder.decode(DietProfileLight.self, from: data) else {
            return 0
        }

        // Use the max of the dedicated key and the profile value
        let actualUsed = max(cheatsUsed, profile.cheatsUsedThisWeek)
        return max(0, profile.weeklyCheatMeals - actualUsed)
    }

    /// Activate a cheat meal from the extension (30 min bypass)
    /// NOTE: Does NOT re-encode dietProfile because DietProfileLight is missing
    /// fields (macroRatios, activatedAt, weekStartDate, etc.) which would corrupt
    /// the main app's DietProfile decode. Instead writes to a dedicated key.
    private func activateCheatMeal() -> Bool {
        guard let userDefaults = userDefaults else { return false }

        // Read profile to check allowance
        guard let data = userDefaults.data(forKey: "dietProfile"),
              let profile = try? jsonDecoder.decode(DietProfileLight.self, from: data) else {
            return false
        }

        // Get current usage from dedicated key (may be higher than profile value)
        let currentUsed = max(
            userDefaults.integer(forKey: "cheatsUsedThisWeek"),
            profile.cheatsUsedThisWeek
        )

        // Check remaining
        guard profile.weeklyCheatMeals - currentUsed > 0 else {
            return false
        }

        // Write updated cheat count to dedicated key only (don't corrupt the profile)
        let newUsed = currentUsed + 1
        userDefaults.set(newUsed, forKey: "cheatsUsedThisWeek")

        // Set cheat meal state
        let expiresAt = Date().addingTimeInterval(TimeInterval(DebugConfig.cheatMealMinutes * 60))
        userDefaults.set(true, forKey: "cheatMealActive")
        userDefaults.set(expiresAt, forKey: "cheatMealExpires")

        // Increment today's cheat count
        let todayCheats = userDefaults.integer(forKey: "cheatsUsedToday")
        userDefaults.set(todayCheats + 1, forKey: "cheatsUsedToday")

        // Remove restrictions temporarily
        manager.removeRestrictions()

        // Notify main app via Darwin notification
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName("com.gia.screendiet.dietChanged" as CFString),
            nil, nil, true
        )

        return true
    }

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
                print("Error sending shield notification: \(error)")
            }
        }
    }

    // MARK: - Action Handlers

    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handleAction(action: action, completionHandler: completionHandler)
    }

    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handleAction(action: action, completionHandler: completionHandler)
    }

    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handleAction(action: action, completionHandler: completionHandler)
    }

    private func handleAction(action: ShieldAction, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // If cheat meal is active, allow access
        if isCheatMealActive() {
            completionHandler(.close)
            return
        }

        let shieldType = getCurrentShieldType()

        switch action {
        case .primaryButtonPressed:
            handlePrimaryButton(shieldType: shieldType, completionHandler: completionHandler)
        case .secondaryButtonPressed:
            handleSecondaryButton(shieldType: shieldType, completionHandler: completionHandler)
        @unknown default:
            completionHandler(.none)
        }
    }

    private func handlePrimaryButton(shieldType: String, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch shieldType {
        case "portionTimer":
            // Kitchen open - allow the app
            completionHandler(.close)

        case "proteinApp":
            // Protein apps always allowed
            completionHandler(.close)

        case "kitchenClosed", "carbCurfew", "dailyLimitReached", "nightLock":
            // Close button - close the shielded app, keep restriction active
            completionHandler(.close)

        default:
            completionHandler(.none)
        }
    }

    private func handleSecondaryButton(shieldType: String, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch shieldType {
        case "kitchenClosed", "carbCurfew", "dailyLimitReached":
            // Secondary button = cheat meal
            if getCheatsRemaining() > 0 {
                if activateCheatMeal() {
                    sendNotification(
                        title: "Cheat Meal Activated",
                        body: "Restrictions lifted for 30 minutes. Enjoy!"
                    )
                    completionHandler(.close)
                } else {
                    completionHandler(.none)
                }
            } else {
                sendNotification(
                    title: "No Cheat Meals Left",
                    body: "You've used all your cheat meals this week."
                )
                completionHandler(.none)
            }

        case "portionTimer", "proteinApp":
            // Close button
            completionHandler(.none)

        case "nightLock":
            // Emergency access - allow temporarily
            manager.removeRestrictions()
            sendNotification(
                title: "Emergency Access Granted",
                body: "Restrictions temporarily removed. They will re-apply at next interval."
            )
            completionHandler(.close)

        default:
            completionHandler(.none)
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
