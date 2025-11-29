import SwiftUI

/// Circular progress indicator with animated fill
struct ProgressRing: View {
    var progress: Double = 0.5
    var lineWidth: CGFloat = 8
    var backgroundColor: Color = .focusCard
    var foregroundColor: Color = .focusAccent
    var secondaryColor: Color = .focusSuccess
    var animationDuration: Double = 0.6
    var showPercentage: Bool = true
    var size: CGFloat = 120
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)
            
            // Animated progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [foregroundColor, secondaryColor]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            // Center content
            if showPercentage {
                VStack(spacing: 4) {
                    Text("\(Int(animatedProgress * 100))%")
                        .smallNumberStyle()
                        .foregroundColor(.focusAccent)
                    
                    Text("Complete")
                        .captionStyle()
                        .foregroundColor(.focusTextSecondary)
                }
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeInOut(duration: animationDuration)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.easeInOut(duration: animationDuration)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 32) {
        VStack(spacing: 16) {
            ProgressRing(progress: 0.25, size: 100)
            Text("25% Progress")
                .captionStyle()
                .foregroundColor(.focusTextSecondary)
        }
        
        VStack(spacing: 16) {
            ProgressRing(progress: 0.65, size: 140)
            Text("65% Progress")
                .captionStyle()
                .foregroundColor(.focusTextSecondary)
        }
        
        VStack(spacing: 16) {
            ProgressRing(progress: 1.0, size: 120)
            Text("100% Complete")
                .captionStyle()
                .foregroundColor(.focusTextSecondary)
        }
    }
    .screenBackground()
    .screenPadding()
}

// MARK: - Typography Extension Helper
extension Text {
    func smallNumberStyle() -> some View {
        self
            .font(.system(size: 32, weight: .bold))
            .lineLimit(1)
    }
}
