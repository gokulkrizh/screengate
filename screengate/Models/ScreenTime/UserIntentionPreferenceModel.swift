import Foundation
import Combine

// MARK: - User Intention Preference Model

struct UserIntentionPreference: Codable, Equatable {
    // MARK: - Core Preferences
    var preferredIntentionTypes: [IntentionCategory]
    var enableVariety: Bool
    var maxDailyIntentions: Int
    var defaultIntentionDuration: TimeInterval
    var enableSmartSelection: Bool

    // MARK: - App-Specific Mappings
    var appIntentionMappings: [String: [IntentionActivity]] // App bundle ID -> intentions
    var categoryIntentionMappings: [String: [IntentionActivity]] // App category -> intentions

    // MARK: - Time-Based Preferences
    var timeBasedPreferences: [ClosedRange<Int>: [String]] // Hour range -> intention IDs
    var moodBasedPreferences: [Mood: [IntentionCategory]]

    // MARK: - Notification Preferences
    var enableIntentionReminders: Bool
    var reminderFrequency: ReminderFrequency
    var reminderTimes: [DateComponents]
    var enableProgressNotifications: Bool

    // MARK: - Learning & Adaptation
    var enableLearningMode: Bool
    var adaptationRate: AdaptationRate
    var resetLearnedPreferences: Bool

    // MARK: - UI Preferences
    var showIntentionPreviews: Bool
    var enableHapticFeedback: Bool
    var preferredVoiceGender: VoiceGender?
    var backgroundMusicEnabled: Bool

    // MARK: - Advanced Settings
    var enableAnalytics: Bool
    var dataRetentionDays: Int
    var shareUsageData: Bool
    var experimentalFeaturesEnabled: Bool

    // MARK: - Initialization
    init(
        preferredIntentionTypes: [IntentionCategory] = [.breathing, .quickBreak, .mindfulness],
        enableVariety: Bool = true,
        maxDailyIntentions: Int = 20,
        defaultIntentionDuration: TimeInterval = 180,
        enableSmartSelection: Bool = true,
        appIntentionMappings: [String: [IntentionActivity]] = [:],
        categoryIntentionMappings: [String: [IntentionActivity]] = [:],
        timeBasedPreferences: [ClosedRange<Int>: [String]] = [:],
        moodBasedPreferences: [Mood: [IntentionCategory]] = [:],
        enableIntentionReminders: Bool = true,
        reminderFrequency: ReminderFrequency = .daily,
        reminderTimes: [DateComponents] = [],
        enableProgressNotifications: Bool = true,
        enableLearningMode: Bool = true,
        adaptationRate: AdaptationRate = .moderate,
        resetLearnedPreferences: Bool = false,
        showIntentionPreviews: Bool = true,
        enableHapticFeedback: Bool = true,
        preferredVoiceGender: VoiceGender? = nil,
        backgroundMusicEnabled: Bool = false,
        enableAnalytics: Bool = true,
        dataRetentionDays: Int = 90,
        shareUsageData: Bool = false,
        experimentalFeaturesEnabled: Bool = false
    ) {
        self.preferredIntentionTypes = preferredIntentionTypes
        self.enableVariety = enableVariety
        self.maxDailyIntentions = maxDailyIntentions
        self.defaultIntentionDuration = defaultIntentionDuration
        self.enableSmartSelection = enableSmartSelection
        self.appIntentionMappings = appIntentionMappings
        self.categoryIntentionMappings = categoryIntentionMappings
        self.timeBasedPreferences = timeBasedPreferences
        self.moodBasedPreferences = moodBasedPreferences
        self.enableIntentionReminders = enableIntentionReminders
        self.reminderFrequency = reminderFrequency
        self.reminderTimes = reminderTimes.isEmpty ? [DateComponents(hour: 9, minute: 0)] : reminderTimes
        self.enableProgressNotifications = enableProgressNotifications
        self.enableLearningMode = enableLearningMode
        self.adaptationRate = adaptationRate
        self.resetLearnedPreferences = resetLearnedPreferences
        self.showIntentionPreviews = showIntentionPreviews
        self.enableHapticFeedback = enableHapticFeedback
        self.preferredVoiceGender = preferredVoiceGender
        self.backgroundMusicEnabled = backgroundMusicEnabled
        self.enableAnalytics = enableAnalytics
        self.dataRetentionDays = dataRetentionDays
        self.shareUsageData = shareUsageData
        self.experimentalFeaturesEnabled = experimentalFeaturesEnabled
    }

    // MARK: - Default Configuration
    static let `default` = UserIntentionPreference()

    // MARK: - Computed Properties
    var isCustomized: Bool {
        return self != UserIntentionPreference.default
    }

    // Add Equatable conformance to make comparison work
    static func == (lhs: UserIntentionPreference, rhs: UserIntentionPreference) -> Bool {
        return lhs.preferredIntentionTypes == rhs.preferredIntentionTypes &&
               lhs.enableVariety == rhs.enableVariety &&
               lhs.maxDailyIntentions == rhs.maxDailyIntentions
    }

    var activeCategories: [IntentionCategory] {
        return preferredIntentionTypes.filter { category in
            categoryIntentionMappings.values.flatMap { $0 }.contains { $0.category == category } ||
            appIntentionMappings.values.flatMap { $0 }.contains { $0.category == category }
        }
    }
}

// MARK: - Supporting Enums

enum Mood: String, Codable, CaseIterable {
    case stressed = "stressed"
    case anxious = "anxious"
    case tired = "tired"
    case unfocused = "unfocused"
    case happy = "happy"
    case calm = "calm"
    case energetic = "energetic"
    case sad = "sad"

    var displayName: String {
        switch self {
        case .stressed: return "Stressed"
        case .anxious: return "Anxious"
        case .tired: return "Tired"
        case .unfocused: return "Unfocused"
        case .happy: return "Happy"
        case .calm: return "Calm"
        case .energetic: return "Energetic"
        case .sad: return "Sad"
        }
    }

    var recommendedCategories: [IntentionCategory] {
        switch self {
        case .stressed, .anxious:
            return [.breathing, .mindfulness, .reflection]
        case .tired:
            return [.movement, .quickBreak, .breathing]
        case .unfocused:
            return [.breathing, .quickBreak, .mindfulness]
        case .happy:
            return [.reflection]
        case .calm:
            return [.mindfulness, .reflection]
        case .energetic:
            return [.quickBreak, .movement]
        case .sad:
            return [.reflection, .mindfulness, .breathing]
        }
    }

    var iconName: String {
        switch self {
        case .stressed: return "exclamationmark.triangle.fill"
        case .anxious: return "heart.circle.fill"
        case .tired: return "bed.double.fill"
        case .unfocused: return "eye.slash.fill"
        case .happy: return "face.smiling.fill"
        case .calm: return "leaf.fill"
        case .energetic: return "bolt.fill"
        case .sad: return "cloud.rain.fill"
        }
    }
}

enum ReminderFrequency: String, Codable, CaseIterable {
    case never = "never"
    case daily = "daily"
    case twiceDaily = "twiceDaily"
    case weekly = "weekly"

    var displayName: String {
        switch self {
        case .never: return "Never"
        case .daily: return "Daily"
        case .twiceDaily: return "Twice Daily"
        case .weekly: return "Weekly"
        }
    }

    var description: String {
        switch self {
        case .never: return "No automatic reminders"
        case .daily: return "Once per day"
        case .twiceDaily: return "Twice per day"
        case .weekly: return "Once per week"
        }
    }
}

enum AdaptationRate: String, Codable, CaseIterable {
    case slow = "slow"
    case moderate = "moderate"
    case fast = "fast"

    var displayName: String {
        switch self {
        case .slow: return "Slow"
        case .moderate: return "Moderate"
        case .fast: return "Fast"
        }
    }

    var learningFactor: Double {
        switch self {
        case .slow: return 0.1
        case .moderate: return 0.3
        case .fast: return 0.5
        }
    }

    var description: String {
        switch self {
        case .slow: return "Gradually learns preferences over time"
        case .moderate: return "Balanced learning pace"
        case .fast: return "Quickly adapts to your patterns"
        }
    }
}

enum VoiceGender: String, Codable, CaseIterable {
    case male = "male"
    case female = "female"
    case neutral = "neutral"

    var displayName: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        case .neutral: return "Neutral"
        }
    }
}

// MARK: - Preference Manager

class UserIntentionPreferenceManager: ObservableObject {
    @Published var preferences: UserIntentionPreference = .default

    private let userDefaults = UserDefaults.standard
    private let preferencesKey = "UserIntentionPreferences"

    init() {
        loadPreferences()
    }

    // MARK: - Preference Management
    func updatePreferences(_ newPreferences: UserIntentionPreference) {
        preferences = newPreferences
        savePreferences()
    }

    func updateAppIntentionMapping(appBundleId: String, intentions: [IntentionActivity]) {
        preferences.appIntentionMappings[appBundleId] = intentions
        savePreferences()
    }

    func removeAppIntentionMapping(appBundleId: String) {
        preferences.appIntentionMappings.removeValue(forKey: appBundleId)
        savePreferences()
    }

    func updateCategoryIntentionMapping(category: String, intentions: [IntentionActivity]) {
        preferences.categoryIntentionMappings[category] = intentions
        savePreferences()
    }

    func updateTimeBasedPreference(hourRange: ClosedRange<Int>, intentionIds: [String]) {
        preferences.timeBasedPreferences[hourRange] = intentionIds
        savePreferences()
    }

    func removeTimeBasedPreference(hourRange: ClosedRange<Int>) {
        preferences.timeBasedPreferences.removeValue(forKey: hourRange)
        savePreferences()
    }

    func updateMoodPreference(mood: Mood, categories: [IntentionCategory]) {
        preferences.moodBasedPreferences[mood] = categories
        savePreferences()
    }

    // MARK: - Quick Updates
    func addPreferredIntentionType(_ category: IntentionCategory) {
        if !preferences.preferredIntentionTypes.contains(category) {
            preferences.preferredIntentionTypes.append(category)
            savePreferences()
        }
    }

    func removePreferredIntentionType(_ category: IntentionCategory) {
        preferences.preferredIntentionTypes.removeAll { $0 == category }
        savePreferences()
    }

    func toggleVariety() {
        preferences.enableVariety.toggle()
        savePreferences()
    }

    func updateMaxDailyIntentions(_ count: Int) {
        preferences.maxDailyIntentions = max(1, min(100, count))
        savePreferences()
    }

    func updateDefaultDuration(_ duration: TimeInterval) {
        preferences.defaultIntentionDuration = max(30, min(1800, duration)) // 30s to 30min
        savePreferences()
    }

    // MARK: - Reset Functions
    func resetToDefaults() {
        preferences = .default
        savePreferences()
    }

    func resetLearnedPreferences() {
        preferences.appIntentionMappings.removeAll()
        preferences.categoryIntentionMappings.removeAll()
        preferences.timeBasedPreferences.removeAll()
        preferences.moodBasedPreferences.removeAll()
        savePreferences()
    }

    // MARK: - Data Persistence
    private func loadPreferences() {
        if let data = userDefaults.data(forKey: preferencesKey),
           let loadedPreferences = try? JSONDecoder().decode(UserIntentionPreference.self, from: data) {
            preferences = loadedPreferences
        }
    }

    private func savePreferences() {
        if let data = try? JSONEncoder().encode(preferences) {
            userDefaults.set(data, forKey: preferencesKey)
        }
    }

    // MARK: - Validation
    func validatePreferences() -> [ValidationError] {
        var errors: [ValidationError] = []

        if preferences.preferredIntentionTypes.isEmpty {
            errors.append(.noPreferredTypes)
        }

        if preferences.maxDailyIntentions < 1 || preferences.maxDailyIntentions > 100 {
            errors.append(.invalidMaxDailyIntentions)
        }

        if preferences.defaultIntentionDuration < 30 || preferences.defaultIntentionDuration > 1800 {
            errors.append(.invalidDefaultDuration)
        }

        return errors
    }
}

// MARK: - Validation Error

enum ValidationError: LocalizedError {
    case noPreferredTypes
    case invalidMaxDailyIntentions
    case invalidDefaultDuration

    var errorDescription: String? {
        switch self {
        case .noPreferredTypes:
            return "At least one intention type must be preferred"
        case .invalidMaxDailyIntentions:
            return "Maximum daily intentions must be between 1 and 100"
        case .invalidDefaultDuration:
            return "Default duration must be between 30 seconds and 30 minutes"
        }
    }
}

// MARK: - Extensions

// Note: ClosedRange<Int> already conforms to Codable in Swift framework
// No need for custom implementation