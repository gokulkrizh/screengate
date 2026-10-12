import SwiftUI

/// Onboarding step 15 · V2-15 "The best midnight snack is sleep." Night theme. Night Fast itself is a Plus feature:
/// the choice is remembered here and only becomes real when the diet is activated with an active membership.
struct NightFastStep: View {
    @ObservedObject var data: OnboardingData
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(EntitlementManager.self) private var entitlements

    private var on: Bool { data.nightFastEnabled }
    private var night: NightFast { data.resolvedNightFast(enabled: true) }
    private var range: String {
        "\(EatingWindow.formatTime(hour: night.startHour, minute: night.startMinute)) – \(EatingWindow.formatTime(hour: night.endHour, minute: night.endMinute))"
    }
    private var wakeLabel: String {
        let h = night.endHour % 12 == 0 ? 12 : night.endHour % 12
        return night.endMinute == 0 ? "\(h)" : "\(h):\(String(format: "%02d", night.endMinute))"
    }

    var body: some View {
        OnboardingPage {
            artwork.rise(1).padding(.horizontal, -4).padding(.top, -2)
            VStack(alignment: .leading, spacing: 10) {
                OnboardingEyebrow(text: "Let the kitchen rest · Plus").rise(2)
                OnboardingTitle(first: "The best midnight", second: "snack is sleep.", size: 34).rise(3)
            }.padding(.top, 4)
            card.rise(3).padding(.horizontal, -4)
        } footer: {
            VStack(spacing: 2) {
                KitchenPrimaryButton(title: on ? "Keep Night Fast" : "Skip for now", systemImage: "arrow.right") { data.nextScreen() }
                if !entitlements.isPremium && on {
                    Text("Night Fast switches on with Plus.").font(KitchenFont.label(11)).foregroundStyle(theme.faint)
                        .frame(minHeight: 24)
                }
            }.rise(8)
        }
        .overlay(alignment: .topLeading) { stars }
        .animation(reduceMotion ? .easeOut(duration: 0.2) : .easeInOut(duration: 0.6), value: on)
    }

    // MARK: Artwork + sign

    private var artwork: some View {
        Color.clear.frame(height: 250).frame(maxWidth: .infinity)
            .overlay {
                DietHeroArt(asset: "NightGarden")
                    .saturation(on ? 1 : 0.3).brightness(on ? 0 : -0.45)
            }
            .overlay(alignment: .topTrailing) {
                if on { NightFastSign(wake: wakeLabel).padding(.trailing, 22).transition(.opacity) }
            }
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(color: .black.opacity(0.5), radius: 24, y: 24)
            .overlay(RoundedRectangle(cornerRadius: 30).stroke(theme.line, lineWidth: 1))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("A sleeping clay phone resting on a crescent moon among clouds. \(on ? "Sign reads: Closed, see you at \(wakeLabel)." : "")")
    }

    private var stars: some View {
        ZStack(alignment: .topLeading) {
            Star(x: 300, y: -90, size: 3, delay: 0); Star(x: 240, y: -50, size: 2, delay: 0.8); Star(x: 350, y: -20, size: 2, delay: 1.5)
        }.allowsHitTesting(false).accessibilityHidden(true)
    }

    // MARK: Toggle card

    private var card: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Night Fast").font(KitchenFont.body(16).weight(.bold)).foregroundStyle(theme.text)
                    Text(range).font(KitchenFont.body(12)).monospacedDigit().foregroundStyle(theme.muted)
                }
                Spacer()
                NightSwitch(isOn: Binding(get: { data.nightFastEnabled }, set: { data.nightFastEnabled = $0 }))
            }
            .frame(minHeight: 66)
            ForEach(Array(rules.enumerated()), id: \.offset) { i, rule in
                Divider().overlay(theme.line)
                HStack(spacing: 12) {
                    Circle().fill(theme.color(for: rule.0)).frame(width: 8, height: 8)
                    Text(rule.1).font(KitchenFont.body(13)).foregroundStyle(theme.muted)
                    Spacer(minLength: 0)
                }
                .frame(minHeight: 44)
                .editorialEntrance(delay: 0.5 + Double(i) * 0.08)
            }
        }
        .padding(.horizontal, 16)
        .kitchenCard(theme, radius: 22)
    }

    private var rules: [(KitchenFoodGroup, String)] {
        [(.carbs, "Carbs and Fats rest overnight"), (.protein, "Protein stays on the table"), (.fats, "Takes priority over kitchen hours")]
    }
}

private struct Star: View {
    let x: CGFloat, y: CGFloat, size: CGFloat, delay: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        if reduceMotion {
            Circle().fill(Color(hex: "F1E6C8")).frame(width: size, height: size).opacity(0.6).offset(x: x, y: y)
        } else {
            PhaseAnimator(delay > 0.5 ? [1.0, 0.25] : [0.25, 1.0]) { o in
                Circle().fill(Color(hex: "F1E6C8")).frame(width: size, height: size).opacity(o)
            } animation: { _ in .easeInOut(duration: 1.3).delay(0) }
            .offset(x: x, y: y)
        }
    }
}

/// "CLOSED · SEE YOU AT 7" sign that swings in on a string (hang keyframes 0.9 s).
private struct NightFastSign: View {
    let wake: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var token = 0
    @State private var started = false

    struct Pose { var y: CGFloat = 0; var rot: Double = 0; var opacity: Double = 1 }

    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color(hex: "F1E6C8").opacity(0.6)).frame(width: 2, height: 26)
            Text("CLOSED\nSEE YOU AT \(wake)").font(KitchenFont.label(11).weight(.heavy)).tracking(1.1).multilineTextAlignment(.center)
                .lineSpacing(2).foregroundStyle(Color(hex: "151830"))
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(Color(hex: "F1E6C8"), in: RoundedRectangle(cornerRadius: 10))
                .shadow(color: .black.opacity(0.35), radius: 10, y: 10)
        }
        .opacity(started ? 1 : 0)
        .keyframeAnimator(initialValue: Pose(), trigger: token) { v, p in
            v.rotationEffect(.degrees(p.rot), anchor: .top).offset(y: p.y).opacity(p.opacity)
        } keyframes: { _ in
            KeyframeTrack(\.y) { MoveKeyframe(reduceMotion ? 0 : -40); CubicKeyframe(4, duration: 0.54); CubicKeyframe(0, duration: 0.36) }
            KeyframeTrack(\.rot) { MoveKeyframe(reduceMotion ? 0 : -8); CubicKeyframe(3, duration: 0.54); CubicKeyframe(-1.5, duration: 0.18); CubicKeyframe(0, duration: 0.18) }
            KeyframeTrack(\.opacity) { MoveKeyframe(0); LinearKeyframe(1, duration: reduceMotion ? 0.2 : 0.4) }
        }
        .onAppear { started = true; token += 1 }
        .accessibilityHidden(true)
    }
}

/// 54 × 32 switch (lamp track when on). 44 pt tall hit area.
private struct NightSwitch: View {
    @Binding var isOn: Bool
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        Button { isOn.toggle() } label: {
            Capsule().fill(isOn ? theme.lamp : theme.surface2).frame(width: 54, height: 32)
                .overlay(alignment: isOn ? .trailing : .leading) {
                    Circle().fill(isOn ? Color(hex: "151830") : Color(hex: "EEF0FA")).frame(width: 26, height: 26)
                        .shadow(color: .black.opacity(0.3), radius: 3, y: 2).padding(3)
                }
                .frame(minWidth: 54, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.3, dampingFraction: 0.75), value: isOn)
        .sensoryFeedback(.selection, trigger: isOn)
        .accessibilityLabel("Night Fast")
        .accessibilityValue(isOn ? "On" : "Off")
        .accessibilityAddTraits(.isToggle)
    }
}
