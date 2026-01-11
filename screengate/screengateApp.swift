//
//  DeviceActivityMonitorDemoApp.swift
//  DeviceActivityMonitorDemo
//
//  Created by Gokul on 2025/11/05.
//

import SwiftUI
import UserNotifications
import SuperwallKit

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    private let manager = DeviceActivityManager()

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        let userInfo = response.notification.request.content.userInfo

        if let _ = userInfo["removeRestrictionsAndShowView"] as? Bool {
            // Remove restrictions first
            manager.removeRestrictions()

            // Post notification to app to show the view
            NotificationCenter.default.post(name: .showRestrictionLiftedView, object: nil)
        } else if let _ = userInfo["showRestrictionLiftedView"] as? Bool {
            // Legacy format - just show the view
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
struct DeviceActivityMonitorDemoApp: App {
    @State private var showRestrictionLifted = false
    @State private var hasCompletedOnboarding = OnboardingData.hasCompletedOnboarding()
    private let notificationDelegate = NotificationDelegate()

    init() {
        Superwall.configure(apiKey: "pk_u5bxkniFBjniC5yFeiCtV")
    }
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                HomeScreen()
            } else {
                NavigationStack {
                    SplashView(onCompletion: {
                        hasCompletedOnboarding = true
                    })
                }
            }
        }
    }

    private func handleDeepLink(_ url: URL) {
        if url.scheme == "screengate" && url.host == "restriction-lifted" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showRestrictionLifted = true
            }
        }
    }

    private func setupNotificationDelegate() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }
}

