import Foundation
import SwiftUI
import Combine

// MARK: - Intention ViewModel

@MainActor
class IntentionViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var currentIntention: IntentionActivity?
    @Published var isIntentionActive: Bool = false
    @Published var completionProgress: Double = 0.0
    @Published var remainingTime: TimeInterval = 0
    @Published var isPaused: Bool = false
    @Published var isCompleted: Bool = false
    @Published var sourceAppInfo: SourceAppInfo?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    // MARK: - Private Properties
    private var timer: Timer?
    private var startTime: Date?
    private var pausedTime: TimeInterval = 0
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Services
    private let screenTimeService = ScreenTimeService.shared

    // MARK: - Computed Properties
    var progressPercentage: Double {
        guard let intention = currentIntention,
              let startTime = startTime,
              isIntentionActive && !isPaused else { return 0 }

        let elapsed = Date().timeIntervalSince(startTime) - pausedTime
        let progress = min(elapsed / intention.duration, 1.0)
        return max(0, progress)
    }

    var formattedRemainingTime: String {
        let time = max(remainingTime, 0)
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var formattedProgressTime: String {
        guard let intention = currentIntention else { return "00:00" }
        let elapsed = intention.duration * completionProgress
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Initialization
    init() {
        // Listen for deep link manager updates
        NotificationCenter.default.publisher(for: .deepLinkReceived)
            .compactMap { $0.object as? URL }
            .sink { [weak self] url in
                self?.handleDeepLink(url)
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods

    /// Start an intention activity
    func startIntention(_ intention: IntentionActivity, sourceInfo: SourceAppInfo? = nil) {
        currentIntention = intention
        sourceAppInfo = sourceInfo
        isIntentionActive = true
        isCompleted = false
        isPaused = false
        completionProgress = 0.0
        remainingTime = intention.duration
        startTime = Date()
        pausedTime = 0
        errorMessage = nil

        startTimer()
        logIntentionStart()
    }

    /// Pause the current intention
    func pauseIntention() {
        guard isIntentionActive && !isPaused else { return }

        isPaused = true
        timer?.invalidate()
        pausedTime += Date().timeIntervalSince(startTime ?? Date())
        logIntentionPause()
    }

    /// Resume a paused intention
    func resumeIntention() {
        guard isIntentionActive && isPaused else { return }

        isPaused = false
        startTime = Date()
        startTimer()
        logIntentionResume()
    }

    /// Complete the intention manually
    func completeIntention() {
        guard isIntentionActive else { return }

        timer?.invalidate()
        isIntentionActive = false
        isCompleted = true
        completionProgress = 1.0
        remainingTime = 0

        logIntentionComplete()
        saveCompletionAnalytics()
    }

    /// Skip the current intention
    func skipIntention() {
        guard isIntentionActive else { return }

        timer?.invalidate()
        isIntentionActive = false
        isCompleted = false
        completionProgress = 0

        logIntentionSkip()
    }

    /// Reset the intention state
    func resetIntention() {
        timer?.invalidate()
        currentIntention = nil
        isIntentionActive = false
        isCompleted = false
        isPaused = false
        completionProgress = 0.0
        remainingTime = 0
        sourceAppInfo = nil
        errorMessage = nil
        startTime = nil
        pausedTime = 0
    }

    // MARK: - Private Methods

    private func startTimer() {
        timer?.invalidate()

        // CRITICAL PERFORMANCE FIX: Changed from 0.1s to 1.0s (10x reduction in frequency)
        // This was causing 100% CPU usage by running 10 times per second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateProgress()
            }
        }
    }

    private func updateProgress() {
        guard let intention = currentIntention,
              let startTime = startTime,
              isIntentionActive && !isPaused else { return }

        let elapsed = Date().timeIntervalSince(startTime) - pausedTime
        let progress = min(elapsed / intention.duration, 1.0)

        completionProgress = progress
        remainingTime = max(intention.duration - elapsed, 0)

        // Auto-complete when finished
        if progress >= 1.0 {
            completeIntention()
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "screengate",
              url.host == "intention" else { return }

        // Extract intention data from deep link
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []

        let intentionId = queryItems.first(where: { $0.name == "intentionId" })?.value
        let intentionName = queryItems.first(where: { $0.name == "intentionName" })?.value
        let categoryString = queryItems.first(where: { $0.name == "category" })?.value
        let sourceApp = queryItems.first(where: { $0.name == "sourceApp" })?.value
        let sourceAppName = queryItems.first(where: { $0.name == "sourceAppName" })?.value
        let isFromCategory = queryItems.first(where: { $0.name == "isFromCategory" })?.value == "true"
        let durationString = queryItems.first(where: { $0.name == "duration" })?.value

        // Create intention from deep link data
        if let intentionId = intentionId,
           let intentionName = intentionName,
           let categoryString = categoryString,
           let durationString = durationString,
           let duration = TimeInterval(durationString) {

            let intention = createIntentionFromDeepLink(
                id: intentionId,
                name: intentionName,
                category: categoryString,
                duration: duration
            )

            let sourceInfo = SourceAppInfo(
                bundleIdentifier: sourceApp ?? "",
                appName: sourceAppName,
                isFromCategory: isFromCategory
            )

            startIntention(intention, sourceInfo: sourceInfo)
        }
    }

    private func createIntentionFromDeepLink(
        id: String,
        name: String,
        category: String,
        duration: TimeInterval
    ) -> IntentionActivity {
        // Map category string to IntentionCategory
        let intentionCategory: IntentionCategory
        switch category.lowercased() {
        case "breathing":
            intentionCategory = .breathing
        case "mindfulness":
            intentionCategory = .mindfulness
        case "reflection":
            intentionCategory = .reflection
        case "movement":
            intentionCategory = .movement
        case "quick break":
            intentionCategory = .quickBreak
        default:
            intentionCategory = .breathing
        }

        // Create appropriate content based on category
        let content: IntentionContent
        switch intentionCategory {
        case .breathing:
            content = .breathing(BreathingContent(
                pattern: .box,
                inhaleDuration: 4,
                holdDuration: 4,
                exhaleDuration: 4,
                pauseDuration: 4,
                cycles: Int(duration / 16),
                instructions: [
                    "Follow the breathing pattern",
                    "Inhale for 4 counts",
                    "Hold for 4 counts",
                    "Exhale for 4 counts",
                    "Pause for 4 counts"
                ]
            ))
        case .mindfulness:
            content = .mindfulness(MindfulnessContent(
                type: .presentMoment,
                script: ["Notice your breath", "Be present in this moment"],
                backgroundSound: .none
            ))
        case .reflection:
            content = .reflection(ReflectionContent(
                type: .gratitude,
                prompts: ["Take a deep breath", "Notice your thoughts", "Be kind to yourself"],
                journalingEnabled: false
            ))
        case .movement:
            content = .movement(MovementContent(
                type: .stretching,
                exercises: [
                    MovementExercise(
                        name: "Quick Stretch",
                        description: "Take a moment to stretch and move your body",
                        duration: duration,
                        repetitions: 1,
                        imageUrl: nil
                    )
                ]
            ))
        case .quickBreak:
            content = .quickBreak(QuickBreakContent(
                type: .walkAround,
                message: "Take a quick break to refresh your mind",
                action: "Step away from your screen for a moment",
                followUpSuggestions: ["Take a few deep breaths", "Stretch your arms", "Look out a window"]
            ))
        }

        return IntentionActivity(
            id: id,
            title: name,
            description: "Mindful intention to practice before continuing",
            category: intentionCategory,
            duration: duration,
            content: content,
            difficulty: .beginner,
            tags: ["shield-triggered"],
            isCustom: false,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    // MARK: - Analytics

    private func logIntentionStart() {
        guard let intention = currentIntention else { return }
        print("🎯 Intention Started: \(intention.title) (\(intention.category))")

        // Save to analytics
        saveIntentionEvent(type: .start)
    }

    private func logIntentionPause() {
        guard let intention = currentIntention else { return }
        print("⏸️ Intention Paused: \(intention.title)")

        saveIntentionEvent(type: .pause)
    }

    private func logIntentionResume() {
        guard let intention = currentIntention else { return }
        print("▶️ Intention Resumed: \(intention.title)")

        saveIntentionEvent(type: .resume)
    }

    private func logIntentionComplete() {
        guard let intention = currentIntention else { return }
        print("✅ Intention Completed: \(intention.title) in \(formattedProgressTime)")

        saveIntentionEvent(type: .complete)
    }

    private func logIntentionSkip() {
        guard let intention = currentIntention else { return }
        print("⏭️ Intention Skipped: \(intention.title)")

        saveIntentionEvent(type: .skip)
    }

    private func saveCompletionAnalytics() {
        guard let intention = currentIntention,
              let sourceApp = sourceAppInfo else { return }

        let completion = IntentionCompletion(
            intentionId: intention.id,
            intentionName: intention.title,
            category: intention.category,
            duration: intention.duration,
            actualDuration: intention.duration * completionProgress,
            completionRate: completionProgress,
            sourceApp: sourceApp.bundleIdentifier,
            sourceAppName: sourceApp.appName,
            isFromCategory: sourceApp.isFromCategory,
            completedAt: Date(),
            wasSkipped: !isCompleted
        )

        // Save to UserDefaults (simplified for now)
        var completions = getIntentionCompletions()
        completions.append(completion)
        saveIntentionCompletions(completions)
    }

    private func saveIntentionEvent(type: IntentionEventType) {
        guard let intention = currentIntention else { return }

        let event = IntentionEvent(
            intentionId: intention.id,
            type: type,
            timestamp: Date(),
            progress: completionProgress,
            sourceApp: sourceAppInfo?.bundleIdentifier
        )

        // Save event (simplified implementation)
        var events = getIntentionEvents()
        events.append(event)
        saveIntentionEvents(events)
    }

    // MARK: - Data Persistence (Simplified)

    private func getIntentionCompletions() -> [IntentionCompletion] {
        if let data = UserDefaults.standard.data(forKey: "IntentionCompletions"),
           let completions = try? JSONDecoder().decode([IntentionCompletion].self, from: data) {
            return completions
        }
        return []
    }

    private func saveIntentionCompletions(_ completions: [IntentionCompletion]) {
        if let data = try? JSONEncoder().encode(completions) {
            UserDefaults.standard.set(data, forKey: "IntentionCompletions")
        }
    }

    private func getIntentionEvents() -> [IntentionEvent] {
        if let data = UserDefaults.standard.data(forKey: "IntentionEvents"),
           let events = try? JSONDecoder().decode([IntentionEvent].self, from: data) {
            return events
        }
        return []
    }

    private func saveIntentionEvents(_ events: [IntentionEvent]) {
        if let data = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(data, forKey: "IntentionEvents")
        }
    }

    // MARK: - Deinit
    deinit {
        timer?.invalidate()
        cancellables.removeAll()
    }
}

// MARK: - Supporting Models

struct IntentionCompletion: Codable, Identifiable {
    let id: String
    let intentionId: String
    let intentionName: String
    let category: IntentionCategory
    let duration: TimeInterval
    let actualDuration: TimeInterval
    let completionRate: Double
    let sourceApp: String?
    let sourceAppName: String?
    let isFromCategory: Bool
    let completedAt: Date
    let wasSkipped: Bool

    init(intentionId: String, intentionName: String, category: IntentionCategory,
         duration: TimeInterval, actualDuration: TimeInterval, completionRate: Double,
         sourceApp: String?, sourceAppName: String?, isFromCategory: Bool,
         completedAt: Date, wasSkipped: Bool) {
        self.id = UUID().uuidString
        self.intentionId = intentionId
        self.intentionName = intentionName
        self.category = category
        self.duration = duration
        self.actualDuration = actualDuration
        self.completionRate = completionRate
        self.sourceApp = sourceApp
        self.sourceAppName = sourceAppName
        self.isFromCategory = isFromCategory
        self.completedAt = completedAt
        self.wasSkipped = wasSkipped
    }
}

struct IntentionEvent: Codable, Identifiable {
    let id: String
    let intentionId: String
    let type: IntentionEventType
    let timestamp: Date
    let progress: Double
    let sourceApp: String?

    init(intentionId: String, type: IntentionEventType, timestamp: Date,
         progress: Double, sourceApp: String?) {
        self.id = UUID().uuidString
        self.intentionId = intentionId
        self.type = type
        self.timestamp = timestamp
        self.progress = progress
        self.sourceApp = sourceApp
    }
}

enum IntentionEventType: String, Codable, CaseIterable {
    case start = "start"
    case pause = "pause"
    case resume = "resume"
    case complete = "complete"
    case skip = "skip"

    var displayName: String {
        switch self {
        case .start: return "Started"
        case .pause: return "Paused"
        case .resume: return "Resumed"
        case .complete: return "Completed"
        case .skip: return "Skipped"
        }
    }
}

// MARK: - Notification Extensions

extension Notification.Name {
    static let intentionStarted = Notification.Name("intentionStarted")
    static let intentionCompleted = Notification.Name("intentionCompleted")
    static let intentionPaused = Notification.Name("intentionPaused")
    static let intentionResumed = Notification.Name("intentionResumed")
    static let intentionSkipped = Notification.Name("intentionSkipped")
}
