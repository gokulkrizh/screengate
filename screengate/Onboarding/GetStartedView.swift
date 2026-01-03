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
            VStack {
                HStack {
                    VStack(spacing: 0) {
                        Circle()
                            .fill(appTheme.colors.primary.opacity(0.2))
                            .blur(radius: 100)
                            .frame(width: 300, height: 300)
                        Spacer()
                    }
                    .offset(x: 150, y: -60)
                    
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Circle()
                            .fill(appTheme.colors.primary.opacity(0.1))
                            .blur(radius: 80)
                            .frame(width: 250, height: 250)
                    }
                    .offset(x: 100, y: 50)
                }
            }
            .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                Spacer()
                
                // Hero Image Area - Welcome Screen Image
                ZStack {
                    Image("welcomScreen")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea(.all)
                }
                .frame(height: 280)
                .cornerRadius(24)
                .padding(.horizontal, appTheme.spacing.large)
                .padding(.bottom, appTheme.spacing.large)
                
                // Text Content
                VStack(spacing: appTheme.spacing.medium) {
                    Text("Screendiet")
                        .font(appTheme.fonts.displayMedium)
                        .fontWeight(.bold)
                        .tracking(0.5)
                        .foregroundColor(appTheme.colors.text)
                    
                    Text("Reclaim your time. Master your focus. Digital fasting for a clearer mind.")
                        .font(appTheme.fonts.titleLarge)
                        .foregroundColor(appTheme.colors.textSecondary)
                        .lineLimit(4)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, appTheme.spacing.large)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: appTheme.spacing.medium) {
                    // Get Started Button
                    Button(action: {
                        withAnimation {
                            data.currentScreen = 1
                        }
                    }) {
                        HStack(spacing: appTheme.spacing.small) {
                            Text("Get Started")
                                .font(appTheme.fonts.titleLarge)
                                .fontWeight(.bold)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(appTheme.colors.primary)
                        .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                        .cornerRadius(14)
                        .shadow(color: appTheme.colors.primary.opacity(0.25), radius: 12)
                    }
                    .activeScale(0.98)
                    
                    // Log In Button
                    Button(action: {
                        // Future: Implement login flow
                    }) {
                        Text("Already have an account? Log in")
                            .font(appTheme.fonts.bodyMedium)
                            .fontWeight(.semibold)
                            .foregroundColor(appTheme.colors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(14)
                    }
                }
                .padding(.horizontal, appTheme.spacing.large)
                .padding(.bottom, appTheme.spacing.large)
            }
            .zIndex(10)
        }
    }
}

// MARK: - View Extension for scale effect
extension View {
    @ViewBuilder
    func activeScale(_ scale: CGFloat) -> some View {
        self.scaleEffect(1.0, anchor: .center)
    }
}

#Preview {
    GetStartedView(data: OnboardingData())
}
