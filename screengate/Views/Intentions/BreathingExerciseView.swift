import SwiftUI

// MARK: - Breathing Exercise View

struct BreathingExerciseView: View {
    let content: BreathingContent
    let intention: IntentionActivity
    let progress: Double
    let remainingTime: TimeInterval
    let isActive: Bool
    let isPaused: Bool

    let onComplete: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void

    @State private var currentPhase: BreathingPhase = .inhale
    @State private var phaseProgress: Double = 0.0
    @State private var cycleCount: Int = 0
    @State private var currentInstructionIndex: Int = 0
    @State private var animationTimer: Timer?

    // MARK: - Animation Constants
    private let animationDuration: Double = 0.05 // 50ms per frame for smooth animation

    var body: some View {
        VStack(spacing: 30) {
            // Header
            headerView

            // Breathing Circle
            breathingCircleView

            // Phase indicator
            phaseIndicatorView

            // Instructions
            instructionsView

            // Progress
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

            Spacer()
        }
        .padding()
        .onAppear {
            startBreathingAnimation()
        }
        .onDisappear {
            stopBreathingAnimation()
        }
        .onChange(of: isActive) { newValue in
            if newValue {
                startBreathingAnimation()
            } else {
                stopBreathingAnimation()
            }
        }
        .onChange(of: isPaused) { newValue in
            if newValue {
                stopBreathingAnimation()
            } else {
                startBreathingAnimation()
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

            Text("Box Breathing")
                .font(.headline)
                .foregroundColor(.blue)

            Text("Cycles: \(cycleCount) / \(content.cycles)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Breathing Circle View

    private var breathingCircleView: some View {
        ZStack {
            // Outer guide circle
            Circle()
                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                .frame(width: 250, height: 250)

            // Animated breathing circle
            Circle()
                .fill(Color.blue.opacity(0.3 + 0.3 * phaseProgress))
                .frame(width: circleSize, height: circleSize)
                .scaleEffect(circleScale)
                .animation(.easeInOut(duration: currentPhaseDuration), value: circleScale)

            // Phase text
            Text(phaseText.uppercased())
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(phaseTextColor)
                .scaleEffect(textScale)
                .animation(.easeInOut(duration: currentPhaseDuration), value: textScale)
        }
        .frame(height: 280)
    }

    // MARK: - Phase Indicator View

    private var phaseIndicatorView: some View {
        HStack(spacing: 20) {
            ForEach(BreathingPhase.allCases, id: \.self) { phase in
                Circle()
                    .fill(phaseColor(for: phase))
                    .frame(width: 12, height: 12)
                    .scaleEffect(currentPhase == phase ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: currentPhase == phase)
            }
        }
    }

    // MARK: - Instructions View

    private var instructionsView: some View {
        VStack(spacing: 8) {
            Text(currentInstruction)
                .font(.body)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)

            Text(getPhaseHint())
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .padding()
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
                    .background(Color.blue)
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

                Button(action: onComplete) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Complete")
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

    private var circleSize: CGFloat { 180 }
    private var currentPhaseDuration: Double {
        switch currentPhase {
        case .inhale: return Double(content.inhaleDuration)
        case .hold: return Double(content.holdDuration)
        case .exhale: return Double(content.exhaleDuration)
        case .pause: return Double(content.pauseDuration)
        }
    }

    private var phaseText: String {
        switch currentPhase {
        case .inhale: return "Inhale"
        case .hold: return "Hold"
        case .exhale: return "Exhale"
        case .pause: return "Pause"
        }
    }

    private var phaseTextColor: Color {
        switch currentPhase {
        case .inhale: return .blue
        case .hold: return .purple
        case .exhale: return .teal
        case .pause: return .gray
        }
    }

    private var currentInstruction: String {
        guard currentInstructionIndex < content.instructions.count else {
            return content.instructions.first ?? "Follow the breathing pattern"
        }
        return content.instructions[currentInstructionIndex]
    }

    private var circleScale: CGFloat {
        switch currentPhase {
        case .inhale: return 1.3
        case .hold: return 1.1
        case .exhale: return 1.3
        case .pause: return 0.9
        }
    }

    private var textScale: CGFloat {
        switch currentPhase {
        case .inhale, .exhale: return 1.1
        case .hold: return 1.0
        case .pause: return 0.9
        }
    }

    // MARK: - Animation Methods

    private func startBreathingAnimation() {
        stopBreathingAnimation()
        resetAnimation()
        animationTimer = Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: true) { _ in
            updateAnimation()
        }
    }

    private func stopBreathingAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }

    private func resetAnimation() {
        currentPhase = .inhale
        phaseProgress = 0.0
        currentInstructionIndex = 0
    }

    private func updateAnimation() {
        let increment = animationDuration / currentPhaseDuration
        phaseProgress += increment

        if phaseProgress >= 1.0 {
            moveToNextPhase()
        }
    }

    private func moveToNextPhase() {
        phaseProgress = 0.0

        switch currentPhase {
        case .inhale:
            currentPhase = .hold

        case .hold:
            currentPhase = .exhale

        case .exhale:
            currentPhase = .pause

        case .pause:
            currentPhase = .inhale
            cycleCount += 1

            // Update instruction for new cycle
            if content.instructions.count > 1 {
                currentInstructionIndex = (currentInstructionIndex + 1) % content.instructions.count
            }

            // Check if all cycles completed
            if cycleCount >= content.cycles {
                animationTimer?.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onComplete()
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func phaseColor(for phase: BreathingPhase) -> Color {
        if phase == currentPhase {
            return phaseTextColor
        } else {
            return Color.gray.opacity(0.3)
        }
    }

    private func getPhaseHint() -> String {
        switch currentPhase {
        case .inhale:
            return "Breathe in through your nose for \(content.inhaleDuration) counts"
        case .hold:
            return "Hold your breath gently"
        case .exhale:
            return "Exhale slowly through your mouth for \(content.exhaleDuration) counts"
        case .pause:
            return "Take a brief pause before the next cycle"
        }
    }
}

// MARK: - Breathing Phase

enum BreathingPhase: CaseIterable {
    case inhale
    case hold
    case exhale
    case pause
}


#Preview {
    BreathingExerciseView(
        content: BreathingContent(
            pattern: .box,
            inhaleDuration: 4,
            holdDuration: 4,
            exhaleDuration: 4,
            pauseDuration: 4,
            cycles: 3,
            instructions: [
                "Find a comfortable position",
                "Close your eyes or soften your gaze",
                "Follow the circle's rhythm",
                "Focus on your breath"
            ]
        ),
        intention: IntentionActivity.breathingExercise,
        progress: 0.3,
        remainingTime: 120,
        isActive: true,
        isPaused: false,
        onComplete: {},
        onPause: {},
        onResume: {}
    )
}