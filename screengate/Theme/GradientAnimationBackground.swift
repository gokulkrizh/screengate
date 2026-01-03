import SwiftUI

/// Animated radial gradient background with dark, blue, and white mix colors
struct GradientAnimationBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            RadialGradient(
                colors: [
                    // Muted colors for screen time wellness app
                    Color(red: 0.65, green: 0.7, blue: 0.75),         // Muted light grey-blue at center
                    Color(red: 0.25, green: 0.3, blue: 0.45),         // Muted blue in middle
                    Color(red: 0.1, green: 0.1, blue: 0.15)           // Dark at edges
                ],
                center: animateGradient ? .bottomLeading : .bottomTrailing,
                startRadius: 50,
                endRadius: 500,
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 4)
                    .repeatForever(autoreverses: true)
                ) {
                    animateGradient.toggle()
                }
            }
        }
    }
}

#Preview {
    ZStack {
        GradientAnimationBackground()
        
        VStack {
            Text("Animated Radial Gradient")
                .font(.title)
                .foregroundColor(.white)
        }
    }
}
