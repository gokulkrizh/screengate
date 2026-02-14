import Foundation
import FamilyControls

// MARK: - Food Group Model

/// Represents the four macronutrient categories for digital consumption
enum FoodGroup: String, Codable, CaseIterable, Identifiable {
    case protein  // Create: Notes, Camera, GarageBand, Code
    case carbs    // Consume: Instagram, TikTok, Twitter, Games
    case fats     // Connect: Messages, WhatsApp, FaceTime
    case fiber    // Learn: Kindle, Podcasts, News

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .protein: return "PROTEIN"
        case .carbs: return "CARBS"
        case .fats: return "FATS"
        case .fiber: return "FIBER"
        }
    }

    var subtitle: String {
        switch self {
        case .protein: return "Create"
        case .carbs: return "Consume"
        case .fats: return "Connect"
        case .fiber: return "Learn"
        }
    }

    var description: String {
        switch self {
        case .protein: return "High-quality nutrition. Create something meaningful."
        case .carbs: return "Processed content. Ration carefully."
        case .fats: return "Essential nutrients. Moderate portions."
        case .fiber: return "Slow digestion. Daily recommended."
        }
    }

    var emoji: String {
        switch self {
        case .protein: return "🥩"
        case .carbs: return "🍩"
        case .fats: return "🥑"
        case .fiber: return "🥦"
        }
    }

    var icon: String {
        switch self {
        case .protein: return "hammer.fill"
        case .carbs: return "play.circle.fill"
        case .fats: return "message.fill"
        case .fiber: return "book.fill"
        }
    }

    var exampleApps: String {
        switch self {
        case .protein: return "Notes, Camera, GarageBand, Code"
        case .carbs: return "Instagram, TikTok, Twitter, Games"
        case .fats: return "Messages, WhatsApp, FaceTime"
        case .fiber: return "Kindle, Podcasts, News"
        }
    }

    /// Whether this food group has unlimited access (no time restrictions)
    var isUnlimited: Bool {
        switch self {
        case .protein: return true
        case .carbs, .fats, .fiber: return false
        }
    }

    /// Monitor allocation for threshold tracking (total must be <= 20)
    var monitorCount: Int {
        switch self {
        case .carbs: return 8    // 3-min threshold, 9.6 hrs coverage
        case .fats: return 6     // 5-min threshold, 12 hrs coverage
        case .protein: return 4  // 5-min threshold, 8 hrs coverage
        case .fiber: return 2    // 5-min threshold, 4 hrs coverage
        }
    }

    /// Threshold interval in minutes for usage tracking
    var thresholdMinutes: Int {
        switch self {
        case .carbs: return 3
        case .fats, .protein, .fiber: return 5
        }
    }
}

// MARK: - Food Group Selection

/// Stores the user's app selections per food group
struct FoodGroupSelection: Codable {
    var foodGroup: FoodGroup
    var selection: FamilyActivitySelection

    var appCount: Int {
        selection.applicationTokens.count
    }

    var categoryCount: Int {
        selection.categoryTokens.count
    }

    var totalItemCount: Int {
        appCount + categoryCount
    }

    var hasApps: Bool {
        !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty
    }

    init(foodGroup: FoodGroup, selection: FamilyActivitySelection = FamilyActivitySelection()) {
        self.foodGroup = foodGroup
        self.selection = selection
    }
}
