//
//  DeviceActivityManager.swift
//  DeviceActivityMonitorDemo
//
//  Created by Gokul on 2025/11/05.
//

import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity

class DeviceActivityManager {

    var monitoringActivities: [String] = []
    
    private static let nameIdentifier = "com.gia.screendiet"
    // A data store that stores settings to the current user or device.
    private let managedSettingsStore: ManagedSettingsStore = ManagedSettingsStore(named: .init(nameIdentifier))
    
    // A class that we use this to schedule monitoring within our main app,
    // and enables an application’s extension to start monitoring scheduled device activity.
    // * All instances are equivalent and manage the activities monitored by the application’s extension.
    private let deviceActivityCenter: DeviceActivityCenter = DeviceActivityCenter()
    

    private let userDefaults: UserDefaults = UserDefaults(suiteName: "group.com.gia.screendiet") ?? .standard
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    
    init() {
        monitoringActivities = deviceActivityCenter.activities.map({self.parseActivityName($0)})
    }
    
    func applyImmediateRestrictions(activitySelection: FamilyActivitySelection) {
        self.applyImmediateRestrictions(
            applicationTokens: activitySelection.applicationTokens,
            categoryTokens: activitySelection.categoryTokens,
            webDomainTokens: activitySelection.webDomainTokens
        )
    }
    
    func applyImmediateRestrictions(applicationTokens: Set<ApplicationToken>, categoryTokens: Set<ActivityCategoryToken>, webDomainTokens: Set<WebDomainToken>) {
        if !applicationTokens.isEmpty {
            managedSettingsStore.shield.applications = applicationTokens
        } else {
            managedSettingsStore.shield.applications = nil
        }

        if !categoryTokens.isEmpty {
            managedSettingsStore.shield.applicationCategories = .specific(categoryTokens)
        } else {
            managedSettingsStore.shield.applicationCategories = nil
        }

        if !webDomainTokens.isEmpty {
            managedSettingsStore.shield.webDomains = webDomainTokens
        } else {
            managedSettingsStore.shield.webDomains = nil
        }
    }
    
    
    func removeRestrictions() {
        managedSettingsStore.shield.applications = nil
        managedSettingsStore.shield.applicationCategories = nil
        managedSettingsStore.shield.webDomains = nil
    }
    
    
    // If the specified applications, categories, and webDomains have been in use longer than the event’s `threshold` within the activity’s scheduled interval (start - end), we will shield those applications.
    func startMonitor(activitySelection: FamilyActivitySelection, shieldThreshold: TimeInterval, start: Date, end: Date, repeatDaily: Bool, activityName: String, eventName: String = "threshold", warningTimeMinutes: Int = 10) throws {
        let (start, end) = repeatDaily ? createRepeatDailySchedule(start: start, end: end) : createOneTimeSchedule(start: start, end: end)

        let deviceActivityName = makeActivityName(activityName)
        let deviceEventName = DeviceActivityEvent.Name(eventName)

        try self.saveSelection(activitySelection, activityName: deviceActivityName, eventName: deviceEventName)

        let schedule = DeviceActivitySchedule(
            intervalStart: start,
            intervalEnd: end,
            repeats: repeatDaily,
            warningTime: DateComponents(minute: warningTimeMinutes)
        )

        let event = DeviceActivityEvent(
            applications: activitySelection.applicationTokens,
            categories: activitySelection.categoryTokens,
            webDomains: activitySelection.webDomainTokens,
            threshold: createThreshold(shieldThreshold),
            includesPastActivity: true,
        )

        try self.deviceActivityCenter.startMonitoring(
            deviceActivityName,
            during: schedule,
            events: [
                deviceEventName : event,
            ]
        )

        self.monitoringActivities.append(activityName)
    }

    /// Start a monitor with multiple threshold events for incremental usage tracking.
    /// Each threshold fires `eventDidReachThreshold` in the extension, enabling granular tracking.
    func startMonitorWithIncrementalThresholds(
        activitySelection: FamilyActivitySelection,
        thresholdMinutes: [Int],
        start: Date,
        end: Date,
        repeatDaily: Bool,
        activityName: String,
        warningTimeMinutes: Int = 5
    ) throws {
        let (start, end) = repeatDaily ? createRepeatDailySchedule(start: start, end: end) : createOneTimeSchedule(start: start, end: end)

        let deviceActivityName = makeActivityName(activityName)

        let schedule = DeviceActivitySchedule(
            intervalStart: start,
            intervalEnd: end,
            repeats: repeatDaily,
            warningTime: DateComponents(minute: warningTimeMinutes)
        )

        var events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]

        for minutes in thresholdMinutes {
            let eventName = DeviceActivityEvent.Name("usage-\(minutes)")
            try self.saveSelection(activitySelection, activityName: deviceActivityName, eventName: eventName)

            let event = DeviceActivityEvent(
                applications: activitySelection.applicationTokens,
                categories: activitySelection.categoryTokens,
                webDomains: activitySelection.webDomainTokens,
                threshold: DateComponents(minute: minutes),
                includesPastActivity: true
            )
            events[eventName] = event
        }

        try self.deviceActivityCenter.startMonitoring(
            deviceActivityName,
            during: schedule,
            events: events
        )

        self.monitoringActivities.append(activityName)
    }
    
    func stopMonitor(activityName: String) {
        self.stopMonitor(activityName: makeActivityName(activityName))
    }

    func stopMonitor(activityName: DeviceActivityName) {
        let schedule = self.deviceActivityCenter.schedule(for: activityName)
        guard schedule != nil else { return }

        let events = self.getEvents(activityName: activityName, details: false)
        events.keys.forEach({
            let key = makeUserDefaultsKey(activityName: activityName, eventName: $0)
            self.removeSavedSelection(key: key)
        })

        self.deviceActivityCenter.stopMonitoring([activityName])
        self.monitoringActivities.removeAll(where: {$0 == parseActivityName(activityName)})
    }
    
    func stopAllMonitors() {
        let allActivities = Array(deviceActivityCenter.activities)
        for activityName in allActivities {
            stopMonitor(activityName: activityName)
        }
        self.deviceActivityCenter.stopMonitoring([])
        self.monitoringActivities.removeAll()
    }
    
    
    func getEvents(activityName: String, details: Bool) -> [DeviceActivityEvent.Name : DeviceActivityEvent] {
        return self.getEvents(activityName: makeActivityName(activityName), details: details)
    }
    
    func getEvents(activityName: DeviceActivityName, details: Bool) -> [DeviceActivityEvent.Name : DeviceActivityEvent] {
        var events = self.deviceActivityCenter.events(for: activityName)
        if !details {
            return events
        }

        for (key, value) in events {
            let userDefaultsKey = self.makeUserDefaultsKey(activityName: activityName, eventName: key)
            let tokens = self.getSavedSelection(key: userDefaultsKey)
            events[key] = DeviceActivityEvent(
                applications: tokens.applicationTokens,
                categories: tokens.categoryTokens,
                webDomains: tokens.webDomainTokens,
                threshold: value.threshold,
                includesPastActivity: value.includesPastActivity
            )
        }

        return events
    }
    
    
    func getSchedule(activityName: String) -> DeviceActivitySchedule? {
        return self.getSchedule(activityName: makeActivityName(activityName))
    }
    
    func getSchedule(activityName: DeviceActivityName) -> DeviceActivitySchedule? {
        return self.deviceActivityCenter.schedule(for: activityName)
    }

}




// MARK: Permission
extension DeviceActivityManager {
    func requestFamilyControlAuthorization() async {
        let center = AuthorizationCenter.shared
        if center.authorizationStatus == .notDetermined {
            do {
                // to request authorization parental controls for FamilyControlsMember.child, use .child instead.
                try await center.requestAuthorization(for: .individual)
            } catch(let error) {
                print(error)
            }
        }
    }
}


// MARK: UserDefaults
extension DeviceActivityManager {
    private func getSavedSelection(key: String) -> FamilyActivitySelection {
        guard let data = userDefaults.data(forKey: key), let selection = try? self.jsonDecoder.decode(FamilyActivitySelection.self, from: data) else {
            return FamilyActivitySelection()
        }
        return selection
    }

    private func saveSelection(_ selection: FamilyActivitySelection, activityName: DeviceActivityName, eventName: DeviceActivityEvent.Name) throws {
        let key = self.makeUserDefaultsKey(activityName: activityName, eventName: eventName)
        let data = try self.jsonEncoder.encode(selection)
        userDefaults.set(data, forKey: key)
    }
    
    
    private func removeSavedSelection(key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    private func makeUserDefaultsKey(activityName: DeviceActivityName, eventName: DeviceActivityEvent.Name) -> String {
        return "\(activityName.rawValue).\(eventName.rawValue)"
    }
    
    /// Clear all UserDefaults data except onboarding-related keys (for development/debugging)
    func clearAllData() {
        let suiteDomain = userDefaults.dictionaryRepresentation()

        let onboardingKeys = suiteDomain.keys.filter { $0.lowercased().contains("onboarding") }

        var onboardingData: [String: Any] = [:]
        for key in onboardingKeys {
            if let value = suiteDomain[key] {
                onboardingData[key] = value
            }
        }

        for key in suiteDomain.keys {
            userDefaults.removeObject(forKey: key)
        }

        for (key, value) in onboardingData {
            userDefaults.set(value, forKey: key)
        }
    }
}


// MARK: Helpers
extension DeviceActivityManager {
    
    private func makeActivityName(_ activityName: String) -> DeviceActivityName {
        return DeviceActivityName("\(DeviceActivityManager.nameIdentifier).\(activityName)")
    }
    
    private func parseActivityName(_ activityName: DeviceActivityName) -> String {
        return activityName.rawValue.replacing("\(DeviceActivityManager.nameIdentifier).", with: "")
    }
    
    
    private func createThreshold(_ threshold: TimeInterval) -> DateComponents {
        let (h, m, _) = threshold.hms
        var component = DateComponents()
        component.hour = h
        component.minute = m
        return component
    }
    
    private func createOneTimeSchedule(start: Date, end: Date) -> (DateComponents, DateComponents) {
        let start = Calendar.current.dateComponents([.calendar, .timeZone, .year, .month, .day, .hour, .minute], from: start)
        let end = Calendar.current.dateComponents([.calendar, .timeZone, .year, .month, .day, .hour, .minute], from: end)
        return (start, end)
    }
    
    private func createRepeatDailySchedule(start: Date, end: Date) -> (DateComponents, DateComponents) {
        let start = Calendar.current.dateComponents([.calendar, .timeZone, .hour, .minute], from: start)
        let end = Calendar.current.dateComponents([.calendar, .timeZone, .hour, .minute], from: end)
        return (start, end)
    }
}
