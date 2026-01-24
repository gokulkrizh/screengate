import SwiftUI

/// Standard onboarding screen header with back button and progress indicator
struct OnboardingHeader: View {
    let currentStep: Int
    let totalSteps: Int
    let onBack: () -> Void
    let showBackButton: Bool
    
    private let appTheme = AppTheme.shared
    
    init(
        currentStep: Int,
        totalSteps: Int,
        showBackButton: Bool = true,
        onBack: @escaping () -> Void
    ) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
        self.showBackButton = showBackButton
        self.onBack = onBack
    }
    
    var body: some View {
        ZStack {
            HStack {
                if showBackButton {
                    BackButton(action: onBack)
                }
                Spacer()
            }
            
            ProgressIndicatorHeader(currentStep: currentStep, totalSteps: totalSteps)
        }
        .padding(.horizontal, appTheme.spacing.large)
    }
}

#Preview {
    ZStack {
        Color(red: 0.06, green: 0.13, blue: 0.09)
            .ignoresSafeArea()
        
        VStack {
            OnboardingHeader(currentStep: 3, totalSteps: 10) {
                print("Back tapped")
            }
            
            Spacer()
        }
    }
}
