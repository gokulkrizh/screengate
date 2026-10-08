import Foundation

// MARK: - Notification IDs (the plan)

enum NotificationID: String, CaseIterable, Identifiable {
    case kitchenOpening = "kitchen.opening"
    case kitchenOpen = "kitchen.open"
    case portionHalf = "portion.half"
    case portionLast5 = "portion.last5"
    case portionEmpty = "portion.empty"
    case kitchenClosing = "kitchen.closing"
    case nightSoon = "night.soon"
    case cheatEnding = "cheat.ending"
    case morningRecap = "morning.recap"
    case streakRisk = "streak.risk"
    case sundayCheckin = "sunday.checkin"
    case trialEnding = "trial.ending"

    var id: String { rawValue }

    /// Time-sensitive requires the capability; only these two use it.
    var isTimeSensitive: Bool {
        self == .portionLast5 || self == .nightSoon
    }

    // Settings copy
    var settingsTitle: String {
        switch self {
        case .kitchenOpening: return "Kitchen opening soon"
        case .kitchenOpen: return "Kitchen open"
        case .portionHalf: return "Half portion"
        case .portionLast5: return "Last bites"
        case .portionEmpty: return "Plate empty"
        case .kitchenClosing: return "Kitchen closing"
        case .nightSoon: return "Night Fast soon"
        case .cheatEnding: return "Cheat meal ending"
        case .morningRecap: return "Morning recap"
        case .streakRisk: return "Streak at risk"
        case .sundayCheckin: return "Sunday check-in"
        case .trialEnding: return "Trial ending"
        }
    }

    var settingsSubtitle: String {
        switch self {
        case .kitchenOpening, .kitchenOpen: return "When your eating window opens"
        case .portionHalf, .portionLast5, .portionEmpty: return "As you use your portion"
        case .kitchenClosing: return "10 minutes before the window closes"
        case .nightSoon: return "15 minutes before Night Fast"
        case .cheatEnding: return "2 minutes before a cheat meal ends"
        case .morningRecap: return "A recap when the kitchen opens"
        case .streakRisk: return "When you're close to your portion"
        case .sundayCheckin: return "Sunday 18:00 — your weekly label"
        case .trialEnding: return "Before your trial ends"
        }
    }

    /// Everything is on by default.
    var defaultEnabled: Bool { true }
}

// MARK: - Categories & actions

enum NotificationCategoryID {
    static let nightSoon = "NIGHT_SOON"
    static let label = "LABEL"
}

enum NotificationActionID {
    static let startFast = "START_FAST"
    static let seeLabel = "SEE_LABEL"
}

// MARK: - Routes

/// Where a notification tap should take the user.
enum NotificationRoute: String {
    case kitchen
    case report
    case startFast

    static let userInfoKey = "dietRoute"
}

extension Notification.Name {
    static let dietNotificationRoute = Notification.Name("dietNotificationRoute")
}
