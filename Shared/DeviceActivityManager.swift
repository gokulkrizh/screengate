//
//  DeviceActivityManager.swift
//  Shared
//
//  Thin wrapper around ManagedSettings + DeviceActivity. Stateless: the desired
//  rules come from `SharedState` via the pure `DietRules`, so the app and the
//  monitor extension always reconcile to the same result.
//

import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity

final class DeviceActivityManager {

    private static let nameIdentifier = "com.gia.screendiet"

    // One store per rule — blocks stack, nothing overwrites anything else.
    private let carbsStore = ManagedSettingsStore(named: .carbs)
    private let nightStore = ManagedSettingsStore(named: .night)
    private let fastStore = ManagedSettingsStore(named: .fast)
    private let strictStore = ManagedSettingsStore(named: .strict)

    private let deviceActivityCenter = DeviceActivityCenter()

    // MARK: - Store reconciliation

    /// Block the carbs selection in the `.carbs` store.
    func applyCarbsBlock(selection: FamilyActivitySelection) {
        apply(store: carbsStore, selection: selection)
    }

    /// Block carbs + fats in the `.night` store (Night Fast).
    func applyNightBlock(selection: FamilyActivitySelection) {
        apply(store: nightStore, selection: selection)
    }

    /// Block carbs + fats in the `.fast` store (Fast Now).
    func applyFastBlock(selection: FamilyActivitySelection) {
        apply(store: fastStore, selection: selection)
    }

    func clearCarbsBlock() { carbsStore.clearAllSettings() }
    func clearNightBlock() { nightStore.clearAllSettings() }
    func clearFastBlock() { fastStore.clearAllSettings() }

    func clearDietStores() {
        clearCarbsBlock()
        clearNightBlock()
        clearFastBlock()
    }

    /// Clear the single pre-v1 store so old shields disappear after migration.
    func clearLegacyStore() {
        ManagedSettingsStore(named: .legacy).clearAllSettings()
    }

    // MARK: - Strict mode (premium)

    func applyStrictMode() {
        strictStore.application.denyAppRemoval = true
        strictStore.dateAndTime.requireAutomaticDateAndTime = true
    }

    func clearStrictMode() {
        strictStore.clearAllSettings()
    }

    /// Compute the desired blocks from shared state and apply them.
    func reconcile(state: SharedState, at now: Date = Date()) {
        let plan = DietRules.storePlan(
            at: now,
            profile: state.profile,
            counters: state.counters,
            cheat: state.cheat,
            fast: state.fast
        )

        let carbs = state.selection(for: .carbs)
        let fats = state.selection(for: .fats)
        let carbsAndFats = Self.union(carbs, fats)

        set(store: carbsStore, blocked: plan.carbsBlocked, selection: carbs)
        set(store: nightStore, blocked: plan.nightBlocked, selection: carbsAndFats)
        set(store: fastStore, blocked: plan.fastBlocked, selection: carbsAndFats)
    }

    private func set(store: ManagedSettingsStore, blocked: Bool, selection: FamilyActivitySelection) {
        if blocked {
            apply(store: store, selection: selection)
        } else {
            store.clearAllSettings()
        }
    }

    private func apply(store: ManagedSettingsStore, selection: FamilyActivitySelection) {
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
    }

    /// Union of two selections (applications, categories and web domains).
    static func union(_ a: FamilyActivitySelection, _ b: FamilyActivitySelection) -> FamilyActivitySelection {
        var merged = FamilyActivitySelection()
        merged.applicationTokens = a.applicationTokens.union(b.applicationTokens)
        merged.categoryTokens = a.categoryTokens.union(b.categoryTokens)
        merged.webDomainTokens = a.webDomainTokens.union(b.webDomainTokens)
        return merged
    }

    // MARK: - Scheduling

    /// Start a DeviceActivity schedule. `name` is a `ScheduleNames` value; the
    /// manager adds the `com.gia.screendiet.` prefix.
    func start(
        name: String,
        schedule: DeviceActivitySchedule,
        events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]
    ) throws {
        try deviceActivityCenter.startMonitoring(makeActivityName(name), during: schedule, events: events)
    }

    func stop(name: String) {
        deviceActivityCenter.stopMonitoring([makeActivityName(name)])
    }

    func stopAll() {
        let all = Array(deviceActivityCenter.activities)
        if !all.isEmpty {
            deviceActivityCenter.stopMonitoring(all)
        }
    }

    /// Stop the pre-v1 schedules (`diet.carbs.window`, `diet.nightlock`, ...).
    func stopLegacySchedules() {
        deviceActivityCenter.stopMonitoring(ScheduleNames.legacyNames.map(makeActivityName))
    }

    var activeScheduleNames: [String] {
        deviceActivityCenter.activities.map(parseActivityName)
    }

    /// Build incremental usage-threshold events (`usage-N`).
    static func thresholdEvents(selection: FamilyActivitySelection, thresholds: [Int]) -> [DeviceActivityEvent.Name: DeviceActivityEvent] {
        var events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]
        for minutes in thresholds {
            let name = DeviceActivityEvent.Name("usage-\(minutes)")
            events[name] = DeviceActivityEvent(
                applications: selection.applicationTokens,
                categories: selection.categoryTokens,
                webDomains: selection.webDomainTokens,
                threshold: DateComponents(minute: minutes),
                includesPastActivity: false
            )
        }
        return events
    }

    // MARK: - Names

    private func makeActivityName(_ name: String) -> DeviceActivityName {
        DeviceActivityName("\(Self.nameIdentifier).\(name)")
    }

    private func parseActivityName(_ name: DeviceActivityName) -> String {
        name.rawValue.replacing("\(Self.nameIdentifier).", with: "")
    }
}

// MARK: - Schedule builders

extension DeviceActivitySchedule {

    /// Repeating daily schedule (hour/minute only).
    static func repeatingDaily(start: DateComponents, end: DateComponents, warningMinutes: Int = 0) -> DeviceActivitySchedule {
        var start = start
        var end = end
        start.hour = start.hour ?? 0
        start.minute = start.minute ?? 0
        start.second = nil
        start.nanosecond = nil
        end.hour = end.hour ?? 0
        end.minute = end.minute ?? 0
        end.second = nil
        end.nanosecond = nil
        // Keep time zone + calendar so overnight windows resolve correctly.
        start.calendar = Calendar.current
        start.timeZone = TimeZone.current
        end.calendar = Calendar.current
        end.timeZone = TimeZone.current
        return DeviceActivitySchedule(
            intervalStart: start,
            intervalEnd: end,
            repeats: true,
            warningTime: warningMinutes > 0 ? DateComponents(minute: warningMinutes) : nil
        )
    }

    /// One-off schedule for a concrete start/end date (cheat meal, Fast Now).
    static func oneOff(start: Date, end: Date, warningMinutes: Int = 0) -> DeviceActivitySchedule {
        let startComponents = Calendar.current.dateComponents(
            [.calendar, .timeZone, .year, .month, .day, .hour, .minute],
            from: start
        )
        let endComponents = Calendar.current.dateComponents(
            [.calendar, .timeZone, .year, .month, .day, .hour, .minute],
            from: end
        )
        return DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: false,
            warningTime: warningMinutes > 0 ? DateComponents(minute: warningMinutes) : nil
        )
    }
}

extension FamilyActivitySelection {
    /// True when the selection contains at least one app, category or web domain.
    var hasAnyTokens: Bool {
        !applicationTokens.isEmpty || !categoryTokens.isEmpty || !webDomainTokens.isEmpty
    }
}

// MARK: - Permission

extension DeviceActivityManager {
    func requestFamilyControlAuthorization() async {
        let center = AuthorizationCenter.shared
        if center.authorizationStatus == .notDetermined {
            do {
                try await center.requestAuthorization(for: .individual)
            } catch {
                print("[DeviceActivityManager] Authorization error: \(error)")
            }
        }
    }
}
