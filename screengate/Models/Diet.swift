import Foundation

// MARK: - Diet Type

/// Predefined diet plans with macro ratio configurations
enum DietType: String, Codable, CaseIterable, Identifiable {
    case keto      // High creation, low consumption
    case balanced  // Mixed macros
    case detox     // 7-day elimination cleanse
    case custom    // User-defined ratios

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .keto: return "KETO"
        case .balanced: return "BALANCED"
        case .detox: return "DETOX"
        case .custom: return "CUSTOM"
        }
    }

    var subtitle: String {
        switch self {
        case .keto: return "High creation, low consumption"
        case .balanced: return "Mixed macros"
        case .detox: return "7-day elimination cleanse"
        case .custom: return "Build your own"
        }
    }

    var icon: String {
        switch self {
        case .keto: return "🥗"
        case .balanced: return "⚖️"
        case .detox: return "🧘"
        case .custom: return "🔧"
        }
    }

    /// Default macro ratios for each diet type
    var defaultRatios: [FoodGroup: Int] {
        switch self {
        case .keto:
            return [.protein: 70, .carbs: 10, .fats: 15, .fiber: 5]
        case .balanced:
            return [.protein: 40, .carbs: 30, .fats: 20, .fiber: 10]
        case .detox:
            return [.protein: 60, .carbs: 0, .fats: 20, .fiber: 20]
        case .custom:
            return [.protein: 25, .carbs: 25, .fats: 25, .fiber: 25]
        }
    }

    /// Default daily carb limit in minutes
    var defaultCarbLimitMinutes: Int {
        switch self {
        case .keto: return DebugConfig.defaultPortionMinutes
        case .balanced: return DebugConfig.relaxedPortionMinutes
        case .detox: return 0
        case .custom: return DebugConfig.defaultPortionMinutes
        }
    }

    /// Default eating window start (hour)
    var defaultWindowStartHour: Int {
        switch self {
        case .keto: return 12
        case .balanced: return 10
        case .detox: return 12
        case .custom: return 12
        }
    }

    /// Default eating window end (hour)
    var defaultWindowEndHour: Int {
        switch self {
        case .keto: return 18    // 6 PM
        case .balanced: return 20 // 8 PM
        case .detox: return 12   // No window (blocked)
        case .custom: return 18
        }
    }

    var ratioSummary: String {
        let ratios = defaultRatios
        let p = ratios[.protein] ?? 0
        let c = ratios[.carbs] ?? 0
        let f = ratios[.fats] ?? 0
        let fi = ratios[.fiber] ?? 0
        return "\(p)% Protein | \(c)% Carbs | \(f)% Fats | \(fi)% Fiber"
    }
}

// MARK: - Eating Window

/// Defines when carb/restricted apps are accessible
struct EatingWindow: Codable, Equatable {
    var startHour: Int       // 0-23
    var startMinute: Int     // 0-59
    var endHour: Int         // 0-23
    var endMinute: Int       // 0-59
    var dailyCarbLimitMinutes: Int  // e.g., 60

    var startTimeComponents: DateComponents {
        var components = DateComponents()
        components.hour = startHour
        components.minute = startMinute
        return components
    }

    var endTimeComponents: DateComponents {
        var components = DateComponents()
        components.hour = endHour
        components.minute = endMinute
        return components
    }

    /// Duration of eating window in hours
    var windowDurationHours: Double {
        let startTotal = Double(startHour) + Double(startMinute) / 60.0
        let endTotal = Double(endHour) + Double(endMinute) / 60.0
        if endTotal > startTotal {
            return endTotal - startTotal
        }
        return (24.0 - startTotal) + endTotal  // overnight window
    }

    /// Formatted start time string
    var startTimeString: String {
        formatTime(hour: startHour, minute: startMinute)
    }

    /// Formatted end time string
    var endTimeString: String {
        formatTime(hour: endHour, minute: endMinute)
    }

    private func formatTime(hour: Int, minute: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        if minute == 0 {
            return "\(displayHour):00 \(period)"
        }
        return "\(displayHour):\(String(format: "%02d", minute)) \(period)"
    }

    /// Check if current time is within the eating window
    func isWindowOpen(at date: Date = Date()) -> Bool {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let currentMinutes = hour * 60 + minute
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute

        if endMinutes > startMinutes {
            return currentMinutes >= startMinutes && currentMinutes < endMinutes
        }
        // Overnight window
        return currentMinutes >= startMinutes || currentMinutes < endMinutes
    }

    /// Minutes remaining until window closes (or 0 if closed)
    func minutesUntilClose(at date: Date = Date()) -> Int {
        guard isWindowOpen(at: date) else { return 0 }
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let currentMinutes = hour * 60 + minute
        let endMinutes = endHour * 60 + endMinute

        if endMinutes > currentMinutes {
            return endMinutes - currentMinutes
        }
        return (24 * 60 - currentMinutes) + endMinutes
    }

    /// Minutes remaining until window opens (or 0 if open)
    func minutesUntilOpen(at date: Date = Date()) -> Int {
        guard !isWindowOpen(at: date) else { return 0 }
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let currentMinutes = hour * 60 + minute
        let startMinutes = startHour * 60 + startMinute

        if startMinutes > currentMinutes {
            return startMinutes - currentMinutes
        }
        return (24 * 60 - currentMinutes) + startMinutes
    }

    static let defaultKeto = EatingWindow(
        startHour: 12, startMinute: 0,
        endHour: 18, endMinute: 0,
        dailyCarbLimitMinutes: DebugConfig.defaultPortionMinutes
    )
}

// MARK: - Diet Profile

/// Complete diet configuration for a user
struct DietProfile: Codable, Equatable {
    var dietType: DietType
    var macroRatios: [String: Int]  // Using String keys for Codable (FoodGroup.rawValue -> percentage)
    var eatingWindow: EatingWindow
    var nightLockHour: Int            // 0-23, e.g., 21 for 9 PM
    var nightLockMinute: Int          // 0-59
    var weeklyCheatMeals: Int         // default 3
    var cheatsUsedThisWeek: Int
    var isActive: Bool
    var activatedAt: Date?
    var weekNumber: Int
    var weekStartDate: Date?

    // MARK: - Convenience Accessors

    func ratio(for group: FoodGroup) -> Int {
        macroRatios[group.rawValue] ?? 0
    }

    mutating func setRatio(_ value: Int, for group: FoodGroup) {
        macroRatios[group.rawValue] = value
    }

    var nightLockTimeComponents: DateComponents {
        var components = DateComponents()
        components.hour = nightLockHour
        components.minute = nightLockMinute
        return components
    }

    var nightLockTimeString: String {
        let period = nightLockHour >= 12 ? "PM" : "AM"
        let displayHour = nightLockHour == 0 ? 12 : (nightLockHour > 12 ? nightLockHour - 12 : nightLockHour)
        return "\(displayHour):00 \(period)"
    }

    var cheatsRemaining: Int {
        max(0, weeklyCheatMeals - cheatsUsedThisWeek)
    }

    /// Check if night lock is currently active
    func isNightLockActive(at date: Date = Date()) -> Bool {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let currentMinutes = hour * 60 + minute
        let lockMinutes = nightLockHour * 60 + nightLockMinute
        let windowStartMinutes = eatingWindow.startHour * 60 + eatingWindow.startMinute

        // Night lock is active from lockHour until eating window opens next day
        if lockMinutes > windowStartMinutes {
            // Normal case: lock at 9PM, window at 12PM
            return currentMinutes >= lockMinutes || currentMinutes < windowStartMinutes
        }
        // Edge case: lock and window same day
        return currentMinutes >= lockMinutes && currentMinutes < windowStartMinutes
    }

    /// Fasting duration in hours (from window close to window open)
    var fastingHours: Double {
        24.0 - eatingWindow.windowDurationHours
    }

    // MARK: - Factory

    static func create(dietType: DietType) -> DietProfile {
        let ratios = dietType.defaultRatios
        var macroRatios: [String: Int] = [:]
        for (group, value) in ratios {
            macroRatios[group.rawValue] = value
        }

        return DietProfile(
            dietType: dietType,
            macroRatios: macroRatios,
            eatingWindow: EatingWindow(
                startHour: dietType.defaultWindowStartHour,
                startMinute: 0,
                endHour: dietType.defaultWindowEndHour,
                endMinute: 0,
                dailyCarbLimitMinutes: dietType.defaultCarbLimitMinutes
            ),
            nightLockHour: 21,  // 9 PM default
            nightLockMinute: 0,
            weeklyCheatMeals: 3,
            cheatsUsedThisWeek: 0,
            isActive: false,
            activatedAt: nil,
            weekNumber: 1,
            weekStartDate: nil
        )
    }
}

// MARK: - Diet State

/// Current state of the diet at any given moment
enum DietState: String, Equatable {
    case fasting        // Outside eating window, before night lock
    case windowOpen     // Within eating window, under daily limit
    case limitReached   // Within eating window but daily carb limit hit
    case nightLock      // After night lock time
    case inactive       // Diet not activated
}

// MARK: - Shield Type

/// Determines which shield to display when a restricted app is opened
enum ShieldType: String, Codable {
    case kitchenClosed      // Fasting period - carb app blocked
    case portionTimer       // Within window - shows remaining budget
    case dailyLimitReached  // Carbs maxed out for the day
    case proteinApp         // Always available - encouraging message
    case carbCurfew         // Window ended while actively using
    case nightLock          // After night lock time
}
