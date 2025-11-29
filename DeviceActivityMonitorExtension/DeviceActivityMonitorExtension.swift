//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitorExtension
//
//  Created by Gokul on 2025/11/05.
//

import DeviceActivity
import ManagedSettings
import Foundation

/// Extension that monitors device activity and logs intervention attempts
/// Communicates with main app via shared container
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    // MARK: - Lifecycle Events
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        print("🎬 Focus interval started: \(activity.rawValue)")
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        print("⏹️ Focus interval ended: \(activity.rawValue)")
        
        // Clear any active session data
        let sharedManager = SharedContainerManager.shared
        sharedManager.clearActiveSession()
        sharedManager.clearActiveBreak()
    }
    
    // MARK: - App Launch Interception
    
    /// Called when an event reaches its threshold
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        // Log the intervention event
        let timestamp = Date()
        
        print("🚨 Threshold reached at \(timestamp)")
        
        // Log intervention via shared container
        let sharedManager = SharedContainerManager.shared
        sharedManager.logIntervention(
            bundleID: "com.unknown.app",
            appName: "App",
            type: "block",
            timestamp: timestamp
        )
    }
    
    // MARK: - Warnings
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        print("⏰ Focus interval will start soon: \(activity.rawValue)")
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        print("⏰ Focus interval will end soon: \(activity.rawValue)")
    }
}

