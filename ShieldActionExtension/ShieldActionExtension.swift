//
//  ShieldActionExtension.swift
//  ShieldActionExtension
//
//  Two-tap extra serving (formerly "cheat meal"):
//   1. Secondary button ("Use an extra serving") → write a pending confirmation (20 s TTL,
//      token-scoped) and return `.defer` so the shield re-renders as "Tap again to confirm".
//   2. Primary button ("Yes, 15 minutes") within the TTL → start the `diet.cheat` schedule and
//      unlock. Secondary ("Never mind") clears the pending confirmation.
//
//  Cheat meals are never offered during Night Fast / Fast Now, and only while
//  weekly cheats remain for the current tier.
//

import ManagedSettings
import DeviceActivity
import UserNotifications
import Foundation

class ShieldActionExtension: ShieldActionDelegate {

    private let manager = DeviceActivityManager()
    private let store = SharedStore.shared

    // MARK: - Delegate

    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handle(action, scope: ShieldPending.scope(for: application), completionHandler: completionHandler)
    }

    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handle(action, scope: ShieldPending.scope(for: webDomain), completionHandler: completionHandler)
    }

    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handle(action, scope: ShieldPending.scope(for: category), completionHandler: completionHandler)
    }

    // MARK: - Routing

    private func handle(_ action: ShieldAction, scope: String, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            // Confirmation shield: the primary button is "Yes, 15 minutes".
            if let pending = store.load().shieldPending, pending.isActive(), pending.scope == scope {
                handleCheatMeal(scope: scope, completionHandler: completionHandler)
            } else {
                cancelPendingConfirmation()
                completionHandler(.close)
            }

        case .secondaryButtonPressed:
            // Confirmation shield: the secondary button is "Never mind".
            if let pending = store.load().shieldPending, pending.isActive(), pending.scope == scope {
                cancelPendingConfirmation()
                completionHandler(.close)
            } else {
                handleCheatMeal(scope: scope, completionHandler: completionHandler)
            }

        @unknown default:
            completionHandler(.none)
        }
    }

    // MARK: - Cheat meal

    private func handleCheatMeal(scope: String, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        let state = store.load()

        // Already cheating → just open.
        if DietRules.isCheatActive(state.cheat) {
            completionHandler(.close)
            return
        }

        // Never offered during a fast.
        if DietRules.isFastActive(state.fast) {
            completionHandler(.none)
            return
        }

        // Only kitchen-closed / plate-empty shields offer cheats.
        let dietState = DietRules.state(
            profile: state.profile,
            counters: state.counters,
            fast: state.fast,
            cheat: state.cheat
        )
        let kind = DietRules.shieldKind(for: dietState)
        guard kind == .kitchenClosed || kind == .plateEmpty,
              let profile = state.profile,
              profile.isActive else {
            completionHandler(.none)
            return
        }

        // Weekly allowance for the current tier.
        let allowed = Entitlement.clampedCheats(profile.cheatsPerWeek, isPremium: state.isPremium)
        guard allowed - state.week.cheatsUsed > 0 else {
            sendNotification(
                title: "No Extra Servings Left",
                body: "You've used all \(allowed) extra servings this week."
            )
            completionHandler(.none)
            return
        }

        // Tap 2 (same shield, within the TTL) confirms; tap 1 defers.
        if let pending = state.shieldPending, pending.isActive(), pending.scope == scope {
            startCheatMeal(completionHandler: completionHandler)
        } else {
            var updated = state
            updated.shieldPending = ShieldPending(
                scope: scope,
                expiresAt: Date().addingTimeInterval(20)
            )
            store.save(updated)
            completionHandler(.defer)
        }
    }

    private func startCheatMeal(completionHandler: @escaping (ShieldActionResponse) -> Void) {
        var state = store.load()
        let now = Date()
        let minutes = DietRules.cheatMealMinutes
        let endsAt = now.addingTimeInterval(TimeInterval(minutes * 60))

        state.cheat = CheatSession(startedAt: now, endsAt: endsAt, source: .shield)
        state.counters.cheatsUsedToday += 1
        state.week.cheatsUsed += 1
        state.shieldPending = nil
        let saved = store.save(state)

        // One-off schedule: the monitor extension re-blocks carbs at the end.
        let schedule = DeviceActivitySchedule.oneOff(start: now, end: endsAt)
        try? manager.start(name: ScheduleNames.cheat, schedule: schedule)
        manager.reconcile(state: saved)

        sendNotification(
            title: "Extra Serving",
            body: "Carbs are open for \(minutes) minutes. Enjoy."
        )
        completionHandler(.close)
    }

    private func cancelPendingConfirmation() {
        var state = store.load()
        guard state.shieldPending != nil else { return }
        state.shieldPending = nil
        store.save(state)
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
