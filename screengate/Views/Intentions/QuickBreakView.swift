import SwiftUI

// MARK: - Quick Break View

struct QuickBreakView: View {
    let content: QuickBreakContent
    let intention: IntentionActivity
    let progress: Double
    let remainingTime: TimeInterval
    let isActive: Bool
    let isPaused: Bool

    let onComplete: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void

    @State private var currentActivityIndex: Int = 0
    @State private var activityProgress: Double = 0.0
    @State private var isActivityActive: Bool = false
    @State private var completedActivities: Set<Int> = []
    @State private var breakTimer: Timer?
    @State private var showCompletionFeedback: Bool = false
    @State private var userFeedback: String = ""

    // MARK: - Computed Properties
    private var currentActivity: QuickBreakActivity {
        // Generate activities based on QuickBreakContent type and suggestions
        return QuickBreakActivity(
            id: content.type.rawValue,
            name: content.type.displayName,
            description: content.message,
            hint: content.followUpSuggestions.first ?? "Take a moment for yourself",
            duration: 60,
            systemImage: activitySystemImage
        )
    }

    private var completedCount: Int {
        completedActivities.count
    }

    private var totalActivities: Int {
        1 // Single activity per quick break
    }

    private var activitySystemImage: String {
        switch content.type {
        case .hydration:
            return "drop.fill"
        case .eyeRest:
            return "eye"
        case .walkAround:
            return "figure.walk"
        case .mentalReset:
            return "brain.head.profile"
        }
    }

    private var activityProgressPercentage: Double {
        guard totalActivities > 0 else { return 0 }
        return Double(completedCount) / Double(totalActivities)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                headerView

                // Main content
                VStack(spacing: 20) {
                    // Current activity
                    currentActivityView

                    // Activity interaction
                    activityInteractionView

                    // Progress indicator
                    activityProgressView

                    // Completion feedback
                    if showCompletionFeedback {
                        completionFeedbackView
                    }
                }

                // Progress bar
                IntentionProgressBarView(
                    progress: progress,
                    remainingTime: remainingTime,
                    isActive: isActive,
                    isPaused: isPaused
                )

                // Controls
                if isActive {
                    controlButtonsView
                }

                Spacer(minLength: 50)
            }
            .padding()
        }
        .onAppear {
            startBreakSession()
        }
        .onDisappear {
            stopBreakSession()
        }
        .onChange(of: isActive) { newValue in
            if newValue {
                startBreakSession()
            } else {
                stopBreakSession()
            }
        }
        .onChange(of: isPaused) { newValue in
            if newValue {
                pauseBreakSession()
            } else {
                resumeBreakSession()
            }
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 8) {
            Text(intention.title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(content.type.displayName)
                .font(.headline)
                .foregroundColor(.purple)

            if totalActivities > 1 {
                Text("Activity \(currentActivityIndex + 1) of \(totalActivities)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Current Activity View

    private var currentActivityView: some View {
        VStack(spacing: 16) {
            // Activity icon
            Image(systemName: currentActivity.systemImage)
                .font(.system(size: 50))
                .foregroundColor(.purple)
                .scaleEffect(isActivityActive ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isActivityActive)

            // Activity name
            Text(currentActivity.name)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            // Activity description
            Text(currentActivity.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Activity hint
            if !currentActivity.hint.isEmpty {
                HStack {
                    Image(systemName: "lightbulb")
                        .foregroundColor(.purple)
                    Text(currentActivity.hint)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color.purple.opacity(0.05))
        .cornerRadius(16)
    }

    // MARK: - Activity Interaction View

    private var activityInteractionView: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "hand.tap")
                    .foregroundColor(.purple)

                Text("Your Turn")
                    .font(.headline)
                    .foregroundColor(.purple)

                Spacer()
            }

            // Interactive content based on activity type
            activitySpecificInteraction

            // Quick completion button
            Button(action: completeCurrentActivity) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("I did it!")
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(25)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }

    // MARK: - Activity Specific Interaction

    @ViewBuilder
    private var activitySpecificInteraction: some View {
        switch content.type {
        case .hydration:
            waterBreakInteraction
        case .eyeRest:
            lookAwayInteraction
        case .walkAround:
            walkAroundInteraction
        case .mentalReset:
            mentalResetInteraction
        }
    }

    private var waterBreakInteraction: some View {
        VStack(spacing: 12) {
            Image(systemName: "drop.fill")
                .font(.system(size: 40))
                .foregroundColor(.blue)

            Text("Take a sip of water")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                ForEach(0..<3) { _ in
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding()
    }

    private var walkAroundInteraction: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.walk")
                .font(.system(size: 40))
                .foregroundColor(.green)

            Text("Stand up and walk around for a minute")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("🚶‍♀️ 🚶‍♂️")
                .font(.title2)
        }
        .padding()
    }

    private var lookAwayInteraction: some View {
        VStack(spacing: 12) {
            Image(systemName: "eye")
                .font(.system(size: 40))
                .foregroundColor(.orange)

            Text("Look at something 20 feet away for 20 seconds")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("👀 → 🏔️")
                .font(.title2)
        }
        .padding()
    }

    private var mentalResetInteraction: some View {
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 40))
                .foregroundColor(.purple)

            Text("Take three deep breaths and clear your mind")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                Text("☁️")
                    .font(.title2)
                Text("🧘")
                    .font(.title2)
                Text("✨")
                    .font(.title2)
            }
        }
        .padding()
    }

    private var genericInteraction: some View {
        VStack(spacing: 12) {
            Image(systemName: "star.fill")
                .font(.system(size: 40))
                .foregroundColor(.purple)

            Text("Take a moment to complete this activity")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    // MARK: - Activity Progress View

    private var activityProgressView: some View {
        VStack(spacing: 12) {
            Text("Break Progress")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack {
                ForEach(0..<totalActivities, id: \.self) { index in
                    Circle()
                        .fill(completedActivities.contains(index) ? Color.purple : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                        .scaleEffect(index == currentActivityIndex ? 1.3 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: currentActivityIndex)
                }

                Spacer()

                Text("\(Int(activityProgressPercentage * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.purple)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }

    // MARK: - Completion Feedback View

    private var completionFeedbackView: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "heart")
                    .foregroundColor(.pink)

                Text("How are you feeling?")
                    .font(.headline)
                    .foregroundColor(.pink)

                Spacer()
            }

            TextField("Share how you feel after this break...", text: $userFeedback, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            if !userFeedback.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Button(action: saveFeedback) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                        Text("Save Feedback")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.pink.opacity(0.1))
                    .foregroundColor(.pink)
                    .cornerRadius(20)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    // MARK: - Control Buttons View

    private var controlButtonsView: some View {
        HStack(spacing: 20) {
            if isPaused {
                Button(action: onResume) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        Text("Resume")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(25)
                }
            } else {
                Button(action: onPause) {
                    HStack {
                        Image(systemName: "pause.circle.fill")
                        Text("Pause")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(25)
                }

                Button(action: skipToNextActivity) {
                    HStack {
                        Image(systemName: "arrow.right.circle")
                        Text("Skip")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(25)
                }

                Button(action: onComplete) {
                    HStack {
                        Image(systemName: "flag.checkered")
                        Text("Finish")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(25)
                }
            }
        }
    }

    // MARK: - Session Management

    private func startBreakSession() {
        isActivityActive = true
        startActivityTimer()
        print("☕ Started quick break session")
    }

    private func pauseBreakSession() {
        isActivityActive = false
        breakTimer?.invalidate()
        print("⏸️ Paused quick break session")
    }

    private func resumeBreakSession() {
        isActivityActive = true
        startActivityTimer()
        print("▶️ Resumed quick break session")
    }

    private func stopBreakSession() {
        isActivityActive = false
        breakTimer?.invalidate()
        saveBreakData()
        print("⏹️ Stopped quick break session")
    }

    private func startActivityTimer() {
        breakTimer?.invalidate()

        guard currentActivity.duration > 0 else {
            // For activities without duration, don't use timer
            return
        }

        breakTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] _ in
            Task { @MainActor in
                self.updateActivityProgress()
            }
        }
    }

    private func updateActivityProgress() {
        guard currentActivity.duration > 0 else { return }

        activityProgress += 1.0 / currentActivity.duration

        if activityProgress >= 1.0 {
            // Auto-complete activity after duration
            completeCurrentActivity()
        }
    }

    private func completeCurrentActivity() {
        completedActivities.insert(currentActivityIndex)
        activityProgress = 0.0
        showCompletionFeedback = true
        print("✅ Completed activity: \(currentActivity.name)")

        // Auto-advance after showing feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            advanceToNextActivity()
        }
    }

    private func advanceToNextActivity() {
        // Since this is a single activity quick break, always complete
      if true {
            // All activities completed
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onComplete()
            }
            return
        }

        currentActivityIndex += 1
        activityProgress = 0.0
        print("☕ Advanced to activity \(currentActivityIndex + 1)")
    }

    private func skipToNextActivity() {
        advanceToNextActivity()
    }

    private func saveFeedback() {
        guard !userFeedback.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        // Save feedback (simplified implementation)
        var feedbackHistory = UserDefaults.standard.array(forKey: "BreakFeedback") as? [String] ?? []
        feedbackHistory.append(userFeedback)
        UserDefaults.standard.set(feedbackHistory, forKey: "BreakFeedback")

        showCompletionFeedback = false
        userFeedback = ""
        print("💾 Saved break feedback")
    }

    private func saveBreakData() {
        let breakData = QuickBreakData(
            intentionId: intention.id,
            intentionName: intention.title,
            type: content.type,
            activities: [], // Remove activities array
            completedActivities: Array(completedActivities),
            userFeedback: userFeedback,
            totalDuration: intention.duration * progress,
            completedAt: Date()
        )

        // Save to UserDefaults (simplified implementation)
        var allBreaks = getQuickBreaks()
        allBreaks.append(breakData)
        saveQuickBreaks(allBreaks)
        print("💾 Saved quick break data")
    }

    private func getQuickBreaks() -> [QuickBreakData] {
        if let data = UserDefaults.standard.data(forKey: "QuickBreaks"),
           let breaks = try? JSONDecoder().decode([QuickBreakData].self, from: data) {
            return breaks
        }
        return []
    }

    private func saveQuickBreaks(_ breaks: [QuickBreakData]) {
        if let data = try? JSONEncoder().encode(breaks) {
            UserDefaults.standard.set(data, forKey: "QuickBreaks")
        }
    }
}

// MARK: - Quick Break Data Model

struct QuickBreakData: Codable, Identifiable {
    let id: String
    let intentionId: String
    let intentionName: String
    let type: QuickBreakType
    let userFeedback: String
    let totalDuration: TimeInterval
    let completedAt: Date

    init(intentionId: String, intentionName: String, type: QuickBreakType,
         activities: [QuickBreakActivity], completedActivities: [Int],
         userFeedback: String, totalDuration: TimeInterval, completedAt: Date) {
        self.id = UUID().uuidString
        self.intentionId = intentionId
        self.intentionName = intentionName
        self.type = type
        self.userFeedback = userFeedback
        self.totalDuration = totalDuration
        self.completedAt = completedAt
    }
}


// MARK: - Quick Break Activity Extensions

// Create a struct for quick break activities since it's not in the models
struct QuickBreakActivity: Identifiable {
    let id: String
    let name: String
    let description: String
    let hint: String
    let duration: TimeInterval
    let systemImage: String

    static let defaultActivity = QuickBreakActivity(
        id: "mental-reset",
        name: "Quick Mental Reset",
        description: "Take a moment to clear your mind and refocus",
        hint: "Close your eyes and take three deep breaths",
        duration: 60,
        systemImage: "brain.head.profile"
    )
}

#Preview {
    QuickBreakView(
        content: QuickBreakContent(
            type: .hydration,
            message: "Your body needs water to function optimally. Take a few sips now.",
            action: "Drink a glass of water",
            followUpSuggestions: [
                "Set a reminder for your next water break",
                "Notice how your body feels after hydrating"
            ]
        ),
        intention: IntentionActivity.waterBreak,
        progress: 0.6,
        remainingTime: 120,
        isActive: true,
        isPaused: false,
        onComplete: {},
        onPause: {},
        onResume: {}
    )
}