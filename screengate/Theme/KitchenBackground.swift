import SwiftUI

/// Spec §2 "Backgrounds (never flat)": light source glow, 48 pt backsplash tile grid, base colour.
/// Changing `theme` cross-fades over 0.6 s.
struct KitchenBackground: View {
    let theme: KitchenTheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            theme.bg
            TileGrid(color: tileColor)
            glow
            if theme == .night { Stars(reduceMotion: reduceMotion) }
        }
        .ignoresSafeArea()
        .animation(reduceMotion ? .easeOut(duration: 0.2) : KitchenMetrics.crossFade, value: theme)
        .accessibilityHidden(true)
    }

    private var tileColor: Color {
        switch theme {
        case .lamp: Color(hex: "FFECD2").opacity(0.03)
        case .daylight: Color(hex: "3C2814").opacity(0.03)
        case .night: Color(hex: "DCE2FF").opacity(0.025)
        }
    }

    @ViewBuilder private var glow: some View {
        GeometryReader { geo in
            switch theme {
            case .lamp:
                // Pendant lamp: ellipse 110 % × 55 % centred above the screen.
                RadialGradient(colors: [Color(hex: "F3D9A4").opacity(0.18), .clear],
                               center: .center, startRadius: 0, endRadius: geo.size.width * 0.55)
                    .frame(width: geo.size.width * 1.1, height: geo.size.height * 0.55)
                    .position(x: geo.size.width / 2, y: 0)
            case .daylight:
                RadialGradient(colors: [Color(hex: "FFCE78").opacity(0.38), .clear],
                               center: .topTrailing, startRadius: 0, endRadius: geo.size.width * 0.95)
            case .night:
                RadialGradient(colors: [Color(hex: "96A0FF").opacity(0.20), .clear],
                               center: .topLeading, startRadius: 0, endRadius: geo.size.width * 0.95)
            }
        }
    }
}

private struct TileGrid: View {
    let color: Color
    var body: some View {
        Canvas { ctx, size in
            var path = Path()
            var x: CGFloat = 0
            while x <= size.width { path.move(to: CGPoint(x: x, y: 0)); path.addLine(to: CGPoint(x: x, y: size.height)); x += 48 }
            var y: CGFloat = 0
            while y <= size.height { path.move(to: CGPoint(x: 0, y: y)); path.addLine(to: CGPoint(x: size.width, y: y)); y += 48 }
            ctx.stroke(path, with: .color(color), lineWidth: 1)
        }
    }
}

private struct Stars: View {
    let reduceMotion: Bool
    private static let points: [(CGFloat, CGFloat, CGFloat, Double)] = [
        (0.12, 0.08, 2, 0), (0.30, 0.16, 3, 0.7), (0.52, 0.06, 2, 1.4), (0.74, 0.14, 3, 0.3),
        (0.90, 0.07, 2, 1.0), (0.20, 0.30, 2, 1.9), (0.84, 0.28, 2, 0.5), (0.62, 0.24, 3, 1.2),
    ]
    var body: some View {
        GeometryReader { geo in
            ForEach(Array(Self.points.enumerated()), id: \.offset) { _, p in
                Star(size: p.2, delay: p.3, animated: !reduceMotion)
                    .position(x: geo.size.width * p.0, y: geo.size.height * p.1)
            }
        }
    }
}

private struct Star: View {
    let size: CGFloat, delay: Double, animated: Bool
    @State private var dim = false
    var body: some View {
        Circle().fill(Color(hex: "EEF0FA")).frame(width: size, height: size)
            .opacity(animated ? (dim ? 0.25 : 0.9) : 0.6)
            .onAppear {
                guard animated else { return }
                withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true).delay(delay)) { dim = true }
            }
    }
}

extension View {
    /// Places the view over the themed kitchen background.
    func kitchenBackground(_ theme: KitchenTheme) -> some View {
        background { KitchenBackground(theme: theme) }
    }
}

#Preview("Lamp") { Color.clear.kitchenBackground(.lamp) }
#Preview("Daylight") { Color.clear.kitchenBackground(.daylight) }
#Preview("Night") { Color.clear.kitchenBackground(.night) }
