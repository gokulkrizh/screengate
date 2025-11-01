import SwiftUI

// MARK: - Reflection View

struct ReflectionView: View {
    let content: ReflectionContent
    let intention: IntentionActivity
    let progress: Double
    let remainingTime: TimeInterval
    let isActive: Bool
    let isPaused: Bool

    let onComplete: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void

    @State private var currentPromptIndex: Int = 0
    @State private var journalText: String = ""
    @State private var responses: [String] = []
    @State private var showJournal: Bool = false
    @State private var reflectionTimer: Timer?

    // MARK: - Computed Properties
    private var currentPrompt: String {
        guard currentPromptIndex < content.prompts.count else {
            return content.prompts.first ?? "Take a moment to reflect"
        }
        return content.prompts[currentPromptIndex]
    }

    private var completedPrompts: Int {
        min(currentPromptIndex + 1, content.prompts.count)
    }

    private var progressPercentage: Double {
        guard content.prompts.count > 0 else { return 0 }
        return Double(completedPrompts) / Double(content.prompts.count)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                headerView

                // Main content
                VStack(spacing: 20) {
                    // Current prompt
                    currentPromptView

                    if showJournal {
                        // Journal section
                        journalSectionView
                    }

                    // Response section
                    responseSectionView

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

                Spacer(minLength: 50)
            }
            .padding()
        }
        .onAppear {
            showJournal = content.journalingEnabled
            startReflectionSession()
        }
        .onDisappear {
            stopReflectionSession()
        }
        .onChange(of: isActive) { newValue in
            if newValue {
                startReflectionSession()
            } else {
                stopReflectionSession()
            }
        }
        .onChange(of: isPaused) { newValue in
            if newValue {
                pauseReflectionSession()
            } else {
                resumeReflectionSession()
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
                .foregroundColor(.teal)

            if content.prompts.count > 1 {
                Text("Question \(completedPrompts) of \(content.prompts.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Current Prompt View

    private var currentPromptView: some View {
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 40))
                .foregroundColor(.teal)

            Text(currentPrompt)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding(.horizontal)

            if !responses.isEmpty {
                Text("Previous reflections:")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.teal.opacity(0.05))
        .cornerRadius(16)
    }

    // MARK: - Journal Section View

    private var journalSectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "book")
                    .foregroundColor(.teal)

                Text("Journal")
                    .font(.headline)
                    .foregroundColor(.teal)

                Spacer()

                Button(action: toggleJournal) {
                    Image(systemName: showJournal ? "chevron.up" : "chevron.down")
                        .foregroundColor(.teal)
                }
            }

            if showJournal {
                TextEditor(text: $journalText)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }

    // MARK: - Response Section View

    private var responseSectionView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "text.bubble")
                    .foregroundColor(.teal)

                Text("Your Reflection")
                    .font(.headline)
                    .foregroundColor(.teal)

                Spacer()
            }

            // Current response input
            TextField("Share your thoughts...", text: Binding(
                get: { responses.last ?? "" },
                set: { newValue in
                    if !responses.isEmpty {
                        responses[responses.count - 1] = newValue
                    } else {
                        responses.append(newValue)
                    }
                }
            ), axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)

            // Previous responses
            if responses.count > 1 {
                ForEach(Array(responses.dropLast().enumerated()), id: \.offset) { index, response in
                    HStack(alignment: .top, spacing: 8) {
                        Text("Q\(index + 1):")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 30, alignment: .leading)

                        Text(response)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(8)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(8)

                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    // MARK: - Progress Indicator View

    private var progressIndicatorView: some View {
        VStack(spacing: 8) {
            Text("Reflection Progress")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack {
                ForEach(0..<content.prompts.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentPromptIndex ? Color.teal : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(index == currentPromptIndex ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: currentPromptIndex)
                }

                Spacer()

                Text("\(Int(progressPercentage * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.teal)
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
                    .background(Color.teal)
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

                Button(action: saveCurrentResponse) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(25)
                }

                Button(action: advanceToNextPrompt) {
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

    // MARK: - Session Management

    private func startReflectionSession() {
        if responses.isEmpty {
            responses.append("")
        }
        startProgressionTimer()
        print("🤔 Started reflection session")
    }

    private func pauseReflectionSession() {
        reflectionTimer?.invalidate()
        print("⏸️ Paused reflection session")
    }

    private func resumeReflectionSession() {
        startProgressionTimer()
        print("▶️ Resumed reflection session")
    }

    private func stopReflectionSession() {
        reflectionTimer?.invalidate()
        saveReflectionData()
        print("⏹️ Stopped reflection session")
    }

    private func startProgressionTimer() {
        reflectionTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [self] _ in
            Task { @MainActor in
                self.autoAdvanceProgression()
            }
        }
    }

    private func autoAdvanceProgression() {
        // Auto-advance if no user activity detected
        // This would track user activity and advance if needed
        // For now, we'll leave manual control
    }

    private func saveCurrentResponse() {
        guard !responses.isEmpty else { return }

        let currentResponse = responses.last ?? ""
        if !currentResponse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            saveReflectionData()
            print("💾 Saved reflection response")
        }
    }

    private func advanceToNextPrompt() {
        saveCurrentResponse()

        guard currentPromptIndex < content.prompts.count - 1 else {
            // All prompts completed
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onComplete()
            }
            return
        }

        currentPromptIndex += 1
        responses.append("")
        print("📝 Advanced to prompt \(currentPromptIndex + 1)")
    }

    private func toggleJournal() {
        showJournal.toggle()
        if !showJournal {
            // Save journal text when closing
            if !journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                saveReflectionData()
            }
        }
    }

    private func saveReflectionData() {
        let reflectionData = ReflectionData(
            intentionId: intention.id,
            intentionName: intention.title,
            type: content.type,
            prompts: content.prompts,
            responses: responses,
            journalText: journalText,
            completedAt: Date(),
            timeSpent: intention.duration * progress
        )

        // Save to UserDefaults (simplified implementation)
        var allReflections = getReflections()
        allReflections.append(reflectionData)
        saveReflections(allReflections)
        print("💾 Saved reflection data")
    }

    private func getReflections() -> [ReflectionData] {
        if let data = UserDefaults.standard.data(forKey: "Reflections"),
           let reflections = try? JSONDecoder().decode([ReflectionData].self, from: data) {
            return reflections
        }
        return []
    }

    private func saveReflections(_ reflections: [ReflectionData]) {
        if let data = try? JSONEncoder().encode(reflections) {
            UserDefaults.standard.set(data, forKey: "Reflections")
        }
    }
}

// MARK: - Reflection Data Model

struct ReflectionData: Codable, Identifiable {
    let id: String
    let intentionId: String
    let intentionName: String
    let type: ReflectionType
    let prompts: [String]
    let responses: [String]
    let journalText: String
    let completedAt: Date
    let timeSpent: TimeInterval

    init(intentionId: String, intentionName: String, type: ReflectionType,
         prompts: [String], responses: [String], journalText: String,
         completedAt: Date, timeSpent: TimeInterval) {
        self.id = UUID().uuidString
        self.intentionId = intentionId
        self.intentionName = intentionName
        self.type = type
        self.prompts = prompts
        self.responses = responses
        self.journalText = journalText
        self.completedAt = completedAt
        self.timeSpent = timeSpent
    }
}



#Preview {
    ReflectionView(
        content: ReflectionContent(
            type: .gratitude,
            prompts: [
                "What are three things you're grateful for right now?",
                "Who in your life brings you joy and why?",
                "What simple pleasure did you experience today?",
                "What's something you often take for granted?",
                "How can you express gratitude today?"
            ],
            journalingEnabled: true
        ),
        intention: IntentionActivity.gratitudeReflection,
        progress: 0.6,
        remainingTime: 180,
        isActive: true,
        isPaused: false,
        onComplete: {},
        onPause: {},
        onResume: {}
    )
}