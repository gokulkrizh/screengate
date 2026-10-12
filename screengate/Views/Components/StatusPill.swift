import SwiftUI

/// Pill with an optional gently pulsing dot ("NOW SERVING", "NIGHT FAST", …).
struct StatusPill: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let text: String
    let color: Color
    var showsDot = false
    /// Light pill that sits on artwork (spec Kitchen hero) rather than on the surface.
    var onArtwork = false
    var compact = false
    @State private var pulse = false

    var body: some View {
        HStack(spacing: 8) {
            if showsDot {
                Circle().fill(color).frame(width: 8, height: 8)
                    .scaleEffect(pulse ? 1.35 : 1).opacity(pulse ? 0.65 : 1)
            }
            Text(text.uppercased()).font(.custom(KitchenFont.manrope, size: compact ? 9 : 11, relativeTo: .caption2).weight(.heavy)).tracking(0.5)
        }
        .foregroundStyle(onArtwork ? Color(hex: "1F1A14") : color)
        .padding(.horizontal, compact ? 8 : 12).frame(height: compact ? 20 : 28)
        .background(onArtwork ? Color(hex: "FFFDF8").opacity(0.94) : color.opacity(0.14), in: Capsule())
        .onAppear {
            guard showsDot, !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) { pulse = true }
        }
    }
}
