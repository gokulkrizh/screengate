import SwiftUI

/// Host for the v1 NutritionReportExtension (Phase 3). Until the extension
/// lands, this screen explains where exact numbers come from.
struct NutritionReportView: View {
    private let appTheme = AppTheme.shared

    var body: some View {
        ScrollView {
            VStack(spacing: appTheme.spacing.large) {
                HStack {
                    Text("Nutrition Report")
                        .font(appTheme.fonts.headlineLarge)
                        .foregroundColor(appTheme.colors.text)
                    Spacer()
                }
                .padding(.top, appTheme.spacing.medium)

                VStack(spacing: appTheme.spacing.medium) {
                    Text("🍽️")
                        .font(.system(size: 44))
                    Text("Your Weekly Nutrition Label")
                        .font(appTheme.fonts.headlineSmall)
                        .foregroundColor(appTheme.colors.text)
                    Text("Exact usage, junk share and your weekly grade appear here once there's a full day of data to report.")
                        .font(appTheme.fonts.bodyMedium)
                        .foregroundColor(appTheme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(appTheme.spacing.large)
                .frame(maxWidth: .infinity)
                .background(appTheme.colors.surface)
                .cornerRadius(appTheme.spacing.cornerRadiusLarge)

                Text("Live numbers in the Kitchen are approximate (5-minute steps). This report reads exact data from the system.")
                    .font(appTheme.fonts.labelSmall)
                    .foregroundColor(appTheme.colors.textSecondary)
                    .multilineTextAlignment(.center)

                Spacer(minLength: 80)
            }
            .padding(.horizontal, appTheme.spacing.large)
        }
        .background(appTheme.colors.background.ignoresSafeArea())
    }
}
