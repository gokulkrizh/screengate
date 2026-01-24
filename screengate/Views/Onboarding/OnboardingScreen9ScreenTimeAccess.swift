import SwiftUI

/// OnboardingScreen9ScreenTimeAccess - Screen Time Permission Request
/// Explains why the app needs Screen Time access and related permissions
struct OnboardingScreen9ScreenTimeAccess: View {
    @ObservedObject var data: OnboardingData
    
    private let appTheme = AppTheme.shared
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.06, green: 0.13, blue: 0.09)
                .ignoresSafeArea()
            
            // Decorative gradient blobs
            VStack {
                Circle()
                    .fill(appTheme.colors.primary.opacity(0.1))
                    .blur(radius: 120)
                    .frame(width: 350, height: 350)
                    .offset(x: 100, y: -100)
                
                Spacer()
                
                Circle()
                    .fill(appTheme.colors.primary.opacity(0.05))
                    .blur(radius: 100)
                    .frame(width: 280, height: 280)
                    .offset(x: -80, y: 50)
            }
            .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                // Header with progress
                ZStack {
                    HStack {
                        BackButton {
                            data.currentScreen = 6
                        }
                       
                        Spacer()
                    }
                    ProgressIndicatorHeader(currentStep: 6, totalSteps: 10)
                }
                .padding(.horizontal, appTheme.spacing.large)
                .padding(.top, appTheme.spacing.large)
               // .padding(.vertical, appTheme.spacing.medium)
                
                // Top spacing
                VStack(spacing: 24) {
                    // Icon with glow
                    ZStack {
                        // Glow effect
                        Circle()
                            .fill(appTheme.colors.primary.opacity(0.2))
                            .blur(radius: 32)
                            .frame(width: 180, height: 180)
                        
                        // Icon container
                        Circle()
                            .fill(Color.white.opacity(0.03))
                            .frame(width: 128, height: 128)
                            .border(appTheme.colors.primary.opacity(0.3), width: 0.5)
                            .overlay(
                                Image(systemName: "timelapse")
                                    .font(.system(size: 56, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                    }
                    
                    // Title and description
                    VStack(spacing: 12) {
                        Text("Screen Time Access")
                            .font(appTheme.fonts.displaySmall)
                            .foregroundColor(appTheme.colors.text)
                            .lineLimit(2)
                        
                        Text("Screendiet needs this permission to sync with your device's usage data.")
                            .font(appTheme.fonts.bodyLarge)
                            .foregroundColor(appTheme.colors.textSecondary)
                            .lineLimit(3)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                .padding(.bottom, 32)
                
                // Feature cards
                VStack(spacing: 12) {
                    featureCard(
                        icon: "analytics",
                        title: "Monitor Usage",
                        description: "Accurately track your daily digital habits to generate insights."
                    )
                    
                    featureCard(
                        icon: "block",
                        title: "Enforce Limits",
                        description: "Effectively block distracting apps when your limits are reached."
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    PrimaryButton(
                        title: "Allow Access",
                        action: {
                            data.currentScreen += 1
                        }
                    )
                    
                    Button(action: {
                        data.currentScreen += 1
                    }) {
                        Text("Not Now")
                            .font(.system(size: 15, weight: .semibold, design: .default))
                            .foregroundColor(.white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(12)
                    }
                    
                    Text("Your data stays private and never leaves your device.")
                        .font(.system(size: 11, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
    }
    
    // MARK: - Feature Card Component
    private func featureCard(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            // Icon container
            Circle()
                .fill(appTheme.colors.primary.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(appTheme.colors.primary)
                )
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .default))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.03))
        .border(appTheme.colors.primary.opacity(0.1), width: 0.5)
        .cornerRadius(20)
    }
}

#Preview {
    OnboardingScreen9ScreenTimeAccess(data: OnboardingData())
}
