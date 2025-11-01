import Foundation
import Combine

// MARK: - Intention Category Model

enum IntentionCategory: String, Codable, CaseIterable, Identifiable {
    case breathing = "breathing"
    case mindfulness = "mindfulness"
    case reflection = "reflection"
    case movement = "movement"
    case quickBreak = "quickBreak"

    var id: String { rawValue }

    // MARK: - Display Properties
    var displayName: String {
        switch self {
        case .breathing: return "Breathing Exercises"
        case .mindfulness: return "Mindfulness"
        case .reflection: return "Reflection"
        case .movement: return "Movement"
        case .quickBreak: return "Quick Breaks"
        }
    }

    var description: String {
        switch self {
        case .breathing: return "Structured breathing techniques to calm your mind and body"
        case .mindfulness: return "Meditation and awareness practices to stay present"
        case .reflection: return "Journaling prompts and self-reflection exercises"
        case .movement: return "Physical activities to energize and stretch your body"
        case .quickBreak: return "Brief activities to reset and refresh quickly"
        }
    }

    var iconName: String {
        switch self {
        case .breathing: return "lungs.fill"
        case .mindfulness: return "brain.head.profile"
        case .reflection: return "heart.text.square"
        case .movement: return "figure.walk"
        case .quickBreak: return "clock.fill"
        }
    }

    var color: String {
        switch self {
        case .breathing: return "blue"
        case .mindfulness: return "purple"
        case .reflection: return "pink"
        case .movement: return "green"
        case .quickBreak: return "orange"
        }
    }

    // MARK: - Category Preferences
    var preferenceWeight: Int {
        switch self {
        case .breathing: return 5
        case .mindfulness: return 4
        case .reflection: return 3
        case .movement: return 4
        case .quickBreak: return 5
        }
    }

    var defaultDuration: TimeInterval {
        switch self {
        case .breathing: return 120 // 2 minutes
        case .mindfulness: return 300 // 5 minutes
        case .reflection: return 180 // 3 minutes
        case .movement: return 240 // 4 minutes
        case .quickBreak: return 60 // 1 minute
        }
    }

    var recommendedTimeOfDay: [TimeOfDay] {
        switch self {
        case .breathing: return [.morning, .afternoon, .evening]
        case .mindfulness: return [.morning, .evening]
        case .reflection: return [.evening, .night]
        case .movement: return [.morning, .afternoon]
        case .quickBreak: return [.morning, .afternoon, .evening]
        }
    }

    // MARK: - Category Statistics
    var popularityScore: Double {
        switch self {
        case .breathing: return 0.9
        case .quickBreak: return 0.8
        case .mindfulness: return 0.7
        case .movement: return 0.6
        case .reflection: return 0.5
        }
    }

    var effectivenessRating: Double {
        switch self {
        case .breathing: return 0.85
        case .mindfulness: return 0.80
        case .movement: return 0.75
        case .reflection: return 0.70
        case .quickBreak: return 0.65
        }
    }
}

// MARK: - Time of Day

enum TimeOfDay: String, Codable, CaseIterable, Identifiable {
    case morning = "morning"
    case afternoon = "afternoon"
    case evening = "evening"
    case night = "night"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .morning: return "Morning (6AM - 12PM)"
        case .afternoon: return "Afternoon (12PM - 6PM)"
        case .evening: return "Evening (6PM - 10PM)"
        case .night: return "Night (10PM - 6AM)"
        }
    }

    var hourRange: ClosedRange<Int> {
        switch self {
        case .morning: return 6...11
        case .afternoon: return 12...17
        case .evening: return 18...21
        case .night: return 22...23
        }
    }

    var recommendedCategories: [IntentionCategory] {
        switch self {
        case .morning:
            return [.breathing, .movement, .mindfulness]
        case .afternoon:
            return [.quickBreak, .breathing, .movement]
        case .evening:
            return [.reflection, .mindfulness, .breathing]
        case .night:
            return [.breathing, .reflection]
        }
    }
}

// MARK: - Category Preferences

struct CategoryPreference: Codable, Identifiable {
    let id = UUID().uuidString
    let category: IntentionCategory
    let isEnabled: Bool
    let priority: Priority
    let preferredTimeOfDay: [TimeOfDay]
    let customDuration: TimeInterval?
    let frequencyMultiplier: Double

    enum Priority: String, Codable, CaseIterable {
        case low = "low"
        case medium = "medium"
        case high = "high"

        var displayName: String {
            switch self {
            case .low: return "Low Priority"
            case .medium: return "Medium Priority"
            case .high: return "High Priority"
            }
        }

        var weight: Double {
            switch self {
            case .low: return 0.5
            case .medium: return 1.0
            case .high: return 2.0
            }
        }
    }

    init(
        category: IntentionCategory,
        isEnabled: Bool = true,
        priority: Priority = .medium,
        preferredTimeOfDay: [TimeOfDay] = [],
        customDuration: TimeInterval? = nil,
        frequencyMultiplier: Double = 1.0
    ) {
        self.category = category
        self.isEnabled = isEnabled
        self.priority = priority
        self.preferredTimeOfDay = preferredTimeOfDay.isEmpty ? category.recommendedTimeOfDay : preferredTimeOfDay
        self.customDuration = customDuration
        self.frequencyMultiplier = frequencyMultiplier
    }
}

// MARK: - Category Analytics

struct CategoryAnalytics: Codable {
    let category: IntentionCategory
    var totalUsageCount: Int
    var completionRate: Double
    var averageDuration: TimeInterval
    var averageRating: Double
    let mostUsedTimeOfDay: TimeOfDay?
    var lastUsedDate: Date?
    let weeklyTrend: [Double] // Usage for each day of the week

    init(category: IntentionCategory, totalUsageCount: Int = 0, completionRate: Double = 0.0, averageDuration: TimeInterval = 0.0, averageRating: Double = 0.0, mostUsedTimeOfDay: TimeOfDay? = nil, lastUsedDate: Date? = nil, weeklyTrend: [Double] = []) {
        self.category = category
        self.totalUsageCount = totalUsageCount
        self.completionRate = completionRate
        self.averageDuration = averageDuration
        self.averageRating = averageRating
        self.mostUsedTimeOfDay = mostUsedTimeOfDay
        self.lastUsedDate = lastUsedDate
        self.weeklyTrend = weeklyTrend
    }

    var isPerformingWell: Bool {
        return completionRate > 0.7 && averageRating > 3.5
    }

    var needsAttention: Bool {
        return completionRate < 0.5 || averageRating < 2.5
    }

    var trendingUp: Bool {
        guard weeklyTrend.count >= 2 else { return false }
        let recentAverage = weeklyTrend.suffix(3).reduce(0, +) / 3
        let earlierAverage = weeklyTrend.prefix(3).reduce(0, +) / 3
        return recentAverage > earlierAverage * 1.2
    }
}

// MARK: - Category Manager

class CategoryManager: ObservableObject {
    @Published var categoryPreferences: [CategoryPreference] = []
    @Published var categoryAnalytics: [CategoryAnalytics] = []

    private let userDefaults = UserDefaults.standard
    private let preferencesKey = "CategoryPreferences"
    private let analyticsKey = "CategoryAnalytics"

    init() {
        loadPreferences()
        loadAnalytics()
        setupDefaultPreferencesIfNeeded()
    }

    // MARK: - Preference Management
    private func setupDefaultPreferencesIfNeeded() {
        if categoryPreferences.isEmpty {
            categoryPreferences = IntentionCategory.allCases.map { category in
                CategoryPreference(category: category)
            }
            savePreferences()
        }
    }

    func updatePreference(_ preference: CategoryPreference) {
        if let index = categoryPreferences.firstIndex(where: { $0.category == preference.category }) {
            categoryPreferences[index] = preference
            savePreferences()
        }
    }

    func getPreference(for category: IntentionCategory) -> CategoryPreference {
        return categoryPreferences.first { $0.category == category } ?? CategoryPreference(category: category)
    }

    func getEnabledCategories() -> [IntentionCategory] {
        return categoryPreferences.filter { $0.isEnabled }.map { $0.category }
    }

    func getCategoriesByPriority() -> [IntentionCategory] {
        return categoryPreferences
            .filter { $0.isEnabled }
            .sorted { $0.priority.weight > $1.priority.weight }
            .map { $0.category }
    }

    // MARK: - Analytics Management
    func recordUsage(category: IntentionCategory, duration: TimeInterval, completed: Bool, rating: Double? = nil) {
        var analytics = getAnalytics(for: category)
        analytics.totalUsageCount += 1

        if completed {
            // Update completion rate
            let completedCount = (Double(analytics.totalUsageCount) * analytics.completionRate) + 1
            analytics.completionRate = completedCount / Double(analytics.totalUsageCount)

            // Update average duration
            analytics.averageDuration = (analytics.averageDuration * Double(analytics.totalUsageCount - 1) + duration) / Double(analytics.totalUsageCount)

            // Update average rating if provided
            if let rating = rating {
                analytics.averageRating = (analytics.averageRating * Double(analytics.totalUsageCount - 1) + rating) / Double(analytics.totalUsageCount)
            }
        }

        analytics.lastUsedDate = Date()

        updateAnalytics(analytics)
    }

    func getAnalytics(for category: IntentionCategory) -> CategoryAnalytics {
        return categoryAnalytics.first { $0.category == category } ?? CategoryAnalytics(category: category)
    }

    private func updateAnalytics(_ analytics: CategoryAnalytics) {
        if let index = categoryAnalytics.firstIndex(where: { $0.category == analytics.category }) {
            categoryAnalytics[index] = analytics
        } else {
            categoryAnalytics.append(analytics)
        }
        saveAnalytics()
    }

    // MARK: - Data Persistence
    private func loadPreferences() {
        if let data = userDefaults.data(forKey: preferencesKey),
           let preferences = try? JSONDecoder().decode([CategoryPreference].self, from: data) {
            categoryPreferences = preferences
        }
    }

    private func savePreferences() {
        if let data = try? JSONEncoder().encode(categoryPreferences) {
            userDefaults.set(data, forKey: preferencesKey)
        }
    }

    private func loadAnalytics() {
        if let data = userDefaults.data(forKey: analyticsKey),
           let analytics = try? JSONDecoder().decode([CategoryAnalytics].self, from: data) {
            categoryAnalytics = analytics
        }
    }

    private func saveAnalytics() {
        if let data = try? JSONEncoder().encode(categoryAnalytics) {
            userDefaults.set(data, forKey: analyticsKey)
        }
    }
}