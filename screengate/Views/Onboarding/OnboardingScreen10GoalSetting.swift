import SwiftUI

/// OnboardingScreen10GoalSetting - Goal Setting Survey
/// Allows users to select success goals for their wellness journey
struct OnboardingScreen10GoalSetting: View {
    @ObservedObject var data: OnboardingData
    @State private var selectedGoals: Set<String> = []
    @State private var customGoal: String = ""
    
    private let appTheme = AppTheme.shared
    
    let predefinedGoals: [(id: String, title: String)] = [
        ("reclaim_time", "Reclaiming 2 hours a day"),
        ("deep_work", "Deep work without distractions"),
        ("sleep", "Better sleep hygiene"),
        ("family", "Being present with family"),
        ("anxiety", "Reducing screen anxiety")
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.06, green: 0.13, blue: 0.09)
                .ignoresSafeArea()
            
            // Decorative gradient blobs
            DecorativeGradientBlobs()
            
            // Main content
            VStack(spacing: 0) {
                // Header with back button and centered progress
                OnboardingHeader(
                    currentStep: 7,
                    totalSteps: 10
                ) {
                    data.currentScreen -= 1
                }
                
                // Title and subtitle (fixed, not scrollable)
                VStack(alignment: .leading, spacing: appTheme.spacing.medium) {
                    Text("What would success look like for you?")
                        .font(appTheme.fonts.displaySmall)
                        .foregroundColor(appTheme.colors.text)
                    
                    Text("Select all that apply to personalize your journey.")
                        .font(appTheme.fonts.bodyLarge)
                        .foregroundColor(appTheme.colors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, appTheme.spacing.large)
                .padding(.vertical, appTheme.spacing.large)
                
                // Scrollable options
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(predefinedGoals, id: \.id) { goal in
                            GoalCheckbox(
                                id: goal.id,
                                title: goal.title,
                                isSelected: selectedGoals.contains(goal.id)
                            ) {
                                if selectedGoals.contains(goal.id) {
                                    selectedGoals.remove(goal.id)
                                } else {
                                    selectedGoals.insert(goal.id)
                                }
                            }
                        }
                        
                        // Custom goal input
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.4))
                                
                                TextField("Write my own goal...", text: $customGoal)
                                    .font(.system(size: 16, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.03))
                            .border(Color.white.opacity(0.1), width: 0.5)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, appTheme.spacing.large)
                    .padding(.bottom, 140)
                    .padding(.top, appTheme.spacing.small)
                }
                
                Spacer()
            }
            .zIndex(10)
            
            // Bottom button
            VStack(spacing: 0) {
                Spacer()
                
                BottomGradientContainer {
                    VStack(spacing: appTheme.spacing.medium) {
                        PrimaryButton(
                            title: "Continue",
                            isDisabled: selectedGoals.isEmpty && customGoal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ) {
                            // Capture response
                            var selected: [String] = selectedGoals.compactMap { goalId in
                                predefinedGoals.first(where: { $0.id == goalId })?.title
                            }
                            let trimmedCustom = customGoal.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmedCustom.isEmpty {
                                selected.append("Custom: \(trimmedCustom)")
                            }
                            data.saveQuestionResponse(
                                screenNumber: 10,
                                question: "What would success look like for you?",
                                availableOptions: predefinedGoals.map { $0.title } + ["Custom goal option"],
                                selectedOptions: selected
                            )
                            data.currentScreen += 1
                        }
                    }
                    .padding(.horizontal, appTheme.spacing.large)
                }
            }
            .zIndex(20)
            .ignoresSafeArea(.keyboard)
        }
    }
}

#Preview {
    OnboardingScreen10GoalSetting(data: OnboardingData())
}
