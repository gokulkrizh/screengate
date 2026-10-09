import SwiftUI
import DeviceActivity

struct HookBView: View {
    @ObservedObject var data: OnboardingData
    @Environment(DietManager.self) private var dietManager
    var body: some View {
        DietPage {
            DietHeading(eyebrow: "A moment of perspective", title: "Your attention\nhas a story.", detail: "Here’s what your selected Carbs looked like over the last seven days.", centered: true)
            if dietManager.foodGroupSelections[.carbs]?.hasAnyTokens == true {
                DeviceActivityReport(DeviceActivityReport.Context(ReportContexts.hookInsight), filter: ReportFilters.lastSevenDays(state: dietManager.sharedState))
                    .frame(height: 300).clipShape(RoundedRectangle(cornerRadius: 24)).editorialEntrance(delay: 0.15)
            } else {
                DietFeatureRow(icon: "chart.bar", title: "Your insight needs ingredients", detail: "Go back and choose your Carbs to see this report.").dietCard()
            }
            DietArtwork(asset: "LifeReclaimed", height: 160)
            Text("This is a starting point, not a judgment. With limited activity, the report may show a clearly labeled estimate from your answers.").font(.caption).foregroundStyle(AppTheme.shared.colors.textSecondary).multilineTextAlignment(.center)
        } footer: {
            PrimaryButton(title: "Let’s make some room", icon: "arrow.right") { data.nextScreen() }
        }
    }
}
