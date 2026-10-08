import Foundation

// MARK: - DeviceActivity schedule names

/// Short names for every schedule the app registers. `DeviceActivityManager`
/// prefixes them with `com.gia.screendiet.`.
enum ScheduleNames {
    static let windowWeekday = "diet.window.weekday"
    static let windowWeekend = "diet.window.weekend"   // premium, v1.2
    static let night = "diet.night"
    static let cheat = "diet.cheat"
    static let fast = "diet.fast"
    static let rollover = "diet.daily.rollover"

    /// Pre-v1 names, stopped once during migration.
    static let legacyNames = [
        "diet.carbs.window",
        "diet.nightlock",
        "diet.fats.window",
    ]
}
