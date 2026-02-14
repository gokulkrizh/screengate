import Foundation

// MARK: - Nutrition Log

/// Daily nutrition tracking for a single day
struct NutritionLog: Codable, Identifiable {
    var id: String { dateKey }
    var dateKey: String  // "yyyy-MM-dd" format for keying
    var date: Date
    var proteinMinutes: Int
    var carbsMinutes: Int
    var fatsMinutes: Int
    var fiberMinutes: Int
    var cheatsUsed: Int

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    /// Total tracked screen time in minutes
    var totalMinutes: Int {
        proteinMinutes + carbsMinutes + fatsMinutes + fiberMinutes
    }

    /// Macro percentages based on actual usage
    var proteinPercentage: Double {
        guard totalMinutes > 0 else { return 0 }
        return Double(proteinMinutes) / Double(totalMinutes) * 100
    }

    var carbsPercentage: Double {
        guard totalMinutes > 0 else { return 0 }
        return Double(carbsMinutes) / Double(totalMinutes) * 100
    }

    var fatsPercentage: Double {
        guard totalMinutes > 0 else { return 0 }
        return Double(fatsMinutes) / Double(totalMinutes) * 100
    }

    var fiberPercentage: Double {
        guard totalMinutes > 0 else { return 0 }
        return Double(fiberMinutes) / Double(totalMinutes) * 100
    }

    func minutes(for group: FoodGroup) -> Int {
        switch group {
        case .protein: return proteinMinutes
        case .carbs: return carbsMinutes
        case .fats: return fatsMinutes
        case .fiber: return fiberMinutes
        }
    }

    func percentage(for group: FoodGroup) -> Double {
        switch group {
        case .protein: return proteinPercentage
        case .carbs: return carbsPercentage
        case .fats: return fatsPercentage
        case .fiber: return fiberPercentage
        }
    }

    static func today() -> NutritionLog {
        let now = Date()
        return NutritionLog(
            dateKey: dateFormatter.string(from: now),
            date: now,
            proteinMinutes: 0,
            carbsMinutes: 0,
            fatsMinutes: 0,
            fiberMinutes: 0,
            cheatsUsed: 0
        )
    }

    static func dateKey(from date: Date) -> String {
        dateFormatter.string(from: date)
    }
}

// MARK: - Weekly Nutrition Summary

/// Aggregated nutrition data for a week
struct WeeklyNutritionSummary: Codable {
    var weekNumber: Int
    var startDate: Date
    var endDate: Date
    var dailyLogs: [NutritionLog]
    var metabolicGrade: String  // A+, A, B+, B, C+, C, D+, D, F

    var totalProteinMinutes: Int {
        dailyLogs.reduce(0) { $0 + $1.proteinMinutes }
    }

    var totalCarbsMinutes: Int {
        dailyLogs.reduce(0) { $0 + $1.carbsMinutes }
    }

    var totalFatsMinutes: Int {
        dailyLogs.reduce(0) { $0 + $1.fatsMinutes }
    }

    var totalFiberMinutes: Int {
        dailyLogs.reduce(0) { $0 + $1.fiberMinutes }
    }

    var totalMinutes: Int {
        dailyLogs.reduce(0) { $0 + $1.totalMinutes }
    }

    var totalHours: Double {
        Double(totalMinutes) / 60.0
    }

    var totalCheatsUsed: Int {
        dailyLogs.reduce(0) { $0 + $1.cheatsUsed }
    }

    var averageDailyMinutes: Int {
        guard !dailyLogs.isEmpty else { return 0 }
        return totalMinutes / dailyLogs.count
    }

    func overallPercentage(for group: FoodGroup) -> Double {
        guard totalMinutes > 0 else { return 0 }
        let groupTotal: Int
        switch group {
        case .protein: groupTotal = totalProteinMinutes
        case .carbs: groupTotal = totalCarbsMinutes
        case .fats: groupTotal = totalFatsMinutes
        case .fiber: groupTotal = totalFiberMinutes
        }
        return Double(groupTotal) / Double(totalMinutes) * 100
    }
}

// MARK: - Metabolic Score Calculator

struct MetabolicScoreCalculator {
    /// Calculate metabolic grade based on adherence to diet ratios
    static func calculate(actual: [FoodGroup: Double], target: [FoodGroup: Int]) -> String {
        var totalDeviation: Double = 0
        for group in FoodGroup.allCases {
            let actualPct = actual[group] ?? 0
            let targetPct = Double(target[group] ?? 0)
            totalDeviation += abs(actualPct - targetPct)
        }

        // Lower deviation = better grade
        switch totalDeviation {
        case 0..<10: return "A+"
        case 10..<20: return "A"
        case 20..<30: return "B+"
        case 30..<45: return "B"
        case 45..<60: return "C+"
        case 60..<75: return "C"
        case 75..<90: return "D+"
        case 90..<110: return "D"
        default: return "F"
        }
    }
}
