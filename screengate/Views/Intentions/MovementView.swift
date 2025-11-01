import SwiftUI

// MARK: - Movement View

struct MovementView: View {
    let content: MovementContent
    let intention: IntentionActivity
    let progress: Double
    let remainingTime: TimeInterval
    let isActive: Bool
    let isPaused: Bool

    let onComplete: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void

    @State private var currentExerciseIndex: Int = 0
    @State private var exerciseProgress: Double = 0.0
    @State private var isExerciseActive: Bool = false
    @State private var completedExercises: Set<Int> = []
    @State private var movementTimer: Timer?
    @State private var currentInstructionIndex: Int = 0

    // MARK: - Computed Properties
    private var currentExercise: MovementExercise {
        guard currentExerciseIndex < content.exercises.count else {
            return content.exercises.first ?? .defaultExercise
        }
        return content.exercises[currentExerciseIndex]
    }

    private var completedCount: Int {
        completedExercises.count
    }

    private var totalExercises: Int {
        content.exercises.count
    }

    private var exerciseProgressPercentage: Double {
        guard totalExercises > 0 else { return 0 }
        return Double(completedCount) / Double(totalExercises)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                headerView

                // Main content
                VStack(spacing: 20) {
                    // Current exercise
                    currentExerciseView

                    // Exercise instructions
                    exerciseInstructionsView

                    // Progress indicator
                    exerciseProgressView
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
            startMovementSession()
        }
        .onDisappear {
            stopMovementSession()
        }
        .onChange(of: isActive) { newValue in
            if newValue {
                startMovementSession()
            } else {
                stopMovementSession()
            }
        }
        .onChange(of: isPaused) { newValue in
            if newValue {
                pauseMovementSession()
            } else {
                resumeMovementSession()
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
                .foregroundColor(.green)

            if totalExercises > 1 {
                Text("Exercise \(currentExerciseIndex + 1) of \(totalExercises)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Current Exercise View

    private var currentExerciseView: some View {
        VStack(spacing: 16) {
            // Exercise icon
            Image(systemName: exerciseSystemImage)
                .font(.system(size: 50))
                .foregroundColor(.green)
                .scaleEffect(isExerciseActive ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isExerciseActive)

            // Exercise name
            Text(currentExercise.name)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            // Exercise description
            Text(currentExercise.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Duration indicator
            if currentExercise.duration > 0 {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.green)
                    Text("\(Int(currentExercise.duration)) seconds")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            // Repetition indicator
            if (currentExercise.repetitions ?? 0) > 0 {
                HStack {
                    Image(systemName: "repeat")
                        .foregroundColor(.green)
                    Text("\(currentExercise.repetitions ?? 0) reps")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.05))
        .cornerRadius(16)
    }

    // MARK: - Exercise Instructions View

    private var exerciseInstructionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "list.bullet")
                    .foregroundColor(.green)

                Text("Instructions")
                    .font(.headline)
                    .foregroundColor(.green)

                Spacer()
            }

            if !exerciseInstructions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(exerciseInstructions.enumerated()), id: \.offset) { index, instruction in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(index + 1).")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(width: 20, alignment: .leading)

                            Text(instruction)
                                .font(.body)
                                .foregroundColor(.primary)

                            Spacer()
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }

    // MARK: - Exercise Progress View

    private var exerciseProgressView: some View {
        VStack(spacing: 12) {
            Text("Movement Progress")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack {
                ForEach(0..<totalExercises, id: \.self) { index in
                    Circle()
                        .fill(completedExercises.contains(index) ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                        .scaleEffect(index == currentExerciseIndex ? 1.3 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: currentExerciseIndex)
                }

                Spacer()

                Text("\(Int(exerciseProgressPercentage * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
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
                    .background(Color.green)
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

                Button(action: completeCurrentExercise) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                        Text("Complete")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(25)
                }

                Button(action: skipToNextExercise) {
                    HStack {
                        Image(systemName: "arrow.right.circle")
                        Text("Next")
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
                        Text("Finish All")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(25)
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var exerciseSystemImage: String {
        switch currentExercise.name.lowercased() {
        case let name where name.contains("neck"):
            return "figure.mind.and.body"
        case let name where name.contains("shoulder"):
            return "figure.arms.open"
        case let name where name.contains("wrist"):
            return "hand.wave"
        case let name where name.contains("back"):
            return "figure.stand"
        case let name where name.contains("eye"):
            return "eye"
        default:
            return "figure.walk"
        }
    }

    private var exerciseInstructions: [String] {
        // Generate instructions based on exercise name
        switch currentExercise.name.lowercased() {
        case let name where name.contains("neck"):
            return [
                "Slowly tilt your head to the right",
                "Hold for 10 seconds",
                "Return to center",
                "Tilt your head to the left",
                "Hold for 10 seconds"
            ]
        case let name where name.contains("shoulder"):
            return [
                "Lift your shoulders toward your ears",
                "Hold for 5 seconds",
                "Release and let shoulders drop",
                "Repeat for recommended repetitions"
            ]
        case let name where name.contains("wrist"):
            return [
                "Extend your arms in front of you",
                "Rotate wrists in clockwise circles",
                "Rotate wrists in counter-clockwise circles",
                "Repeat for recommended repetitions"
            ]
        default:
            return [
                "Follow the exercise description",
                "Maintain proper form",
                "Complete the recommended repetitions",
                "Listen to your body"
            ]
        }
    }

    // MARK: - Session Management

    private func startMovementSession() {
        isExerciseActive = true
        startExerciseTimer()
        print("🏃 Started movement session")
    }

    private func pauseMovementSession() {
        isExerciseActive = false
        movementTimer?.invalidate()
        print("⏸️ Paused movement session")
    }

    private func resumeMovementSession() {
        isExerciseActive = true
        startExerciseTimer()
        print("▶️ Resumed movement session")
    }

    private func stopMovementSession() {
        isExerciseActive = false
        movementTimer?.invalidate()
        saveMovementData()
        print("⏹️ Stopped movement session")
    }

    private func startExerciseTimer() {
        movementTimer?.invalidate()

        guard currentExercise.duration > 0 else {
            // For exercises without duration, don't use timer
            return
        }

        movementTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] _ in
            Task { @MainActor in
                self.updateExerciseProgress()
            }
        }
    }

    private func updateExerciseProgress() {
        guard currentExercise.duration > 0 else { return }

        exerciseProgress += 1.0 / currentExercise.duration

        if exerciseProgress >= 1.0 {
            // Auto-complete exercise after duration
            completeCurrentExercise()
        }
    }

    private func completeCurrentExercise() {
        completedExercises.insert(currentExerciseIndex)
        exerciseProgress = 0.0
        print("✅ Completed exercise: \(currentExercise.name)")

        // Auto-advance to next exercise after a brief pause
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            advanceToNextExercise()
        }
    }

    private func advanceToNextExercise() {
        guard currentExerciseIndex < content.exercises.count - 1 else {
            // All exercises completed
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onComplete()
            }
            return
        }

        currentExerciseIndex += 1
        exerciseProgress = 0.0
        currentInstructionIndex = 0
        print("🏃 Advanced to exercise \(currentExerciseIndex + 1)")
    }

    private func skipToNextExercise() {
        advanceToNextExercise()
    }

    private func saveMovementData() {
        let movementData = MovementData(
            intentionId: intention.id,
            intentionName: intention.title,
            type: content.type,
            exercises: content.exercises,
            completedExercises: Array(completedExercises),
            totalDuration: intention.duration * progress,
            completedAt: Date()
        )

        // Save to UserDefaults (simplified implementation)
        var allMovements = getMovements()
        allMovements.append(movementData)
        saveMovements(allMovements)
        print("💾 Saved movement data")
    }

    private func getMovements() -> [MovementData] {
        if let data = UserDefaults.standard.data(forKey: "Movements"),
           let movements = try? JSONDecoder().decode([MovementData].self, from: data) {
            return movements
        }
        return []
    }

    private func saveMovements(_ movements: [MovementData]) {
        if let data = try? JSONEncoder().encode(movements) {
            UserDefaults.standard.set(data, forKey: "Movements")
        }
    }
}

// MARK: - Movement Data Model

struct MovementData: Codable, Identifiable {
    let id: String
    let intentionId: String
    let intentionName: String
    let type: MovementType
    let exercises: [MovementExercise]
    let completedExercises: [Int]
    let totalDuration: TimeInterval
    let completedAt: Date

    init(intentionId: String, intentionName: String, type: MovementType,
         exercises: [MovementExercise], completedExercises: [Int],
         totalDuration: TimeInterval, completedAt: Date) {
        self.id = UUID().uuidString
        self.intentionId = intentionId
        self.intentionName = intentionName
        self.type = type
        self.exercises = exercises
        self.completedExercises = completedExercises
        self.totalDuration = totalDuration
        self.completedAt = completedAt
    }
}


// MARK: - Movement Exercise Extensions

extension MovementExercise {
    static let defaultExercise = MovementExercise(
        name: "Neck Stretch",
        description: "Gently stretch your neck to relieve tension",
        duration: 30,
        repetitions: 3,
        imageUrl: nil
    )
}

#Preview {
    MovementView(
        content: MovementContent(
            type: .stretching,
            exercises: [
                MovementExercise(
                    name: "Neck Stretch",
                    description: "Gently stretch your neck to relieve tension",
                    duration: 30,
                    repetitions: 3,
                    imageUrl: nil
                ),
                MovementExercise(
                    name: "Shoulder Rolls",
                    description: "Roll your shoulders to release upper body tension",
                    duration: 20,
                    repetitions: 5,
                    imageUrl: nil
                )
            ]
        ),
        intention: IntentionActivity.deskStretches,
        progress: 0.6,
        remainingTime: 120,
        isActive: true,
        isPaused: false,
        onComplete: {},
        onPause: {},
        onResume: {}
    )
}