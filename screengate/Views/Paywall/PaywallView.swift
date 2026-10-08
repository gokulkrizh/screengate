import SwiftUI

/// The premium offer. Used as onboarding step #11 and as a sheet for feature
/// placements. Phase 5 keeps local UI + entitlement plumbing; Superwall takes
/// over the presentation once the API key and products exist.
struct PaywallView: View {
    var placement: PaywallPlacement = .onboardingComplete
    var onFinished: () -> Void

    @Environment(EntitlementManager.self) private var entitlements
    @State private var purchaseFailed = false
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
                    Button(action: purchase) {
                        VStack(spacing: 2) {
                            Text("Start 7-day free trial")
                                .font(appTheme.fonts.titleMedium)
                            Text("then $29.99/year")
                                .font(appTheme.fonts.labelSmall)
                                .opacity(0.8)
                        }
                        .foregroundColor(appTheme.colors.background)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(appTheme.colors.primary)
                        .cornerRadius(appTheme.spacing.cornerRadiusLarge)
                    }

                    Button("Continue with Free") {
                        onFinished()
                    }
                    .font(appTheme.fonts.bodyMedium)
                    .foregroundColor(appTheme.colors.textSecondary)
                }
                .padding(.horizontal, appTheme.spacing.large)
                .padding(.bottom, appTheme.spacing.extraLarge)
            }
        }
        .alert("Purchases are being set up", isPresented: $purchaseFailed) {
            Button("Continue with Free") { onFinished() }
            Button("OK", role: .cancel) { }
        } message: {
            Text("In-app purchases aren't live yet. You can keep using ScreenDiet on the free plan.")
        }
    }

    private func purchase() {
        Task {
            let succeeded = await entitlements.purchase("screendiet.premium.yearly")
            if succeeded {
                onFinished()
            } else {
                purchaseFailed = true
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
