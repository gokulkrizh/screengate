import Foundation
import DeviceActivity
import FamilyControls

/// Builds the `DeviceActivityFilter`s the app hands to `DeviceActivityReport`.
/// The filters cover the union of the carbs and fats selections; the report
/// extension classifies the rows back into carbs / fats / other.
enum ReportFilters {

    static func junkSelection(state: SharedState) -> FamilyActivitySelection {
        DeviceActivityManager.union(state.selection(for: .carbs), state.selection(for: .fats))
    }

    /// Today, hour by hour (Kitchen card).
    static func today(state: SharedState) -> DeviceActivityFilter {
        let start = Calendar.current.startOfDay(for: Date())
        return makeFilter(
            segment: .hourly(during: DateInterval(start: start, end: Date())),
            state: state
        )
    }

    /// Rolling 7 days, hour by hour (Nutrition Label + hook insight).
    static func lastSevenDays(state: SharedState) -> DeviceActivityFilter {
        let end = Date()
        let start = Calendar.current.date(byAdding: .day, value: -7, to: end) ?? end
        return makeFilter(
            segment: .hourly(during: DateInterval(start: start, end: end)),
            state: state
        )
    }

    /// The current calendar week, day by day (weekly grade).
    static func currentWeek(state: SharedState) -> DeviceActivityFilter {
        let interval = Calendar.current.dateInterval(of: .weekOfYear, for: Date())
            ?? DateInterval(start: Date(), duration: 0)
        return makeFilter(segment: .daily(during: interval), state: state)
    }

    private static func makeFilter(
        segment: DeviceActivityFilter.SegmentInterval,
        state: SharedState
    ) -> DeviceActivityFilter {
        let junk = junkSelection(state: state)
        return DeviceActivityFilter(
            segment: segment,
            applications: junk.applicationTokens,
            categories: junk.categoryTokens,
            webDomains: junk.webDomainTokens
        )
    }
}
