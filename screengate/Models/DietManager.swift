import Foundation
import FamilyControls
import UserNotifications
import DeviceActivity

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

    private let deviceActivityManager = DeviceActivityManager()
    private let userDefaults: UserDefaults
    private var cheatTimer: Timer?

    // MARK: - UserDefaults Keys

    private let dietProfileKey = "dietProfile"
    private let foodGroupSelectionsPrefix = "foodGroup_"
    private let todayLogKey = "todayLog"
    private let weeklyLogsKey = "weeklyLogs"
    private let cheatMealActiveKey = "cheatMealActive"
    private let cheatMealExpiresKey = "cheatMealExpires"
    private let currentShieldTypeKey = "currentShieldType"
    private let carbsUsedTodayKey = "carbsUsedToday"

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

        // Apply initial restrictions based on current state
        applyRestrictionsForCurrentState()

        // Start diet monitoring
        try startDietMonitoring()

        // Update shield type
        updateShieldType()

        saveToUserDefaults()

        print("✅ [DietManager] Diet activated: \(profile.dietType.displayName)")
    }

    /// Deactivate the diet and remove all restrictions
    func deactivateDiet() {
        deviceActivityManager.stopAllMonitors()
        deviceActivityManager.removeRestrictions()

        dietProfile?.isActive = false
        updateShieldType()
        saveToUserDefaults()

        print("✅ [DietManager] Diet deactivated")
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
        self.cheatMealExpiresAt = Date().addingTimeInterval(30 * 60)  // 30 min

        // Remove carb restrictions temporarily
        deviceActivityManager.removeRestrictions()

        // Save cheat state for extensions
        userDefaults.set(true, forKey: cheatMealActiveKey)
        userDefaults.set(cheatMealExpiresAt, forKey: cheatMealExpiresKey)

        todayLog.cheatsUsed += 1

        saveToUserDefaults()
        startCheatTimer()

        print("✅ [DietManager] Cheat meal activated, \(profile.cheatsRemaining) remaining")
    }

    /// End cheat meal early
    func endCheatMeal() {
        isCheatMealActive = false
        cheatMealExpiresAt = nil
        cheatTimer?.invalidate()
        cheatTimer = nil

        userDefaults.set(false, forKey: cheatMealActiveKey)
        userDefaults.removeObject(forKey: cheatMealExpiresKey)

        // Re-apply restrictions
        applyRestrictionsForCurrentState()
        saveToUserDefaults()

        print("✅ [DietManager] Cheat meal ended")
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
            // Carb window monitor: threshold = daily limit
            let carbLimitSeconds = TimeInterval(profile.eatingWindow.dailyCarbLimitMinutes * 60)
            try deviceActivityManager.startMonitor(
                activitySelection: carbSelection,
                shieldThreshold: carbLimitSeconds,
                start: windowStart,
                end: windowEnd,
                repeatDaily: true,
                activityName: "diet.carbs.window",
                eventName: "carb-limit",
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

        print("✅ [DietManager] Diet monitoring started with \(deviceActivityManager.monitoringActivities.count) monitors")
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
        print("✅ [DietManager] Carb restrictions applied (fasting/curfew)")
    }

    private func applyCarbLimitRestrictions() {
        guard let carbSelection = foodGroupSelections[.carbs] else { return }
        deviceActivityManager.applyImmediateRestrictions(activitySelection: carbSelection)
        print("✅ [DietManager] Carb limit restrictions applied")
    }

    private func applyNightLockRestrictions() {
        let nightLockSelection = mergeSelections(excluding: .protein)
        deviceActivityManager.applyImmediateRestrictions(activitySelection: nightLockSelection)
        print("✅ [DietManager] Night lock restrictions applied (everything except protein)")
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
        userDefaults.synchronize()
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

                DispatchQueue.main.async {
                    manager.loadFromUserDefaults()
                    manager.applyRestrictionsForCurrentState()
                    print("✅ [DietManager] Received Darwin notification, reloaded state")
                }
            },
            "com.gia.screendiet.dietChanged" as CFString,
            nil,
            .deliverImmediately
        )
    }

    // MARK: - Persistence

    func saveToUserDefaults() {
        do {
            // Save diet profile
            if let profile = dietProfile {
                let data = try JSONEncoder().encode(profile)
                userDefaults.set(data, forKey: dietProfileKey)
            }

            // Save today's log
            let logData = try JSONEncoder().encode(todayLog)
            userDefaults.set(logData, forKey: todayLogKey)

            // Save weekly logs
            let weeklyData = try JSONEncoder().encode(weeklyLogs)
            userDefaults.set(weeklyData, forKey: weeklyLogsKey)

            // Save carbs used today (for extension access)
            userDefaults.set(todayLog.carbsMinutes, forKey: carbsUsedTodayKey)

            userDefaults.synchronize()

            // Post Darwin notification
            CFNotificationCenterPostNotification(
                CFNotificationCenterGetDarwinNotifyCenter(),
                CFNotificationName("com.gia.screendiet.dietChanged" as CFString),
                nil, nil, true
            )
        } catch {
            print("❌ [DietManager] Error saving to UserDefaults: \(error)")
        }
    }

    func saveFoodGroupSelections() {
        for (group, selection) in foodGroupSelections {
            let key = "\(foodGroupSelectionsPrefix)\(group.rawValue)"
            if let data = try? JSONEncoder().encode(selection) {
                userDefaults.set(data, forKey: key)
            }
        }
        userDefaults.synchronize()
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
