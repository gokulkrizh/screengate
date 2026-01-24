import SwiftUI

/// OnboardingScreen10GoalSetting - Goal Setting Survey
/// Allows users to select success goals for their wellness journey
struct OnboardingScreen10GoalSetting: View {
    @ObservedObject var data: OnboardingData
    @State private var selectedGoals: Set<String> = ["reclaim_time"]
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
            VStack {
                HStack {
                    VStack(spacing: 0) {
                        Circle()
                            .fill(appTheme.colors.primary.opacity(0.05))
                            .blur(radius: 120)
                            .frame(width: 320, height: 320)
                        Spacer()
                    }
                    .offset(x: 120, y: -100)
                    
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Circle()
                            .fill(appTheme.colors.primary.opacity(0.08))
                            .blur(radius: 100)
                            .frame(width: 280, height: 280)
                    }
                    .offset(x: 80, y: 80)
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with back button and centered progress
                ZStack {
                    HStack {
                        BackButton {
                            data.currentScreen -= 1
                        }
                        
                        Spacer()
                    }
                    
                    ProgressIndicatorHeader(currentStep: 7, totalSteps: 10)
                }
                .padding(.horizontal, 0)
               // .padding(.vertical, 12)
                
                // Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Title and description
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What would success look like for you?")
                                .font(appTheme.fonts.displaySmall)
                                .foregroundColor(appTheme.colors.text)
                                .lineLimit(3)
                            
                            Text("Select all that apply to personalize your journey.")
                                .font(appTheme.fonts.bodyLarge)
                                .foregroundColor(appTheme.colors.textSecondary)
                        }
                        .padding(.top, 12)
                        
                        // Goal options
                        VStack(spacing: 12) {
                            ForEach(predefinedGoals, id: \.id) { goal in
                                goalCheckbox(
                                    id: goal.id,
                                    title: goal.title,
                                    isSelected: selectedGoals.contains(goal.id)
                                )
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
                        .padding(.bottom, 32)
                    }
                   //.padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Continue button
                VStack(spacing: 12) {
                    PrimaryButton(
                        title: "Continue",
                        action: {
                            data.currentScreen += 1
                        }
                    )
                }
                .padding(.vertical, 20)
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Goal Checkbox Component
    private func goalCheckbox(id: String, title: String, isSelected: Bool) -> some View {
        Button(action: {
            if selectedGoals.contains(id) {
                selectedGoals.remove(id)
            } else {
                selectedGoals.insert(id)
            }
        }) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Checkbox circle
                Circle()
                    .fill(isSelected ? appTheme.colors.primary : Color.white.opacity(0.1))
                    .frame(width: 24, height: 24)
                    .overlay(
                        isSelected ?
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                        : nil
                    )
                    .scaleEffect(isSelected ? 1.1 : 1.0)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isSelected ? 0.1 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? appTheme.colors.primary : Color.white.opacity(0.1),
                                lineWidth: 1.5
                            )
                    )
            )
            .cornerRadius(12)
        }
    }
}

#Preview {
    OnboardingScreen10GoalSetting(data: OnboardingData())
}
