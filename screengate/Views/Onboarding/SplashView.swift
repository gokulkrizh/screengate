import SwiftUI

/// Onboarding step 00 (canvas V2-00): the lamp flickers on, a light cone appears, the plate slides in, three
/// tiles drop (Carbs, Fats, Protein) and the wordmark rises. After ~2 s "Tap to begin" appears; tapping presents
/// `OnboardingView`.
struct SplashView: View {
    @State private var proceed = false
    var onCompletion: () -> Void = {}

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var lampOn = 0.0
    @State private var plateIn = false
    @State private var tiles = [false, false, false]
    @State private var wordmarkIn = false
    @State private var hintIn = false
    @State private var breathe = false
    @State private var sway = false

    private let theme = KitchenTheme.lamp

    var body: some View {
        Button { proceed = true } label: {
            ZStack(alignment: .top) {
                KitchenBackground(theme: .lamp)
                lamp
                cone
                plate
                wordmark
                hint
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Begin ScreenDiet")
        .accessibilityHint("Starts onboarding")
        .environment(\.kitchenTheme, theme)
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $proceed) {
            OnboardingView(initialScreen: Self.debugStartStep, onCompletion: onCompletion).paywallPresenter()
        }
        .task { await run() }
    }

    /// Debug only: `-onboarding-start N` opens onboarding at step N so the end of the real flow can be tested.
    private static var debugStartStep: Int {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(of: "-onboarding-start"), args.indices.contains(i + 1), let n = Int(args[i + 1]) { return n }
        #endif
        return 1
    }

    // MARK: Pieces

    private var lamp: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color(hex: "3A332B")).frame(width: 2, height: 150)
            UnevenRoundedRectangle(topLeadingRadius: 65, bottomLeadingRadius: 6, bottomTrailingRadius: 6, topTrailingRadius: 65)
                .fill(Color(hex: "2E2822")).frame(width: 130, height: 60)
                .overlay(alignment: .bottom) { Rectangle().fill(Color(hex: "241F1A")).frame(height: 6) }
            UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 23, bottomTrailingRadius: 23, topTrailingRadius: 0)
                .fill(theme.lamp).frame(width: 46, height: 14).padding(.top, -4)
                .shadow(color: theme.lamp.opacity(0.55), radius: 18)
                .opacity(lampOn)
        }
        .rotationEffect(.degrees(sway ? 2 : -2), anchor: .top)
        .accessibilityHidden(true)
    }

    private var cone: some View {
        Cone()
            .fill(LinearGradient(colors: [theme.lamp.opacity(0.30), theme.lamp.opacity(0.08), .clear], startPoint: .top, endPoint: .bottom))
            .frame(width: 420, height: 420)
            .padding(.top, 210)
            .opacity(lampOn)
            .accessibilityHidden(true)
    }

    private var plate: some View {
        ZStack(alignment: .topLeading) {
            Circle().fill(theme.plate)
            Circle().fill(theme.plateInner).frame(width: 182, height: 182).offset(x: 24, y: 24)
                .shadow(color: Color(hex: "3C2814").opacity(0.14), radius: 5, y: 2)
            tile(0, x: 34, y: 74, color: theme.color(for: .carbs), ink: "2A1418", symbol: "play.rectangle", rot: -10)
            tile(1, x: 92, y: 52, color: theme.color(for: .fats), ink: "1B2410", symbol: "bubble.left", rot: 6)
            tile(2, x: 134, y: 104, color: theme.color(for: .protein), ink: "2A1A08", symbol: "book", rot: 12)
        }
        .frame(width: 230, height: 230)
        .background(Circle().fill(theme.plateEdge).offset(y: 6))
        .shadow(color: .black.opacity(0.6), radius: 30, y: 30)
        .padding(.top, 360)
        .scaleEffect(plateIn || reduceMotion ? 1 : 0.9)
        .offset(y: plateIn || reduceMotion ? 0 : 40)
        .opacity(plateIn ? 1 : 0)
        .accessibilityHidden(true)
    }

    private func tile(_ i: Int, x: CGFloat, y: CGFloat, color: Color, ink: String, symbol: String, rot: Double) -> some View {
        Image(systemName: symbol).font(.system(size: 24, weight: .semibold)).foregroundStyle(Color(hex: ink))
            .frame(width: 58, height: 58)
            .background(color, in: RoundedRectangle(cornerRadius: 17))
            .shadow(color: .black.opacity(0.25), radius: 9, y: 10)
            .rotationEffect(.degrees(rot))
            .offset(x: x, y: y + (tiles[i] || reduceMotion ? 0 : -90))
            .scaleEffect(tiles[i] || reduceMotion ? 1 : 0.9)
            .opacity(tiles[i] ? 1 : 0)
    }

    private var wordmark: some View {
        VStack(spacing: 10) {
            (Text("screendiet").foregroundStyle(theme.text) + Text(".").foregroundStyle(theme.lamp))
                .font(KitchenFont.headline(46)).tracking(-1.8)
            Text("A little less scrolling. A little more living.")
                .font(KitchenFont.body(15)).foregroundStyle(theme.muted).multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
        .padding(.top, 636)
        .offset(y: wordmarkIn || reduceMotion ? 0 : 18)
        .opacity(wordmarkIn ? 1 : 0)
    }

    private var hint: some View {
        VStack {
            Spacer()
            Text("TAP TO BEGIN").font(.custom(KitchenFont.manrope, size: 12, relativeTo: .caption).weight(.bold))
                .tracking(1.9).foregroundStyle(theme.faint)
                .opacity(hintIn ? (breathe ? 1 : 0.5) : 0)
                .offset(y: hintIn || reduceMotion ? 0 : 18)
                .padding(.bottom, 8)
        }
        .accessibilityHidden(true)
    }

    // MARK: Timeline

    @MainActor private func run() async {
        if reduceMotion {
            withAnimation(.easeOut(duration: 0.2)) { lampOn = 1; plateIn = true; tiles = [true, true, true]; wordmarkIn = true }
            try? await Task.sleep(for: .seconds(1.2))
            withAnimation(.easeOut(duration: 0.2)) { hintIn = true; breathe = true }
            return
        }
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { sway = true }
        // Lamp flicker: 0 → .6 → .1 → 1
        try? await Task.sleep(for: .seconds(0.1))
        for (v, d) in [(0.6, 0.2), (0.1, 0.08), (1.0, 0.12)] {
            withAnimation(.linear(duration: d)) { lampOn = v }
            try? await Task.sleep(for: .seconds(d))
        }
        try? await Task.sleep(for: .seconds(0.2))
        withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8)) { plateIn = true }
        try? await Task.sleep(for: .seconds(0.55))
        for i in 0..<3 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { tiles[i] = true }
            try? await Task.sleep(for: .seconds(0.2))
        }
        try? await Task.sleep(for: .seconds(0.1))
        withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8)) { wordmarkIn = true }
        try? await Task.sleep(for: .seconds(0.5))
        withAnimation(.easeOut(duration: 0.6)) { hintIn = true }
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) { breathe = true }
    }
}

/// Trapezoid light cone: apex width 24 % of the base, matching the canvas clip-path.
private struct Cone: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX + r.width * 0.38, y: r.minY))
        p.addLine(to: CGPoint(x: r.minX + r.width * 0.62, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX, y: r.maxY))
        p.closeSubpath()
        return p
    }
}
