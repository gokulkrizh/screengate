import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var textOpacity = 0.0
    @State private var proceed = false
    var onCompletion: () -> Void = {}
    
    private let appTheme = AppTheme.shared
    
    var body: some View {
        ZStack {
            // Dark background matching design (#102216)
            Color(red: 0.06, green: 0.13, blue: 0.09)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo with pulsing animation
                ZStack {
                    // Outer glow effect
                    RoundedRectangle(cornerRadius: appTheme.spacing.cornerRadiusLarge)
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    appTheme.colors.primary.opacity(0.2),
                                    appTheme.colors.primary.opacity(0)
                                ]),
                                center: .center,
                                startRadius: 40,
                                endRadius: 120
                            )
                        )
                        .scaleEffect(isAnimating ? 1.15 : 1.0)
                    
                    // Logo background
                    RoundedRectangle(cornerRadius: appTheme.spacing.cornerRadiusLarge)
                        .fill(appTheme.colors.primary)
                        .frame(width: 128, height: 128)
                        .shadow(color: appTheme.colors.primary.opacity(0.2), radius: 16)
                    
                    // Smartphone icon
                    Image(systemName: "smartphone")
                        .font(.system(size: 60, weight: .regular))
                        .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                    
                    // Bite/reduction circle overlay
                    Circle()
                        .fill(Color(red: 0.06, green: 0.13, blue: 0.09))
                        .frame(width: 40, height: 40)
                        .offset(x: 45, y: -45)
                }
                .frame(height: 200)
                
                Spacer()
                
                // App name
                VStack(spacing: appTheme.spacing.small) {
                    Text("Screendiet")
                        .font(appTheme.fonts.displayMedium)
                        .tracking(0.5)
                        .foregroundColor(appTheme.colors.text)
                    
                    Text("Digital Wellbeing")
                        .font(appTheme.fonts.labelMedium)
                        .tracking(1.5)
                        .foregroundColor(appTheme.colors.textSecondary)
                }
                .opacity(textOpacity)
                
                Spacer()
                
                // Bottom section: Progress bar and version
                VStack(spacing: appTheme.spacing.large) {
                    // Progress bar
                    VStack(spacing: appTheme.spacing.small) {
                        ZStack(alignment: .leading) {
                            // Background track
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                                .frame(maxWidth: 200)
                                .frame(height: 6)
                            
                            // Progress fill
                            Capsule()
                                .fill(appTheme.colors.primary)
                                .frame(maxWidth: 200 * 0.6, alignment: .leading)
                                .frame(height: 6)
                        }
                        .frame(maxWidth: 200)
                        
                        Text("Loading your profile...")
                            .font(appTheme.fonts.labelSmall)
                            .foregroundColor(appTheme.colors.textSecondary)
                    }
                    
                    // Version info
                    Text("v1.0")
                        .font(appTheme.fonts.bodySmall)
                        .foregroundColor(appTheme.colors.textSecondary.opacity(0.6))
                }
                .padding(.bottom, appTheme.spacing.large)
            }
            .padding(.horizontal, appTheme.spacing.large)
        }
        .fullScreenCover(isPresented: $proceed) {
            OnboardingView(onCompletion: onCompletion)
        }
        .onAppear {
            // Animate logo
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            
            // Fade in text
            withAnimation(.easeIn(duration: 0.8)) {
                textOpacity = 1.0
            }
            
            // Auto-advance after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                proceed = true
            }
        }
    }
}

#Preview {
    SplashView()
}
