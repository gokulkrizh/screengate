import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var textOpacity = 0.0
    @State private var proceed = false
    var onCompletion: () -> Void = {}
    
    var body: some View {
        ZStack {
            // Dark background
            Color(red: 0.06, green: 0.06, blue: 0.07)
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
                                    Color(red: 0, green: 1, blue: 0.39).opacity(0.3),
                                    Color(red: 0, green: 1, blue: 0.39).opacity(0)
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
                        .foregroundColor(Color(red: 0, green: 1, blue: 0.39))
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                }
                .frame(height: 200)
                
                Spacer()
                
                // App name
                VStack(spacing: 8) {
                    Text("BRAIN DIET")
                        .font(Font.custom("Manrope", size: 36).weight(.bold))
                        .tracking(2)
                        .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                    
                    Text("Feed Your Mind Better")
                        .font(Font.custom("Manrope", size: 14).weight(.regular))
                        .tracking(1)
                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.49))
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
