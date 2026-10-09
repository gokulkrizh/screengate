import SwiftUI

struct PlanSuggestionView: View {
    @ObservedObject var data: OnboardingData
    @Environment(EntitlementManager.self) private var entitlements
    @State private var selected: DietPlan?
    var body: some View {
        DietPage {
            DietHeading(eyebrow: "Made around your answers", title: "Your kind\nof balance.", detail: "\(data.suggestedPlan.displayName.capitalized) is a starting suggestion. Choose what you can live with.")
            ForEach(Array(DietPlan.allCases.enumerated()), id: \.element.id) { index, plan in
                VStack(alignment: .leading, spacing: 8) {
                    if plan == data.suggestedPlan { Text("SUGGESTED FOR YOU").font(.caption2.bold()).tracking(1.5).foregroundStyle(AppTheme.shared.colors.primary).padding(.leading, 16) }
                    DietChoice(icon: plan == .lean ? "leaf.fill" : plan == .keto ? "target" : plan == .detox ? "arrow.counterclockwise" : "slider.horizontal.3", title: plan.displayName.capitalized + (entitlements.canUse(plan: plan) ? "" : " · Plus"), detail: plan.subtitle, selected: selected == plan) {
                        if entitlements.canUse(plan: plan) { selected = plan }
                        else { entitlements.presentPaywall(.featureCustomPlan) }
                    }
                }.editorialEntrance(delay: Double(index) * 0.07)
            }
            DietFeatureRow(icon: "sparkles", title: "Consistency over intensity", detail: "A routine you repeat is more useful than one you abandon. Start gently.").dietCard()
        } footer: {
            PrimaryButton(title: "Set my daily rhythm", icon: "arrow.right", isDisabled: selected == nil) {
                guard let selected else { return }
                data.selectedPlan = selected
                data.dailyCarbLimitMinutes = selected.defaultPortionMinutes
                data.windowStartHour = selected.defaultWindowStartHour
                data.windowEndHour = selected.defaultWindowEndHour
                data.nextScreen()
            }
        }.onAppear { if selected == nil { selected = entitlements.canUse(plan: data.suggestedPlan) ? data.suggestedPlan : .lean } }
    }
}
