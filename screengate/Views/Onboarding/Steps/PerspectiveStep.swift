import SwiftUI
import DeviceActivity

/// Onboarding step 11 (canvas V2-11): "3½ hours back" counts up in half-hour steps, bars grow from the bottom.
struct PerspectiveStep: View {
    @ObservedObject var data: OnboardingData
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(DietManager.self) private var dietManager
    @State private var halfHours = 0
    @State private var barsUp = false

    private let heights: [CGFloat] = [58, 72, 50, 78, 64, 84, 76]
    private let days = ["M", "T", "W", "T", "F", "S", "S"]
    private let target = 7   // 7 × 0.5 h = 3½ h = 30 min × 7 days

    private var hoursLabel: String {
        let whole = halfHours / 2
        return halfHours % 2 == 1 ? "\(whole)½" : "\(whole)"
    }

    private var hasCarbs: Bool { dietManager.foodGroupSelections[.carbs]?.hasAnyTokens == true }

    var body: some View {
        OnboardingPage {
            VStack(alignment: .leading, spacing: 10) {
                OnboardingEyebrow(text: "A little perspective").rise(1)
                OnboardingTitle(first: "Small portions.", second: "A real difference.", emphasis: false).rise(2)
            }
            card.rise(3).padding(.top, 4)
            Text("An illustration: 30 minutes × 7 days. Not your measured usage, and not a promise.")
                .font(KitchenFont.body(12)).foregroundStyle(theme.faint).padding(.horizontal, 4)
                .fixedSize(horizontal: false, vertical: true).rise(3)
            if hasCarbs {
                VStack(alignment: .leading, spacing: 8) {
                    OnboardingEyebrow(text: "Your last 7 days")
                    DeviceActivityReport(DeviceActivityReport.Context(ReportContexts.hookInsight), filter: ReportFilters.lastSevenDays(state: dietManager.sharedState))
                        .frame(height: 260).clipShape(RoundedRectangle(cornerRadius: 24))
                }.rise(4)
            }
        } footer: {
            KitchenPrimaryButton(title: "Prepare my plan", systemImage: "arrow.right") { data.nextScreen() }
                .editorialEntrance(delay: 1.4)
        }
        .task { await countUp() }
    }

    private var card: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 140)
                .overlay { DietHeroArt(asset: "FocusGarden") }
                .overlay(alignment: .topLeading) {
                    Text("A possible return · every week")
                        .font(KitchenFont.label(11)).foregroundStyle(theme.text).padding(.horizontal, 10).frame(height: 26)
                        .background(Color(hex: "FFFDF8").opacity(0.9), in: Capsule()).padding(.leading, 16).padding(.top, 14)
                }
                .clipped()
                .accessibilityLabel("A clay hourglass beside a phone and a small plant")
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(hoursLabel).font(KitchenFont.bigNumber(72)).tracking(-3).foregroundStyle(theme.text)
                        .contentTransition(.numericText()).minimumScaleFactor(0.6).lineLimit(1)
                    Text("hours back").font(.custom(KitchenFont.manrope, size: 20, relativeTo: .title3).weight(.heavy)).foregroundStyle(theme.muted)
                }
                .accessibilityElement(children: .ignore).accessibilityLabel("3 and a half hours back")
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(0..<7, id: \.self) { i in
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 7).fill(theme.surface2).frame(height: heights[i])
                                .overlay(alignment: .top) {
                                    UnevenRoundedRectangle(topLeadingRadius: 7, bottomLeadingRadius: 3, bottomTrailingRadius: 3, topTrailingRadius: 7)
                                        .fill(theme.color(for: .protein)).frame(height: 20)
                                }
                                .scaleEffect(y: barsUp || reduceMotion ? 1 : 0.001, anchor: .bottom)
                                .animation(reduceMotion ? .easeOut(duration: 0.2) : .timingCurve(0.2, 0.8, 0.2, 1, duration: 0.7).delay(0.6 + Double(i) * 0.07), value: barsUp)
                            Text(days[i]).font(KitchenFont.label(11)).foregroundStyle(theme.faint)
                        }.frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 84, alignment: .bottom)
                .accessibilityHidden(true)
                Divider().overlay(theme.line)
                HStack {
                    Text("30 min back a day, for").foregroundStyle(theme.muted)
                    Spacer()
                    Text(data.intention ?? "Reading").fontWeight(.heavy).foregroundStyle(theme.text)
                }
                .font(KitchenFont.body(14)).padding(.top, -4)
            }
            .padding(.horizontal, 20).padding(.vertical, 18)
        }
        .background(theme.surface, in: RoundedRectangle(cornerRadius: 28))
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(theme.line, lineWidth: 1))
        .shadow(color: Color(hex: "5A401E").opacity(0.16), radius: 20, y: 18)
    }

    private func countUp() async {
        if reduceMotion { halfHours = target; barsUp = true; return }
        withAnimation { barsUp = true }
        try? await Task.sleep(for: .milliseconds(250))
        for step in 1...target {
            withAnimation(.snappy(duration: 0.14)) { halfHours = step }
            try? await Task.sleep(for: .milliseconds(140))
        }
    }
}
