import SwiftUI

/// The 19 onboarding steps (spec §7). Raw value = step number on the canvas; the splash (00) is `SplashView`.
enum OnboardingStep: Int, CaseIterable {
    case welcome = 1, story, ingredients, goal, intention, rhythm, screenTime
    case carbs, fats, protein
    case perspective, plan, portion, hours, nightFast, reminders
    case recipe, membership, ready

    var chapter: OnboardingChapter {
        switch self {
        case .welcome, .story, .ingredients: .story
        case .goal, .intention, .rhythm, .screenTime: .you
        case .carbs, .fats, .protein: .plates
        case .perspective, .plan, .portion, .hours, .nightFast, .reminders: .recipe
        case .recipe, .membership, .ready: .ready
        }
    }

    /// 1-based position inside the chapter, and the chapter's step count.
    var positionInChapter: (index: Int, count: Int) {
        let siblings = Self.allCases.filter { $0.chapter == chapter }
        return ((siblings.firstIndex(of: self) ?? 0) + 1, siblings.count)
    }

    /// Spec §1: Lamp = story/membership, Night = Night Fast, otherwise Daylight.
    var theme: KitchenTheme {
        switch self {
        case .welcome, .story, .membership: .lamp
        case .nightFast: .night
        default: .daylight
        }
    }

    var showsBack: Bool { self != .welcome }
    var isPlus: Bool { self == .membership }
}
