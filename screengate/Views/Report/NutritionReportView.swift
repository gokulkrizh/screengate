import SwiftUI
import DeviceActivity

/// Journal tab (canvas V2A-Journal). Lamp look is provided by HomeScreen.
/// The numbers themselves are rendered by the NutritionReportExtension scenes.
struct NutritionReportView: View {
    @Environment(DietManager.self) private var diet
    @Environment(EntitlementManager.self) private var entitlements
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var today = false
    @State private var help = false
    @Namespace private var seg

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                KitchenTitleBlock(eyebrow: "Balance, over time", title: "Journal").padding(.horizontal, 4).riseIn(0)
                if !entitlements.isPremium { locked }
                else if !ReportFilters.junkSelection(state: diet.sharedState).hasAnyTokens { empty }
                else {
                    segmented.padding(.top, 2).riseIn(1)
                    if today {
                        DeviceActivityReport(DeviceActivityReport.Context(ReportContexts.today), filter: ReportFilters.today(state: diet.sharedState))
                            .frame(height: typeSize.isAccessibilitySize ? 760 : 420)
                    } else {
                        DeviceActivityReport(DeviceActivityReport.Context(ReportContexts.weeklyGrade), filter: ReportFilters.currentWeek(state: diet.sharedState))
                            .frame(height: typeSize.isAccessibilitySize ? 380 : 140)
                        DeviceActivityReport(DeviceActivityReport.Context(ReportContexts.nutritionLabel), filter: ReportFilters.lastSevenDays(state: diet.sharedState))
                            .frame(height: typeSize.isAccessibilitySize ? 1900 : 1180)
                    }
                    Text("Your measured activity stays inside Apple’s report extension. Screen Time may take time to make new activity available.")
                        .font(KitchenFont.body(12)).foregroundStyle(theme.faint).multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity).padding(.top, 4)
                }
                Button { help = true } label: {
                    Label("How to read your journal", systemImage: "info.circle").font(KitchenFont.label(13)).foregroundStyle(theme.muted)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }.buttonStyle(TactileButtonStyle())
            }
            .padding(.horizontal, KitchenMetrics.cardMargin).padding(.top, 8).padding(.bottom, 24)
            .frame(maxWidth: 600).frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .foregroundStyle(theme.text)
        .sheet(isPresented: $help) { ReportGuide() }
    }

    // MARK: Segmented control

    private var segmented: some View {
        HStack(spacing: 4) {
            ForEach([(false, "This week"), (true, "Today")].reversed(), id: \.0) { value, label in
                let on = today == value
                Button {
                    withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.35, dampingFraction: 0.8)) { today = value }
                } label: {
                    Text(label).font(KitchenFont.label(13).weight(.bold))
                        .foregroundStyle(on ? theme.text : theme.faint)
                        .frame(maxWidth: .infinity, minHeight: 38)
                        .background {
                            if on {
                                RoundedRectangle(cornerRadius: 18).fill(theme.surface2)
                                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(theme.line2, lineWidth: 1))
                                    .matchedGeometryEffect(id: "seg", in: seg)
                            }
                        }
                }.buttonStyle(TactileButtonStyle()).accessibilityAddTraits(on ? .isSelected : [])
            }
        }
        .padding(4).background(theme.surface, in: RoundedRectangle(cornerRadius: 22))
        .sensoryFeedback(.selection, trigger: today)
    }

    // MARK: States

    private func artCard(_ asset: String, height: CGFloat) -> some View {
        Image(asset).resizable().scaledToFill().frame(height: height).frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 28)).accessibilityHidden(true)
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 14) {
            artCard("BalancedPantry", height: 190)
            Text("Your story needs a few selections.").font(KitchenFont.headline(24)).tracking(-0.8)
            Text("Assign your Carbs and Fats in the Pantry. Your measured activity will appear here as Screen Time records it.")
                .kitchenBody(14).foregroundStyle(theme.muted)
            KitchenPrimaryButton(title: "Open my Pantry") { NotificationCenter.default.post(name: .screenDietTab, object: 2) }
        }.padding(.top, 8).riseIn(1)
    }

    private var locked: some View {
        VStack(alignment: .leading, spacing: 14) {
            artCard("FreshStart", height: 190)
            Text("See what’s growing. Know what to adjust.").font(KitchenFont.headline(24)).tracking(-0.8)
            Text("ScreenDiet Plus turns Screen Time activity into a weekly nutrition label.").kitchenBody(14).foregroundStyle(theme.muted)
            SettingsGroupCard {
                SettingsRow(symbol: "chart.pie.fill", group: .carbs, title: "Your digital nutrition", subtitle: "Measured Carbs, Fats and other activity.", showsDivider: false)
                SettingsRow(symbol: "chart.bar.xaxis", group: .fats, title: "A week of attention", subtitle: "See daily activity and the apps you reach for.")
                SettingsRow(symbol: "moon.stars", group: .protein, title: "The patterns underneath", subtitle: "Nighttime use, pickups and a weekly grade.")
            }
            KitchenPrimaryButton(title: "Unlock my bigger picture", systemImage: "sparkles") { entitlements.presentPaywall(.weeklyReport) }
            Text("No sample numbers are presented as your activity.").font(KitchenFont.body(11)).foregroundStyle(theme.faint).frame(maxWidth: .infinity)
        }.padding(.top, 8).riseIn(1)
    }
}

struct ReportGuide: View {
    @Environment(\.dismiss) private var dismiss
    private let theme = KitchenTheme.lamp
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                KitchenSheetHeader(eyebrow: "Awareness over judgment", title: "Your Journal") { dismiss() }
                Text("Read the pattern. Choose one small change.").kitchenBody(14).foregroundStyle(theme.muted)
                SettingsGroupCard {
                    SettingsRow(symbol: "chart.pie.fill", group: .carbs, title: "Start with the mix", subtitle: "Carbs and Fats follow your Pantry selections. Protein & other is the remaining activity, including apps and websites you haven’t classified.", showsDivider: false)
                    SettingsRow(symbol: "chart.bar", group: .fats, title: "Notice your rhythm", subtitle: "Daily bars show measured total activity, stacked by plate. Missing bars mean no activity was received for that day.")
                    SettingsRow(symbol: "moon.stars", group: .protein, title: "Look beyond the total", subtitle: "Nighttime activity is measured between 10 pm and 6 am. Pickups describe how often the device was reached for.")
                    SettingsRow(symbol: "seal", group: .carbs, title: "Treat your grade as a guide", subtitle: "It reflects Carbs share, days within portion, night usage and pickups. The current-week grade and rolling seven-day label use different periods.")
                }
                KitchenPrimaryButton(title: "Back to my journal") { dismiss() }
            }.padding(20)
        }
        .foregroundStyle(theme.text)
        .environment(\.kitchenTheme, .lamp).kitchenBackground(.lamp).preferredColorScheme(.dark).tint(theme.lamp)
    }
}

extension Notification.Name { static let screenDietTab = Notification.Name("screenDietTab") }
