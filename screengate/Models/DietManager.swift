import Foundation
import FamilyControls
import UserNotifications
import DeviceActivity
import Observation

/// App-side coordinator. All persistent state lives in `SharedStore`; this class
/// is a thin observable façade over `SharedState` plus schedule registration.
@Observable
final class DietManager {

    // MARK: - State

    /// The single source of truth (read-only for views).
    private(set) var sharedState: SharedState

    @ObservationIgnored
    private let store = SharedStore.shared
    @ObservationIgnored
    private let deviceActivityManager = DeviceActivityManager()
    @ObservationIgnored
    private var lastSeenRevision = -1

    // MARK: - View-facing state

    var dietProfile: DietProfile? { sharedState.profile }

    var todayLog: NutritionLog { NutritionLog(counters: sharedState.counters) }

    var foodGroupSelections: [FoodGroup: FamilyActivitySelection] {
        Dictionary(uniqueKeysWithValues: FoodGroup.allCases.map { ($0, sharedState.selection(for: $0)) })
    }

    var isCheatMealActive: Bool { DietRules.isCheatActive(sharedState.cheat) }
    var cheatMealExpiresAt: Date? { sharedState.cheat?.endsAt }
    var isFastActive: Bool { DietRules.isFastActive(sharedState.fast) }
    var fastEndsAt: Date? { sharedState.fast?.endsAt }
    var isPremium: Bool { sharedState.isPremium }

    /// Current diet state (fast > night > portion hit > window closed).
    var currentDietState: DietState {
        DietRules.state(
            profile: sharedState.profile,
            counters: sharedState.counters,
            fast: sharedState.fast,
            cheat: sharedState.cheat
        )
    }

    /// Minutes of carb allowance remaining today.
    var carbsRemainingMinutes: Int {
        guard let profile = dietProfile else { return 0 }
        return max(0, profile.portionMinutes - sharedState.counters.carbMinutes)
    }

    /// Carb minutes within the portion (regular usage).
    var regularCarbMinutes: Int {
        guard let profile = dietProfile else { return sharedState.counters.carbMinutes }
        return min(sharedState.counters.carbMinutes, profile.portionMinutes)
    }

    /// Carb minutes beyond the portion (cheat usage).
    var cheatCarbMinutes: Int {
        guard let profile = dietProfile else { return 0 }
        return max(0, sharedState.counters.carbMinutes - profile.portionMinutes)
    }

    /// Fasting progress as a percentage (0-100).
    var fastingProgress: Double {
        guard let profile = dietProfile else { return 0 }
        let now = Date()
        guard !profile.eatingWindow.isOpen(at: now) else { return 0 }
        let totalFastMinutes = max(profile.fastingHours * 60, 1)
        let minutesSinceWindowClosed = minutesSinceWindowClosed(profile: profile, now: now)
        return min(100, Double(minutesSinceWindowClosed) / totalFastMinutes * 100)
    }

    /// Number of cheat meals remaining this week.
    var cheatsRemaining: Int {
        cheatsRemaining(in: sharedState)
    }

    /// Consecutive days within portion.
    var fastStreak: Int { sharedState.streak }

    // MARK: - Init

    init() {
        var state = store.load()
        let dayKey = state.counters.dateKey
        DietRules.rolloverIfNeeded(&state)
        if state.counters.dateKey != dayKey { state = store.save(state) }
        self.sharedState = state
        self.lastSeenRevision = state.revision

        if store.didMigrateLegacyState {
            deviceActivityManager.clearLegacyStore()
        }
        deviceActivityManager.stopLegacySchedules()

        setupDarwinObserver()
        refreshSchedules()
        syncStores()
    }

    deinit {
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterRemoveObserver(
            center,
            Unmanaged.passUnretained(self).toOpaque(),
            nil,
            nil
        )
    }

    // MARK: - Setup

    func setFoodGroupSelection(_ selection: FamilyActivitySelection, for group: FoodGroup) {
        var state = store.load()
        state.setSelection(selection, for: group)
        sharedState = persist(state)
        syncStores()
    }

    /// Configure and activate a diet profile.
    func activateDiet(profile: DietProfile) throws {
        let issues = DietRules.validate(profile)
        guard issues.isEmpty else { throw DietError.invalidConfiguration(issues) }

        var state = store.load()
        var active = profile
        active.isActive = true
        active.activatedAt = Date()
        active.weekStartDate = WeekCounters.current().weekStart
        active.weekNumber = max(1, active.weekNumber)

        state.profile = active
        state.counters = .today()
        state.week = .current()
        state.cheat = nil
        state.fast = nil
        state.streak = 0
        sharedState = persist(state)

        refreshSchedules()
        syncStores()
    }

    /// Deactivate the diet and remove all restrictions.
    func deactivateDiet() {
        deviceActivityManager.stopAll()
        deviceActivityManager.stopLegacySchedules()
        deviceActivityManager.clearDietStores()
        deviceActivityManager.clearLegacyStore()

        var state = store.load()
        state.profile?.isActive = false
        state.cheat = nil
        state.fast = nil
        sharedState = persist(state)
    }

    /// Update the profile (window, portion, night fast, cheats).
    func updateDietProfile(_ profile: DietProfile) throws {
        let issues = DietRules.validate(profile)
        guard issues.isEmpty else { throw DietError.invalidConfiguration(issues) }

        var state = store.load()
        state.profile = profile
        sharedState = persist(state)

        refreshSchedules()
        syncStores()
    }

    // MARK: - Cheat meal

    /// Start a cheat meal (lifts the carbs block for the schedule duration).
    func useCheatMeal(durationMinutes: Int? = nil) throws {
        var state = store.load()
        guard state.profile?.isActive == true else { throw DietError.dietNotActive }
        guard cheatsRemaining(in: state) > 0 else { throw DietError.noCheatMealsRemaining }
        guard !DietRules.isFastActive(state.fast) else { throw DietError.cheatNotAvailableDuringFast }

        let now = Date()
        let minutes = durationMinutes ?? DietRules.cheatMealMinutes
        let endsAt = now.addingTimeInterval(TimeInterval(minutes * 60))

        state.cheat = CheatSession(startedAt: now, endsAt: endsAt, source: .app)
        state.counters.cheatsUsedToday += 1
        state.week.cheatsUsed += 1
        sharedState = persist(state)

        registerCheatSchedule(until: endsAt)
        syncStores()
    }

    /// End the cheat meal early.
    func endCheatMeal() {
        deviceActivityManager.stop(name: ScheduleNames.cheat)

        var state = store.load()
        state.cheat = nil
        sharedState = persist(state)
        syncStores()
    }

    // MARK: - Fast Now

    /// Start an immediate fast (blocks carbs + fats).
    func startFast(minutes: Int, source: FastSession.Source = .button) {
        guard let profile = sharedState.profile, profile.isActive else { return }

        let now = Date()
        let minutes = max(DietRules.minimumScheduleMinutes, minutes)
        let endsAt = now.addingTimeInterval(TimeInterval(minutes * 60))

        var state = store.load()
        // A fast takes over any active cheat meal.
        state.cheat = nil
        state.fast = FastSession(startedAt: now, endsAt: endsAt, source: source)
        sharedState = persist(state)

        registerFastSchedule(until: endsAt)
        syncStores()
    }

    func endFast() {
        deviceActivityManager.stop(name: ScheduleNames.fast)

        var state = store.load()
        state.fast = nil
        sharedState = persist(state)
        syncStores()
    }

    // MARK: - Restrictions & schedules

    /// Recompute the named stores from state (the system's source of truth).
    func syncStores() {
        deviceActivityManager.reconcile(state: sharedState)
    }

    /// Register all repeating schedules for the current profile. Safe to call on
    /// every foreground — the system is the source of truth.
    func refreshSchedules() {
        deviceActivityManager.stopAll()
        deviceActivityManager.stopLegacySchedules()

        guard let profile = sharedState.profile, profile.isActive else { return }

        // Midnight rollover: reset counters, streak and week.
        let rolloverStart = DateComponents(hour: 0, minute: 0)
        let rolloverEnd = DateComponents(hour: 0, minute: 15)
        try? deviceActivityManager.start(
            name: ScheduleNames.rollover,
            schedule: .repeatingDaily(start: rolloverStart, end: rolloverEnd)
        )

        // Carbs window + usage thresholds (skipped for detox / empty selection).
        let carbsSelection = sharedState.selection(for: .carbs)
        if profile.plan != .detox, profile.portionMinutes > 0, carbsSelection.hasAnyTokens {
            let thresholds = DietRules.thresholdMinutes(portionMinutes: profile.portionMinutes)
            let events = DeviceActivityManager.thresholdEvents(selection: carbsSelection, thresholds: thresholds)
            let schedule = DeviceActivitySchedule.repeatingDaily(
                start: profile.eatingWindow.startTimeComponents,
                end: profile.eatingWindow.endTimeComponents,
                warningMinutes: 10
            )
            try? deviceActivityManager.start(name: ScheduleNames.windowWeekday, schedule: schedule, events: events)
        }

        // Night Fast.
        if profile.nightFast.isEnabled {
            let schedule = DeviceActivitySchedule.repeatingDaily(
                start: profile.nightFast.startTimeComponents,
                end: profile.nightFast.endTimeComponents,
                warningMinutes: 15
            )
            try? deviceActivityManager.start(name: ScheduleNames.night, schedule: schedule)
        }

        // In-flight sessions (e.g., after relaunch).
        if let cheat = sharedState.cheat, cheat.endsAt > Date() {
            registerCheatSchedule(until: cheat.endsAt)
        }
        if let fast = sharedState.fast, fast.endsAt > Date() {
            registerFastSchedule(until: fast.endsAt)
        }
    }

    private func registerCheatSchedule(until endsAt: Date) {
        let start = Date()
        let end = max(endsAt, start.addingTimeInterval(TimeInterval(DietRules.minimumScheduleMinutes * 60)))
        let schedule = DeviceActivitySchedule.oneOff(start: start, end: end)
        try? deviceActivityManager.start(name: ScheduleNames.cheat, schedule: schedule)
    }

    private func registerFastSchedule(until endsAt: Date) {
        let start = Date()
        let end = max(endsAt, start.addingTimeInterval(TimeInterval(DietRules.minimumScheduleMinutes * 60)))
        let schedule = DeviceActivitySchedule.oneOff(start: start, end: end)
        try? deviceActivityManager.start(name: ScheduleNames.fast, schedule: schedule)
    }

    /// Remove all diet blocks (Settings → Pause All Restrictions).
    func removeAllRestrictions() {
        deviceActivityManager.clearDietStores()
    }

    /// Reload shared state (app foreground) and make the system match.
    func reloadState() {
        var incoming = store.load()
        let dayKey = incoming.counters.dateKey
        DietRules.rolloverIfNeeded(&incoming)
        if incoming.counters.dateKey != dayKey { incoming = store.save(incoming) }
        sharedState = incoming
        lastSeenRevision = incoming.revision
        refreshSchedules()
        syncStores()
    }

    // MARK: - Darwin notification

    private func setupDarwinObserver() {
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterAddObserver(
            center,
            Unmanaged.passUnretained(self).toOpaque(),
            { _, observer, _, _, _ in
                guard let observer else { return }
                let manager = Unmanaged<DietManager>.fromOpaque(observer).takeUnretainedValue()
                DispatchQueue.main.async {
                    manager.handleStateChanged()
                }
            },
            SharedStore.darwinStateChanged as CFString,
            nil,
            .deliverImmediately
        )
    }

    /// Reload when another process wrote newer state (ignore our own writes).
    private func handleStateChanged() {
        let incoming = store.load()
        guard incoming.writerID != store.writerID,
              incoming.revision > lastSeenRevision else { return }

        var state = incoming
        let dayKey = state.counters.dateKey
        DietRules.rolloverIfNeeded(&state)
        if state.counters.dateKey != dayKey { state = store.save(state) }
        sharedState = state
        lastSeenRevision = state.revision
        syncStores()
    }

    // MARK: - Persistence helper

    @discardableResult
    private func persist(_ state: SharedState) -> SharedState {
        let saved = store.save(state)
        lastSeenRevision = saved.revision
        return saved
    }

    // MARK: - Helpers

    private func cheatsRemaining(in state: SharedState) -> Int {
        guard let profile = state.profile else { return 0 }
        let allowed = Entitlement.clampedCheats(profile.cheatsPerWeek, isPremium: state.isPremium)
        return max(0, allowed - state.week.cheatsUsed)
    }

    private func minutesSinceWindowClosed(profile: DietProfile, now: Date) -> Int {
        let calendar = Calendar.current
        let currentMinutes = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)
        let windowEnd = profile.eatingWindow.endHour * 60 + profile.eatingWindow.endMinute
        if currentMinutes >= windowEnd {
            return currentMinutes - windowEnd
        }
        return (24 * 60 - windowEnd) + currentMinutes
    }

}

// MARK: - Errors

enum DietError: LocalizedError {
    case noCheatMealsRemaining
    case dietNotActive
    case cheatNotAvailableDuringFast
    case invalidConfiguration([String])

    var errorDescription: String? {
        switch self {
        case .noCheatMealsRemaining:
            return "No cheat meals remaining this week"
        case .dietNotActive:
            return "Diet is not currently active"
        case .cheatNotAvailableDuringFast:
            return "Cheat meals are not available during a fast"
        case .invalidConfiguration(let issues):
            return issues.joined(separator: "\n")
        }
    }
}
