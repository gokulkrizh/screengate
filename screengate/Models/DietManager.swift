import Foundation
import FamilyControls
import UserNotifications
import DeviceActivity
import Observation

@Observable
final class DietManager {
    // MARK: - Published State

    var dietProfile: DietProfile?
    var foodGroupSelections: [FoodGroup: FamilyActivitySelection] = [:]
    var todayLog: NutritionLog = NutritionLog.today()
    var weeklyLogs: [NutritionLog] = []
    var isCheatMealActive: Bool = false
    var cheatMealExpiresAt: Date?

    // MARK: - Private Dependencies

    @ObservationIgnored
    private let deviceActivityManager = DeviceActivityManager()
    @ObservationIgnored
    private let userDefaults: UserDefaults
    @ObservationIgnored
    private var cheatTimer: Timer?
    @ObservationIgnored
    private var isSavingToUserDefaults = false  // Prevent Darwin notification self-loop

    // MARK: - UserDefaults Keys

    @ObservationIgnored
    private let dietProfileKey = "dietProfile"
    @ObservationIgnored
    private let foodGroupSelectionsPrefix = "foodGroup_"
    @ObservationIgnored
    private let todayLogKey = "todayLog"
    @ObservationIgnored
    private let weeklyLogsKey = "weeklyLogs"
    @ObservationIgnored
    private let cheatMealActiveKey = "cheatMealActive"
    @ObservationIgnored
    private let cheatMealExpiresKey = "cheatMealExpires"
    @ObservationIgnored
    private let currentShieldTypeKey = "currentShieldType"
    @ObservationIgnored
    private let carbsUsedTodayKey = "carbsUsedToday"
    @ObservationIgnored
    private let cheatsUsedThisWeekKey = "cheatsUsedThisWeek"
    @ObservationIgnored
    private let cheatsUsedTodayKey = "cheatsUsedToday"

    // MARK: - Computed Properties

    /// Current diet state based on time, window, and usage
    var currentDietState: DietState {
        guard let profile = dietProfile, profile.isActive else {
            return .inactive
        }

        let now = Date()

        // Check night lock first (highest priority)
        if profile.isNightLockActive(at: now) {
            return .nightLock
        }

        // Check if eating window is open
        if profile.eatingWindow.isWindowOpen(at: now) {
            // Window is open - check if carb limit reached
            if todayLog.carbsMinutes >= profile.eatingWindow.dailyCarbLimitMinutes
                && profile.eatingWindow.dailyCarbLimitMinutes > 0 {
                return .limitReached
            }
            return .windowOpen
        }

        // Outside window, before night lock
        return .fasting
    }

    /// Current shield type to write to UserDefaults for extensions
    var currentShieldType: ShieldType {
        switch currentDietState {
        case .fasting: return .kitchenClosed
        case .windowOpen: return .portionTimer
        case .limitReached: return .dailyLimitReached
        case .nightLock: return .nightLock
        case .inactive: return .kitchenClosed
        }
    }

    /// Minutes of carb allowance remaining today
    var carbsRemainingMinutes: Int {
        guard let profile = dietProfile else { return 0 }
        return max(0, profile.eatingWindow.dailyCarbLimitMinutes - todayLog.carbsMinutes)
    }

    /// Carb minutes within the daily limit (regular usage)
    var regularCarbMinutes: Int {
        guard let profile = dietProfile else { return todayLog.carbsMinutes }
        return min(todayLog.carbsMinutes, profile.eatingWindow.dailyCarbLimitMinutes)
    }

    /// Carb minutes beyond the daily limit (cheat meal usage)
    var cheatCarbMinutes: Int {
        guard let profile = dietProfile else { return 0 }
        return max(0, todayLog.carbsMinutes - profile.eatingWindow.dailyCarbLimitMinutes)
    }

    /// Fasting progress as a percentage (0-100)
    var fastingProgress: Double {
        guard let profile = dietProfile else { return 0 }
        let now = Date()
        guard !profile.eatingWindow.isWindowOpen(at: now) else { return 0 }

        let totalFastMinutes = profile.fastingHours * 60
        let minutesSinceWindowClosed = minutesSinceWindowClosed()
        return min(100, Double(minutesSinceWindowClosed) / totalFastMinutes * 100)
    }

    /// Number of cheat meals remaining this week
    var cheatsRemaining: Int {
        dietProfile?.cheatsRemaining ?? 0
    }

    /// Fast streak (consecutive days meeting fasting goal)
    var fastStreak: Int {
        // Calculate from weekly logs (days where carb usage was within limit)
        var streak = 0
        let sortedLogs = weeklyLogs.sorted { $0.date > $1.date }
        guard let profile = dietProfile else { return 0 }
        for log in sortedLogs {
            if log.carbsMinutes <= profile.eatingWindow.dailyCarbLimitMinutes {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }

    // MARK: - Initialization

    init() {
        self.userDefaults = UserDefaults(suiteName: "group.com.gia.screendiet") ?? .standard
        loadFromUserDefaults()
        setupDarwinNotificationObserver()
        resetDailyLogIfNeeded()
    }

    deinit {
        cheatTimer?.invalidate()
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let observer = Unmanaged.passUnretained(self).toOpaque()
        CFNotificationCenterRemoveObserver(center, observer, nil, nil)
    }

    // MARK: - Diet Setup

    /// Set food group selection for a specific group
    func setFoodGroupSelection(_ selection: FamilyActivitySelection, for group: FoodGroup) {
        foodGroupSelections[group] = selection
        saveFoodGroupSelections()
    }

    /// Configure and activate a diet profile
    func activateDiet(profile: DietProfile) throws {
        var activeProfile = profile
        activeProfile.isActive = true
        activeProfile.activatedAt = Date()
        activeProfile.weekStartDate = Date()
        activeProfile.weekNumber = 1
        self.dietProfile = activeProfile

        // Reset daily counters to avoid stale data from previous installs
        // (App group UserDefaults persist across app reinstalls)
        todayLog = NutritionLog.today()
        userDefaults.set(0, forKey: carbsUsedTodayKey)
        userDefaults.set(0, forKey: cheatsUsedThisWeekKey)
        userDefaults.set(0, forKey: cheatsUsedTodayKey)
        userDefaults.set(false, forKey: cheatMealActiveKey)
        userDefaults.removeObject(forKey: cheatMealExpiresKey)

        // Apply initial restrictions based on current state
        applyRestrictionsForCurrentState()

        // Start diet monitoring
        try startDietMonitoring()

        // Update shield type
        updateShieldType()

        saveToUserDefaults()

        #if DEBUG
        print("[DietManager] Diet activated: \(profile.dietType.displayName)")
        #endif
    }

    /// Deactivate the diet and remove all restrictions
    func deactivateDiet() {
        deviceActivityManager.stopAllMonitors()
        deviceActivityManager.removeRestrictions()

        dietProfile?.isActive = false
        updateShieldType()
        saveToUserDefaults()

    }

    /// Update diet profile (e.g., change window times, limits)
    func updateDietProfile(_ profile: DietProfile) throws {
        self.dietProfile = profile

        // Restart monitoring with new settings
        deviceActivityManager.stopAllMonitors()
        try startDietMonitoring()

        applyRestrictionsForCurrentState()
        updateShieldType()
        saveToUserDefaults()
    }

    // MARK: - Cheat Meal

    /// Use a cheat meal (temporarily allow carb apps for 30 min)
    func useCheatMeal() throws {
        guard var profile = dietProfile else { return }
        guard profile.cheatsRemaining > 0 else {
            throw DietError.noCheatMealsRemaining
        }

        profile.cheatsUsedThisWeek += 1
        self.dietProfile = profile
        self.isCheatMealActive = true
        self.cheatMealExpiresAt = Date().addingTimeInterval(6 * 60)  // 6 min (testing; change back to 30 * 60 for production)

        // Remove carb restrictions temporarily
        deviceActivityManager.removeRestrictions()

        // Save cheat state for extensions
        userDefaults.set(true, forKey: cheatMealActiveKey)
        userDefaults.set(cheatMealExpiresAt, forKey: cheatMealExpiresKey)

        todayLog.cheatsUsed += 1

        saveToUserDefaults()
        startCheatTimer()
    }

    /// End cheat meal early
    func endCheatMeal() {
        #if DEBUG
        print("[DietManager] Cheat meal ended - carb usage tracked via threshold events (current: \(todayLog.carbsMinutes)m)")
        #endif

        isCheatMealActive = false
        cheatMealExpiresAt = nil
        cheatTimer?.invalidate()
        cheatTimer = nil

        userDefaults.set(false, forKey: cheatMealActiveKey)
        userDefaults.removeObject(forKey: cheatMealExpiresKey)

        // Sync latest carb usage from extension before re-applying restrictions
        let extensionCarbs = userDefaults.integer(forKey: carbsUsedTodayKey)
        if extensionCarbs > todayLog.carbsMinutes {
            todayLog.carbsMinutes = extensionCarbs
        }

        // Re-apply restrictions
        applyRestrictionsForCurrentState()
        saveToUserDefaults()
    }

    // MARK: - Nutrition Tracking

    /// Increment usage minutes for a food group (called by extension via UserDefaults)
    func incrementUsage(for group: FoodGroup, minutes: Int) {
        switch group {
        case .protein: todayLog.proteinMinutes += minutes
        case .carbs: todayLog.carbsMinutes += minutes
        case .fats: todayLog.fatsMinutes += minutes
        case .fiber: todayLog.fiberMinutes += minutes
        }

        // Check if carb limit reached
        if let profile = dietProfile,
           group == .carbs,
           todayLog.carbsMinutes >= profile.eatingWindow.dailyCarbLimitMinutes {
            applyCarbLimitRestrictions()
        }

        saveToUserDefaults()
    }

    /// Get weekly summary for current or past week
    func getWeeklySummary() -> WeeklyNutritionSummary? {
        guard let profile = dietProfile else { return nil }
        let logs = weeklyLogs + [todayLog]
        let actualRatios: [FoodGroup: Double] = [
            .protein: todayLog.proteinPercentage,
            .carbs: todayLog.carbsPercentage,
            .fats: todayLog.fatsPercentage,
            .fiber: todayLog.fiberPercentage
        ]
        let targetRatios = profile.macroRatios.reduce(into: [FoodGroup: Int]()) { result, pair in
            if let group = FoodGroup(rawValue: pair.key) {
                result[group] = pair.value
            }
        }
        let grade = MetabolicScoreCalculator.calculate(actual: actualRatios, target: targetRatios)

        return WeeklyNutritionSummary(
            weekNumber: profile.weekNumber,
            startDate: profile.weekStartDate ?? Date(),
            endDate: Date(),
            dailyLogs: logs,
            metabolicGrade: grade
        )
    }

    // MARK: - Monitor Scheduling

    /// Start all diet monitors based on current profile
    private func startDietMonitoring() throws {
        guard let profile = dietProfile else { return }

        // Monitor 1: Carb window schedule (daily repeating)
        // Opens carb access during window, closes outside
        let windowStart = Calendar.current.date(
            from: profile.eatingWindow.startTimeComponents
        ) ?? Date()
        let windowEnd = Calendar.current.date(
            from: profile.eatingWindow.endTimeComponents
        ) ?? Date()

        if let carbSelection = foodGroupSelections[.carbs], carbSelection.applicationTokens.count > 0 || carbSelection.categoryTokens.count > 0 {
            // Create incremental thresholds every 5 minutes up to daily limit
            // This allows the extension to report usage back to the app at each interval
            let limitMinutes = profile.eatingWindow.dailyCarbLimitMinutes
            let interval = 5
            let maxEvents = 20  // iOS DeviceActivity max events per activity
            var thresholds: [Int] = []
            var t = interval
            while t <= limitMinutes {
                thresholds.append(t)
                t += interval
            }
            // Ensure the exact limit is included
            if thresholds.last != limitMinutes && limitMinutes > 0 {
                thresholds.append(limitMinutes)
            }
            // Add post-limit thresholds to track usage during cheat meals.
            // Without these, no threshold events fire beyond the daily limit,
            // so carb usage during cheat meals would go untracked.
            let lastThreshold = thresholds.last ?? limitMinutes
            t = lastThreshold + interval
            while thresholds.count < maxEvents {
                thresholds.append(t)
                t += interval
            }

            try deviceActivityManager.startMonitorWithIncrementalThresholds(
                activitySelection: carbSelection,
                thresholdMinutes: thresholds,
                start: windowStart,
                end: windowEnd,
                repeatDaily: true,
                activityName: "diet.carbs.window",
                warningTimeMinutes: 5
            )
        }

        // Monitor 2: Night lock schedule (daily repeating)
        let nightLockStart = Calendar.current.date(
            from: profile.nightLockTimeComponents
        ) ?? Date()
        // Night lock ends when eating window opens
        let nightLockEnd = windowStart

        // Merge all non-protein selections for night lock
        let nightLockSelection = mergeSelections(excluding: .protein)
        if nightLockSelection.applicationTokens.count > 0 || nightLockSelection.categoryTokens.count > 0 {
            try deviceActivityManager.startMonitor(
                activitySelection: nightLockSelection,
                shieldThreshold: 0,
                start: nightLockStart,
                end: nightLockEnd,
                repeatDaily: true,
                activityName: "diet.nightlock",
                eventName: "nightlock-active",
                warningTimeMinutes: 15
            )
        }

        // Monitor 3: Fats usage tracking (if fats have a limit)
        if let fatsSelection = foodGroupSelections[.fats],
           fatsSelection.applicationTokens.count > 0 || fatsSelection.categoryTokens.count > 0 {
            let fatsLimitMinutes = profile.ratio(for: .fats) * 3  // rough limit from ratio
            let fatsLimitSeconds = TimeInterval(fatsLimitMinutes * 60)
            if fatsLimitSeconds > 0 {
                try deviceActivityManager.startMonitor(
                    activitySelection: fatsSelection,
                    shieldThreshold: fatsLimitSeconds,
                    start: windowStart,
                    end: windowEnd,
                    repeatDaily: true,
                    activityName: "diet.fats.window",
                    eventName: "fats-limit",
                    warningTimeMinutes: 5
                )
            }
        }
    }

    // MARK: - Restriction Application

    /// Apply restrictions based on current diet state
    func applyRestrictionsForCurrentState() {
        // Skip if cheat meal active
        guard !isCheatMealActive else { return }

        switch currentDietState {
        case .fasting:
            // Block carbs during fasting
            applyCarbRestrictions()
        case .windowOpen:
            // Remove carb restrictions (window is open)
            deviceActivityManager.removeRestrictions()
        case .limitReached:
            // Block carbs (limit hit)
            applyCarbLimitRestrictions()
        case .nightLock:
            // Block everything except protein
            applyNightLockRestrictions()
        case .inactive:
            deviceActivityManager.removeRestrictions()
        }

        updateShieldType()
    }

    private func applyCarbRestrictions() {
        guard let carbSelection = foodGroupSelections[.carbs] else { return }
        deviceActivityManager.applyImmediateRestrictions(activitySelection: carbSelection)
    }

    private func applyCarbLimitRestrictions() {
        guard let carbSelection = foodGroupSelections[.carbs] else { return }
        deviceActivityManager.applyImmediateRestrictions(activitySelection: carbSelection)
    }

    private func applyNightLockRestrictions() {
        let nightLockSelection = mergeSelections(excluding: .protein)
        deviceActivityManager.applyImmediateRestrictions(activitySelection: nightLockSelection)
    }

    /// Remove all restrictions
    func removeAllRestrictions() {
        deviceActivityManager.removeRestrictions()
    }

    // MARK: - Shield Type

    /// Update the shield type in UserDefaults for extensions to read
    func updateShieldType() {
        let shieldType = currentShieldType
        userDefaults.set(shieldType.rawValue, forKey: currentShieldTypeKey)
    }

    // MARK: - Helpers

    /// Merge all food group selections except the excluded one
    private func mergeSelections(excluding: FoodGroup) -> FamilyActivitySelection {
        var merged = FamilyActivitySelection()
        for (group, selection) in foodGroupSelections {
            if group == excluding { continue }
            merged.applicationTokens.formUnion(selection.applicationTokens)
            merged.categoryTokens.formUnion(selection.categoryTokens)
            merged.webDomainTokens.formUnion(selection.webDomainTokens)
        }
        return merged
    }

    /// Calculate minutes since eating window closed
    private func minutesSinceWindowClosed() -> Int {
        guard let profile = dietProfile else { return 0 }
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentTotalMinutes = currentHour * 60 + currentMinute
        let windowEndMinutes = profile.eatingWindow.endHour * 60 + profile.eatingWindow.endMinute

        if currentTotalMinutes >= windowEndMinutes {
            return currentTotalMinutes - windowEndMinutes
        }
        // Past midnight
        return (24 * 60 - windowEndMinutes) + currentTotalMinutes
    }

    /// Reset daily log if it's a new day
    private func resetDailyLogIfNeeded() {
        let today = NutritionLog.dateKey(from: Date())
        if todayLog.dateKey != today {
            // Archive yesterday's log
            weeklyLogs.append(todayLog)
            // Keep only last 7 days
            if weeklyLogs.count > 7 {
                weeklyLogs.removeFirst(weeklyLogs.count - 7)
            }
            // Reset today
            todayLog = NutritionLog.today()

            // Reset weekly cheat count if new week
            if let profile = dietProfile,
               let weekStart = profile.weekStartDate,
               Calendar.current.dateComponents([.day], from: weekStart, to: Date()).day ?? 0 >= 7 {
                var updatedProfile = profile
                updatedProfile.cheatsUsedThisWeek = 0
                updatedProfile.weekNumber += 1
                updatedProfile.weekStartDate = Date()
                self.dietProfile = updatedProfile
            }

            saveToUserDefaults()
        }
    }

    // MARK: - Cheat Timer

    private func startCheatTimer() {
        cheatTimer?.invalidate()
        cheatTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if let expiresAt = self.cheatMealExpiresAt, expiresAt <= Date() {
                self.endCheatMeal()
            }
        }
    }

    // MARK: - Darwin Notification Observer

    private func setupDarwinNotificationObserver() {
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let observer = Unmanaged.passUnretained(self).toOpaque()

        CFNotificationCenterAddObserver(
            center,
            observer,
            { (center, observer, name, object, userInfo) in
                guard let observer = observer else { return }
                let manager = Unmanaged<DietManager>.fromOpaque(observer).takeUnretainedValue()

                // Skip notifications we posted ourselves
                guard !manager.isSavingToUserDefaults else { return }

                DispatchQueue.main.async {
                    #if DEBUG
                    print("[DietManager] Darwin notification received from extension - reloading")
                    #endif
                    manager.loadFromUserDefaults()
                    manager.applyRestrictionsForCurrentState()
                }
            },
            "com.gia.screendiet.dietChanged" as CFString,
            nil,
            .deliverImmediately
        )
    }

    // MARK: - Persistence

    func saveToUserDefaults() {
        isSavingToUserDefaults = true
        defer { isSavingToUserDefaults = false }

        do {
            let encoder = JSONEncoder()

            if let profile = dietProfile {
                let data = try encoder.encode(profile)
                userDefaults.set(data, forKey: dietProfileKey)
            }

            let logData = try encoder.encode(todayLog)
            userDefaults.set(logData, forKey: todayLogKey)

            let weeklyData = try encoder.encode(weeklyLogs)
            userDefaults.set(weeklyData, forKey: weeklyLogsKey)

            userDefaults.set(todayLog.carbsMinutes, forKey: carbsUsedTodayKey)

            // Write cheat counts as dedicated keys for extensions
            if let profile = dietProfile {
                userDefaults.set(profile.cheatsUsedThisWeek, forKey: cheatsUsedThisWeekKey)
            }
            userDefaults.set(todayLog.cheatsUsed, forKey: cheatsUsedTodayKey)

            // Post Darwin notification for extensions (not for self)
            CFNotificationCenterPostNotification(
                CFNotificationCenterGetDarwinNotifyCenter(),
                CFNotificationName("com.gia.screendiet.dietChanged" as CFString),
                nil, nil, true
            )
        } catch {
            print("[DietManager] Error saving to UserDefaults: \(error)")
        }
    }

    func saveFoodGroupSelections() {
        for (group, selection) in foodGroupSelections {
            let key = "\(foodGroupSelectionsPrefix)\(group.rawValue)"
            if let data = try? JSONEncoder().encode(selection) {
                userDefaults.set(data, forKey: key)
            }
        }
    }

    func loadFromUserDefaults() {
        // Load diet profile
        if let data = userDefaults.data(forKey: dietProfileKey),
           let profile = try? JSONDecoder().decode(DietProfile.self, from: data) {
            self.dietProfile = profile
        }

        // Load food group selections
        for group in FoodGroup.allCases {
            let key = "\(foodGroupSelectionsPrefix)\(group.rawValue)"
            if let data = userDefaults.data(forKey: key),
               let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
                foodGroupSelections[group] = selection
            }
        }

        // Load today's log
        if let data = userDefaults.data(forKey: todayLogKey),
           let log = try? JSONDecoder().decode(NutritionLog.self, from: data) {
            self.todayLog = log
        }

        // Sync carbsUsedToday from the extension into todayLog
        // The extension writes only this integer key (not the full todayLog)
        let extensionCarbs = userDefaults.integer(forKey: carbsUsedTodayKey)
        if extensionCarbs > todayLog.carbsMinutes {
            todayLog.carbsMinutes = extensionCarbs
            #if DEBUG
            print("[DietManager] Synced carbsUsedToday from extension: \(extensionCarbs)")
            #endif
        }

        // Sync cheatsUsedThisWeek from the extension's dedicated key
        let extensionCheats = userDefaults.integer(forKey: cheatsUsedThisWeekKey)
        if var profile = dietProfile, extensionCheats > profile.cheatsUsedThisWeek {
            profile.cheatsUsedThisWeek = extensionCheats
            self.dietProfile = profile
            #if DEBUG
            print("[DietManager] Synced cheatsUsedThisWeek from extension: \(extensionCheats)")
            #endif
        }

        // Sync cheatsUsedToday from extension's dedicated key
        let extensionCheatsToday = userDefaults.integer(forKey: cheatsUsedTodayKey)
        if extensionCheatsToday > todayLog.cheatsUsed {
            todayLog.cheatsUsed = extensionCheatsToday
        }

        // Persist the merged values back to UserDefaults JSON so they
        // survive the next loadFromUserDefaults() call without data loss.
        // (Don't post Darwin notification — just update the JSON keys quietly.)
        let needsPersist = extensionCarbs > 0 || extensionCheats > 0 || extensionCheatsToday > 0
        if needsPersist {
            if let logData = try? JSONEncoder().encode(todayLog) {
                userDefaults.set(logData, forKey: todayLogKey)
            }
            if let profile = dietProfile, let profileData = try? JSONEncoder().encode(profile) {
                userDefaults.set(profileData, forKey: dietProfileKey)
            }
        }

        // Load weekly logs
        if let data = userDefaults.data(forKey: weeklyLogsKey),
           let logs = try? JSONDecoder().decode([NutritionLog].self, from: data) {
            self.weeklyLogs = logs
        }

        // Load cheat meal state
        isCheatMealActive = userDefaults.bool(forKey: cheatMealActiveKey)
        if let expiresAt = userDefaults.object(forKey: cheatMealExpiresKey) as? Date {
            cheatMealExpiresAt = expiresAt
            if isCheatMealActive && expiresAt > Date() {
                startCheatTimer()
            } else if isCheatMealActive && expiresAt <= Date() {
                endCheatMeal()
            }
        }

        #if DEBUG
        print("[DietManager] Loaded from UserDefaults - carbsMinutes: \(todayLog.carbsMinutes), carbsUsedToday key: \(extensionCarbs), state: \(currentDietState)")
        #endif
    }

    /// Check if diet has been set up (onboarding completed)
    static func hasDietProfile() -> Bool {
        let userDefaults = UserDefaults(suiteName: "group.com.gia.screendiet") ?? .standard
        return userDefaults.data(forKey: "dietProfile") != nil
    }
}

// MARK: - Errors

enum DietError: LocalizedError {
    case noCheatMealsRemaining
    case dietNotActive
    case invalidConfiguration

    var errorDescription: String? {
        switch self {
        case .noCheatMealsRemaining:
            return "No cheat meals remaining this week"
        case .dietNotActive:
            return "Diet is not currently active"
        case .invalidConfiguration:
            return "Invalid diet configuration"
        }
    }
}
