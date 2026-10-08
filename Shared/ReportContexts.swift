import Foundation

// MARK: - DeviceActivityReport contexts

/// Raw context names shared by the app (which renders `DeviceActivityReport`)
/// and the NutritionReportExtension (which provides a scene per context).
enum ReportContexts {
    /// Onboarding hook: last 7 days total + junk share + yearly projection.
    static let hookInsight = "hookInsight"
    /// Kitchen tab card: today's split, pickups, first pickup.
    static let today = "today"
    /// Report tab: weekly split %, top junk apps, late-night minutes, pickups/day.
    static let nutritionLabel = "nutritionLabel"
    /// Report tab + Sunday screen: A–F weekly grade.
    static let weeklyGrade = "weeklyGrade"
}
