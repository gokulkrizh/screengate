import XCTest

/// First tests in the project: pure DietRules behavior.
final class DietRulesTests: XCTestCase {

    private let calendar = Calendar.current

    // MARK: - Helpers

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }

    private func activeProfile(
        window: (Int, Int, Int, Int) = (12, 0, 20, 0),
        night: (Int, Int, Int, Int) = (21, 0, 12, 0),
        portion: Int = 45,
        plan: DietPlan = .lean
    ) -> DietProfile {
        var profile = DietProfile.create(plan: plan)
        profile.eatingWindow = EatingWindow(startHour: window.0, startMinute: window.1, endHour: window.2, endMinute: window.3)
        profile.nightFast = NightFast(isEnabled: true, startHour: night.0, startMinute: night.1, endHour: night.2, endMinute: night.3)
        profile.portionMinutes = portion
        profile.isActive = true
        return profile
    }

    private func counters(portionHit: Bool = false, carbMinutes: Int = 0) -> DayCounters {
        DayCounters(dateKey: "2026-01-15", carbMinutes: carbMinutes, cheatsUsedToday: 0, portionHit: portionHit)
    }

    // MARK: - Clock normalization

    /// Older builds of the window dial could save midnight as 24:00, which made
    /// `Calendar.date(bySettingHour:)` return nil and crashed notification scheduling.
    func testNormalizingClockFoldsHour24ToMidnight() {
        let profile = activeProfile(window: (11, 30, 24, 0), night: (24, 0, 11, 30)).normalizingClock()
        XCTAssertEqual(profile.eatingWindow.startHour, 11)
        XCTAssertEqual(profile.eatingWindow.endHour, 0)
        XCTAssertEqual(profile.nightFast.startHour, 0)
        XCTAssertEqual(profile.nightFast.endHour, 11)
    }

    // MARK: - Thresholds

    func testPortionStep() {
        XCTAssertEqual(DietRules.portionStep(portionMinutes: 6), 5)
        XCTAssertEqual(DietRules.portionStep(portionMinutes: 45), 5)
        XCTAssertEqual(DietRules.portionStep(portionMinutes: 60), 5)
        XCTAssertEqual(DietRules.portionStep(portionMinutes: 90), 8)
        XCTAssertEqual(DietRules.portionStep(portionMinutes: 120), 10)
    }

    func testThresholdsIncludeExactPortionAndStayWithinBudget() {
        for portion in [6, 45, 90, 120] {
            let thresholds = DietRules.thresholdMinutes(portionMinutes: portion)
            XCTAssertLessThanOrEqual(thresholds.count, 20, "portion \(portion) exceeded the 20-event budget")
            XCTAssertTrue(thresholds.contains(portion), "portion \(portion) must fire an exact threshold")
            XCTAssertEqual(thresholds, thresholds.sorted(), "thresholds must be ascending")
        }
    }

    func testDetoxHasNoThresholds() {
        XCTAssertTrue(DietRules.thresholdMinutes(portionMinutes: 0).isEmpty)
    }

    // MARK: - State precedence

    func testWindowOpenState() {
        let profile = activeProfile()
        let now = date(2026, 1, 15, 14)
        XCTAssertEqual(
            DietRules.state(at: now, profile: profile, counters: counters(), fast: nil, cheat: nil),
            .windowOpen
        )
    }

    func testPortionHitState() {
        let profile = activeProfile()
        XCTAssertEqual(
            DietRules.state(at: date(2026, 1, 15, 14), profile: profile, counters: counters(portionHit: true, carbMinutes: 45), fast: nil, cheat: nil),
            .portionHit
        )
    }

    func testNightFastBeatsPortionHit() {
        let profile = activeProfile()
        XCTAssertEqual(
            DietRules.state(at: date(2026, 1, 15, 23), profile: profile, counters: counters(portionHit: true), fast: nil, cheat: nil),
            .nightFast
        )
    }

    func testFastNowBeatsNightFast() {
        let profile = activeProfile()
        let now = date(2026, 1, 15, 23)
        let fast = FastSession(startedAt: date(2026, 1, 15, 22), endsAt: date(2026, 1, 16, 1), source: .button)
        XCTAssertEqual(
            DietRules.state(at: now, profile: profile, counters: counters(), fast: fast, cheat: nil),
            .fastNow
        )
    }

    func testFastingState() {
        // 20:30: window closed (ends 20:00) and night fast not started yet (21:00).
        let profile = activeProfile()
        XCTAssertEqual(
            DietRules.state(at: date(2026, 1, 15, 20, 30), profile: profile, counters: counters(), fast: nil, cheat: nil),
            .fasting
        )
    }

    // MARK: - Store plans

    func testStorePlanOpenWindow() {
        let plan = DietRules.storePlan(
            at: date(2026, 1, 15, 14),
            profile: activeProfile(),
            counters: counters(),
            cheat: nil,
            fast: nil
        )
        XCTAssertFalse(plan.carbsBlocked)
        XCTAssertFalse(plan.nightBlocked)
        XCTAssertFalse(plan.fastBlocked)
    }

    func testStorePlanPortionHitBlocksCarbsOnly() {
        let plan = DietRules.storePlan(
            at: date(2026, 1, 15, 14),
            profile: activeProfile(),
            counters: counters(portionHit: true),
            cheat: nil,
            fast: nil
        )
        XCTAssertTrue(plan.carbsBlocked)
        XCTAssertFalse(plan.nightBlocked)
        XCTAssertFalse(plan.fastBlocked)
    }

    func testCheatLiftsCarbsButNotNightFast() {
        let now = date(2026, 1, 15, 23)
        let cheat = CheatSession(startedAt: date(2026, 1, 15, 22, 55), endsAt: date(2026, 1, 15, 23, 30), source: .shield)
        let plan = DietRules.storePlan(
            at: now,
            profile: activeProfile(),
            counters: counters(portionHit: true),
            cheat: cheat,
            fast: nil
        )
        XCTAssertFalse(plan.carbsBlocked, "cheat must lift the carbs block")
        XCTAssertTrue(plan.nightBlocked, "night fast must still stack during a cheat")
    }

    func testDetoxBlocksCarbsAlways() {
        let profile = activeProfile(portion: 0, plan: .detox)
        let plan = DietRules.storePlan(
            at: date(2026, 1, 15, 14),
            profile: profile,
            counters: counters(),
            cheat: nil,
            fast: nil
        )
        XCTAssertTrue(plan.carbsBlocked)
    }

    // MARK: - Validation

    func testValidationRejectsShortWindow() {
        var profile = activeProfile(window: (12, 0, 12, 10))
        profile.nightFast.isEnabled = false
        XCTAssertFalse(DietRules.validate(profile).isEmpty)
    }

    func testValidationRejectsOverlappingWindowAndNightFast() {
        var profile = activeProfile(window: (12, 0, 22, 0), night: (21, 0, 12, 0))
        profile.nightFast.isEnabled = true
        XCTAssertTrue(DietRules.validate(profile).contains { $0.contains("overlap") })
    }

    func testValidationAcceptsStandardProfile() {
        XCTAssertTrue(DietRules.validate(activeProfile()).isEmpty)
    }

    func testValidationAcceptsDetox() {
        var profile = DietProfile.create(plan: .detox)
        profile.portionMinutes = 0
        XCTAssertTrue(DietRules.validate(profile).isEmpty)
    }

    // MARK: - Rollover

    func testRolloverResetsCountersAndUpdatesStreak() {
        var state = SharedState.empty(date(2026, 1, 14, 20))
        state.profile = activeProfile()
        state.streak = 3
        state.counters = DayCounters(dateKey: "2026-01-14", carbMinutes: 45, cheatsUsedToday: 1, portionHit: true)

        DietRules.rolloverIfNeeded(&state, at: date(2026, 1, 15, 0, 5))

        XCTAssertEqual(state.counters.carbMinutes, 0)
        XCTAssertFalse(state.counters.portionHit)
        XCTAssertEqual(state.streak, 0, "a portion-hit day breaks the streak")
        XCTAssertEqual(state.week.daysOverPortion, 1)
        XCTAssertEqual(state.counters.cheatsUsedToday, 0)
    }

    func testRolloverWithinPortionKeepsStreak() {
        var state = SharedState.empty(date(2026, 1, 14, 20))
        state.profile = activeProfile()
        state.streak = 3
        state.counters = DayCounters(dateKey: "2026-01-14", carbMinutes: 20, cheatsUsedToday: 0, portionHit: false)

        DietRules.rolloverIfNeeded(&state, at: date(2026, 1, 15, 0, 5))

        XCTAssertEqual(state.streak, 4)
        XCTAssertEqual(state.week.daysOverPortion, 0)
    }

    func testRolloverIsIdempotentWithinTheSameDay() {
        var state = SharedState.empty(date(2026, 1, 15, 10))
        state.profile = activeProfile()
        state.streak = 1

        DietRules.rolloverIfNeeded(&state, at: date(2026, 1, 15, 11))
        XCTAssertEqual(state.streak, 1, "same-day calls must not touch the streak")
    }
}
