import SwiftUI
import FamilyControls

/// Onboarding step 07 (canvas V2-07): phone → three bowls illustration, benefits, Screen Time authorization.
struct ScreenTimeStep: View {
    @ObservedObject var data: OnboardingData
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.scenePhase) private var scenePhase
    @State private var status = AuthorizationCenter.shared.authorizationStatus
    @State private var requesting = false
    @State private var errorMessage: String?

    private let benefits: [(title: String, detail: String, icon: String)] = [
        ("Private by design", "Your selections and diet stay on this iPhone.", "lock"),
        ("Apple’s secure picker", "You choose the apps. ScreenDiet never sees which ones.", "checkmark.shield"),
        ("Measured by Screen Time", "Your reports come from Apple, not from tracking.", "chart.bar.doc.horizontal"),
    ]

    var body: some View {
        OnboardingPage {
            ScreenTimeIllustration().padding(.horizontal, -4).rise(0)
            VStack(alignment: .leading, spacing: 8) {
                OnboardingEyebrow(text: "Connect your ingredients").rise(1)
                OnboardingTitle(first: "Your kitchen needs", second: "to know your apps.", emphasis: false, size: 32).rise(2)
            }
            VStack(spacing: 0) {
                ForEach(Array(benefits.enumerated()), id: \.offset) { i, b in
                    HStack(spacing: 14) {
                        Image(systemName: b.icon).font(.system(size: 15, weight: .semibold)).foregroundStyle(theme.muted)
                            .frame(width: 36, height: 36).background(theme.surface2, in: RoundedRectangle(cornerRadius: 12))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(b.title).font(KitchenFont.body(14).weight(.bold)).foregroundStyle(theme.text)
                            Text(b.detail).font(KitchenFont.body(12)).foregroundStyle(theme.muted).fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 12)
                    .overlay(alignment: .top) { if i > 0 { Rectangle().fill(theme.line).frame(height: 1) } }
                    .accessibilityElement(children: .combine)
                    .editorialEntrance(delay: 0.5 + Double(i) * 0.1)
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 4)
            .kitchenCard(theme)
            .padding(.horizontal, -4)
            if let errorMessage {
                Text(errorMessage).font(KitchenFont.body(13)).foregroundStyle(theme.color(for: .carbs))
                    .frame(maxWidth: .infinity, alignment: .leading).transition(.opacity)
            }
            if status == .denied {
                Text("You can review Screen Time access in iOS Settings, then return here to continue.")
                    .font(KitchenFont.body(12)).foregroundStyle(theme.muted)
                KitchenSecondaryButton(title: "Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
                }
            }
        } footer: {
            KitchenPrimaryButton(title: status == .approved ? "Access granted · Continue" : requesting ? "Waiting for iOS…" : "Connect Screen Time",
                                 systemImage: status == .approved ? "checkmark" : "arrow.right", isEnabled: !requesting) {
                if status == .approved { data.nextScreen() } else { request() }
            }
            Text("Apple will ask you to confirm on the next screen.")
                .font(KitchenFont.body(12)).foregroundStyle(theme.faint).padding(.top, 10)
        }
        .onChange(of: scenePhase) { _, phase in if phase == .active { status = AuthorizationCenter.shared.authorizationStatus } }
    }

    private func request() {
        requesting = true; errorMessage = nil
        Task { @MainActor in
            defer { requesting = false }
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                status = AuthorizationCenter.shared.authorizationStatus
                if status == .approved { data.nextScreen() }
            } catch {
                status = AuthorizationCenter.shared.authorizationStatus
                errorMessage = "ScreenDiet needs this permission to apply your app boundaries. Try again when you’re ready."
            }
        }
    }
}

/// Drawn-in-code: a phone with a shield badge, three dashed flows pouring into Carbs / Fats / Protein bowls.
private struct ScreenTimeIllustration: View {
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        RoundedRectangle(cornerRadius: 28).fill(theme.surface).frame(height: 220)
            .overlay { canvas.frame(width: 350, height: 220) }
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(theme.line, lineWidth: 1))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("A phone sorting your apps into three bowls: carbs, fats and protein")
    }

    private var canvas: some View {
        ZStack(alignment: .topLeading) {
            TimelineView(.animation(minimumInterval: 1.0 / 30, paused: reduceMotion)) { ctx in
                let phase = reduceMotion ? 0 : -(ctx.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 1.4) / 1.4) * 12
                ZStack {
                    flow(to: CGPoint(x: 70, y: 176), c1: CGPoint(x: 175, y: 160), c2: CGPoint(x: 70, y: 150), color: theme.color(for: .carbs), phase: phase)
                    flow(to: CGPoint(x: 175, y: 176), c1: CGPoint(x: 175, y: 140), c2: CGPoint(x: 175, y: 160), color: theme.color(for: .fats), phase: phase)
                    flow(to: CGPoint(x: 280, y: 176), c1: CGPoint(x: 175, y: 160), c2: CGPoint(x: 280, y: 150), color: theme.color(for: .protein), phase: phase)
                }
            }
            PulsingBadge().frame(width: 68, height: 110)
                .background(Color(hex: "26221D"), in: RoundedRectangle(cornerRadius: 18))
                .shadow(color: Color(hex: "3C2814").opacity(0.25), radius: 15, y: 16)
                .offset(x: 141, y: 20)
            bowl(.carbs, x: 34, delay: 0.5)
            bowl(.fats, x: 139, delay: 0.62)
            bowl(.protein, x: 244, delay: 0.74)
        }
    }

    private func flow(to end: CGPoint, c1: CGPoint, c2: CGPoint, color: Color, phase: Double) -> some View {
        Path { p in
            p.move(to: CGPoint(x: 175, y: 128))
            p.addCurve(to: end, control1: c1, control2: c2)
        }
        .stroke(color, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, dash: [4, 8], dashPhase: phase))
        .frame(width: 350, height: 220)
    }

    private func bowl(_ g: KitchenFoodGroup, x: CGFloat, delay: Double) -> some View {
        BowlView(color: theme.color(for: g)).offset(x: x, y: 166).bowlEntrance(delay: delay)
    }
}

private struct BowlView: View {
    let color: Color
    var body: some View {
        VStack(spacing: 0) {
            Capsule().fill(color.opacity(0.55)).frame(width: 72, height: 8)
            UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 30, bottomTrailingRadius: 30, topTrailingRadius: 0)
                .fill(color).frame(width: 60, height: 30)
        }
        .frame(width: 72)
    }
}

private struct PulsingBadge: View {
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var ring = false
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 13).stroke(theme.lamp.opacity(ring ? 0 : 0.45), lineWidth: 8)
                .frame(width: 40, height: 40).scaleEffect(ring ? 1.9 : 1)
            Image(systemName: "checkmark.shield").font(.system(size: 18, weight: .semibold)).foregroundStyle(Color(hex: "FFF8EA"))
                .frame(width: 40, height: 40).background(theme.lamp, in: RoundedRectangle(cornerRadius: 13))
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeOut(duration: 2.2).delay(1).repeatForever(autoreverses: false)) { ring = true }
        }
    }
}

private extension View {
    func bowlEntrance(delay: Double) -> some View { modifier(BowlEntrance(delay: delay)) }
}

private struct BowlEntrance: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let delay: Double
    @State private var shown = false
    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .scaleEffect(shown || reduceMotion ? 1 : 0.8)
            .offset(y: shown || reduceMotion ? 0 : 16)
            .task {
                if reduceMotion { withAnimation(.easeOut(duration: 0.2)) { shown = true }; return }
                try? await Task.sleep(for: .seconds(delay))
                withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) { shown = true }
            }
    }
}
