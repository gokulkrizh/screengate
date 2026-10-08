import Foundation

// MARK: - Food Group Model (v1: three groups)

/// The three v1 food groups.
///
/// - `carbs`: time-wasting / consumable apps. Portion-limited during the eating window.
/// - `fats`: social apps. No usage limit, but blocked during Night Fast and Fast Now.
/// - `protein`: creative / productive apps. Always available.
enum FoodGroup: String, Codable, CaseIterable, Identifiable {
    case carbs
    case fats
    case protein

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .carbs: return "CARBS"
        case .fats: return "FATS"
        case .protein: return "PROTEIN"
        }
    }

    var subtitle: String {
        switch self {
        case .carbs: return "Consume"
        case .fats: return "Connect"
        case .protein: return "Create"
        }
    }

    var description: String {
        switch self {
        case .carbs: return "Processed content. Ration carefully."
        case .fats: return "Essential nutrients. Moderate portions."
        case .protein: return "High-quality nutrition. Create something meaningful."
        }
    }

    var emoji: String {
        switch self {
        case .carbs: return "🍩"
        case .fats: return "🥑"
        case .protein: return "🥩"
        }
    }

    var icon: String {
        switch self {
        case .carbs: return "play.circle.fill"
        case .fats: return "message.fill"
        case .protein: return "hammer.fill"
        }
    }

    var exampleApps: String {
        switch self {
        case .carbs: return "Instagram, TikTok, Twitter, Games"
        case .fats: return "Messages, WhatsApp, FaceTime"
        case .protein: return "Notes, Camera, GarageBand, Code"
        }
    }

    /// Protein is unrestricted. Fats have no limit but are blocked during fasts.
    var isUnlimited: Bool { self == .protein }
}
