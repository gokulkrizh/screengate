import SwiftUI

/// OnboardingScreen13TryForFree - Paywall / Free Trial Offer Screen
/// Final onboarding screen offering 7-day free trial with key features
struct OnboardingScreen13TryForFree: View {
    @ObservedObject var data: OnboardingData
    
    private let appTheme = AppTheme.shared
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.06, green: 0.13, blue: 0.09)
                .ignoresSafeArea()
            
            // Decorative gradient blob
            DecorativeGradientBlobs()
            
            VStack(spacing: 0) {
                
                // Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 30) {
                        // Hero image
                        ZStack(alignment: .topTrailing) {

                            // Hero Image Area
                            HeroImageView(imageName: "paywallTryForFree", height: 220)
            
                            Circle()
                                .fill(Color.white.opacity(0.05))
                                .frame(width: 44, height: 44)
                                .border(Color.white.opacity(0.1), width: 0.5)
                                .overlay(
                                    Image(systemName: "lock.open.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(appTheme.colors.primary)
                                )
                                .padding(16)
                        }
                        .frame(height: 200)
                        .padding(.horizontal, 20)
                        
                        // Title and description
                        VStack(alignment: .center, spacing: 12) {
                            VStack(spacing: 4) {
                                Text("Zero cost.")
                                    .font(appTheme.fonts.displaySmall)
                                    .foregroundColor(appTheme.colors.text)
                                
                                Text("100% Focus.")
                                    .font(appTheme.fonts.displaySmall)
                                    .foregroundColor(appTheme.colors.primary)
                                    .shadow(color: appTheme.colors.primary.opacity(0.25), radius: 8)
                            }
                            
                            Text("Experience the full power of Screendiet before you commit.")
                                .font(appTheme.fonts.bodyLarge)
                                .foregroundColor(appTheme.colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        
                        // Features
                        VStack(spacing: 12) {
                            FeatureCard(
                                title: "Instant App Blocking",
                                isHighlighted: false
                            )
                            
                            FeatureCard(
                                title: "Detailed Screen Time Analytics",
                                isHighlighted: false
                            )
                            
                            FeatureCard(
                                title: "7-Day Free Trial",
                                subtitle: "START TODAY",
                                isHighlighted: true
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
                
                // Bottom button
                VStack(spacing: 0) {
                    BottomGradientContainer {
                        VStack(spacing: 8) {
                            PrimaryButton(
                                title: "Unlock Free Access",
                            ) {
                                data.currentScreen += 1
                            }

                            HStack(spacing: 8) {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(appTheme.colors.primary)

                                Text("We'll remind you 2 days before trial ends")
                                    .font(.system(size: 12, weight: .semibold, design: .default))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        .padding(.horizontal, appTheme.spacing.large)
                    }
                }
                .zIndex(20)
                .ignoresSafeArea(.keyboard)
                
                // Bottom section with button and reminder
//                VStack(spacing: 0) {
//                    PrimaryButton(
//                        title: "Unlock Free Access",
//                        action: {
//                            data.isOnboardingComplete = true
            }
        }
    }
}

#Preview {
    OnboardingScreen13TryForFree(data: OnboardingData())
}
