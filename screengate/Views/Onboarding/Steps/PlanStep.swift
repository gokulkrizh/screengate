import SwiftUI

/// Onboarding step 12 (canvas V2-12): choose a plan. Display names per spec §9; Plus plans are gated by `EntitlementManager`.
struct PlanStep: View {
    @ObservedObject var data: OnboardingData
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(EntitlementManager.self) private var entitlements
    @State private var selected: DietPlan?

    private struct Fact { let text: String; let group: KitchenFoodGroup }

    private func detail(_ plan: DietPlan) -> (title: String, text: String, facts: [Fact]) {
        switch plan {
        case .lean: ("Balanced", "Moderate portions, steady progress.", [Fact(text: "45 min Carbs", group: .carbs), Fact(text: "12 – 8 PM", group: .protein), Fact(text: "1 extra serving / wk", group: .fats)])
        case .keto: ("Maker", "More creating, less consuming.", [Fact(text: "45 min Carbs", group: .carbs), Fact(text: "12 – 6 PM", group: .protein), Fact(text: "3 extra servings / wk", group: .fats)])
        case .detox: ("Reset", "A short break from Carbs entirely.", [Fact(text: "Carbs off", group: .carbs), Fact(text: "No extra servings", group: .fats)])
        case .custom: ("Custom", "Build your own rules.", [Fact(text: "Your portion", group: .carbs), Fact(text: "Your hours", group: .protein)])
        }
    }

    var body: some View {
        OnboardingPage {
            VStack(alignment: .leading, spacing: 10) {
                OnboardingEyebrow(text: "Made around your answers").rise(1)
                OnboardingTitle(first: "A rhythm you can", second: "actually keep.", emphasis: false).rise(2)
                OnboardingBody(text: "Start gently. You can change your plan any time.").rise(3)
            }
            VStack(spacing: 10) {
                ForEach(Array(DietPlan.allCases.enumerated()), id: \.element.id) { i, plan in
                    planCard(plan).editorialEntrance(delay: 0.4 + Double(i) * 0.08)
                }
            }.padding(.top, 4)
        } footer: {
            KitchenPrimaryButton(title: "Use this plan", systemImage: "arrow.right", isEnabled: selected != nil) { commit() }
                .editorialEntrance(delay: 0.9)
        }
        .onAppear {
            if selected == nil {
                selected = data.selectedPlan.flatMap { entitlements.canUse(plan: $0) ? $0 : nil }
                    ?? (entitlements.canUse(plan: data.suggestedPlan) ? data.suggestedPlan : .lean)
            }
        }
    }

    private func planCard(_ plan: DietPlan) -> some View {
        let d = detail(plan)
        let on = selected == plan
        return Button {
            if entitlements.canUse(plan: plan) { selected = plan } else { entitlements.presentPaywall(.featureCustomPlan) }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Text(d.title).font(KitchenFont.headline(20)).tracking(-0.4).foregroundStyle(theme.text)
                    if plan == data.suggestedPlan { badge("SUGGESTED", filled: true) }
                    if plan.isPremium { badge("PLUS", filled: false) }
                    Spacer(minLength: 0)
                    Circle().strokeBorder(on ? Color.clear : theme.line2, lineWidth: 1.5)
                        .background(Circle().fill(on ? theme.text : .clear))
                        .overlay { Image(systemName: "checkmark").font(.system(size: 11, weight: .heavy)).foregroundStyle(theme.surface).scaleEffect(on ? 1 : 0.3).opacity(on ? 1 : 0) }
                        .frame(width: 24, height: 24)
                }
                Text(d.text).font(KitchenFont.body(13)).foregroundStyle(theme.muted).fixedSize(horizontal: false, vertical: true)
                PlateStepFlowLayout(spacing: 6) {
                    ForEach(d.facts, id: \.text) { f in
                        Text(f.text).font(KitchenFont.label(11)).fontWeight(.bold)
                            .foregroundStyle(theme.color(for: f.group)).padding(.horizontal, 9).frame(height: 24)
                            .background(theme.soft(f.group, opacity: 0.11), in: Capsule())
                    }
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(on ? theme.surface : theme.surface.opacity(0.55), in: RoundedRectangle(cornerRadius: KitchenMetrics.listRadius))
            .overlay(RoundedRectangle(cornerRadius: KitchenMetrics.listRadius).stroke(on ? theme.text : theme.line, lineWidth: on ? 2 : 1))
            .shadow(color: Color(hex: "5A401E").opacity(on ? 0.12 : 0), radius: 12, y: 10)
        }
        .buttonStyle(TactileButtonStyle())
        .animation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.3, dampingFraction: 0.6), value: on)
        .sensoryFeedback(.selection, trigger: on)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(d.title)\(plan.isPremium ? ", Plus" : ""). \(d.text) \(d.facts.map(\.text).joined(separator: ", "))")
        .accessibilityAddTraits(on ? .isSelected : [])
    }

    private func badge(_ text: String, filled: Bool) -> some View {
        Text(text).font(.custom(KitchenFont.manrope, size: 10, relativeTo: .caption2).weight(.heavy)).tracking(0.6)
            .foregroundStyle(filled ? Color(hex: "FFF8EA") : theme.muted).padding(.horizontal, 8).frame(height: 22)
            .background(filled ? theme.lamp : .clear, in: Capsule())
            .overlay(Capsule().stroke(filled ? .clear : theme.line2, lineWidth: 1))
    }

    private func commit() {
        guard let selected else { return }
        data.selectedPlan = selected
        data.dailyCarbLimitMinutes = selected.defaultPortionMinutes
        data.windowStartHour = selected.defaultWindowStartHour
        data.windowEndHour = selected.defaultWindowEndHour
        data.nextScreen()
    }
}
