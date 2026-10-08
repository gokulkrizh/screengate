//
//  screengateApp.swift
//  screengate
//

import SwiftUI
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    private let manager = DeviceActivityManager()

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if let _ = userInfo["removeRestrictionsAndShowView"] as? Bool {
            manager.clearDietStores()
            NotificationCenter.default.post(name: .showRestrictionLiftedView, object: nil)
        } else if let _ = userInfo["showRestrictionLiftedView"] as? Bool {
            NotificationCenter.default.post(name: .showRestrictionLiftedView, object: nil)
        }

        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}

extension Notification.Name {
    static let showRestrictionLiftedView = Notification.Name("showRestrictionLiftedView")
}

@main
struct ScreenDietApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var showRestrictionLifted = false
    @State private var hasCompletedOnboarding = OnboardingData.hasCompletedOnboarding()
    @State private var dietManager = DietManager()
    @State private var entitlementManager = EntitlementManager()
    private let notificationDelegate = NotificationDelegate()

    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
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
            .environment(entitlementManager)
            .sheet(item: $entitlementManager.activePlacement) { placement in
                PaywallView(placement: placement) {
                    entitlementManager.dismissPaywall()
                }
                .environment(entitlementManager)
                .environment(dietManager)
            }
            .alert("You're back on the free plan", isPresented: Binding(
                get: { entitlementManager.showDowngradeNotice },
                set: { if !$0 { entitlementManager.acknowledgeDowngrade() } }
            )) {
                Button("OK") { entitlementManager.acknowledgeDowngrade() }
            } message: {
                Text("Your diet keeps running on Lean rules — Night Fast is off and you have 1 cheat meal a week. Resubscribe anytime.")
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
}
