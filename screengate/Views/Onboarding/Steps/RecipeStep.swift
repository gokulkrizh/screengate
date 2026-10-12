import SwiftUI
import FamilyControls

/// Onboarding step 17 · V2-17 "Your recipe": a receipt that prints top-down, then a stamp thumps in.
struct RecipeStep: View {
    @ObservedObject var data: OnboardingData
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(DietManager.self) private var diet
    @Environment(EntitlementManager.self) private var entitlements
    @State private var printed = false

    private var intention: String { data.intention?.lowercased() ?? "what matters" }

    private func count(_ group: FoodGroup) -> Int {
        let s = diet.foodGroupSelections[group]
        return (s?.applicationTokens.count ?? 0) + (s?.categoryTokens.count ?? 0) + (s?.webDomainTokens.count ?? 0)
    }
    private func apps(_ n: Int) -> String { n == 0 ? "Your picks" : "\(n) app\(n == 1 ? "" : "s")" }

    private var hoursRange: String {
        let a = OnboardingFormat.compactTime(hour: data.windowStartHour, minute: data.windowStartMinute)
        let b = OnboardingFormat.compactTime(hour: data.windowEndHour, minute: data.windowEndMinute)
        let samePeriod = (data.windowStartHour >= 12) == (data.windowEndHour >= 12)
        return "\(samePeriod ? String(a.dropLast(3)) : a) – \(b)"
    }

    private var rows: [RecipeRow] {
        let carbs = data.selectedPlan == .detox ? "\(apps(count(.carbs))) · resting" : "\(apps(count(.carbs))) · \(data.dailyCarbLimitMinutes) min a day"
        let night = data.resolvedNightFast(enabled: true)
        let nightValue = !data.nightFastEnabled ? "Off" : entitlements.isPremium
            ? "\(OnboardingFormat.compactTime(hour: night.startHour, minute: night.startMinute)) – \(OnboardingFormat.compactTime(hour: night.endHour, minute: night.endMinute))"
            : "With Plus"
        return [
            RecipeRow(dot: .carbs, key: "Carbs", value: carbs),
            RecipeRow(dot: .fats, key: "Fats", value: "\(apps(count(.fats))) · rest during fasts"),
            RecipeRow(dot: .protein, key: "Protein", value: "\(apps(count(.protein))) · always on"),
            RecipeRow(dot: nil, key: "Kitchen hours", value: hoursRange),
            RecipeRow(dot: nil, key: "Night Fast", value: nightValue),
            RecipeRow(dot: nil, key: "Extra servings", value: "\(entitlements.isPremium ? (data.selectedPlan ?? .lean).defaultCheatsPerWeek : Entitlement.freeCheatsPerWeek) a week"),
        ]
    }

    var body: some View {
        OnboardingPage {
            VStack(alignment: .leading, spacing: 10) {
                OnboardingEyebrow(text: "Prepared just for you").rise(1)
                OnboardingTitle(first: "Your recipe for a", second: "little more \(intention).", emphasis: false, size: 34).rise(2)
            }.padding(.top, 6)
            RecipeCard(planName: OnboardingFormat.planName(data.selectedPlan), rows: rows)
                .padding(.horizontal, -4).padding(.top, 4)
        } footer: {
            VStack(spacing: 2) {
                KitchenPrimaryButton(title: "Looks like my kind of diet", systemImage: "arrow.right") { data.nextScreen() }
                KitchenSecondaryButton(title: "Adjust ingredients") { data.goToScreen(OnboardingStep.carbs.rawValue) }
            }.editorialEntrance(delay: reduceMotion ? 0 : 2.1)
        }
    }
}

private struct RecipeRow { let dot: KitchenFoodGroup?; let key: String; let value: String }

private struct RecipeCard: View {
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let planName: String
    let rows: [RecipeRow]
    @State private var progress: CGFloat = 0
    @State private var stampShown = false
    @State private var stampToken = 0

    struct Stamp { var scale: CGFloat = 1; var rot: Double = -6; var opacity: Double = 1 }

    private let ink = Color(hex: "26231F"), sub = Color(hex: "6E675D")

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("SCREENDIET · RECIPE No. 01").font(KitchenFont.label(10).weight(.heavy)).tracking(1.6).foregroundStyle(Color(hex: "7A7266"))
                Text("The \(planName) Plan").font(KitchenFont.headline(28)).tracking(-1).foregroundStyle(ink).minimumScaleFactor(0.7).lineLimit(1)
                Text("Prepared for being more present.").font(KitchenFont.body(13)).foregroundStyle(sub)
            }
            .frame(minHeight: 82, alignment: .topLeading)
            Rectangle().fill(.clear).frame(height: 2)
                .overlay(Line().stroke(Color(hex: "DDD4C4"), style: StrokeStyle(lineWidth: 2, dash: [5, 4])))
                .padding(.top, 12).padding(.bottom, 6)
            ForEach(Array(rows.enumerated()), id: \.offset) { i, r in
                if i > 0 { Rectangle().fill(Color(hex: "EFE8DB")).frame(height: 1) }
                HStack(spacing: 10) {
                    Group {
                        if let g = r.dot { Circle().fill(theme.color(for: g)) }
                        else { Circle().strokeBorder(Color(hex: "B9B0A1"), lineWidth: 1.5) }
                    }.frame(width: 8, height: 8)
                    Text(r.key).font(KitchenFont.body(14)).foregroundStyle(sub)
                    Spacer(minLength: 6)
                    Text(r.value).font(KitchenFont.body(14).weight(.bold)).monospacedDigit().foregroundStyle(ink)
                        .multilineTextAlignment(.trailing).minimumScaleFactor(0.8).lineLimit(2)
                }
                .frame(minHeight: 44)
                .editorialEntrance(delay: reduceMotion ? 0 : 0.9 + Double(i) * 0.12)
            }
        }
        .padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 52)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
        .overlay(alignment: .topLeading) { notch.offset(x: -10, y: 94) }
        .overlay(alignment: .topTrailing) { notch.offset(x: 10, y: 94) }
        .overlay(alignment: .bottomTrailing) { stamp.padding(.trailing, 18).padding(.bottom, 12) }
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "3C2814").opacity(0.06), lineWidth: 1))
        .shadow(color: Color(hex: "5A401E").opacity(0.16), radius: 20, y: 22)
        .mask(alignment: .top) { Rectangle().scaleEffect(y: progress, anchor: .top).padding(.bottom, -40).padding(.horizontal, -30) }
        .offset(y: reduceMotion ? 0 : (1 - progress) * -30)
        .onAppear {
            withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .timingCurve(0.2, 0.8, 0.2, 1, duration: 1).delay(0.35)) { progress = 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + (reduceMotion ? 0.3 : 1.8)) { stampShown = true; stampToken += 1 }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("The \(planName) Plan. \(rows.map { "\($0.key): \($0.value)" }.joined(separator: ". ")). Prepared with intention.")
    }

    private var notch: some View { Circle().fill(theme.bg).frame(width: 20, height: 20) }

    private var stamp: some View {
        Text("PREPARED WITH INTENTION").font(KitchenFont.label(10).weight(.heavy)).tracking(1.4)
            .foregroundStyle(Color(hex: "9A6E1E"))
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(Color.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "B8862C"), lineWidth: 2))
            .opacity(stampShown ? 1 : 0)
            .keyframeAnimator(initialValue: Stamp(), trigger: stampToken) { v, s in
                v.scaleEffect(s.scale).rotationEffect(.degrees(s.rot)).opacity(s.opacity)
            } keyframes: { _ in
                KeyframeTrack(\.scale) { MoveKeyframe(reduceMotion ? 1 : 2.2); CubicKeyframe(0.92, duration: 0.3); CubicKeyframe(1, duration: 0.2) }
                KeyframeTrack(\.rot) { MoveKeyframe(reduceMotion ? -6 : -12); CubicKeyframe(-5, duration: 0.3); CubicKeyframe(-6, duration: 0.2) }
                KeyframeTrack(\.opacity) { MoveKeyframe(0); LinearKeyframe(1, duration: reduceMotion ? 0.2 : 0.2) }
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: stampToken)
    }
}

private struct Line: Shape {
    func path(in rect: CGRect) -> Path { var p = Path(); p.move(to: CGPoint(x: 0, y: rect.midY)); p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY)); return p }
}
