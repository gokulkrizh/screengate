import Foundation
import Combine

// MARK: - Intention Library Manager

class IntentionLibraryManager: ObservableObject {
    static let shared = IntentionLibraryManager()

    @Published var allIntentions: [IntentionActivity] = []
    @Published var customIntentions: [IntentionActivity] = []
    @Published var favoriteIntentions: [String] = [] // Store intention IDs

    private let userDefaults = UserDefaults.standard
    private let customIntentionsKey = "CustomIntentions"
    private let favoritesKey = "FavoriteIntentions"

    private init() {
        setupDefaultIntentions()
        loadCustomIntentions()
        loadFavorites()
    }

    // MARK: - Library Management
    func getAllIntentions() -> [IntentionActivity] {
        return allIntentions + customIntentions
    }

    func getIntentionsByCategory(_ category: IntentionCategory) -> [IntentionActivity] {
        return getAllIntentions().filter { $0.category == category }
    }

    func getIntentionsByTypes(_ types: [IntentionCategory]) -> [IntentionActivity] {
        return getAllIntentions().filter { types.contains($0.category) }
    }

    func getIntentionsByTag(_ tag: String) -> [IntentionActivity] {
        return getAllIntentions().filter { $0.tags.contains(tag) }
    }

    func getIntentionsByDifficulty(_ difficulty: DifficultyLevel) -> [IntentionActivity] {
        return getAllIntentions().filter { $0.difficulty == difficulty }
    }

    func getQuickIntentions(maxDuration: TimeInterval = 120) -> [IntentionActivity] {
        return getAllIntentions().filter { $0.isQuick && $0.duration <= maxDuration }
    }

    func searchIntentions(query: String) -> [IntentionActivity] {
        let lowercaseQuery = query.lowercased()
        return getAllIntentions().filter { intention in
            intention.title.lowercased().contains(lowercaseQuery) ||
            intention.description.lowercased().contains(lowercaseQuery) ||
            intention.tags.contains { $0.lowercased().contains(lowercaseQuery) }
        }
    }

    // MARK: - Custom Intentions
    func addCustomIntention(_ intention: IntentionActivity) {
        var customIntention = intention
        customIntention.isCustom = true
        customIntentions.append(customIntention)
        saveCustomIntentions()
    }

    func updateCustomIntention(_ intention: IntentionActivity) {
        if let index = customIntentions.firstIndex(where: { $0.id == intention.id }) {
            customIntentions[index] = intention
            saveCustomIntentions()
        }
    }

    func deleteCustomIntention(withId id: String) {
        customIntentions.removeAll { $0.id == id }
        removeFromFavorites(id: id)
        saveCustomIntentions()
    }

    // MARK: - Favorites
    func addToFavorites(id: String) {
        if !favoriteIntentions.contains(id) {
            favoriteIntentions.append(id)
            saveFavorites()
        }
    }

    func removeFromFavorites(id: String) {
        favoriteIntentions.removeAll { $0 == id }
        saveFavorites()
    }

    func toggleFavorite(id: String) {
        if favoriteIntentions.contains(id) {
            removeFromFavorites(id: id)
        } else {
            addToFavorites(id: id)
        }
    }

    func isFavorite(id: String) -> Bool {
        return favoriteIntentions.contains(id)
    }

    func getFavoriteIntentions() -> [IntentionActivity] {
        return getAllIntentions().filter { isFavorite(id: $0.id) }
    }

    // MARK: - Recommendations
    func getRecommendedIntentions(
        for mood: Mood? = nil,
        timeOfDay: TimeOfDay? = nil,
        duration: TimeInterval? = nil,
        excludeRecent: [IntentionActivity] = []
    ) -> [IntentionActivity] {
        var candidates = getAllIntentions()

        // Filter by mood
        if let mood = mood {
            candidates = candidates.filter { mood.recommendedCategories.contains($0.category) }
        }

        // Filter by time of day
        if let timeOfDay = timeOfDay {
            candidates = candidates.filter { timeOfDay.recommendedCategories.contains($0.category) }
        }

        // Filter by duration
        if let duration = duration {
            candidates = candidates.filter { abs($0.duration - duration) <= 60 } // Within 1 minute
        }

        // Exclude recent intentions
        let recentIds = Set(excludeRecent.map { $0.id })
        candidates = candidates.filter { !recentIds.contains($0.id) }

        // Sort by relevance
        return candidates.sorted { intention1, intention2 in
            let score1 = calculateRelevanceScore(intention1, mood: mood, timeOfDay: timeOfDay, duration: duration)
            let score2 = calculateRelevanceScore(intention2, mood: mood, timeOfDay: timeOfDay, duration: duration)
            return score1 > score2
        }
    }

    private func calculateRelevanceScore(
        _ intention: IntentionActivity,
        mood: Mood?,
        timeOfDay: TimeOfDay?,
        duration: TimeInterval?
    ) -> Double {
        var score = 0.0

        // Mood relevance
        if let mood = mood {
            score += mood.recommendedCategories.contains(intention.category) ? 30 : 0
        }

        // Time relevance
        if let timeOfDay = timeOfDay {
            score += timeOfDay.recommendedCategories.contains(intention.category) ? 20 : 0
        }

        // Duration relevance
        if let duration = duration {
            let durationDiff = abs(intention.duration - duration)
            score += max(0, 20 - durationDiff)
        }

        // Popularity bonus
        score += intention.category.popularityScore * 10

        // Favorite bonus
        if isFavorite(id: intention.id) {
            score += 15
        }

        return score
    }

    // MARK: - Default Intentions Setup
    private func setupDefaultIntentions() {
        allIntentions = [
            // Breathing Exercises
            .breathingExercise,

            IntentionActivity(
                id: "breathing-4-7-8",
                title: "4-7-8 Breathing",
                description: "A calming breathing technique to reduce anxiety and promote sleep",
                category: .breathing,
                duration: 180,
                content: .breathing(
                    BreathingContent(
                        pattern: .fourSevenEight,
                        inhaleDuration: 4,
                        holdDuration: 7,
                        exhaleDuration: 8,
                        pauseDuration: 0,
                        cycles: 6,
                        instructions: [
                            "Inhale through your nose for 4 counts",
                            "Hold your breath for 7 counts",
                            "Exhale through your mouth for 8 counts",
                            "Repeat for 6 cycles"
                        ]
                    )
                ),
                difficulty: .intermediate,
                tags: ["anxiety", "sleep", "relaxation", "stress"]
            ),

            // Mindfulness Exercises
            .mindfulnessBodyScan,

            IntentionActivity(
                id: "mindfulness-five-senses",
                title: "Five Senses Grounding",
                description: "Ground yourself by noticing five things you can see, hear, feel, smell, and taste",
                category: .mindfulness,
                duration: 240,
                content: .mindfulness(
                    MindfulnessContent(
                        type: .fiveSenses,
                        script: [
                            "Notice 5 things you can see around you",
                            "Notice 4 things you can hear",
                            "Notice 3 things you can feel (touch)",
                            "Notice 2 things you can smell",
                            "Notice 1 thing you can taste"
                        ],
                        backgroundSound: .none
                    )
                ),
                difficulty: .beginner,
                tags: ["grounding", "anxiety", "awareness", "panic"]
            ),

            // Reflection Activities
            .gratitudeReflection,

            IntentionActivity(
                id: "reflection-goal-check",
                title: "Goal Check-in",
                description: "Take a moment to review your goals and progress",
                category: .reflection,
                duration: 300,
                content: .reflection(
                    ReflectionContent(
                        type: .goalCheckIn,
                        prompts: [
                            "What progress have you made on your goals today?",
                            "What obstacles did you encounter?",
                            "What are you proud of accomplishing?",
                            "What will you focus on tomorrow?",
                            "How can you better support your goals?"
                        ],
                        journalingEnabled: true
                    )
                ),
                difficulty: .intermediate,
                tags: ["goals", "productivity", "planning", "motivation"]
            ),

            // Movement Activities
            .deskStretches,

            IntentionActivity(
                id: "movement-eye-exercises",
                title: "Eye Exercises",
                description: "Relieve eye strain from screen time with simple eye movements",
                category: .movement,
                duration: 120,
                content: .movement(
                    MovementContent(
                        type: .eyeExercises,
                        exercises: [
                            MovementExercise(
                                name: "Eye Rolls",
                                description: "Gently roll your eyes in circles",
                                duration: 20,
                                repetitions: 4,
                                imageUrl: nil
                            ),
                            MovementExercise(
                                name: "Focus Shift",
                                description: "Look at something near, then something far away",
                                duration: 30,
                                repetitions: 5,
                                imageUrl: nil
                            ),
                            MovementExercise(
                                name: "Palming",
                                description: "Cover your eyes with your palms and relax",
                                duration: 30,
                                repetitions: 1,
                                imageUrl: nil
                            )
                        ]
                    )
                ),
                difficulty: .beginner,
                tags: ["eyes", "strain", "screen", "relaxation"]
            ),

            // Quick Breaks
            .waterBreak,

            IntentionActivity(
                id: "quick-look-away",
                title: "20-20-20 Rule",
                description: "Look at something 20 feet away for 20 seconds",
                category: .quickBreak,
                duration: 30,
                content: .quickBreak(
                    QuickBreakContent(
                        type: .eyeRest,
                        message: "Give your eyes a break from the screen",
                        action: "Look at something 20 feet away for 20 seconds",
                        followUpSuggestions: [
                            "Set a reminder for regular eye breaks",
                            "Adjust your screen brightness",
                            "Check your posture"
                        ]
                    )
                ),
                difficulty: .beginner,
                tags: ["eyes", "screen", "health", "quick"]
            )
        ]
    }

    // MARK: - Data Persistence
    private func loadCustomIntentions() {
        if let data = userDefaults.data(forKey: customIntentionsKey),
           let intentions = try? JSONDecoder().decode([IntentionActivity].self, from: data) {
            customIntentions = intentions
        }
    }

    private func saveCustomIntentions() {
        if let data = try? JSONEncoder().encode(customIntentions) {
            userDefaults.set(data, forKey: customIntentionsKey)
        }
    }

    private func loadFavorites() {
        favoriteIntentions = userDefaults.stringArray(forKey: favoritesKey) ?? []
    }

    private func saveFavorites() {
        userDefaults.set(favoriteIntentions, forKey: favoritesKey)
    }
}

// MARK: - Intention Templates

struct IntentionTemplate {
    let name: String
    let description: String
    let category: IntentionCategory
    let estimatedDuration: TimeInterval
    let difficulty: DifficultyLevel
    let tags: [String]

    func createIntention() -> IntentionActivity {
        return IntentionActivity(
            title: name,
            description: description,
            category: category,
            duration: estimatedDuration,
            content: getDefaultContent(for: category),
            difficulty: difficulty,
            tags: tags,
            isCustom: true
        )
    }

    private func getDefaultContent(for category: IntentionCategory) -> IntentionContent {
        switch category {
        case .breathing:
            return .breathing(
                BreathingContent(
                    pattern: .equal,
                    inhaleDuration: 4,
                    holdDuration: 0,
                    exhaleDuration: 4,
                    pauseDuration: 2,
                    cycles: 8,
                    instructions: ["Breathe in", "Breathe out", "Pause"]
                )
            )
        case .mindfulness:
            return .mindfulness(
                MindfulnessContent(
                    type: .presentMoment,
                    script: ["Focus on your breath", "Notice your surroundings"],
                    backgroundSound: .gentleAmbient
                )
            )
        case .reflection:
            return .reflection(
                ReflectionContent(
                    type: .dailyReview,
                    prompts: ["How are you feeling?", "What went well today?"],
                    journalingEnabled: true
                )
            )
        case .movement:
            return .movement(
                MovementContent(
                    type: .stretching,
                    exercises: [
                        MovementExercise(name: "Stretch", description: "Gentle stretch", duration: 30, repetitions: 1, imageUrl: nil)
                    ]
                )
            )
        case .quickBreak:
            return .quickBreak(
                QuickBreakContent(
                    type: .mentalReset,
                    message: "Take a quick break",
                    action: "Step away for a moment",
                    followUpSuggestions: ["Breathe deeply", "Stretch"]
                )
            )
        }
    }
}

// MARK: - Template Library

extension IntentionLibraryManager {
    static let templates: [IntentionTemplate] = [
        IntentionTemplate(
            name: "Custom Breathing",
            description: "Create your own breathing exercise",
            category: .breathing,
            estimatedDuration: 120,
            difficulty: .beginner,
            tags: ["breathing", "custom", "relaxation"]
        ),
        IntentionTemplate(
            name: "Custom Meditation",
            description: "Design your own meditation practice",
            category: .mindfulness,
            estimatedDuration: 300,
            difficulty: .intermediate,
            tags: ["meditation", "custom", "mindfulness"]
        ),
        IntentionTemplate(
            name: "Custom Journal Prompt",
            description: "Create a personal reflection prompt",
            category: .reflection,
            estimatedDuration: 180,
            difficulty: .beginner,
            tags: ["journaling", "custom", "reflection"]
        ),
        IntentionTemplate(
            name: "Custom Exercise",
            description: "Design your own movement activity",
            category: .movement,
            estimatedDuration: 240,
            difficulty: .intermediate,
            tags: ["exercise", "custom", "movement"]
        )
    ]

    func createIntentionFromTemplate(_ template: IntentionTemplate) -> IntentionActivity {
        return template.createIntention()
    }
}