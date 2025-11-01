import SwiftUI

// MARK: - Intention Container View

struct IntentionContainerView: View {
    @StateObject private var intentionViewModel = IntentionViewModel()
    @StateObject private var notificationViewModel = NotificationViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var showErrorAlert: Bool = false

    let intention: IntentionActivity?
    let sourceAppInfo: SourceAppInfo?

    // MARK: - Initialization
    init(intention: IntentionActivity? = nil, sourceAppInfo: SourceAppInfo? = nil) {
        self.intention = intention
        self.sourceAppInfo = sourceAppInfo
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            Group {
                if let currentIntention = intentionViewModel.currentIntention {
                    intentionView(for: currentIntention)
                } else if let intention = intention {
                    intentionView(for: intention)
                } else {
                    emptyStateView
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        intentionViewModel.skipIntention()
                        dismiss()
                    }
                    .foregroundColor(.red)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if intentionViewModel.isIntentionActive {
                        HStack {
                            if intentionViewModel.isPaused {
                                Button("Resume") {
                                    intentionViewModel.resumeIntention()
                                }
                            } else {
                                Button("Pause") {
                                    intentionViewModel.pauseIntention()
                                }
                            }

                            Divider()
                                .frame(height: 20)

                            Button("Complete") {
                                intentionViewModel.completeIntention()
                            }
                            .foregroundColor(.green)
                        }
                    }
                }
            }
        }
        .onAppear {
            if let intention = intention {
                intentionViewModel.startIntention(intention, sourceInfo: sourceAppInfo)
            }
        }
        .onReceive(intentionViewModel.$isCompleted) { completed in
            if completed {
                handleCompletion()
            }
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK") {
                intentionViewModel.errorMessage = nil
                showErrorAlert = false
            }
        } message: {
            Text(intentionViewModel.errorMessage ?? "Unknown error")
        }
        .onChange(of: intentionViewModel.errorMessage) { errorMessage in
            showErrorAlert = errorMessage != nil
        }
    }

    // MARK: - Computed Properties

    private var navigationTitle: String {
        if let currentIntention = intentionViewModel.currentIntention {
            return currentIntention.title
        } else if let intention = intention {
            return intention.title
        } else {
            return "Intention"
        }
    }

    // MARK: - View Builders

    @ViewBuilder
    private func intentionView(for intention: IntentionActivity) -> some View {
        switch intention.content {
        case .breathing(let content):
            BreathingExerciseView(
                content: content,
                intention: intention,
                progress: intentionViewModel.completionProgress,
                remainingTime: intentionViewModel.remainingTime,
                isActive: intentionViewModel.isIntentionActive,
                isPaused: intentionViewModel.isPaused,
                onComplete: {
                    intentionViewModel.completeIntention()
                },
                onPause: {
                    intentionViewModel.pauseIntention()
                },
                onResume: {
                    intentionViewModel.resumeIntention()
                }
            )

        case .mindfulness(let content):
            MindfulnessView(
                content: content,
                intention: intention,
                progress: intentionViewModel.completionProgress,
                remainingTime: intentionViewModel.remainingTime,
                isActive: intentionViewModel.isIntentionActive,
                isPaused: intentionViewModel.isPaused,
                onComplete: {
                    intentionViewModel.completeIntention()
                },
                onPause: {
                    intentionViewModel.pauseIntention()
                },
                onResume: {
                    intentionViewModel.resumeIntention()
                }
            )

        case .reflection(let content):
            ReflectionView(
                content: content,
                intention: intention,
                progress: intentionViewModel.completionProgress,
                remainingTime: intentionViewModel.remainingTime,
                isActive: intentionViewModel.isIntentionActive,
                isPaused: intentionViewModel.isPaused,
                onComplete: {
                    intentionViewModel.completeIntention()
                },
                onPause: {
                    intentionViewModel.pauseIntention()
                },
                onResume: {
                    intentionViewModel.resumeIntention()
                }
            )

        case .movement(let content):
            MovementView(
                content: content,
                intention: intention,
                progress: intentionViewModel.completionProgress,
                remainingTime: intentionViewModel.remainingTime,
                isActive: intentionViewModel.isIntentionActive,
                isPaused: intentionViewModel.isPaused,
                onComplete: {
                    intentionViewModel.completeIntention()
                },
                onPause: {
                    intentionViewModel.pauseIntention()
                },
                onResume: {
                    intentionViewModel.resumeIntention()
                }
            )

        case .quickBreak(let content):
            QuickBreakView(
                content: content,
                intention: intention,
                progress: intentionViewModel.completionProgress,
                remainingTime: intentionViewModel.remainingTime,
                isActive: intentionViewModel.isIntentionActive,
                isPaused: intentionViewModel.isPaused,
                onComplete: {
                    intentionViewModel.completeIntention()
                },
                onPause: {
                    intentionViewModel.pauseIntention()
                },
                onResume: {
                    intentionViewModel.resumeIntention()
                }
            )
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Intention Selected")
                .font(.title2)
                .fontWeight(.bold)

            Text("Please select an intention to begin your mindful practice.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Close") {
                dismiss()
            }
            .buttonStyle(.bordered)
            .foregroundColor(.red)
        }
        .padding()
    }

    // MARK: - Helper Methods

    private func handleCompletion() {
        // Send completion celebration notification
        if let intention = intentionViewModel.currentIntention {
            notificationViewModel.sendCompletionCelebration(for: intention)
        }

        // Show completion view
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            dismiss()
        }
    }
}

// MARK: - Source App Header View

struct SourceAppHeaderView: View {
    let sourceAppInfo: SourceAppInfo?

    var body: some View {
        if let sourceInfo = sourceAppInfo {
            HStack(spacing: 12) {
                Image(systemName: "app.badge")
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Interrupted from")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(sourceInfo.appName ?? "App")
                        .font(.headline)
                        .fontWeight(.medium)
                }

                Spacer()

                Text("Continue after intention")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.1))
        }
    }
}

// MARK: - Progress Bar View

struct IntentionProgressBarView: View {
    let progress: Double
    let remainingTime: TimeInterval
    let isActive: Bool
    let isPaused: Bool

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Progress")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(progressColor)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(progressColor)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .cornerRadius(4)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 8)

            HStack {
                Text(formattedRemainingTime)
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Spacer()

                Text(statusText)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(statusColor)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }

    private var progressColor: Color {
        if isPaused {
            return .orange
        } else if progress >= 1.0 {
            return .green
        } else if progress >= 0.75 {
            return .blue
        } else {
            return .blue
        }
    }

    private var statusText: String {
        if !isActive {
            return "Ready"
        } else if isPaused {
            return "Paused"
        } else if progress >= 1.0 {
            return "Complete!"
        } else {
            return "In Progress"
        }
    }

    private var statusColor: Color {
        if !isActive {
            return .gray
        } else if isPaused {
            return .orange
        } else if progress >= 1.0 {
            return .green
        } else {
            return .blue
        }
    }

    private var formattedRemainingTime: String {
        let time = max(remainingTime, 0)
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Completion Options View

struct IntentionCompletionOptionsView: View {
    let intention: IntentionActivity
    let sourceAppInfo: SourceAppInfo?
    let onContinue: () -> Void
    let onRetry: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Success message
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)

                Text("Intention Complete!")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Great job completing \(intention.title)")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)

            // Action buttons
            VStack(spacing: 12) {
                Button(action: onContinue) {
                    HStack {
                        Image(systemName: "arrow.right.circle")
                        Text("Continue to App")
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }

                Button(action: onRetry) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Try Again")
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                }

                Button(action: onClose) {
                    HStack {
                        Image(systemName: "xmark.circle")
                        Text("Close")
                        Spacer()
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    IntentionContainerView(
        intention: IntentionActivity.breathingExercise,
        sourceAppInfo: SourceAppInfo(
            bundleIdentifier: "com.instagram.instagram",
            appName: "Instagram",
            isFromCategory: false
        )
    )
}