//
//  screengateApp.swift
//  screengate
//

import SwiftUI
import UserNotifications

@main
struct ScreenDietApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var hasCompletedOnboarding = OnboardingData.hasCompletedOnboarding()
    @State private var dietManager = DietManager()
    @State private var entitlementManager = EntitlementManager()

    init() {
        UNUserNotificationCenter.current().delegate = NotificationRouter.shared
        NotificationRouter.shared.registerCategories()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    HomeScreen()
                        .environment(dietManager)
                } else {
                    NavigationStack {
                        SplashView(onCompletion: {
                            hasCompletedOnboarding = true
                        })
                    }
                    .environment(dietManager)
                }
            }
            .paywallPresenter()
            .environment(entitlementManager)
            .alert("You're back on the free plan", isPresented: Binding(
                get: { entitlementManager.showDowngradeNotice },
                set: { if !$0 { entitlementManager.acknowledgeDowngrade() } }
            )) {
                Button("OK") { entitlementManager.acknowledgeDowngrade() }
            } message: {
                Text("Your diet keeps running on Lean rules — Night Fast is off and you have 1 cheat meal a week. Resubscribe anytime.")
            }
            .onReceive(NotificationCenter.default.publisher(for: .dietNotificationRoute)) { note in
                guard let raw = note.userInfo?["route"] as? String,
                      let route = NotificationRoute(rawValue: raw) else { return }
                if route == .startFast {
                    dietManager.startFast(minutes: 60)
                }
                // `.report` is handled by HomeScreen (tab switch / paywall).
            }
            .onOpenURL { url in
                handleDeepLink(url)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // Re-sync with the shared store and the system schedules.
                dietManager.reloadState()
                Task { await entitlementManager.refreshEntitlements() }
            }
        }
    }

    /// Handles widget deep links: `screengate://paywall?placement=feature_widgets`.
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "screengate", url.host == "paywall" else { return }
        let placement = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first(where: { $0.name == "placement" })?
            .value
            .flatMap(PaywallPlacement.init(rawValue:)) ?? .featureWidgets
        entitlementManager.presentPaywall(placement)
    }
}
