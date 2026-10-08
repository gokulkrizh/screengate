import Foundation

// MARK: - Nutrition Log

/// App-side, approximate daily counters. Exact numbers come from the
/// NutritionReportExtension; these values are only used for live UI hints.
struct NutritionLog: Codable, Identifiable {
    var id: String { dateKey }
    var dateKey: String      // "yyyy-MM-dd"
    var carbsMinutes: Int    // approximate (5-min threshold steps)
    var cheatsUsed: Int
    var portionHit: Bool

    init(dateKey: String, carbsMinutes: Int, cheatsUsed: Int, portionHit: Bool) {
        self.dateKey = dateKey
        self.carbsMinutes = carbsMinutes
        self.cheatsUsed = cheatsUsed
        self.portionHit = portionHit
    }

    init(counters: DayCounters) {
        self.dateKey = counters.dateKey
        self.carbsMinutes = counters.carbMinutes
        self.cheatsUsed = counters.cheatsUsedToday
        self.portionHit = counters.portionHit
    }

    static func today(_ date: Date = Date()) -> NutritionLog {
        NutritionLog(counters: .today(date))
    }
}
