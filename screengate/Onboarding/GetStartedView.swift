import SwiftUI

struct GetStartedView: View {
    @ObservedObject var data: OnboardingData
    
    private let appTheme = AppTheme.shared
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.06, green: 0.13, blue: 0.09)
                .ignoresSafeArea()
            
            // Decorative gradient blobs
            DecorativeGradientBackground()
            
            // Main content
            VStack(spacing: 0) {
                Spacer()
                
                // Hero Image Area
                HeroImageView(imageName: "welcomScreen")
                
                // Text Content
                ScreenHeader(
                    title: "Screendiet",
                    subtitle: "Reclaim your time. Master your focus. Digital fasting for a clearer mind."
                )
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: appTheme.spacing.medium) {
                    PrimaryButton(
                        title: "Get Started",
                        icon: "arrow.right"
                    ) {
                        data.currentScreen = 1
                    }
                    
                    SecondaryButton(
                        title: "Already have an account? Log in"
                    ) {
                        // Future: Implement login flow
                    }
                }
                .padding(.horizontal, appTheme.spacing.large)
                .padding(.bottom, appTheme.spacing.large)
            }
            .zIndex(10)
        }
    }
}

#Preview {
    GetStartedView(data: OnboardingData())
}
