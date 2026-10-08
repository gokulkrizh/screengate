import Foundation
import FamilyControls

/// File-backed single source of truth in the app group, with pre-v1 migration.
///
/// All processes (app and extensions) read and write `SharedState.json` through
/// this class. Writes are atomic + file-coordinated and bump `writerID`/`revision`
/// so receivers can ignore their own Darwin notifications.
final class SharedStore {
    static let shared = SharedStore()

    static let appGroupID = "group.com.gia.screendiet"
    static let fileName = "SharedState.json"
    static let darwinStateChanged = "com.gia.screendiet.stateChanged"

    /// Legacy UserDefaults keys removed after a successful migration.
    private static let legacyKeys = [
        "dietProfile",
        "foodGroup_protein", "foodGroup_carbs", "foodGroup_fats", "foodGroup_fiber",
        "todayLog", "weeklyLogs",
        "cheatMealActive", "cheatMealExpires", "currentShieldType",
        "carbsUsedToday", "cheatsUsedThisWeek", "cheatsUsedToday",
    ]

    let writerID = UUID()
    /// True when `load()` migrated pre-v1 UserDefaults during this process.
    private(set) var didMigrateLegacyState = false

    private let fileURL: URL
    private let legacyDefaults: UserDefaults?
    private let coordinator = NSFileCoordinator()

    private init() {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Self.appGroupID)
        let base = container
            ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        self.fileURL = base.appendingPathComponent(Self.fileName)
        self.legacyDefaults = UserDefaults(suiteName: Self.appGroupID)
    }

    // MARK: - Load

    func load() -> SharedState {
        if var state = readFromDisk() {
            state.profile = state.profile?.normalizingClock()
            return state
        }

        if let migrated = Self.migrateLegacyState(defaults: legacyDefaults) {
            didMigrateLegacyState = true
            let saved = save(migrated)
            Self.removeLegacyKeys(defaults: legacyDefaults)
            return saved
        }

        return .empty()
    }

    private func readFromDisk() -> SharedState? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        var error: NSError?
        var data: Data?
        coordinator.coordinate(readingItemAt: fileURL, options: [], error: &error) { url in
            data = try? Data(contentsOf: url)
        }
        guard let data else { return nil }
        return try? JSONDecoder().decode(SharedState.self, from: data)
    }

    // MARK: - Save

    @discardableResult
    func save(_ state: SharedState, postNotification: Bool = true) -> SharedState {
        var stamped = state
        stamped.version = SharedState.currentVersion
        stamped.writerID = writerID
        stamped.revision += 1

        if let data = try? JSONEncoder().encode(stamped) {
            var error: NSError?
            coordinator.coordinate(writingItemAt: fileURL, options: .forReplacing, error: &error) { url in
                try? data.write(to: url, options: .atomic)
            }
            if postNotification { Self.postStateChanged() }
        }
        return stamped
    }

    @discardableResult
    func mutate(_ body: (inout SharedState) -> Void, postNotification: Bool = true) -> SharedState {
        var state = load()
        body(&state)
        return save(state, postNotification: postNotification)
    }

    static func postStateChanged() {
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(darwinStateChanged as CFString),
            nil, nil, true
        )
    }

    // MARK: - Legacy migration (pre-v1 UserDefaults -> SharedState v2)

    private static func migrateLegacyState(defaults: UserDefaults?) -> SharedState? {
        guard let defaults else { return nil }
        let hasProfile = defaults.data(forKey: "dietProfile") != nil
        let hasSelections = FoodGroup.allCases.contains { defaults.data(forKey: "foodGroup_\($0.rawValue)") != nil }
        guard hasProfile || hasSelections else { return nil }

        var state = SharedState.empty()

        // Profile
        if let data = defaults.data(forKey: "dietProfile"),
           let legacy = try? JSONDecoder().decode(LegacyDietProfile.self, from: data) {
            let plan: DietPlan = {
                switch legacy.dietType {
                case "keto": return .keto
                case "detox": return .detox
                case "custom": return .custom
                default: return .lean
                }
            }()
            let window = EatingWindow(
                startHour: legacy.eatingWindow.startHour,
                startMinute: legacy.eatingWindow.startMinute,
                endHour: legacy.eatingWindow.endHour,
                endMinute: legacy.eatingWindow.endMinute
            )
            state.profile = DietProfile(
                plan: plan,
                eatingWindow: window,
                weekendWindow: nil,
                portionMinutes: max(0, legacy.eatingWindow.dailyCarbLimitMinutes),
                nightFast: NightFast(
                    isEnabled: true,
                    startHour: legacy.nightLockHour,
                    startMinute: legacy.nightLockMinute,
                    endHour: window.startHour,
                    endMinute: window.startMinute
                ),
                cheatsPerWeek: max(0, legacy.weeklyCheatMeals),
                isActive: legacy.isActive,
                activatedAt: legacy.activatedAt,
                weekNumber: max(1, legacy.weekNumber),
                weekStartDate: legacy.weekStartDate
            )
            if let weekStart = legacy.weekStartDate {
                state.week = WeekCounters(weekStart: weekStart, cheatsUsed: 0, daysOverPortion: 0, daysCompleted: 0)
            }
            state.week.cheatsUsed = max(legacy.cheatsUsedThisWeek, defaults.integer(forKey: "cheatsUsedThisWeek"))
        }

        // Selections (fiber is dropped; protein is unrestricted)
        for group in FoodGroup.allCases {
            let key = "foodGroup_\(group.rawValue)"
            if let data = defaults.data(forKey: key),
               let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
                state.selections[group.rawValue] = selection
            }
        }

        // Today's counters
        var carbMinutes = defaults.integer(forKey: "carbsUsedToday")
        var cheatsToday = defaults.integer(forKey: "cheatsUsedToday")
        if let data = defaults.data(forKey: "todayLog"),
           let log = try? JSONDecoder().decode(LegacyNutritionLog.self, from: data) {
            carbMinutes = max(carbMinutes, log.carbsMinutes)
            cheatsToday = max(cheatsToday, log.cheatsUsed)
        }
        let portion = state.profile?.portionMinutes ?? DebugConfig.defaultPortionMinutes
        state.counters = DayCounters(
            dateKey: DayCounters.dateKey(),
            carbMinutes: carbMinutes,
            cheatsUsedToday: cheatsToday,
            portionHit: portion > 0 && carbMinutes >= portion
        )

        // Streak from the archived daily logs (consecutive days within portion).
        if let data = defaults.data(forKey: "weeklyLogs"),
           let logs = try? JSONDecoder().decode([LegacyNutritionLog].self, from: data),
           let portion = state.profile?.portionMinutes {
            let sorted = logs.sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
            var streak = 0
            for log in sorted {
                if log.carbsMinutes <= portion { streak += 1 } else { break }
            }
            state.streak = streak
        }

        // Active cheat session, if any.
        if defaults.bool(forKey: "cheatMealActive"),
           let expires = defaults.object(forKey: "cheatMealExpires") as? Date,
           expires > Date() {
            state.cheat = CheatSession(startedAt: Date(), endsAt: expires, source: .app)
        }

        return state
    }

    private static func removeLegacyKeys(defaults: UserDefaults?) {
        guard let defaults else { return }
        for key in legacyKeys { defaults.removeObject(forKey: key) }
    }
}

// MARK: - Legacy decoding

private struct LegacyDietProfile: Decodable {
    var dietType: String
    var eatingWindow: LegacyEatingWindow
    var nightLockHour: Int
    var nightLockMinute: Int
    var weeklyCheatMeals: Int
    var cheatsUsedThisWeek: Int
    var isActive: Bool
    var activatedAt: Date?
    var weekNumber: Int
    var weekStartDate: Date?
}

private struct LegacyEatingWindow: Decodable {
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    var dailyCarbLimitMinutes: Int
}

private struct LegacyNutritionLog: Decodable {
    var dateKey: String?
    var date: Date?
    var carbsMinutes: Int
    var cheatsUsed: Int
}
