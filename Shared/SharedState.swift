import Foundation
import FamilyControls

// MARK: - Day counters

/// Approximate daily counters. Exact numbers come from the report extension.
struct DayCounters: Codable, Equatable {
    var dateKey: String          // "yyyy-MM-dd"
    var carbMinutes: Int         // approximate (5-min threshold steps)
    var cheatsUsedToday: Int
    var portionHit: Bool

    static func dateKey(from date: Date = Date(), calendar: Calendar = .current) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    static func today(_ date: Date = Date()) -> DayCounters {
        DayCounters(dateKey: dateKey(from: date), carbMinutes: 0, cheatsUsedToday: 0, portionHit: false)
    }
}

// MARK: - Week counters

struct WeekCounters: Codable, Equatable {
    var weekStart: Date
    var cheatsUsed: Int
    var daysOverPortion: Int
    var daysCompleted: Int

    static func current(_ date: Date = Date()) -> WeekCounters {
        let start = Calendar.current.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        return WeekCounters(weekStart: start, cheatsUsed: 0, daysOverPortion: 0, daysCompleted: 0)
    }
}

// MARK: - Sessions

struct CheatSession: Codable, Equatable {
    enum Source: String, Codable {
        case shield, app, widget, siri
    }

    var startedAt: Date
    var endsAt: Date
    var source: Source
}

struct FastSession: Codable, Equatable {
    enum Source: String, Codable {
        case button, siri, focus, widget
    }

    var startedAt: Date
    var endsAt: Date
    var source: Source
}

/// 2-tap cheat confirmation from a shield. Scoped to the shielded item and valid
/// for a short TTL so a stray tap can't lift restrictions.
struct ShieldPending: Codable, Equatable {
    var scope: String
    var expiresAt: Date

    func isActive(at now: Date = Date()) -> Bool { expiresAt > now }

    /// Opaque scope string for a shield token (stable across processes).
    static func scope(for token: some Encodable) -> String {
        guard let data = try? JSONEncoder().encode(token) else { return "any" }
        return data.base64EncodedString()
    }

    /// Create a pending confirmation for a token.
    static func make(for token: some Encodable, ttl: TimeInterval = 20) -> ShieldPending {
        ShieldPending(scope: scope(for: token), expiresAt: Date().addingTimeInterval(ttl))
    }
}

// MARK: - Onboarding

struct OnboardingAnswers: Codable, Equatable {
    var dailyHours: Int?
    var worstTime: String?
    var goal: String?
}

// MARK: - Shared state

/// Single source of truth, persisted as `SharedState.json` in the app group.
struct SharedState: Codable {
    static let currentVersion = 2

    var version: Int
    var writerID: UUID
    var revision: Int
    var profile: DietProfile?
    /// Keyed by `FoodGroup.rawValue` so the JSON stays readable.
    var selections: [String: FamilyActivitySelection]
    var counters: DayCounters
    var week: WeekCounters
    var cheat: CheatSession?
    var fast: FastSession?
    var streak: Int
    var isPremium: Bool
    var shieldPending: ShieldPending?
    var onboarding: OnboardingAnswers?

    static func empty(_ date: Date = Date()) -> SharedState {
        SharedState(
            version: currentVersion,
            writerID: UUID(),
            revision: 0,
            profile: nil,
            selections: [:],
            counters: DayCounters.today(date),
            week: WeekCounters.current(date),
            cheat: nil,
            fast: nil,
            streak: 0,
            isPremium: false,
            shieldPending: nil,
            onboarding: nil
        )
    }

    // MARK: Selections

    func selection(for group: FoodGroup) -> FamilyActivitySelection {
        selections[group.rawValue] ?? FamilyActivitySelection()
    }

    mutating func setSelection(_ selection: FamilyActivitySelection, for group: FoodGroup) {
        selections[group.rawValue] = selection
    }

    // MARK: Convenience

    var carbsPathBlocked: Bool {
        DietRules.storePlan(profile: profile, counters: counters, cheat: cheat, fast: fast).carbsBlocked
    }
}
