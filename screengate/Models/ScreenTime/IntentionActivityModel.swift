import Foundation

// MARK: - Intention Activity Model

struct IntentionActivity: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let category: IntentionCategory
    let duration: TimeInterval
    let content: IntentionContent
    let difficulty: DifficultyLevel
    let tags: [String]
    var isCustom: Bool
    let createdAt: Date
    let updatedAt: Date

    // MARK: - Initialization
    init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        category: IntentionCategory,
        duration: TimeInterval,
        content: IntentionContent,
        difficulty: DifficultyLevel = .beginner,
        tags: [String] = [],
        isCustom: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.duration = duration
        self.content = content
        self.difficulty = difficulty
        self.tags = tags
        self.isCustom = isCustom
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Computed Properties
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }

    var isQuick: Bool {
        return duration <= 120 // 2 minutes or less
    }

    var isExtended: Bool {
        return duration > 600 // More than 10 minutes
    }

    // MARK: - Static Predefined Intentions
    static let breathingExercise = IntentionActivity(
        id: "breathing-box",
        title: "Box Breathing",
        description: "A simple breathing technique to calm your mind and reduce stress",
        category: .breathing,
        duration: 120,
        content: .breathing(
            BreathingContent(
                pattern: .box,
                inhaleDuration: 4,
                holdDuration: 4,
                exhaleDuration: 4,
                pauseDuration: 4,
                cycles: 8,
                instructions: [
                    "Inhale slowly for 4 counts",
                    "Hold your breath for 4 counts",
                    "Exhale slowly for 4 counts",
                    "Pause for 4 counts before the next cycle"
                ]
            )
        ),
        difficulty: .beginner,
        tags: ["stress", "anxiety", "focus", "quick"]
    )

    static let mindfulnessBodyScan = IntentionActivity(
        id: "mindfulness-body-scan",
        title: "Body Scan Meditation",
        description: "Bring awareness to different parts of your body and release tension",
        category: .mindfulness,
        duration: 300,
        content: .mindfulness(
            MindfulnessContent(
                type: .bodyScan,
                script: [
                    "Begin by finding a comfortable position",
                    "Bring your awareness to your toes",
                    "Slowly scan up through your feet and ankles",
                    "Notice any sensations without judgment",
                    "Continue scanning up through your legs",
                    "Bring awareness to your torso and chest",
                    "Scan your arms and hands",
                    "Finally, bring awareness to your neck and head"
                ],
                backgroundSound: .gentleAmbient
            )
        ),
        difficulty: .beginner,
        tags: ["relaxation", "awareness", "body", "stress"]
    )

    static let gratitudeReflection = IntentionActivity(
        id: "reflection-gratitude",
        title: "Gratitude Practice",
        description: "Take a moment to reflect on what you're grateful for",
        category: .reflection,
        duration: 180,
        content: .reflection(
            ReflectionContent(
                type: .gratitude,
                prompts: [
                    "What are three things you're grateful for right now?",
                    "Who in your life brings you joy and why?",
                    "What simple pleasure did you experience today?",
                    "What's something you often take for granted?",
                    "How can you express gratitude today?"
                ],
                journalingEnabled: true
            )
        ),
        difficulty: .beginner,
        tags: ["gratitude", "positivity", "reflection", "mood"]
    )

    static let deskStretches = IntentionActivity(
        id: "movement-desk-stretches",
        title: "Desk Stretches",
        description: "Simple stretches to relieve tension from sitting at your desk",
        category: .movement,
        duration: 240,
        content: .movement(
            MovementContent(
                type: .stretching,
                exercises: [
                    MovementExercise(
                        name: "Neck Rolls",
                        description: "Gently roll your neck in circles",
                        duration: 30,
                        repetitions: 5,
                        imageUrl: nil
                    ),
                    MovementExercise(
                        name: "Shoulder Shrugs",
                        description: "Lift your shoulders toward your ears, then release",
                        duration: 20,
                        repetitions: 10,
                        imageUrl: nil
                    ),
                    MovementExercise(
                        name: "Wrist Rotations",
                        description: "Rotate your wrists in circles",
                        duration: 20,
                        repetitions: 8,
                        imageUrl: nil
                    )
                ]
            )
        ),
        difficulty: .beginner,
        tags: ["desk", "stretching", "movement", "tension"]
    )

    static let waterBreak = IntentionActivity(
        id: "quick-water-break",
        title: "Hydration Break",
        description: "Take a moment to drink water and hydrate your body",
        category: .quickBreak,
        duration: 60,
        content: .quickBreak(
            QuickBreakContent(
                type: .hydration,
                message: "Your body needs water to function optimally. Take a few sips now.",
                action: "Drink a glass of water",
                followUpSuggestions: [
                    "Set a reminder for your next water break",
                    "Notice how your body feels after hydrating"
                ]
            )
        ),
        difficulty: .beginner,
        tags: ["hydration", "health", "quick", "energy"]
    )
}

// MARK: - Intention Content Types

enum IntentionContent: Codable, Hashable {
    case breathing(BreathingContent)
    case mindfulness(MindfulnessContent)
    case reflection(ReflectionContent)
    case movement(MovementContent)
    case quickBreak(QuickBreakContent)

    var type: String {
        switch self {
        case .breathing: return "breathing"
        case .mindfulness: return "mindfulness"
        case .reflection: return "reflection"
        case .movement: return "movement"
        case .quickBreak: return "quickBreak"
        }
    }
}

// MARK: - Breathing Content

struct BreathingContent: Codable, Hashable {
    let pattern: BreathingPattern
    let inhaleDuration: Int
    let holdDuration: Int
    let exhaleDuration: Int
    let pauseDuration: Int
    let cycles: Int
    let instructions: [String]
}

enum BreathingPattern: String, Codable, CaseIterable, Hashable {
    case box = "box"
    case fourSevenEight = "4-7-8"
    case diaphragmatic = "diaphragmatic"
    case equal = "equal"

    var displayName: String {
        switch self {
        case .box: return "Box Breathing"
        case .fourSevenEight: return "4-7-8 Breathing"
        case .diaphragmatic: return "Diaphragmatic Breathing"
        case .equal: return "Equal Breathing"
        }
    }
}

// MARK: - Mindfulness Content

struct MindfulnessContent: Codable, Hashable {
    let type: MindfulnessType
    let script: [String]
    let backgroundSound: BackgroundSound
}

enum MindfulnessType: String, Codable, CaseIterable, Hashable {
    case bodyScan = "bodyScan"
    case sensoryAwareness = "sensoryAwareness"
    case presentMoment = "presentMoment"
    case fiveSenses = "fiveSenses"

    var displayName: String {
        switch self {
        case .bodyScan: return "Body Scan"
        case .sensoryAwareness: return "Sensory Awareness"
        case .presentMoment: return "Present Moment"
        case .fiveSenses: return "Five Senses"
        }
    }
}

enum BackgroundSound: String, Codable, CaseIterable, Hashable {
    case none = "none"
    case gentleAmbient = "gentleAmbient"
    case rain = "rain"
    case ocean = "ocean"
    case forest = "forest"

    var displayName: String {
        switch self {
        case .none: return "None"
        case .gentleAmbient: return "Gentle Ambient"
        case .rain: return "Rain"
        case .ocean: return "Ocean"
        case .forest: return "Forest"
        }
    }
}

// MARK: - Reflection Content

struct ReflectionContent: Codable, Hashable {
    let type: ReflectionType
    let prompts: [String]
    let journalingEnabled: Bool
}

enum ReflectionType: String, Codable, CaseIterable, Hashable {
    case gratitude = "gratitude"
    case goalCheckIn = "goalCheckIn"
    case valuesReflection = "valuesReflection"
    case dailyReview = "dailyReview"

    var displayName: String {
        switch self {
        case .gratitude: return "Gratitude Practice"
        case .goalCheckIn: return "Goal Check-in"
        case .valuesReflection: return "Values Reflection"
        case .dailyReview: return "Daily Review"
        }
    }
}

// MARK: - Movement Content

struct MovementContent: Codable, Hashable {
    let type: MovementType
    let exercises: [MovementExercise]
}

enum MovementType: String, Codable, CaseIterable, Hashable {
    case stretching = "stretching"
    case eyeExercises = "eyeExercises"
    case posture = "posture"
    case energy = "energy"

    var displayName: String {
        switch self {
        case .stretching: return "Stretching"
        case .eyeExercises: return "Eye Exercises"
        case .posture: return "Posture Correction"
        case .energy: return "Energy Movements"
        }
    }
}

struct MovementExercise: Codable, Identifiable, Hashable {
    let id = UUID().uuidString
    let name: String
    let description: String
    let duration: TimeInterval
    let repetitions: Int?
    let imageUrl: String?
}

// MARK: - Quick Break Content

struct QuickBreakContent: Codable, Hashable {
    let type: QuickBreakType
    let message: String
    let action: String
    let followUpSuggestions: [String]
}

enum QuickBreakType: String, Codable, CaseIterable, Hashable {
    case hydration = "hydration"
    case eyeRest = "eyeRest"
    case walkAround = "walkAround"
    case mentalReset = "mentalReset"

    var displayName: String {
        switch self {
        case .hydration: return "Hydration Break"
        case .eyeRest: return "Eye Rest"
        case .walkAround: return "Walk Around"
        case .mentalReset: return "Mental Reset"
        }
    }
}

// MARK: - Supporting Types

enum DifficultyLevel: String, Codable, CaseIterable, Hashable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"

    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }

    var color: String {
        switch self {
        case .beginner: return "green"
        case .intermediate: return "yellow"
        case .advanced: return "red"
        }
    }
}