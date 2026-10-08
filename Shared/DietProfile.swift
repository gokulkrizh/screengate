import Foundation

// MARK: - Diet Plan (v1: Lean / Keto / Detox / Custom)

/// A diet plan template. `lean` is the free default; the others are premium.
enum DietPlan: String, Codable, CaseIterable, Identifiable {
    case lean
    case keto
    case detox
    case custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .lean: return "LEAN"
        case .keto: return "KETO"
        case .detox: return "DETOX"
        case .custom: return "CUSTOM"
        }
    }

    var subtitle: String {
        switch self {
        case .lean: return "Moderate portions, steady progress"
        case .keto: return "High creation, low consumption"
        case .detox: return "A short elimination cleanse"
        case .custom: return "Build your own rules"
        }
    }

    var icon: String {
        switch self {
        case .lean: return "⚖️"
        case .keto: return "🥗"
        case .detox: return "🧘"
        case .custom: return "🔧"
        }
    }

    /// Free tier is limited to Lean.
    var isPremium: Bool { self != .lean }

    var defaultWindowStartHour: Int {
        switch self {
        case .lean: return 12
        case .keto: return 12
        case .detox: return 12
        case .custom: return 12
        }
    }

    var defaultWindowEndHour: Int {
        switch self {
        case .lean: return 20
        case .keto: return 18
        case .detox: return 12
        case .custom: return 18
        }
    }

    /// Detox blocks carbs entirely (portion 0, no window schedule).
    var defaultPortionMinutes: Int {
        switch self {
        case .detox: return 0
        case .lean, .keto, .custom: return DebugConfig.defaultPortionMinutes
        }
    }

    var defaultCheatsPerWeek: Int {
        switch self {
        case .detox: return 0
        case .lean: return 1
        case .keto, .custom: return 3
        }
    }
}

// MARK: - Eating Window

/// The daily window during which carbs are available.
struct EatingWindow: Codable, Equatable {
    var startHour: Int       // 0-23
    var startMinute: Int     // 0-59
    var endHour: Int         // 0-23
    var endMinute: Int       // 0-59

    var startTimeComponents: DateComponents {
        DateComponents(hour: startHour, minute: startMinute)
    }

    var endTimeComponents: DateComponents {
        DateComponents(hour: endHour, minute: endMinute)
    }

    /// Duration of the window in minutes (handles overnight windows).
    var durationMinutes: Int {
        let start = startHour * 60 + startMinute
        let end = endHour * 60 + endMinute
        if end > start { return end - start }
        return (24 * 60 - start) + end
    }

    var windowDurationHours: Double { Double(durationMinutes) / 60.0 }

    var startTimeString: String { Self.formatTime(hour: startHour, minute: startMinute) }
    var endTimeString: String { Self.formatTime(hour: endHour, minute: endMinute) }

    static func formatTime(hour: Int, minute: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        if minute == 0 { return "\(displayHour):00 \(period)" }
        return "\(displayHour):\(String(format: "%02d", minute)) \(period)"
    }

    /// Check if the window is open at the given time.
    func isOpen(at date: Date = Date(), calendar: Calendar = .current) -> Bool {
        let current = calendar.component(.hour, from: date) * 60 + calendar.component(.minute, from: date)
        return contains(minutesOfDay: current)
    }

    /// Whether a time (in minutes from midnight) falls inside the window.
    func contains(minutesOfDay current: Int) -> Bool {
        let start = startHour * 60 + startMinute
        let end = endHour * 60 + endMinute
        if end > start { return current >= start && current < end }
        // Overnight window
        return current >= start || current < end
    }

    /// Minutes until the window closes (0 if closed).
    func minutesUntilClose(at date: Date = Date(), calendar: Calendar = .current) -> Int {
        guard isOpen(at: date, calendar: calendar) else { return 0 }
        let current = calendar.component(.hour, from: date) * 60 + calendar.component(.minute, from: date)
        let end = endHour * 60 + endMinute
        if end > current { return end - current }
        return (24 * 60 - current) + end
    }

    /// Minutes until the window opens (0 if already open).
    func minutesUntilOpen(at date: Date = Date(), calendar: Calendar = .current) -> Int {
        guard !isOpen(at: date, calendar: calendar) else { return 0 }
        let current = calendar.component(.hour, from: date) * 60 + calendar.component(.minute, from: date)
        let start = startHour * 60 + startMinute
        if start > current { return start - current }
        return (24 * 60 - current) + start
    }
}

// MARK: - Night Fast

/// Nightly fast window. Typically starts in the evening and ends when the
/// eating window opens. Blocks carbs + fats while active.
struct NightFast: Codable, Equatable {
    var isEnabled: Bool
    var startHour: Int       // 0-23
    var startMinute: Int     // 0-59
    var endHour: Int         // 0-23
    var endMinute: Int       // 0-59

    var startTimeComponents: DateComponents {
        DateComponents(hour: startHour, minute: startMinute)
    }

    var endTimeComponents: DateComponents {
        DateComponents(hour: endHour, minute: endMinute)
    }

    var startTimeString: String { EatingWindow.formatTime(hour: startHour, minute: startMinute) }
    var endTimeString: String { EatingWindow.formatTime(hour: endHour, minute: endMinute) }
    var timeRangeString: String { "\(startTimeString) - \(endTimeString)" }

    var durationMinutes: Int {
        let start = startHour * 60 + startMinute
        let end = endHour * 60 + endMinute
        if end > start { return end - start }
        return (24 * 60 - start) + end
    }

    /// Whether a time (in minutes from midnight) falls inside the fast.
    func contains(minutesOfDay current: Int) -> Bool {
        guard isEnabled else { return false }
        let start = startHour * 60 + startMinute
        let end = endHour * 60 + endMinute
        if end > start { return current >= start && current < end }
        return current >= start || current < end
    }

    /// Check if the fast is active at the given time (overnight aware).
    func isActive(at date: Date = Date(), calendar: Calendar = .current) -> Bool {
        let current = calendar.component(.hour, from: date) * 60 + calendar.component(.minute, from: date)
        return contains(minutesOfDay: current)
    }

    static func `default`(window: EatingWindow) -> NightFast {
        NightFast(
            isEnabled: true,
            startHour: 21,
            startMinute: 0,
            endHour: window.startHour,
            endMinute: window.startMinute
        )
    }
}

// MARK: - Diet Profile

/// Complete diet configuration (v1). Counters live in `SharedState`.
struct DietProfile: Codable, Equatable {
    var plan: DietPlan
    var eatingWindow: EatingWindow
    /// Premium weekend refeed window. `nil` means the weekday window applies.
    var weekendWindow: EatingWindow?
    /// Carb portion in minutes (0 = detox, carbs always blocked).
    var portionMinutes: Int
    var nightFast: NightFast
    var cheatsPerWeek: Int
    var isActive: Bool
    var activatedAt: Date?
    var weekNumber: Int
    var weekStartDate: Date?

    // MARK: Factory

    static func create(plan: DietPlan) -> DietProfile {
        let window = EatingWindow(
            startHour: plan.defaultWindowStartHour,
            startMinute: 0,
            endHour: plan.defaultWindowEndHour,
            endMinute: 0
        )
        return DietProfile(
            plan: plan,
            eatingWindow: window,
            weekendWindow: nil,
            portionMinutes: plan.defaultPortionMinutes,
            nightFast: .default(window: window),
            cheatsPerWeek: plan.defaultCheatsPerWeek,
            isActive: false,
            activatedAt: nil,
            weekNumber: 1,
            weekStartDate: nil
        )
    }

    /// Fasting duration in hours (window close to window open).
    var fastingHours: Double { 24.0 - eatingWindow.windowDurationHours }

    var nightFastTimeRange: String { nightFast.timeRangeString }
}
