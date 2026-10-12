import SwiftUI

/// Onboarding step 02 (canvas V2-02): the overflowing plate at 2:14 AM under a flickering "OPEN 24/7" sign.
struct StoryStep: View {
    @ObservedObject var data: OnboardingData
    @Environment(\.kitchenTheme) private var theme
    var body: some View {
        OnboardingPage {
            StoryPlateScene().rise(0)
            VStack(alignment: .leading, spacing: 12) {
                OnboardingEyebrow(text: "A healthier relationship").rise(1)
                OnboardingTitle(first: "You don’t need to quit", second: "every treat.", emphasis: false).rise(2)
                OnboardingBody(text: "Some apps nourish you. Some are a treat. The trouble starts when the kitchen never closes.").rise(3)
            }
            .padding(.top, 6)
        } footer: {
            KitchenPrimaryButton(title: "Let’s find my balance", systemImage: "arrow.right") { data.nextScreen() }
        }
    }
}

/// Drawn-in-code illustration: plate piled with app tiles. Canvas coordinates are for a 350 × 330 card.
private struct StoryPlateScene: View {
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private struct Pile { let color: String; let symbol: String; let x: CGFloat; let y: CGFloat; let size: CGFloat; let rot: Double; let delay: Double }
    private let pile: [Pile] = [
        .init(color: "8E2F2B", symbol: "film", x: 104, y: 196, size: 52, rot: -14, delay: 0.3),
        .init(color: "E0703A", symbol: "text.bubble", x: 152, y: 206, size: 52, rot: 6, delay: 0.38),
        .init(color: "6A5BC2", symbol: "gamecontroller", x: 200, y: 200, size: 52, rot: 14, delay: 0.46),
        .init(color: "D2513E", symbol: "play.rectangle", x: 120, y: 150, size: 54, rot: 8, delay: 0.56),
        .init(color: "4F9A5A", symbol: "bubble.left", x: 172, y: 156, size: 54, rot: -6, delay: 0.64),
        .init(color: "C2577A", symbol: "camera", x: 140, y: 104, size: 56, rot: -4, delay: 0.74),
        .init(color: "2F343B", symbol: "music.note", x: 190, y: 112, size: 52, rot: 18, delay: 0.82),
        .init(color: "D2513E", symbol: "play.rectangle", x: 48, y: 252, size: 46, rot: -28, delay: 0.95),
        .init(color: "C2577A", symbol: "camera", x: 262, y: 256, size: 46, rot: 24, delay: 1.02),
    ]

    var body: some View {
        RoundedRectangle(cornerRadius: 32).fill(Color(hex: "FFECD2").opacity(0.03))
            .frame(height: 330)
            .overlay {
                ZStack(alignment: .topLeading) {
                    Text("2:14 AM").font(.custom(KitchenFont.manrope, size: 11, relativeTo: .caption2).weight(.bold)).tracking(1.3)
                        .foregroundStyle(theme.faint).offset(x: 20, y: 26)
                    Circle().fill(theme.plateEdge).frame(width: 236, height: 236).offset(x: 57, y: 96)
                    Circle().fill(theme.plate).frame(width: 236, height: 236).offset(x: 57, y: 92)
                        .shadow(color: .black.opacity(0.55), radius: 24, y: 24)
                    Circle().fill(theme.plateInner).frame(width: 188, height: 188).offset(x: 81, y: 116)
                    ForEach(Array(pile.enumerated()), id: \.offset) { _, p in
                        PileTile(color: Color(hex: p.color), symbol: p.symbol, size: p.size, rot: p.rot, delay: p.delay)
                            .offset(x: p.x, y: p.y)
                    }
                    OpenSign().offset(x: 350 - 20 - 112, y: 20)
                }
                .frame(width: 350, height: 330, alignment: .topLeading)
            }
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .overlay(RoundedRectangle(cornerRadius: 32).stroke(theme.line, lineWidth: 1))
            .padding(.horizontal, -4)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("A plate overflowing with app icons at 2:14 in the morning, under an open 24/7 sign")
    }
}

private struct PileTile: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let color: Color, symbol: String, size: CGFloat, rot: Double, delay: Double
    @State private var landed = false
    var body: some View {
        Image(systemName: symbol).font(.system(size: size * 0.45, weight: .semibold)).foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(color, in: RoundedRectangle(cornerRadius: size * 0.28))
            .shadow(color: .black.opacity(0.35), radius: 8, y: 8)
            .rotationEffect(.degrees(rot))
            .offset(y: landed || reduceMotion ? 0 : -120)
            .opacity(landed ? 1 : 0)
            .task {
                if reduceMotion { withAnimation(.easeOut(duration: 0.2)) { landed = true }; return }
                try? await Task.sleep(for: .seconds(delay))
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { landed = true }
            }
    }
}

private struct OpenSign: View {
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        let c = theme.color(for: .carbs)
        TimelineView(.animation(minimumInterval: 1.0 / 20, paused: reduceMotion)) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 4) / 4
            let dim = (t > 0.03 && t < 0.06) ? 0.4 : (t > 0.5 && t < 0.52) ? 0.55 : 1.0
            Text("OPEN 24/7").font(KitchenFont.headline(14)).tracking(1.1)
                .foregroundStyle(c)
                .shadow(color: c.opacity(0.6), radius: 4)
                .padding(.horizontal, 14).frame(height: 34)
                .background(RoundedRectangle(cornerRadius: 10).fill(c.opacity(0.08)))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(c, lineWidth: 1.5))
                .shadow(color: c.opacity(0.35), radius: 9)
                .opacity(reduceMotion ? 1 : dim)
        }
    }
}
