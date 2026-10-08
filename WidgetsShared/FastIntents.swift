import AppIntents
import Foundation
import ActivityKit

// MARK: - Start Fast (widget / Siri / Control / Notification)

/// `LiveActivityIntent` runs in the app process, so it can start the Live
/// Activity as well as apply the fast.
struct StartFastIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Start a fast"
    static var description = IntentDescription("Start a ScreenDiet focus fast.")
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Minutes")
    var minutes: Int

    init() {
        self.minutes = 60
    }

    init(minutes: Int) {
        self.minutes = minutes
    }

    func perform() async throws -> some IntentResult {
        let minutes = max(DietRules.minimumScheduleMinutes, minutes)
        let store = SharedStore.shared
        let now = Date()
        let endsAt = now.addingTimeInterval(TimeInterval(minutes * 60))

        var state = store.load()
        state.cheat = nil
        state.fast = FastSession(startedAt: now, endsAt: endsAt, source: .widget)
        let saved = store.save(state)

        let manager = DeviceActivityManager()
        try? manager.start(
            name: ScheduleNames.fast,
            schedule: .oneOff(start: now, end: endsAt)
        )
        manager.reconcile(state: saved)

        FastActivityStarter.start(kind: .fastNow, endsAt: endsAt, streak: saved.streak)
        return .result()
    }
}

// MARK: - Carbs left (Siri answer)

struct CarbsRemainingIntent: AppIntent {
    static var title: LocalizedStringResource = "How much carbs do I have left?"
    static var description = IntentDescription("Ask ScreenDiet how much of today's portion is left.")
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let state = SharedStore.shared.load()
        guard let profile = state.profile, profile.isActive else {
            return .result(dialog: "Your diet isn't active yet.")
        }
        guard profile.portionMinutes > 0 else {
            return .result(dialog: "You're on Detox — carbs are off the menu today.")
        }
        let remaining = max(0, profile.portionMinutes - state.counters.carbMinutes)
        if state.counters.portionHit || remaining == 0 {
            return .result(dialog: "Your plate is empty. Back tomorrow.")
        }
        return .result(dialog: "About \(remaining) minutes of carbs left today.")
    }
}
