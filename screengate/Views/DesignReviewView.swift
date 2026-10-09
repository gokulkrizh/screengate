#if DEBUG
import SwiftUI

/// Read-only visual review routes. Never persisted as a user's routine.
struct DesignReviewView: View {
    let route: String
    static var launchRoute: String? {
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: "-design-review"), args.indices.contains(index + 1) else { return nil }
        return args[index + 1]
    }
    var body: some View {
        Group {
            if route.hasPrefix("onboarding-") {
                OnboardingView(initialScreen: Int(route.dropFirst("onboarding-".count)) ?? 0)
            } else {
                switch route {
                case "pantry": PantryView()
                case "settings": DietSettingsView()
                case "reports": NutritionReportView()
                case "report-guide": ReportGuide()
                case "paywall": PaywallView(intention: "reading") { }
                case "paywall-night": PaywallView(placement: .featureNightFast) { }
                case "focus": FocusFastSheet()
                case "cheat": CheatMealSheet()
                case "strict": StrictModeSheet()
                case "reminders": NotificationSettingsView()
                case "adjust": AdjustDietView(profile: DietProfile.create(plan: .lean))
                case "kitchen": KitchenView()
                default:
                    ScrollView {
                        VStack(spacing: 24) {
                            Text("DESIGN PREVIEW · SAMPLE STATE").font(.caption2).foregroundStyle(AppTheme.shared.colors.primary)
                            KitchenHero(state: state, remaining: 32, portion: 45, progress: 0.6, nextTime: "12:00 PM", endsAt: state == .fastNow ? Date().addingTimeInterval(3600) : nil)
                        }.padding(24)
                    }.background(AppTheme.shared.colors.background.ignoresSafeArea())
                }
            }
        }.environment(\.dynamicTypeSize, ProcessInfo.processInfo.arguments.contains("-design-large-type") ? .accessibility3 : .large)
    }
    private var state: DietState {
        switch route { case "kitchen-open": return .windowOpen; case "kitchen-night": return .nightFast; case "kitchen-focus": return .fastNow; case "kitchen-empty": return .portionHit; case "kitchen-closed": return .fasting; default: return .inactive }
    }
}
#endif
