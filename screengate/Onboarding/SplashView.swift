import SwiftUI

struct SplashView: View {
    @Environment(\.theme) var theme
    @State private var isAnimating = false
    @State private var textOpacity = 0.0
    @State private var proceed = false
    var onCompletion: () -> Void = {}
    
    var body: some View {
        ZStack {
            // Themed background
            theme.colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Brain icon with pulsing animation
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    theme.colors.primary.opacity(0.3),
                                    theme.colors.primary.opacity(0)
                                ]),
                                center: .center,
                                startRadius: 40,
                                endRadius: 100
                            )
                        )
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .opacity(isAnimating ? 0.3 : 0.6)
                    
                    // Brain icon
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 80, weight: .thin))
                        .foregroundColor(theme.colors.primary)
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                }
                .frame(height: 200)
                
                Spacer()
                
                // App name
                VStack(spacing: theme.spacing.small) {
                    Text("BRAIN DIET")
                        .font(theme.fonts.displaySmall)
                        .tracking(2)
                        .foregroundColor(theme.colors.text)
                    
                    Text("Feed Your Mind Better")
                        .font(theme.fonts.bodyMedium)
                        .tracking(1)
                        .foregroundColor(theme.colors.textSecondary)
                }
                .opacity(textOpacity)
                
                Spacer()
                Spacer()
            }
            .padding()
        }
        .fullScreenCover(isPresented: $proceed) {
            OnboardingView(onCompletion: onCompletion)
        }
        .onAppear {
            // Animate brain icon
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
