import SwiftUI

/// v1 onboarding: hook → quiz → permission → carbs → insight → fats → plan →
/// window dial → notifications → paywall → activation.
struct OnboardingView: View {
    @StateObject private var data = OnboardingData()
    @Environment(\.dismiss) var dismiss
    @Environment(DietManager.self) private var dietManager
    var onCompletion: () -> Void = {}

    var body: some View {
        ZStack {
            AppTheme.shared.colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Group {
                    switch data.currentScreen {
                    case 0:
                        HookAView(data: data)
                    case 1:
                        QuizView(data: data)
                    case 2:
                        PermissionsView(data: data)
                    case 3:
                        GroupPickerView(data: data, group: .carbs)
                    case 4:
                        HookBView(data: data)
                    case 5:
                        GroupPickerView(data: data, group: .fats, isSkippable: true)
                    case 6:
                        PlanSuggestionView(data: data)
                    case 7:
                        WindowDialView(data: data)
                    case 8:
                        NotificationPromptView(data: data)
                    case 9:
                        PaywallView(placement: .onboardingComplete) {
                            data.nextScreen()
                        }
                    default:
                        DietActivatedView(data: data)
                    }
                }
                .transition(.opacity)
            }
        }
        .onChange(of: data.isOnboardingComplete) { _, isComplete in
            if isComplete {
                onCompletion()
                dismiss()
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environment(DietManager())
}
