import SwiftUI

/// Onboarding step 19 · V2-19 "Your digital diet is ready to serve." Activates the diet on appear.
struct ReadyStep: View {
    @ObservedObject var data: OnboardingData
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(DietManager.self) private var diet
    @Environment(EntitlementManager.self) private var entitlements
    @State private var activated = false
    @State private var error: String?

    private var nightOn: Bool { data.nightFastEnabled && entitlements.isPremium }
    private var night: NightFast { data.resolvedNightFast() }

    var body: some View {
        OnboardingPage {
            ReadyHero().rise(0).padding(.horizontal, -4)
            VStack(alignment: .leading, spacing: 10) {
                OnboardingEyebrow(text: "Prepared. Balanced. Yours.").editorialEntrance(delay: 0.9)
                OnboardingTitle(first: "Your digital diet", second: "is ready to serve.").editorialEntrance(delay: 1.05)
            }.padding(.top, 6)
            if let error {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your routine needs an adjustment").font(KitchenFont.body(14).weight(.bold)).foregroundStyle(theme.text)
                    Text(error).font(KitchenFont.body(13)).foregroundStyle(theme.muted)
                    Button("Adjust my routine") { data.goToScreen(OnboardingStep.hours.rawValue) }
                        .font(KitchenFont.label(14)).foregroundStyle(theme.lamp).frame(minHeight: 44)
                }
                .padding(14).frame(maxWidth: .infinity, alignment: .leading).kitchenCard(theme, radius: 18)
            } else {
                HStack(spacing: 8) {
                    stat("Carbs a day", data.selectedPlan == .detox ? "Rest" : "\(data.dailyCarbLimitMinutes) min", .carbs, 0)
                    stat("Kitchen opens", OnboardingFormat.compactTime(hour: data.windowStartHour, minute: data.windowStartMinute), .protein, 1)
                    stat("Night Fast", nightOn ? OnboardingFormat.compactTime(hour: night.startHour, minute: night.startMinute) : "Off", .fats, 2)
                }.padding(.horizontal, -4)
            }
        } footer: {
            KitchenPrimaryButton(title: activated ? "Step into my kitchen" : "Try activation again", systemImage: "arrow.right") {
                if activated { data.completeOnboarding() } else { activate() }
            }
            .editorialEntrance(delay: reduceMotion ? 0 : 1.5)
        }
        .onAppear { activate() }
    }

    private func stat(_ key: String, _ value: String, _ group: KitchenFoodGroup, _ i: Int) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Circle().fill(theme.color(for: group)).frame(width: 8, height: 8).padding(.bottom, 4)
            Text(value).font(KitchenFont.bigNumber(20)).tracking(-0.5).foregroundStyle(theme.text).minimumScaleFactor(0.7).lineLimit(1)
            Text(key).font(KitchenFont.label(11)).foregroundStyle(theme.muted).lineLimit(1).minimumScaleFactor(0.8)
        }
        .padding(12).frame(maxWidth: .infinity, alignment: .leading)
        .kitchenCard(theme, radius: 18)
        .editorialEntrance(delay: reduceMotion ? 0 : 1.2 + Double(i) * 0.08)
        .accessibilityElement(children: .ignore).accessibilityLabel("\(key): \(value)")
    }

    private func activate() {
        #if DEBUG
        if DesignReviewView.launchRoute != nil { activated = true; return }
        #endif
        guard !activated else { return }
        var profile = DietProfile.create(plan: data.selectedPlan ?? .lean)
        profile.eatingWindow = data.eatingWindowValue
        profile.portionMinutes = data.selectedPlan == .detox ? 0 : data.dailyCarbLimitMinutes
        profile.nightFast = data.resolvedNightFast(enabled: nightOn)
        profile.cheatsPerWeek = entitlements.isPremium ? profile.plan.defaultCheatsPerWeek : Entitlement.freeCheatsPerWeek
        do { try diet.activateDiet(profile: profile); error = nil; activated = true }
        catch { self.error = error.localizedDescription }
    }
}

/// FreshStart artwork with sunrise settle, "Recipe saved" badge pop, and a confetti burst in group colours.
private struct ReadyHero: View {
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var rose = false
    @State private var badge = false
    @State private var burst = 0

    private let colors = ["E26D86", "7FA644", "D4913C", "E2C27A"]

    var body: some View {
        Color.clear.frame(height: 330).frame(maxWidth: .infinity)
            .overlay {
                Image("FreshStart").resizable().scaledToFill().frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scaleEffect(rose || reduceMotion ? 1 : 1.1).offset(y: rose || reduceMotion ? 0 : 40)
                    .opacity(rose || reduceMotion ? 1 : 0.2).clipped()
            }
            .overlay(alignment: .topLeading) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark").font(.system(size: 11, weight: .heavy)).foregroundStyle(Color(hex: "FFF8EA"))
                        .frame(width: 22, height: 22).background(theme.color(for: .fats), in: Circle())
                    Text("Recipe saved").font(KitchenFont.label(12).weight(.heavy)).foregroundStyle(Color(hex: "1F1A14"))
                }
                .padding(.leading, 6).padding(.trailing, 12).frame(height: 32)
                .background(Color(hex: "FFFDF8").opacity(0.95), in: Capsule())
                .scaleEffect(badge || reduceMotion ? 1 : 0.2).opacity(badge ? 1 : 0)
                .padding(16)
            }
            .overlay {
                if !reduceMotion { ForEach(0..<14, id: \.self) { i in Confetto(index: i, color: Color(hex: colors[i % 4]), token: burst) } }
            }
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .shadow(color: Color(hex: "5A401E").opacity(0.16), radius: 20, y: 22)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("A clay sprout growing on a plate under a rising sun. Recipe saved.")
            .onAppear {
                withAnimation(.easeOut(duration: reduceMotion ? 0.2 : 1.6)) { rose = true }
                withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.5, dampingFraction: 0.55).delay(0.7)) { badge = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { burst += 1 }
            }
            .sensoryFeedback(.success, trigger: burst)
    }
}

private struct Confetto: View {
    let index: Int
    let color: Color
    let token: Int

    struct P { var x: CGFloat = 0; var y: CGFloat = 0; var rot: Double = 0; var opacity: Double = 0 }

    var body: some View {
        let a = Double(index) / 14 * 2 * .pi + 0.3
        let d = 110.0 + Double(index % 3) * 30
        let dx = CGFloat(cos(a) * d), dy = CGFloat(sin(a) * d * 0.8 - 30)
        let w: CGFloat = index % 2 == 1 ? 8 : 6, h: CGFloat = index % 2 == 1 ? 12 : 6
        let delay = 0.1 + Double(index % 4) * 0.04
        RoundedRectangle(cornerRadius: index % 3 == 0 ? h / 2 : 2).fill(color).frame(width: w, height: h)
            .keyframeAnimator(initialValue: P(), trigger: token) { v, p in
                v.rotationEffect(.degrees(p.rot)).offset(x: p.x, y: p.y).opacity(p.opacity)
            } keyframes: { _ in
                KeyframeTrack(\.opacity) { MoveKeyframe(0); LinearKeyframe(0, duration: delay); LinearKeyframe(1, duration: 0.2); LinearKeyframe(0, duration: 1.2) }
                KeyframeTrack(\.x) { MoveKeyframe(0); LinearKeyframe(0, duration: delay); CubicKeyframe(dx, duration: 1.4) }
                KeyframeTrack(\.y) { MoveKeyframe(0); LinearKeyframe(0, duration: delay); CubicKeyframe(dy, duration: 1.4) }
                KeyframeTrack(\.rot) { MoveKeyframe(0); LinearKeyframe(0, duration: delay); LinearKeyframe(Double(index) * 47, duration: 1.4) }
            }
            .allowsHitTesting(false)
    }
}
