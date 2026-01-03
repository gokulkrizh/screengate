import SwiftUI

struct OnboardingView: View {
    @StateObject private var data = OnboardingData()
    @Environment(\.dismiss) var dismiss
    var onCompletion: () -> Void = {}
    
    var body: some View {
        ZStack {
            GradientAnimationBackground()
            
            VStack(spacing: 0) {
                // Screen selection based on currentScreen (GetStarted is 0, problem screen is 1)
                Group {
                    switch data.currentScreen {
                    case 0:
                        OnboardingScreen14TrialReminder(data: data)
                    case 1:
                        OnboardingScreen1Problem(data: data)
                    case 2:
                        OnboardingScreen2Discovery(data: data)
                    case 3:
                        OnboardingScreen3ProcessUnderstanding(data: data)
                    case 4:
                        OnboardingScreen4BehaviorInsight(data: data)
                    case 5:
                        OnboardingScreen5DailyScreenTime(data: data)
                    case 6:
                        OnboardingScreen6Age(data: data)
                    case 7:
                        OnboardingScreen7ProcessingReport(data: data)
                    case 8:
                        OnboardingScreen8DataReport(data: data)
                    case 9:
                        OnboardingScreen9ScreenTimeAccess(data: data)
                    case 10:
                        OnboardingScreen10GoalSetting(data: data)
                    case 11:
                        OnboardingScreen11CreatingPlan(data: data)
                    case 12:
                        OnboardingScreen12SolutionPreview(data: data)
                    case 13:
                        OnboardingScreen13TryForFree(data: data)
                    case 14:
                        OnboardingScreen14TrialReminder(data: data)
                    default:
                        OnboardingScreen14TrialReminder(data: data)
                    }
                }
                .transition(.opacity)
            }
        }
        .environmentObject(data)
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
}
