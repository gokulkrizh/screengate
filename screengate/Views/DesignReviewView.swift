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
                case "pantry", "tab-pantry": HomeScreen(initialTab: .pantry)
                case "settings", "tab-settings": HomeScreen(initialTab: .settings)
                case "reports", "tab-journal": HomeScreen(initialTab: .journal)
                case "tab-kitchen": HomeScreen(initialTab: .kitchen)
                case "kitchen-open", "kitchen-closed", "kitchen-served", "kitchen-night", "kitchen-focus": KitchenStateReview(route: route)
                case "report-guide": ReportGuide()
                case "paywall": PaywallView(intention: "reading") { }
                case "paywall-night": PaywallView(placement: .featureNightFast) { }
                case "focus": FocusFastSheet()
                case "cheat": CheatMealSheet()
                case "strict": StrictModeSheet()
                case "reminders": NotificationSettingsView()
                case "adjust": AdjustDietView(profile: DietProfile.create(plan: .lean))
                case "kitchen": KitchenView()
                case "theme-lamp": ThemeGallery(theme: .lamp)
                case "theme-daylight": ThemeGallery(theme: .daylight)
                case "theme-night": ThemeGallery(theme: .night)
                default: KitchenView()
                }
            }
        }.environment(\.dynamicTypeSize, ProcessInfo.processInfo.arguments.contains("-design-large-type") ? .accessibility3 : .large)
    }
}

/// Tokens + shared components at a glance, for side-by-side review against the canvas.
private struct ThemeGallery: View {
    let theme: KitchenTheme
    @State private var selected = 0
    @State private var tab = KitchenTab.kitchen
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                KitchenOnboardingHeader(chapter: .you, fraction: 0.5, onBack: {}).padding(.horizontal, -24)
                Text("Make room for life.").kitchenHeadline(38)
                Text("A gentle intro line in body type.").kitchenBody().foregroundStyle(theme.muted)
                HStack {
                    ForEach(KitchenFoodGroup.allCases, id: \.rawValue) { g in
                        Text(g.verb).kitchenEyebrow().foregroundStyle(theme.color(for: g))
                            .padding(.horizontal, 12).frame(height: 30).background(theme.soft(g), in: Capsule())
                    }
                }
                StatusPill(text: "Now serving", color: theme.color(for: .fats), showsDot: true)
                KitchenChoiceCard(title: "Balanced", detail: "Moderate portions, steady progress", systemImage: "leaf", isSelected: selected == 0) { selected = 0 }
                KitchenChoiceCard(title: "Maker", detail: "High creation, low consumption", systemImage: "hammer", badge: "Plus", isSelected: selected == 1) { selected = 1 }
                PlateView(group: .carbs, tiles: [PlateTile(id: "a", symbol: "camera", tint: .pink), PlateTile(id: "b", symbol: "play.fill", tint: .red), PlateTile(id: "c", symbol: "message", tint: .blue)]).frame(maxWidth: .infinity)
                KitchenPrimaryButton(title: "Continue", systemImage: "arrow.right") {}
                KitchenSecondaryButton(title: "Not now") {}
            }.padding(24).padding(.bottom, 90)
        }
        .overlay(alignment: .bottom) { KitchenTabBar(selection: $tab) }
        .environment(\.kitchenTheme, theme)
        .kitchenBackground(theme)
        .preferredColorScheme(theme.colorScheme)
        .foregroundStyle(theme.text)
    }
}

/// Seeds `DietManager` with a sample state so each Kitchen look can be reviewed on the simulator.
private struct KitchenStateReview: View {
    let route: String
    @Environment(DietManager.self) private var diet
    var body: some View {
        HomeScreen(initialTab: .kitchen)
            .task {
                // `scenePhase` reloads from disk shortly after launch; re-apply so the sample sticks.
                for _ in 0..<4 { diet.debugApply(sample()); try? await Task.sleep(for: .seconds(1)) }
            }
    }

    private func sample() -> SharedState {
        let now = Date()
        let h = Calendar.current.component(.hour, from: now)
        func hr(_ offset: Int) -> Int { (h + offset + 24) % 24 }
        var state = SharedState.empty(now)
        var profile = DietProfile.create(plan: .lean)
        profile.isActive = true
        profile.activatedAt = now
        profile.portionMinutes = 45
        profile.nightFast = NightFast(isEnabled: false, startHour: 22, startMinute: 0, endHour: 7, endMinute: 0)
        state.streak = 5
        switch route {
        case "kitchen-closed":
            profile.eatingWindow = EatingWindow(startHour: hr(3), startMinute: 0, endHour: hr(9), endMinute: 0)
        case "kitchen-night":
            profile.eatingWindow = EatingWindow(startHour: hr(8), startMinute: 0, endHour: hr(14), endMinute: 0)
            profile.nightFast = NightFast(isEnabled: true, startHour: hr(-1), startMinute: 0, endHour: hr(7), endMinute: 0)
        default:
            profile.eatingWindow = EatingWindow(startHour: hr(-2), startMinute: 0, endHour: hr(4), endMinute: 0)
        }
        state.profile = profile
        state.counters.carbMinutes = route == "kitchen-served" ? 45 : 13
        state.counters.portionHit = route == "kitchen-served"
        if route == "kitchen-focus" {
            state.fast = FastSession(startedAt: now.addingTimeInterval(-22 * 60), endsAt: now.addingTimeInterval(38 * 60), source: .button)
        }
        return state
    }
}
#endif
