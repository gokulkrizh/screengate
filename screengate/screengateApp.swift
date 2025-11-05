//
//  DeviceActivityMonitorDemoApp.swift
//  DeviceActivityMonitorDemo
//
//  Created by Gokul on 2025/11/05.
//

import SwiftUI
import UserNotifications

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
    @State private var showRestrictionLiftedView = false
    private let notificationDelegate = NotificationDelegate()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleDeepLink(url)
                }
                .onReceive(NotificationCenter.default.publisher(for: .showRestrictionLiftedView)) { _ in
                    showRestrictionLiftedView = true
                }
                .sheet(isPresented: $showRestrictionLiftedView) {
                    RestrictionLiftedView()
                }
                .onAppear {
                    setupNotificationDelegate()
                }
        }
    }

    private func handleDeepLink(_ url: URL) {
        if url.scheme == "screengate" && url.host == "restriction-lifted" {
            showRestrictionLiftedView = true
        }
    }

    private func setupNotificationDelegate() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }
}

