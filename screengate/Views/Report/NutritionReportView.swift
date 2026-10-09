import SwiftUI
import DeviceActivity

struct NutritionReportView: View {
    @Environment(DietManager.self) private var diet
    @Environment(EntitlementManager.self) private var entitlements
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var today = false
    @State private var help = false
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                DietHeading(eyebrow: "The bigger picture", title: "Your Weekly Digest", detail: "A little perspective on where your attention goes.")
                if !entitlements.isPremium { locked }
                else if !ReportFilters.junkSelection(state: diet.sharedState).hasAnyTokens {
                    DietArtwork(asset: "BalancedPantry", height: 230)
                    DietHeading(eyebrow: "Start with your ingredients", title: "Your story needs\na few selections.", detail: "Assign your Carbs and Fats in the Pantry. Your measured activity will appear here as Screen Time records it.", centered: true)
                    Button("Open my Pantry") { NotificationCenter.default.post(name: .screenDietTab, object: 2) }.frame(minHeight: 44)
                } else {
                    Picker("Report period", selection: $today) { Text("Last 7 days").tag(false); Text("Today").tag(true) }.pickerStyle(.segmented)
                    if today {
                        DeviceActivityReport(DeviceActivityReport.Context(ReportContexts.today), filter: ReportFilters.today(state: diet.sharedState)).frame(height: typeSize.isAccessibilitySize ? 540 : 320)
                    } else {
                        DeviceActivityReport(DeviceActivityReport.Context(ReportContexts.weeklyGrade), filter: ReportFilters.currentWeek(state: diet.sharedState)).frame(height: typeSize.isAccessibilitySize ? 340 : 200)
                        DeviceActivityReport(DeviceActivityReport.Context(ReportContexts.nutritionLabel), filter: ReportFilters.lastSevenDays(state: diet.sharedState)).frame(height: typeSize.isAccessibilitySize ? 1700 : 1100)
                    }
                    Text("Your measured activity stays inside Apple’s report extension. Screen Time may take time to make new activity available.").font(.caption).foregroundStyle(AppTheme.shared.colors.textSecondary).multilineTextAlignment(.center)
                }
                Button { help = true } label: { Label("How to read your digest", systemImage: "info.circle").font(.subheadline).frame(minHeight: 44) }
            }.padding(24).frame(maxWidth: 600).frame(maxWidth: .infinity)
        }.background(AppTheme.shared.colors.background.ignoresSafeArea()).editorialEntrance()
            .sheet(isPresented: $help) { ReportGuide() }
    }
    private var locked: some View {
        VStack(spacing: 24) {
            DietArtwork(asset: "FreshStart", height: 240)
            DietHeading(eyebrow: "Your habits have a story", title: "See what’s growing.\nKnow what to adjust.", detail: "ScreenDiet Plus turns Screen Time activity into a weekly nutrition label.", centered: true)
            VStack(spacing: 20) {
                DietFeatureRow(icon: "chart.pie.fill", title: "Your digital nutrition", detail: "Measured Carbs, Fats and other activity.")
                DietFeatureRow(icon: "chart.bar.xaxis", title: "A week of attention", detail: "See daily activity and the apps you reach for.")
                DietFeatureRow(icon: "moon.stars", title: "The patterns underneath", detail: "Nighttime use, pickups and a weekly grade.")
            }.dietCard()
            PrimaryButton(title: "Unlock my bigger picture", icon: "sparkles") { entitlements.presentPaywall(.weeklyReport) }
            Text("No sample numbers are presented as your activity.").font(.caption2).foregroundStyle(AppTheme.shared.colors.textSecondary)
        }
    }
}

struct ReportGuide: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            DietPage {
                DietHeading(eyebrow: "Awareness over judgment", title: "Read the pattern.\nChoose one small change.")
                DietArtwork(asset: "FreshStart", height: 180)
                VStack(spacing: 22) {
                    DietFeatureRow(icon: "chart.pie.fill", title: "Start with the mix", detail: "Carbs and Fats follow your Pantry selections. Protein & other is the remaining activity, including apps and websites you haven’t classified.")
                    DietFeatureRow(icon: "chart.bar", title: "Notice your rhythm", detail: "Daily bars show measured total activity. Apricot highlights Carbs. Missing bars mean no activity was received for that day.")
                    DietFeatureRow(icon: "moon.stars", title: "Look beyond the total", detail: "Nighttime activity is measured between 10 pm and 6 am. Pickups describe how often the device was reached for.")
                    DietFeatureRow(icon: "seal", title: "Treat your grade as a guide", detail: "It reflects Carbs share, days within portion, night usage and pickups. The current-week grade and rolling seven-day label use different periods.")
                }.dietCard()
            } footer: { PrimaryButton(title: "Back to my digest") { dismiss() } }
            .navigationTitle("Your Digest").navigationBarTitleDisplayMode(.inline)
        }.preferredColorScheme(.dark)
    }
}

extension Notification.Name { static let screenDietTab = Notification.Name("screenDietTab") }
