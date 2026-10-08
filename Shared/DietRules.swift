import Foundation

// MARK: - Derived state

/// Current diet state, ordered by shield precedence:
/// Fast Now > Night Fast > portion hit > window closed.
enum DietState: String, Equatable, Codable {
    case fastNow
    case nightFast
    case portionHit
    case windowOpen
    case fasting
    case inactive
}

/// Which shield design to show. Maps 1:1 to the Phase 2 shield designs.
enum ShieldKind: String, Equatable {
    case focusFast      // Fast Now active
    case fasting        // Night Fast active
    case plateEmpty     // portion used up
    case kitchenClosed  // outside the eating window
}

/// Which named stores should be blocking right now.
struct StorePlan: Equatable {
    var carbsBlocked: Bool
    var nightBlocked: Bool
    var fastBlocked: Bool

    static let none = StorePlan(carbsBlocked: false, nightBlocked: false, fastBlocked: false)
}

// MARK: - Rules

/// Pure rules shared by the app, the monitor extension and the shields.
enum DietRules {

    /// DeviceActivity schedule intervals have a 15-minute system minimum.
    static let minimumScheduleMinutes = 15

    /// Effective cheat meal duration (the DeviceActivity minimum overrides the
    /// shorter debug value).
    static var cheatMealMinutes: Int { max(minimumScheduleMinutes, DebugConfig.cheatMealMinutes) }

    // MARK: Session helpers

    static func isCheatActive(_ cheat: CheatSession?, at now: Date = Date()) -> Bool {
        guard let cheat else { return false }
        return cheat.endsAt > now
    }

    static func isFastActive(_ fast: FastSession?, at now: Date = Date()) -> Bool {
        guard let fast else { return false }
        return fast.endsAt > now
    }

    // MARK: State

    static func windowFor(_ profile: DietProfile, at now: Date, calendar: Calendar = .current) -> EatingWindow {
        // Single daily schedule in v1.0; weekend windows are a premium follow-up.
        profile.eatingWindow
    }

    static func state(
        at now: Date = Date(),
        profile: DietProfile?,
        counters: DayCounters,
        fast: FastSession?,
        cheat: CheatSession?
    ) -> DietState {
        guard let profile, profile.isActive else { return .inactive }

        // Precedence: Fast Now > Night Fast > portion hit > window closed.
        if isFastActive(fast, at: now) { return .fastNow }
        if profile.nightFast.isActive(at: now) { return .nightFast }

        let window = self.windowFor(profile, at: now)
        if window.isOpen(at: now) {
            return counters.portionHit ? .portionHit : .windowOpen
        }
        return .fasting
    }

    static func shieldKind(for state: DietState) -> ShieldKind? {
        switch state {
        case .fastNow: return .focusFast
        case .nightFast: return .fasting
        case .portionHit: return .plateEmpty
        case .fasting: return .kitchenClosed
        case .windowOpen, .inactive: return nil
        }
    }

    // MARK: Store plan

    static func storePlan(
        at now: Date = Date(),
        profile: DietProfile?,
        counters: DayCounters,
        cheat: CheatSession?,
        fast: FastSession?
    ) -> StorePlan {
        guard let profile, profile.isActive else { return .none }

        let cheatActive = isCheatActive(cheat, at: now)
        let window = windowFor(profile, at: now)
        let windowOpen = window.isOpen(at: now)

        // Carbs are open only inside the window and under the portion, or during a cheat.
        // Detox (portion 0) blocks carbs entirely.
        let carbsAllowed: Bool
        if profile.plan == .detox || profile.portionMinutes == 0 {
            carbsAllowed = cheatActive
        } else {
            carbsAllowed = cheatActive || (windowOpen && !counters.portionHit)
        }

        return StorePlan(
            carbsBlocked: !carbsAllowed,
            nightBlocked: profile.nightFast.isActive(at: now),
            fastBlocked: isFastActive(fast, at: now)
        )
    }

    // MARK: Portion thresholds

    /// Threshold step for usage events: 5-minute granularity, but lean portions
    /// use a coarser step so that post-portion tracking fits in the 20-event budget.
    static func portionStep(portionMinutes: Int) -> Int {
        let portion = max(portionMinutes, 1)
        return max(5, Int(ceil(Double(portion) / 12.0)))
    }

    /// Usage thresholds (minutes) for a window schedule, including tracking past
    /// the portion (cheat meals) within the 20-event DeviceActivity budget.
    static func thresholdMinutes(portionMinutes: Int, maxEvents: Int = 20) -> [Int] {
        guard portionMinutes > 0 else { return [] }
        let step = portionStep(portionMinutes: portionMinutes)

        var thresholds: [Int] = []
        var t = step
        while t < portionMinutes && thresholds.count < maxEvents {
            thresholds.append(t)
            t += step
        }
        if thresholds.last != portionMinutes { thresholds.append(portionMinutes) }

        var post = portionMinutes
        while thresholds.count < maxEvents {
            post += step
            thresholds.append(post)
        }
        return thresholds
    }

    // MARK: Validation

    /// Constraint checks for a profile. Empty array = valid.
    /// DeviceActivity requires every schedule interval to be at least 15 minutes.
    static func validate(_ profile: DietProfile) -> [String] {
        var issues: [String] = []

        // Detox: no window schedule, portion must be 0.
        if profile.plan == .detox {
            if profile.portionMinutes != 0 { issues.append("Detox must block carbs entirely (portion 0).") }
            return issues
        }

        if profile.eatingWindow.durationMinutes < 15 {
            issues.append("Eating window must be at least 15 minutes.")
        }

        if profile.nightFast.isEnabled {
            if profile.nightFast.durationMinutes < 15 {
                issues.append("Night Fast must be at least 15 minutes.")
            }
            if windowsOverlap(profile.eatingWindow, profile.nightFast) {
                issues.append("Eating window and Night Fast must not overlap.")
            }
        }

        if profile.portionMinutes <= 0 {
            issues.append("Portion must be greater than 0 (or choose Detox).")
        } else if thresholdMinutes(portionMinutes: profile.portionMinutes).count > 20 {
            issues.append("Portion is too large for the threshold budget.")
        }

        if profile.cheatsPerWeek < 0 || profile.cheatsPerWeek > 7 {
            issues.append("Cheats per week must be between 0 and 7.")
        }

        return issues
    }

    /// Do the eating window and the night fast overlap in a 24h day?
    static func windowsOverlap(_ window: EatingWindow, _ night: NightFast) -> Bool {
        let minutes = Set(0..<(24 * 60))
        let windowMinutes = minutes.filter { window.contains(minutesOfDay: $0) }
        let nightMinutes = minutes.filter { night.contains(minutesOfDay: $0) }
        return !windowMinutes.isDisjoint(with: nightMinutes)
    }

    // MARK: Rollover

    /// Reset daily counters, update the streak and roll the week over when needed.
    /// Shared by the app and the `diet.daily.rollover` schedule.
    static func rolloverIfNeeded(_ state: inout SharedState, at now: Date = Date()) {
        let today = DayCounters.today(now)
        guard state.counters.dateKey != today.dateKey else { return }

        // Week rollover (calendar week) first, so yesterday's result lands in the new week.
        if let nextWeekStart = Calendar.current.dateInterval(of: .weekOfYear, for: now)?.start,
           nextWeekStart > state.week.weekStart {
            state.week = WeekCounters.current(now)
            state.profile?.weekNumber += 1
            state.profile?.weekStartDate = nextWeekStart
        }

        // Close out yesterday.
        state.week.daysCompleted += 1
        if state.counters.portionHit {
            state.week.daysOverPortion += 1
            state.streak = 0
        } else if state.profile?.isActive == true {
            state.streak += 1
        }

        state.counters = today
        state.cheat = nil
    }

    // MARK: Loosening (24 h cooldown)

    /// Is this change looser than the current profile? Tightening is instant;
    /// loosening waits out the cooldown.
    static func isLoosening(from current: DietProfile, to next: DietProfile) -> Bool {
        if next.portionMinutes > current.portionMinutes { return true }
        if next.cheatsPerWeek > current.cheatsPerWeek { return true }
        if current.nightFast.isEnabled && !next.nightFast.isEnabled { return true }
        if next.eatingWindow.durationMinutes > current.eatingWindow.durationMinutes { return true }
        if current.plan == .detox && next.plan != .detox { return true }
        return false
    }

    // MARK: Time helpers

    /// Convert minutes-from-midnight into hour/minute components.
    static func components(fromMinutes minutes: Int) -> DateComponents {
        DateComponents(hour: (minutes / 60) % 24, minute: minutes % 60)
    }

    // MARK: Boundaries (widget timelines)

    /// The next known boundary dates (within ~48 h), sorted.
    static func nextBoundaries(
        profile: DietProfile?,
        cheat: CheatSession? = nil,
        fast: FastSession? = nil,
        after now: Date = Date(),
        calendar: Calendar = .current
    ) -> [Date] {
        var dates: Set<Date> = []

        if let cheat, cheat.endsAt > now { dates.insert(cheat.endsAt) }
        if let fast, fast.endsAt > now { dates.insert(fast.endsAt) }

        if let profile, profile.isActive {
            let window = profile.eatingWindow
            dates.insert(nextOccurrence(hour: window.startHour, minute: window.startMinute, after: now, calendar: calendar))
            dates.insert(nextOccurrence(hour: window.endHour, minute: window.endMinute, after: now, calendar: calendar))
            if profile.nightFast.isEnabled {
                dates.insert(nextOccurrence(hour: profile.nightFast.startHour, minute: profile.nightFast.startMinute, after: now, calendar: calendar))
                dates.insert(nextOccurrence(hour: profile.nightFast.endHour, minute: profile.nightFast.endMinute, after: now, calendar: calendar))
            }
        }

        return dates.sorted()
    }

    /// The next time-of-day occurrence after `now`.
    static func nextOccurrence(
        hour: Int,
        minute: Int,
        after now: Date = Date(),
        calendar: Calendar = .current
    ) -> Date {
        let today = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now) ?? now
        return today > now ? today : calendar.date(byAdding: .day, value: 1, to: today) ?? today
    }
}
