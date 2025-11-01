import SwiftUI

// MARK: - Mindfulness View

struct MindfulnessView: View {
    let content: MindfulnessContent
    let intention: IntentionActivity
    let progress: Double
    let remainingTime: TimeInterval
    let isActive: Bool
    let isPaused: Bool

    let onComplete: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void

    @State private var currentScriptIndex: Int = 0
    @State private var isPlaying: Bool = false
    @State private var audioPlayer: AudioPlayer?
    @State private var breathingIndicatorScale: CGFloat = 1.0
    @State private var breathingTimer: Timer?

    // MARK: - Computed Properties
    private var currentScriptLine: String {
        guard currentScriptIndex < content.script.count else {
            return content.script.first ?? "Begin your mindfulness practice"
        }
        return content.script[currentScriptIndex]
    }

    private var totalDuration: TimeInterval {
        TimeInterval(content.script.count * 15) // 15 seconds per script line
    }

    private var progressPercentage: Double {
        min(progress, 1.0)
    }

    var body: some View {
        VStack(spacing: 30) {
            // Header
            headerView

            // Main content area
            VStack(spacing: 20) {
                // Breathing indicator
                breathingIndicatorView

                // Script text
                scriptTextView

                // Progress indicator
                progressIndicatorView
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

            Spacer()
        }
        .padding()
        .onAppear {
            startMindfulnessSession()
        }
        .onDisappear {
            stopMindfulnessSession()
        }
        .onChange(of: isActive) { newValue in
            if newValue {
                startMindfulnessSession()
            } else {
                stopMindfulnessSession()
            }
        }
        .onChange(of: isPaused) { newValue in
            if newValue {
                pauseMindfulnessSession()
            } else {
                resumeMindfulnessSession()
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

            if content.script.count > 1 {
                Text("Step \(currentScriptIndex + 1) of \(content.script.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Breathing Indicator View

    private var breathingIndicatorView: some View {
        VStack(spacing: 12) {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(Color.purple.opacity(0.3), lineWidth: 3)
                    .frame(width: 120, height: 120)

                // Inner circle
                Circle()
                    .fill(Color.purple.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .scaleEffect(breathingIndicatorScale)
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: false), value: breathingIndicatorScale)

                // Center dot
                Circle()
                    .fill(Color.purple)
                    .frame(width: 20, height: 20)
            }

            Text("Breathe")
                .font(.caption)
                .foregroundColor(.purple)
        }
    }

    // MARK: - Script Text View

    private var scriptTextView: some View {
        VStack(spacing: 16) {
            Text(currentScriptLine)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding(.horizontal)
                .padding(.vertical, 20)
                .background(Color.purple.opacity(0.05))
                .cornerRadius(16)

            if content.backgroundSound != .none {
                backgroundSoundControlView
            }
        }
    }

    // MARK: - Background Sound Control View

    private var backgroundSoundControlView: some View {
        HStack {
            Image(systemName: "speaker.2")
                .foregroundColor(.purple)

            Text("Background: \(content.backgroundSound.displayName)")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            Button(action: toggleBackgroundSound) {
                Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                    .foregroundColor(.purple)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }

    // MARK: - Progress Indicator View

    private var progressIndicatorView: some View {
        HStack(spacing: 8) {
            ForEach(0..<content.script.count, id: \.self) { index in
                Circle()
                    .fill(index <= currentScriptIndex ? Color.purple : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == currentScriptIndex ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: currentScriptIndex)
            }
        }
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

                Button(action: skipToNextStep) {
                    HStack {
                        Image(systemName: "forward.circle")
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

    // MARK: - Animation and Timer Methods

    private func startMindfulnessSession() {
        isPlaying = true
        startBreathingAnimation()
        advanceToNextScript()
        startScriptProgression()
        print("🧘 Started mindfulness session")
    }

    private func pauseMindfulnessSession() {
        isPlaying = false
        breathingTimer?.invalidate()
        print("⏸️ Paused mindfulness session")
    }

    private func resumeMindfulnessSession() {
        isPlaying = true
        startBreathingAnimation()
        print("▶️ Resumed mindfulness session")
    }

    private func stopMindfulnessSession() {
        isPlaying = false
        breathingTimer?.invalidate()
        audioPlayer?.stop()
        print("⏹️ Stopped mindfulness session")
    }

    private func startBreathingAnimation() {
        breathingIndicatorScale = 1.0
        breathingTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 4)) {
                self.breathingIndicatorScale = self.breathingIndicatorScale == 1.0 ? 1.2 : 1.0
            }
        }
    }

    private func startScriptProgression() {
        breathingTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
            Task { @MainActor in
                advanceToNextScript()
            }
        }
    }

    private func advanceToNextScript() {
        guard currentScriptIndex < content.script.count - 1 else {
            // All scripts completed
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onComplete()
            }
            return
        }

        currentScriptIndex += 1
        print("📖 Advanced to script \(currentScriptIndex + 1): \(currentScriptLine)")
    }

    private func skipToNextStep() {
        guard currentScriptIndex < content.script.count - 1 else {
            onComplete()
            return
        }

        currentScriptIndex += 1
        print("⏭️ Skipped to step \(currentScriptIndex + 1)")
    }

    private func toggleBackgroundSound() {
        if isPlaying {
            // Stop background sound
            audioPlayer?.stop()
            isPlaying = false
        } else {
            // Start background sound
            playBackgroundSound()
            isPlaying = true
        }
    }

    private func playBackgroundSound() {
        // This would implement actual audio playback
        // For now, we'll just simulate it
        print("🔊 Playing background sound: \(content.backgroundSound.displayName)")
    }
}

// MARK: - Audio Player Helper

class AudioPlayer {
    func play() {
        // Implement audio playback
    }

    func stop() {
        // Stop audio playback
    }
}


#Preview {
    MindfulnessView(
        content: MindfulnessContent(
            type: .bodyScan,
            script: [
                "Bring your awareness to your body",
                "Notice any sensations without judgment",
                "Start from your toes and slowly scan upward",
                "Relax any areas of tension you find"
            ],
            backgroundSound: .gentleAmbient
        ),
        intention: IntentionActivity.mindfulnessBodyScan,
        progress: 0.4,
        remainingTime: 240,
        isActive: true,
        isPaused: false,
        onComplete: {},
        onPause: {},
        onResume: {}
    )
}