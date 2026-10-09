import XCTest

final class EatingWindowTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }
    private func date(_ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: 9, hour: hour, minute: minute))!
    }
    private let window = EatingWindow(startHour: 12, startMinute: 0, endHour: 20, endMinute: 0)
    func testNextOpeningBeforeTodaysWindow() {
        XCTAssertEqual(window.minutesUntilNextOpen(at: date(10), calendar: calendar), 120)
    }
    func testNextOpeningDuringOpenWindowIsTomorrow() {
        XCTAssertEqual(window.minutesUntilNextOpen(at: date(14), calendar: calendar), 22 * 60)
    }
    func testNextOpeningAtOpeningTimeIsTomorrow() {
        XCTAssertEqual(window.minutesUntilNextOpen(at: date(12), calendar: calendar), 1440)
    }
    func testNextOpeningAfterMidnightHandlesOvernightWindow() {
        let overnight = EatingWindow(startHour: 22, startMinute: 0, endHour: 2, endMinute: 0)
        XCTAssertEqual(overnight.minutesUntilNextOpen(at: date(1), calendar: calendar), 21 * 60)
    }
}
