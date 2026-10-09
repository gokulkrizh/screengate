import Foundation
import DeviceActivity
import FamilyControls

/// Builds the `DeviceActivityFilter`s the app hands to `DeviceActivityReport`.
/// The report receives whole-device activity; only the extension classifies
/// tokens into carbs / fats / other. No activity data is sent back to the app.
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
        let start = Calendar.current.date(byAdding: .day, value: -6, to: Calendar.current.startOfDay(for: end)) ?? end
        return makeFilter(
            segment: .hourly(during: DateInterval(start: start, end: end)),
            state: state
        )
    }

    /// The current calendar week, day by day (weekly grade).
    static func currentWeek(state: SharedState) -> DeviceActivityFilter {
        let interval = Calendar.current.dateInterval(of: .weekOfYear, for: Date())
            ?? DateInterval(start: Date(), duration: 0)
        return makeFilter(segment: .hourly(during: DateInterval(start: interval.start, end: Date())), state: state)
    }

    private static func makeFilter(
        segment: DeviceActivityFilter.SegmentInterval,
        state: SharedState
    ) -> DeviceActivityFilter {
        // Unfiltered activity is required for an honest whole-device split.
        // Tokens are classified only inside the report extension.
        // Apple: https://developer.apple.com/documentation/deviceactivity/deviceactivityfilter/init(segment:devices:applications:categories:webdomains:)
        return DeviceActivityFilter(segment: segment)
    }
}
