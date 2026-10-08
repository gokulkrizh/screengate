import SwiftUI

/// HomeScreen - Main 4-tab interface after onboarding
/// Kitchen (home) | Report | Pantry | Settings
struct HomeScreen: View {
    @Environment(DietManager.self) private var dietManager
    @Environment(EntitlementManager.self) private var entitlements
    @State private var selectedTab = 0
    private let appTheme = AppTheme.shared

    var body: some View {
        ZStack {
            appTheme.colors.background.ignoresSafeArea()

            TabView(selection: $selectedTab) {
                // Kitchen Tab
                KitchenView()
                    .environment(dietManager)
                    .tabItem {
                        Label("Kitchen", systemImage: "house.fill")
                    }
                    .tag(0)

                // Report Tab
                NutritionReportView()
                    .environment(dietManager)
                    .tabItem {
                        Label("Report", systemImage: "chart.bar.fill")
                    }
                    .tag(1)

                // Pantry Tab
                PantryView()
                    .environment(dietManager)
                    .tabItem {
                        Label("Pantry", systemImage: "cabinet.fill")
                    }
                    .tag(2)

                // Settings Tab
                DietSettingsView()
                    .environment(dietManager)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(3)
            }
            .tint(appTheme.colors.primary)
        }
        .onReceive(NotificationCenter.default.publisher(for: .dietNotificationRoute)) { note in
            guard let raw = note.userInfo?["route"] as? String,
                  let route = NotificationRoute(rawValue: raw) else { return }
            if route == .report {
                if entitlements.isPremium {
                    selectedTab = 1
                } else {
                    entitlements.presentPaywall(.weeklyReport)
                }
            }
        }
    }
}

#Preview {
    HomeScreen()
        .environment(DietManager())
        .preferredColorScheme(.dark)
}
