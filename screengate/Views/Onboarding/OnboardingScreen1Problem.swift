import SwiftUI

/// OnboardingScreen1 - The Problem
/// Presents the core problem statement with engaging visuals
struct OnboardingScreen1Problem: View {
    @ObservedObject var data: OnboardingData
    
    private let appTheme = AppTheme.shared
    
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
            
            // Main content
            VStack(spacing: 0) {
                // Header with back button and centered progress
                ZStack {
                    HStack {
                        BackButton {
                            // Can't go back from first screen, but keeping for consistency
                        }
                        .opacity(0.3)
                        
                        Spacer()
                    }
                    
                    ProgressIndicatorHeader(currentStep: 0, totalSteps: 10)
                }
                .padding(.horizontal, appTheme.spacing.large)
               // .padding(.vertical, appTheme.spacing.medium)
                
                Spacer()
                    .frame(height: appTheme.spacing.small)
                
                // Hero Image Area
                ZStack {
                    // Background gradient for hero area
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.05, green: 0.1, blue: 0.08),
                            Color(red: 0.08, green: 0.15, blue: 0.12)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Digital glitch effect using horizontal lines
                    // Hero Image Area
                    HeroImageView(imageName: "problemScreen")
                    
                    // Floating icon element
                    VStack {
                        Spacer()
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Image(systemName: "bell.badge.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(appTheme.colors.primary)
                            }
                            .padding(12)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .border(Color.white.opacity(0.1), width: 1)
                            
                            Spacer()
                        }
                        .padding()
                    }
                }
                .frame(height: 280)
                .cornerRadius(20)
                .padding(.horizontal, appTheme.spacing.large)
                .padding(.bottom, appTheme.spacing.large)
                
                // Text Content
                VStack(spacing: appTheme.spacing.medium) {
                    // Meta label
                    Text("THE PROBLEM")
                        .font(appTheme.fonts.labelSmall)
                        .fontWeight(.bold)
                        .tracking(1.5)
                        .foregroundColor(appTheme.colors.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Headline with highlighted text
                    VStack(alignment: .leading, spacing: 4) {
                        Text(makeHeadline())
                            .font(appTheme.fonts.displaySmall)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Body text
                    Text("Constant notifications and endless feeds fragment your focus. Do you remember the last time you focused on one thing for an hour?")
                        .font(appTheme.fonts.bodyLarge)
                        .foregroundColor(appTheme.colors.textSecondary)
                        .lineLimit(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, appTheme.spacing.large)
                
                Spacer()
                
                // Footer: Swipe prompt
                VStack(spacing: appTheme.spacing.medium) {
                    // Or use button for navigation
                    PrimaryButton(
                        title: "Next",
                        icon: "arrow.right"
                    ) {
                        data.currentScreen = 2
                    }
                }
                .padding(.horizontal, appTheme.spacing.large)
                .padding(.bottom, appTheme.spacing.large)
            }
            .zIndex(10)
        }
    }
    
    // Build an attributed headline so only "auctioned" is highlighted.
    private func makeHeadline() -> AttributedString {
        var full = AttributedString("Your attention is being auctioned.")
        
        // Apply base color to entire string
        full.foregroundColor = appTheme.colors.text
        
        // Highlight the word "auctioned"
        if let range = full.range(of: "auctioned") {
            full[range].foregroundColor = appTheme.colors.primary
        }
        
        return full
    }
}

// MARK: - Canvas Backdrop Modifier
extension View {
    @ViewBuilder
    func backdrop(blur: CGFloat) -> some View {
        self
    }
}

#Preview {
    OnboardingScreen1Problem(data: OnboardingData())
}
