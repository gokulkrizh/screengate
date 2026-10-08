//
//  ShieldActionExtension.swift
//  ShieldActionExtension
//
//  Shield button handling. Phase 1: direct cheat meal from the shield (2-tap
//  confirmation arrives in Phase 2). Cheat sessions are stored in SharedState
//  and closed by the `diet.cheat` DeviceActivity schedule.
//

import ManagedSettings
import DeviceActivity
import UserNotifications
import Foundation

class ShieldActionExtension: ShieldActionDelegate {

    private let manager = DeviceActivityManager()
    private let store = SharedStore.shared

    // MARK: - Action Handlers

    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handle(action, completionHandler: completionHandler)
    }

    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handle(action, completionHandler: completionHandler)
    }

    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handle(action, completionHandler: completionHandler)
    }

    private func handle(_ action: ShieldAction, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            // Dismiss the shield; the restriction stays.
            completionHandler(.close)

        case .secondaryButtonPressed:
            handleCheatMeal(completionHandler: completionHandler)

        @unknown default:
            completionHandler(.none)
        }
    }

    // MARK: - Cheat meal

    private func handleCheatMeal(completionHandler: @escaping (ShieldActionResponse) -> Void) {
        var state = store.load()

        // Already cheating → just open.
        if DietRules.isCheatActive(state.cheat) {
            completionHandler(.close)
            return
        }

        // Not offered during a fast.
        if DietRules.isFastActive(state.fast) {
            completionHandler(.none)
            return
        }

        // Requires an active diet and remaining cheats.
        guard let profile = state.profile,
              profile.isActive,
              profile.cheatsPerWeek - state.week.cheatsUsed > 0 else {
            sendNotification(
                title: "No Cheat Meals Left",
                body: "You've used all your cheat meals this week."
            )
            completionHandler(.none)
            return
        }

        let now = Date()
        let minutes = max(DietRules.minimumScheduleMinutes, DebugConfig.cheatMealMinutes)
        let endsAt = now.addingTimeInterval(TimeInterval(minutes * 60))

        state.cheat = CheatSession(startedAt: now, endsAt: endsAt, source: .shield)
        state.counters.cheatsUsedToday += 1
        state.week.cheatsUsed += 1
        let saved = store.save(state)

        // One-off schedule: the monitor extension re-blocks carbs at the end.
        let schedule = DeviceActivitySchedule.oneOff(start: now, end: endsAt)
        try? manager.start(name: ScheduleNames.cheat, schedule: schedule)
        manager.reconcile(state: saved)

        sendNotification(
            title: "Cheat Meal",
            body: "Carbs are open for \(minutes) minutes. Enjoy."
        )
        completionHandler(.close)
    }

    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        )
    }
}
