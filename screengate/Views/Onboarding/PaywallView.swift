import SwiftUI

/// Paywall step (onboarding #11).
///
/// Phase 5 replaces this stub with the Superwall `onboarding_complete` placement
/// and StoreKit entitlement sync. Until then, both paths continue onboarding and
/// the app runs on the free tier rules.
struct PaywallView: View {
    @ObservedObject var data: OnboardingData
    private let appTheme = AppTheme.shared

    var body: some View {
        ZStack {
            appTheme.colors.background.ignoresSafeArea()

            VStack(spacing: appTheme.spacing.large) {
                Spacer()

                Text("🥑")
                    .font(.system(size: 56))

                VStack(spacing: appTheme.spacing.small) {
                    Text("SCREENDIET PREMIUM")
                        .font(appTheme.fonts.labelSmall)
                        .foregroundColor(appTheme.colors.primary)
                        .tracking(1.5)
                    Text("The full nutritionist.")
                        .font(appTheme.fonts.headlineLarge)
                        .foregroundColor(appTheme.colors.text)
                }

                VStack(alignment: .leading, spacing: appTheme.spacing.medium) {
                    feature("moon.zzz.fill", "Night Fast", "Carbs and social apps sleep on schedule")
                    feature("chart.bar.fill", "Full Nutrition Label", "Exact weekly numbers + top junk apps")
                    feature("target", "All plans", "Lean, Keto, Detox and custom rules")
                    feature("ticket.fill", "More cheat meals", "Up to 7 a week instead of 1")
                }
                .padding(appTheme.spacing.large)
                .background(appTheme.colors.surface)
                .cornerRadius(appTheme.spacing.cornerRadiusLarge)
                .padding(.horizontal, appTheme.spacing.large)

                Spacer()

                VStack(spacing: appTheme.spacing.medium) {
                    Button(action: {
                        // TODO(Phase 5): Superwall.shared.register(placement: "onboarding_complete")
                        data.nextScreen()
                    }) {
                        Text("Start 7-day free trial")
                            .font(appTheme.fonts.titleMedium)
                            .foregroundColor(appTheme.colors.background)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(appTheme.colors.primary)
                            .cornerRadius(appTheme.spacing.cornerRadiusLarge)
                    }

                    Button("Continue with Free") {
                        data.nextScreen()
                    }
                    .font(appTheme.fonts.bodyMedium)
                    .foregroundColor(appTheme.colors.textSecondary)
                }
                .padding(.horizontal, appTheme.spacing.large)
                .padding(.bottom, appTheme.spacing.extraLarge)
            }
        }
    }

    private func feature(_ icon: String, _ title: String, _ subtitle: String) -> some View {
        HStack(spacing: appTheme.spacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(appTheme.colors.primary)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(appTheme.fonts.titleSmall)
                    .foregroundColor(appTheme.colors.text)
                Text(subtitle)
                    .font(appTheme.fonts.bodySmall)
                    .foregroundColor(appTheme.colors.textSecondary)
            }
            Spacer()
        }
    }
}
