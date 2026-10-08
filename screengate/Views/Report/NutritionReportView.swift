import SwiftUI
import DeviceActivity

/// Host for the NutritionReportExtension: exact numbers, computed by the system
/// from real device activity. The app never reads or fabricates these values.
struct NutritionReportView: View {
    @Environment(DietManager.self) private var dietManager
    @Environment(EntitlementManager.self) private var entitlements
    private let appTheme = AppTheme.shared

    private var hasJunkSelection: Bool {
        ReportFilters.junkSelection(state: dietManager.sharedState).hasAnyTokens
    }

    var body: some View {
        ScrollView {
            VStack(spacing: appTheme.spacing.large) {
                // Header
                HStack {
                    Text("Nutrition Report")
                        .font(appTheme.fonts.headlineLarge)
                        .foregroundColor(appTheme.colors.text)
                    Spacer()
                }
                .padding(.top, appTheme.spacing.medium)

                if !entitlements.isPremium {
                    lockedReport
                } else if hasJunkSelection {
                    DeviceActivityReport(
                        DeviceActivityReport.Context(ReportContexts.nutritionLabel),
                        filter: ReportFilters.lastSevenDays(state: dietManager.sharedState)
                    )
                    .frame(height: 560)

                    DeviceActivityReport(
                        DeviceActivityReport.Context(ReportContexts.weeklyGrade),
                        filter: ReportFilters.currentWeek(state: dietManager.sharedState)
                    )
                    .frame(height: 150)

                    Text("Exact numbers come straight from the system — no estimates here.")
                        .font(appTheme.fonts.labelSmall)
                        .foregroundColor(appTheme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                } else {
                    VStack(spacing: appTheme.spacing.medium) {
                        Text("🍽️")
                            .font(.system(size: 44))
                        Text("No Food Groups Yet")
                            .font(appTheme.fonts.headlineSmall)
                            .foregroundColor(appTheme.colors.text)
                        Text("Assign apps to Carbs and Fats in your Pantry and your weekly label will appear here.")
                            .font(appTheme.fonts.bodyMedium)
                            .foregroundColor(appTheme.colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(appTheme.spacing.large)
                    .frame(maxWidth: .infinity)
                    .background(appTheme.colors.surface)
                    .cornerRadius(appTheme.spacing.cornerRadiusLarge)
                }

                Spacer(minLength: 80)
            }
            .padding(.horizontal, appTheme.spacing.large)
        }
        .background(appTheme.colors.background.ignoresSafeArea())
    }

    private var lockedReport: some View {
        VStack(spacing: appTheme.spacing.medium) {
            Text("🔒")
                .font(.system(size: 44))
            Text("Your Weekly Nutrition Label")
                .font(appTheme.fonts.headlineSmall)
                .foregroundColor(appTheme.colors.text)
            Text("Exact usage, junk share and your weekly grade — unlocked with Premium.")
                .font(appTheme.fonts.bodyMedium)
                .foregroundColor(appTheme.colors.textSecondary)
                .multilineTextAlignment(.center)

            Button("Unlock the full report") {
                entitlements.presentPaywall(.weeklyReport)
            }
            .font(appTheme.fonts.titleSmall)
            .foregroundColor(appTheme.colors.background)
            .padding(.horizontal, appTheme.spacing.large)
            .padding(.vertical, appTheme.spacing.medium)
            .background(appTheme.colors.primary)
            .cornerRadius(appTheme.spacing.cornerRadiusMedium)
        }
        .padding(appTheme.spacing.large)
        .frame(maxWidth: .infinity)
        .background(appTheme.colors.surface)
        .cornerRadius(appTheme.spacing.cornerRadiusLarge)
    }
}
