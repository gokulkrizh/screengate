import Foundation
import Combine

@MainActor
class IntentionSelectionService: ObservableObject {

    // MARK: - Published Properties
    @Published var selectedIntention: IntentionActivity?
    @Published var recentIntentions: [IntentionActivity] = []
    @Published var recommendedIntentions: [IntentionActivity] = []

    // MARK: - Private Properties
    private let maxRecentIntentions = 10
    private let userDefaults = UserDefaults.standard
    private let recentIntentionsKey = "RecentIntentions"
    private let usageHistoryKey = "IntentionUsageHistory"

    // MARK: - Shared Instance
    static let shared = IntentionSelectionService()

    private init() {
        loadRecentIntentions()
        loadUsageHistory()
    }

    // MARK: - Core Selection Logic

    /// Select the most appropriate intention based on multiple factors
    func selectIntention(
        for appBundleIdentifier: String,
        appName: String,
        userPreferences: UserIntentionPreference,
        timeOfDay: Date = Date()
    ) -> IntentionActivity {
        // Get candidate intentions based on user preferences
        let candidates = getCandidateIntentions(
            for: appBundleIdentifier,
            userPreferences: userPreferences
        )

        // Filter out recently used intentions if variety is preferred
        let filteredCandidates = filterForVariety(
            candidates: candidates,
            userPreferences: userPreferences
        )

        // Apply time-based logic
        let timeBasedCandidates = applyTimeBasedLogic(
            candidates: filteredCandidates,
            timeOfDay: timeOfDay,
            userPreferences: userPreferences
        )

        // Apply usage history learning
        let scoredCandidates = scoreIntentions(
            candidates: timeBasedCandidates,
            appBundleIdentifier: appBundleIdentifier,
            timeOfDay: timeOfDay
        )

        // Select the best candidate
        let selectedIntention = scoredCandidates.max { $0.score < $1.score }?.intention ?? getRandomIntention()

        // Record the selection
        recordIntentionUsage(selectedIntention, for: appBundleIdentifier)

        return selectedIntention
    }

    /// Get recommended intentions for specific context
    func getRecommendedIntentions(
        for appBundleIdentifier: String,
        userPreferences: UserIntentionPreference,
        count: Int = 3
    ) -> [IntentionActivity] {
        let candidates = getCandidateIntentions(
            for: appBundleIdentifier,
            userPreferences: userPreferences
        )

        let scoredCandidates = scoreIntentions(
            candidates: candidates,
            appBundleIdentifier: appBundleIdentifier,
            timeOfDay: Date()
        )

        return Array(scoredCandidates
            .sorted { $0.score > $1.score }
            .prefix(count)
            .map { $0.intention })
    }

    // MARK: - Private Selection Methods

    /// Get candidate intentions based on user preferences and app-specific settings
    private func getCandidateIntentions(
        for appBundleIdentifier: String,
        userPreferences: UserIntentionPreference
    ) -> [IntentionActivity] {
        // Check if there are app-specific intention assignments
        if let appSpecificIntentions = userPreferences.appIntentionMappings[appBundleIdentifier],
           !appSpecificIntentions.isEmpty {
            return appSpecificIntentions
        }

        // Check if there are category-specific preferences
        let category = getCategory(for: appBundleIdentifier)
        if let categoryIntentions = userPreferences.categoryIntentionMappings[category],
           !categoryIntentions.isEmpty {
            return categoryIntentions
        }

        // Fall back to global preferences
        if !userPreferences.preferredIntentionTypes.isEmpty {
            return IntentionLibraryManager.shared.getIntentionsByTypes(
                userPreferences.preferredIntentionTypes
            )
        }

        // Default to all available intentions
        return IntentionLibraryManager.shared.getAllIntentions()
    }

    /// Filter candidates for variety if user prefers variety
    private func filterForVariety(
        candidates: [IntentionActivity],
        userPreferences: UserIntentionPreference
    ) -> [IntentionActivity] {
        guard userPreferences.enableVariety else { return candidates }

        let recentIds = Set(recentIntentions.prefix(5).map { $0.id })
        return candidates.filter { !recentIds.contains($0.id) }
    }

    /// Apply time-based selection logic
    private func applyTimeBasedLogic(
        candidates: [IntentionActivity],
        timeOfDay: Date,
        userPreferences: UserIntentionPreference
    ) -> [IntentionActivity] {
        let hour = Calendar.current.component(.hour, from: timeOfDay)

        // Check for time-specific preferences
        let timePreferences = userPreferences.timeBasedPreferences

        for (timeRange, intentionIds) in timePreferences {
            if timeRange.contains(hour) {
                let timeSpecificIntentions = candidates.filter { intentionIds.contains($0.id) }
                if !timeSpecificIntentions.isEmpty {
                    return timeSpecificIntentions
                }
            }
        }

        // Apply general time-based recommendations
        switch hour {
        case 6...11: // Morning
            return candidates.filter { $0.category == .movement || $0.category == .mindfulness }
        case 12...14: // Midday
            return candidates.filter { $0.category == .breathing || $0.category == .quickBreak }
        case 15...17: // Afternoon
            return candidates.filter { $0.category == .movement || $0.category == .breathing }
        case 18...22: // Evening
            return candidates.filter { $0.category == .reflection || $0.category == .mindfulness }
        default: // Night
            return candidates.filter { $0.category == .breathing || $0.category == .reflection }
        }
    }

    /// Score intentions based on usage history and effectiveness
    private func scoreIntentions(
        candidates: [IntentionActivity],
        appBundleIdentifier: String,
        timeOfDay: Date
    ) -> [ScoredIntention] {
        let usageHistory = getUsageHistory()
        let hour = Calendar.current.component(.hour, from: timeOfDay)

        return candidates.map { intention in
            var score = 50.0 // Base score

            // Add score for completion rate
            let completionRate = getCompletionRate(for: intention.id, app: appBundleIdentifier)
            score += completionRate * 30

            // Add score for time-of-day effectiveness
            let timeEffectiveness = getTimeEffectiveness(for: intention.id, hour: hour)
            score += timeEffectiveness * 20

            // Add score for recent usage (to avoid overuse)
            let recentCount = recentIntentions.filter { $0.id == intention.id }.count
            score -= Double(recentCount) * 5

            // Add score for user preference strength
            score += Double(intention.category.preferenceWeight) * 10

            return ScoredIntention(intention: intention, score: score)
        }
    }

    // MARK: - Usage History Management

    /// Record when an intention is used
    private func recordIntentionUsage(_ intention: IntentionActivity, for app: String) {
        // Add to recent intentions
        recentIntentions.insert(intention, at: 0)
        if recentIntentions.count > maxRecentIntentions {
            recentIntentions.removeLast()
        }
        saveRecentIntentions()

        // Record in usage history
        var usageHistory = getUsageHistory()
        let usageEntry = IntentionUsageEntry(
            intentionId: intention.id,
            appBundleIdentifier: app,
            timestamp: Date(),
            completed: false // Will be updated when user completes the intention
        )
        usageHistory.append(usageEntry)
        saveUsageHistory(usageHistory)
    }

    /// Mark an intention as completed
    func markIntentionCompleted(_ intention: IntentionActivity, for app: String) {
        var usageHistory = getUsageHistory()
        if let lastIndex = usageHistory.lastIndex(where: {
            $0.intentionId == intention.id && $0.appBundleIdentifier == app && !$0.completed
        }) {
            usageHistory[lastIndex].completed = true
            usageHistory[lastIndex].completionTime = Date()
            saveUsageHistory(usageHistory)
        }
    }

    // MARK: - Analytics

    /// Get completion rate for a specific intention
    func getCompletionRate(for intentionId: String, app: String) -> Double {
        let usageHistory = getUsageHistory()
        let relevantEntries = usageHistory.filter {
            $0.intentionId == intentionId && $0.appBundleIdentifier == app
        }

        guard !relevantEntries.isEmpty else { return 0.5 } // Default rate

        let completedCount = relevantEntries.filter { $0.completed }.count
        return Double(completedCount) / Double(relevantEntries.count)
    }

    /// Get time-of-day effectiveness for an intention
    private func getTimeEffectiveness(for intentionId: String, hour: Int) -> Double {
        let usageHistory = getUsageHistory()
        let timeEntries = usageHistory.filter {
            $0.intentionId == intentionId &&
            Calendar.current.component(.hour, from: $0.timestamp) == hour
        }

        guard !timeEntries.isEmpty else { return 0.5 }

        let completedCount = timeEntries.filter { $0.completed }.count
        return Double(completedCount) / Double(timeEntries.count)
    }

    /// Get most effective intentions for specific time
    func getMostEffectiveIntentions(for hour: Int) -> [IntentionActivity] {
        let allIntentions = IntentionLibraryManager.shared.getAllIntentions()
        let scoredIntentions = allIntentions.map { intention in
            let effectiveness = getTimeEffectiveness(for: intention.id, hour: hour)
            return ScoredIntention(intention: intention, score: effectiveness * 100)
        }

        return scoredIntentions
            .sorted { $0.score > $1.score }
            .map { $0.intention }
    }

    // MARK: - Data Persistence

    private func loadRecentIntentions() {
        if let data = userDefaults.data(forKey: recentIntentionsKey),
           let intentions = try? JSONDecoder().decode([IntentionActivity].self, from: data) {
            recentIntentions = intentions
        }
    }

    private func saveRecentIntentions() {
        if let data = try? JSONEncoder().encode(recentIntentions) {
            userDefaults.set(data, forKey: recentIntentionsKey)
        }
    }

    private func getUsageHistory() -> [IntentionUsageEntry] {
        if let data = userDefaults.data(forKey: usageHistoryKey),
           let history = try? JSONDecoder().decode([IntentionUsageEntry].self, from: data) {
            return history
        }
        return []
    }

    private func loadUsageHistory() {
        _ = getUsageHistory() // Load into memory
    }

    private func saveUsageHistory(_ history: [IntentionUsageEntry]) {
        // Keep only last 1000 entries to prevent storage bloat
        let trimmedHistory = Array(history.suffix(1000))
        if let data = try? JSONEncoder().encode(trimmedHistory) {
            userDefaults.set(data, forKey: usageHistoryKey)
        }
    }

    // MARK: - Helper Methods

    private func getCategory(for appBundleIdentifier: String) -> String {
        // This would integrate with an app categorization service
        // For now, return a basic categorization
        let socialApps = ["com.facebook.Facebook", "com.instagram.instagram", "com.twitter.twitter"]
        let entertainmentApps = ["com.netflix.Netflix", "com.youtube.youtube"]
        let productivityApps = ["com.microsoft.Word", "com.apple.Pages"]

        if socialApps.contains(appBundleIdentifier) {
            return "social"
        } else if entertainmentApps.contains(appBundleIdentifier) {
            return "entertainment"
        } else if productivityApps.contains(appBundleIdentifier) {
            return "productivity"
        } else {
            return "other"
        }
    }

    private func getRandomIntention() -> IntentionActivity {
        let allIntentions = IntentionLibraryManager.shared.getAllIntentions()
        return allIntentions.randomElement() ?? IntentionActivity.breathingExercise
    }
}

// MARK: - Supporting Types

private struct ScoredIntention {
    let intention: IntentionActivity
    let score: Double
}

struct IntentionUsageEntry: Codable {
    let intentionId: String
    let appBundleIdentifier: String
    let timestamp: Date
    var completed: Bool
    var completionTime: Date?
}

extension ClosedRange where Bound == Int {
    func contains(_ hour: Int) -> Bool {
        return hour >= lowerBound && hour <= upperBound
    }
}