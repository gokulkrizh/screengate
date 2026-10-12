import SwiftUI

/// Main 4-tab interface after onboarding: Kitchen · Pantry · Journal · Settings (spec §4).
/// The theme follows the kitchen state; Pantry and Settings are always Daylight, Journal is Lamp.
struct HomeScreen: View {
    @Environment(DietManager.self) private var dietManager
    @Environment(EntitlementManager.self) private var entitlements
    @State private var selectedTab: KitchenTab

    init(initialTab: KitchenTab = .kitchen) { _selectedTab = State(initialValue: initialTab) }

    private var theme: KitchenTheme {
        switch selectedTab {
        case .kitchen: KitchenTheme(state: dietManager.currentDietState)
        case .pantry, .settings: .daylight
        case .journal: .lamp
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .kitchen: KitchenView()
                case .pantry: PantryView()
                case .journal: NutritionReportView()
                case .settings: DietSettingsView()
                }
            }
            .environment(dietManager)
            .safeAreaPadding(.bottom, KitchenMetrics.tabBarHeight - 34)
            KitchenTabBar(selection: $selectedTab)
        }
        .environment(\.kitchenTheme, theme)
        .background { KitchenBackground(theme: theme) }
        .preferredColorScheme(theme.colorScheme)
        .tint(theme.lamp)
        .animation(KitchenMetrics.crossFade, value: theme)
        .ignoresSafeArea(edges: .bottom)
        .onReceive(NotificationCenter.default.publisher(for: .screenDietTab)) { note in
            // Legacy indices: 0 kitchen, 1 report, 2 pantry, 3 settings.
            guard let i = note.object as? Int else { return }
            let map: [Int: KitchenTab] = [0: .kitchen, 1: .journal, 2: .pantry, 3: .settings]
            if let tab = map[i] { withAnimation { selectedTab = tab } }
        }
        .onReceive(NotificationCenter.default.publisher(for: .dietNotificationRoute)) { note in
            guard let raw = note.userInfo?["route"] as? String,
                  let route = NotificationRoute(rawValue: raw) else { return }
            if route == .report {
                if entitlements.isPremium { selectedTab = .journal } else { entitlements.presentPaywall(.weeklyReport) }
            }
        }
    }
}

#Preview {
    HomeScreen()
        .environment(DietManager())
        .environment(EntitlementManager())
}
