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
                        OnboardingScreen7ProcessingReport(data: data)
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
                        OnboardingScreen1(data: data)
                    case 9:
                        OnboardingScreen2(data: data)
                    case 6:
                        OnboardingScreen2(data: data)
                    case 7:
                        OnboardingScreen2(data: data)
                    case 8:
                        OnboardingScreen2(data: data)
                    case 9:
                        OnboardingScreen2(data: data)
                    case 10:
                        OnboardingScreen3(data: data)
                    case 11:
                        OnboardingScreen4(data: data)
                    case 12:
                        OnboardingScreen5(data: data)
                    case 13:
                        OnboardingScreen6(data: data)
                    case 14:
                        OnboardingScreen7(data: data)
                    case 15:
                        OnboardingScreen8(data: data)
                    case 16:
                        OnboardingScreen9(data: data)
                    case 17:
                        OnboardingScreen10(data: data)
                    default:
                        OnboardingScreen10(data: data)
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
