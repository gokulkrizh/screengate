import Foundation

// MARK: - Premium features

enum PremiumFeature: String, CaseIterable {
    case nightFast
    case strictMode
    case customPlan
    case weekendRefeed
    case widgets
    case fullReport
    case extraCheats
}

/// Feature gates. `SharedState.isPremium` is the cached entitlement; the paywall
/// (Phase 5) keeps it in sync with StoreKit / Superwall.
enum Entitlement {
    /// Free tier: one plan (Lean), carbs only, window + portion, one cheat a week.
    static let freeCheatsPerWeek = 1
    static let freePlans: Set<DietPlan> = [.lean]

    static func isUnlocked(_ feature: PremiumFeature, isPremium: Bool) -> Bool {
        isPremium
    }

    static func canUse(plan: DietPlan, isPremium: Bool) -> Bool {
        isPremium || freePlans.contains(plan)
    }

    /// Clamp the requested weekly cheats to what the current tier allows.
    static func clampedCheats(_ requested: Int, isPremium: Bool) -> Int {
        isPremium ? max(0, min(7, requested)) : min(requested, freeCheatsPerWeek)
    }
}
