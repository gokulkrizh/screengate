import SwiftUI

struct OnboardingView: View {
    @Environment(\.theme) var theme
    @StateObject private var data = OnboardingData()
    @Environment(\.dismiss) var dismiss
    var onCompletion: () -> Void = {}
    
    var body: some View {
        ZStack {
            GradientAnimationBackground()
            
            VStack(spacing: 0) {
                // Screen selection based on currentScreen (11 screens total)
                Group {
                    switch data.currentScreen {
                    case 0:
                        OnboardingScreen1(data: data)
                    case 1:
                        OnboardingScreen2(data: data)
                    case 2:
                        OnboardingScreen3(data: data)
                    case 3:
                        OnboardingScreen4(data: data)
                    case 4:
                        OnboardingScreen5(data: data)
                    case 5:
                        OnboardingScreen6(data: data)
                    case 6:
                        OnboardingScreen7(data: data)
                    case 7:
                        OnboardingScreen8(data: data)
                    case 8:
                        OnboardingScreen9(data: data)
                    case 9:
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
