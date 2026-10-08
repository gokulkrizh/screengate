import SwiftUI
import DeviceActivity

/// Hook B — the first real insight, computed by the report extension from the
/// last 7 days. Falls back to the quiz estimate on a new phone (< 1h of data).
struct HookBView: View {
    @ObservedObject var data: OnboardingData
    @Environment(DietManager.self) private var dietManager
    private let appTheme = AppTheme.shared

    private var hasCarbs: Bool {
        dietManager.foodGroupSelections[.carbs]?.hasAnyTokens == true
    }

    var body: some View {
        VStack(spacing: appTheme.spacing.large) {
            Spacer(minLength: appTheme.spacing.large)

            VStack(spacing: appTheme.spacing.small) {
                Text("FIRST INSIGHT")
                    .font(appTheme.fonts.labelSmall)
                    .foregroundColor(appTheme.colors.primary)
                    .tracking(1.5)
                Text("Your last 7 days,\nstraight from the system.")
                    .font(appTheme.fonts.headlineLarge)
                    .foregroundColor(appTheme.colors.text)
                    .multilineTextAlignment(.center)
            }

            if hasCarbs {
                DeviceActivityReport(
                    DeviceActivityReport.Context(ReportContexts.hookInsight),
                    filter: ReportFilters.lastSevenDays(state: dietManager.sharedState)
                )
                .frame(height: 270)
            } else {
                Text("Pick your junk apps first and this fills in.")
                    .font(appTheme.fonts.bodyMedium)
                    .foregroundColor(appTheme.colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(appTheme.spacing.large)
            }

            Text("No estimates — this is exactly what the system measured.")
                .font(appTheme.fonts.labelSmall)
                .foregroundColor(appTheme.colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, appTheme.spacing.medium)

            Spacer()

            Button(action: { data.nextScreen() }) {
                Text("That's a lot")
                    .font(appTheme.fonts.titleMedium)
                    .foregroundColor(appTheme.colors.background)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(appTheme.colors.primary)
                    .cornerRadius(appTheme.spacing.cornerRadiusLarge)
            }
            .padding(.horizontal, appTheme.spacing.large)
            .padding(.bottom, appTheme.spacing.extraLarge)
        }
    }
}
