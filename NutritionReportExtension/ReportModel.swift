//
//  ReportModel.swift
//  NutritionReportExtension
//
//  Turns raw DeviceActivityReport data into an exact, honest snapshot.
//  Carbs and fats are classified by comparing tokens against the app-group
//  selections; "other" (protein/neutral) = total − carbs − fats.
//

import Foundation
import DeviceActivity
import FamilyControls
import ManagedSettings
import SwiftUI

// MARK: - Snapshot

struct ReportSnapshot: Hashable {
    var totalSeconds: Double = 0
    var carbSeconds: Double = 0
    var fatSeconds: Double = 0
    var pickups: Int = 0
    var firstPickup: Date?
    var lateNightSeconds: Double = 0
    var topJunkApps: [AppUsage] = []
    /// Carb seconds per day key ("yyyy-MM-dd"), for day-based grading.
    var carbSecondsByDay: [String: Double] = [:]

    var otherSeconds: Double { max(0, totalSeconds - carbSeconds - fatSeconds) }
    var carbShare: Double { totalSeconds > 0 ? carbSeconds / totalSeconds : 0 }
    var junkShare: Double { carbShare }

    var dayCount: Int { carbSecondsByDay.count }

    var averagePickupsPerDay: Double {
        dayCount > 0 ? Double(pickups) / Double(dayCount) : Double(pickups)
    }

    func daysWithinPortion(_ portionMinutes: Int) -> Int {
        guard portionMinutes > 0 else { return 0 }
        let limit = Double(portionMinutes) * 60
        return carbSecondsByDay.values.filter { $0 <= limit }.count
    }

    var isEmpty: Bool { totalSeconds == 0 && pickups == 0 }
}

/// Hook B configuration: real snapshot plus the quiz estimate fallback.
struct HookInsightContent: Hashable {
    let snapshot: ReportSnapshot
    let estimatedDailyMinutes: Int?
}

struct AppUsage: Hashable, Identifiable {
    let token: ApplicationToken?
    let name: String
    let seconds: Double

    var id: String { token.map(ShieldPending.scope(for:)) ?? name }
}

// MARK: - Computer

enum ReportComputer {

    /// Compute a snapshot for the given report data. `includeChildren` controls
    /// whether nested app rows are collected (needed for top-apps lists).
    static func compute(
        data: DeviceActivityResults<DeviceActivityData>,
        state: SharedState,
        collectApps: Bool = true
    ) async -> ReportSnapshot {
        let buckets = Buckets(state: state)
        var snapshot = ReportSnapshot()
        var junkAppUsage: [String: AppUsage] = [:]
        let calendar = Calendar.current

        for await deviceData in data {
            for await segment in deviceData.activitySegments {
                snapshot.totalSeconds += segment.totalActivityDuration
                snapshot.pickups += segment.totalPickupsWithoutApplicationActivity

                if let first = segment.firstPickup {
                    if snapshot.firstPickup == nil || first < snapshot.firstPickup! {
                        snapshot.firstPickup = first
                    }
                }

                let hour = calendar.component(.hour, from: segment.dateInterval.start)
                if hour >= 22 || hour < 6 {
                    snapshot.lateNightSeconds += segment.totalActivityDuration
                }

                for await category in segment.categories {
                    let categoryToken = category.category.token
                    let isCarbCategory = categoryToken.map(buckets.carbCategories.contains) ?? false
                    let isFatCategory = categoryToken.map(buckets.fatCategories.contains) ?? false

                    if isCarbCategory {
                        snapshot.carbSeconds += category.totalActivityDuration
                        addCarbSeconds(&snapshot, at: segment.dateInterval.start, seconds: category.totalActivityDuration)
                        if collectApps {
                            for await app in category.applications {
                                record(app, into: &junkAppUsage)
                            }
                        }
                    } else if isFatCategory {
                        snapshot.fatSeconds += category.totalActivityDuration
                    } else {
                        for await app in category.applications {
                            let activity = app
                            let token = activity.application.token
                            if token.map(buckets.carbApps.contains) ?? false {
                                snapshot.carbSeconds += activity.totalActivityDuration
                                addCarbSeconds(&snapshot, at: segment.dateInterval.start, seconds: activity.totalActivityDuration)
                                if collectApps {
                                    record(activity, into: &junkAppUsage)
                                }
                            } else if token.map(buckets.fatApps.contains) ?? false {
                                snapshot.fatSeconds += activity.totalActivityDuration
                            }
                        }
                    }
                }
            }
        }

        if collectApps {
            snapshot.topJunkApps = junkAppUsage.values
                .sorted { $0.seconds > $1.seconds }
                .prefix(5)
                .map { $0 }
        }
        return snapshot
    }

    // MARK: Helpers

    private static func addCarbSeconds(_ snapshot: inout ReportSnapshot, at date: Date, seconds: Double) {
        let key = DayCounters.dateKey(from: date)
        snapshot.carbSecondsByDay[key, default: 0] += seconds
    }

    private static func record(_ activity: DeviceActivityData.ApplicationActivity, into usage: inout [String: AppUsage]) {
        let app = activity.application
        let key = app.token.map(ShieldPending.scope(for:))
            ?? app.bundleIdentifier
            ?? app.localizedDisplayName
            ?? UUID().uuidString

        let existing = usage[key]
        usage[key] = AppUsage(
            token: app.token,
            name: app.localizedDisplayName ?? app.bundleIdentifier ?? "App",
            seconds: (existing?.seconds ?? 0) + activity.totalActivityDuration
        )
    }

    private struct Buckets {
        let carbApps: Set<ApplicationToken>
        let carbCategories: Set<ActivityCategoryToken>
        let fatApps: Set<ApplicationToken>
        let fatCategories: Set<ActivityCategoryToken>

        init(state: SharedState) {
            let carbs = state.selection(for: .carbs)
            let fats = state.selection(for: .fats)
            carbApps = carbs.applicationTokens
            carbCategories = carbs.categoryTokens
            fatApps = fats.applicationTokens
            fatCategories = fats.categoryTokens
        }
    }
}

// MARK: - Grade (computed inside the extension only)

enum NutritionGrade {
    /// score = 40·(1 − carbShare/target) + 25·(daysWithinPortion/7)
    ///       + 20·(1 − lateNightMin/120) + 15·(1 − pickups/150)
    static func calculate(snapshot: ReportSnapshot, portionMinutes: Int, windowMinutes: Int) -> String {
        let targetShare: Double = {
            guard portionMinutes > 0, windowMinutes > 0 else { return 0.2 }
            return min(0.5, Double(portionMinutes) / Double(windowMinutes))
        }()

        func clamp(_ value: Double) -> Double { min(1, max(0, value)) }

        let carbTerm = clamp(1 - snapshot.carbShare / targetShare)
        let daysTerm = clamp(Double(snapshot.daysWithinPortion(portionMinutes)) / 7.0)
        let lateTerm = clamp(1 - snapshot.lateNightSeconds / (120 * 60))
        let pickupTerm = clamp(1 - snapshot.averagePickupsPerDay / 150.0)

        let score = 40 * carbTerm + 25 * daysTerm + 20 * lateTerm + 15 * pickupTerm

        switch score {
        case 85...: return "A"
        case 70..<85: return "B"
        case 55..<70: return "C"
        case 40..<55: return "D"
        default: return "F"
        }
    }
}

// MARK: - Shared helpers

extension SharedState {
    var portionMinutesForReport: Int { profile?.portionMinutes ?? 0 }
    var windowMinutesForReport: Int { profile?.eatingWindow.durationMinutes ?? 480 }
}
