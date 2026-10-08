import Foundation
import ActivityKit

// MARK: - Live Activity attributes

enum FastKind: String, Codable, Hashable {
    case fastNow
    case nightFast
    case cheatMeal

    var emoji: String {
        switch self {
        case .fastNow: return "⚡"
        case .nightFast: return "🌙"
        case .cheatMeal: return "🍩"
        }
    }

    var title: String {
        switch self {
        case .fastNow: return "Focus Fast"
        case .nightFast: return "Night Fast"
        case .cheatMeal: return "Cheat Meal"
        }
    }
}

struct FastActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var startDate: Date
        var endDate: Date
        var kind: FastKind
        var streak: Int
    }
}

// MARK: - Activity starter (app process only — LiveActivityIntent covers widgets)

enum FastActivityStarter {

    /// Start (or replace) the current fast activity.
    static func start(kind: FastKind, endsAt: Date, streak: Int) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        Task {
            // Only one activity at a time.
            for activity in Activity<FastActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }

            let state = FastActivityAttributes.ContentState(
                startDate: Date(),
                endDate: endsAt,
                kind: kind,
                streak: streak
            )
            let content = ActivityContent(state: state, staleDate: endsAt)
            _ = try? Activity.request(attributes: FastActivityAttributes(), content: content)
        }
    }

    static func endAll() {
        Task {
            for activity in Activity<FastActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }

    static func end(kind: FastKind) {
        Task {
            for activity in Activity<FastActivityAttributes>.activities where activity.content.state.kind == kind {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }

    /// Start the Night Fast activity while the app is in the foreground; end it
    /// when the fast is over. (Extensions cannot start activities.)
    static func syncNightFast(state: SharedState) {
        let active = state.profile?.nightFast.isActive() == true
        let hasSession = DietRules.isFastActive(state.fast) || DietRules.isCheatActive(state.cheat)

        if active, !hasSession {
            let now = Date()
            let minutes = minutesUntilWindowOpen(state: state, at: now) ?? 8 * 60
            let endsAt = now.addingTimeInterval(TimeInterval(minutes * 60))
            let alreadyRunning = Activity<FastActivityAttributes>.activities
                .contains { $0.content.state.kind == .nightFast }
            if !alreadyRunning {
                start(kind: .nightFast, endsAt: endsAt, streak: state.streak)
            }
        } else {
            end(kind: .nightFast)
        }
    }

    private static func minutesUntilWindowOpen(state: SharedState, at date: Date) -> Int? {
        guard let window = state.profile?.eatingWindow else { return nil }
        return window.minutesUntilOpen(at: date)
    }
}
