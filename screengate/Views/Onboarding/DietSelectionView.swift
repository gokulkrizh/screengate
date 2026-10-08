import SwiftUI

struct DietSelectionView: View {
    @ObservedObject var data: OnboardingData
    @State private var selectedPlan: DietPlan?
    private let appTheme = AppTheme.shared

    var body: some View {
        ZStack {
            appTheme.colors.background.ignoresSafeArea()

            VStack(spacing: appTheme.spacing.large) {
                // Header
                VStack(spacing: appTheme.spacing.small) {
                    Text("Choose Your Diet")
                        .font(appTheme.fonts.headlineLarge)
                        .foregroundColor(appTheme.colors.text)

                    Text("Select a digital diet plan that fits your lifestyle. You can adjust it anytime.")
                        .font(appTheme.fonts.bodyLarge)
                        .foregroundColor(appTheme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, appTheme.spacing.extraLarge)
                .padding(.horizontal, appTheme.spacing.large)

                // Diet cards
                ScrollView {
                    VStack(spacing: appTheme.spacing.medium) {
                        ForEach(DietPlan.allCases) { diet in
                            dietCard(diet: diet)
                        }
                    }
                    .padding(.horizontal, appTheme.spacing.large)
                }

                // Continue button
                Button(action: {
                    if let diet = selectedPlan {
                        data.selectedPlan = diet
                        data.nextScreen()
                    }
                }) {
                    Text("Continue")
                        .font(appTheme.fonts.titleMedium)
                        .foregroundColor(appTheme.colors.background)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(selectedPlan != nil ? appTheme.colors.primary : appTheme.colors.secondary)
                        .cornerRadius(appTheme.spacing.cornerRadiusLarge)
                }
                .disabled(selectedPlan == nil)
                .padding(.horizontal, appTheme.spacing.large)
                .padding(.bottom, appTheme.spacing.extraLarge)
            }
        }
    }

    private func dietCard(diet: DietPlan) -> some View {
        let isSelected = selectedPlan == diet

        return Button(action: { selectedPlan = diet }) {
            VStack(alignment: .leading, spacing: appTheme.spacing.medium) {
                // Header row
                HStack {
                    Text(diet.icon)
                        .font(.system(size: 32))

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(diet.displayName)
                                .font(appTheme.fonts.titleLarge)
                                .foregroundColor(appTheme.colors.text)

                            if diet.isPremium {
                                Text("PREMIUM")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(appTheme.colors.primary)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(appTheme.colors.primary.opacity(0.15))
                                    .cornerRadius(4)
                            }
                        }
                        Text(diet.subtitle)
                            .font(appTheme.fonts.bodySmall)
                            .foregroundColor(appTheme.colors.textSecondary)
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(appTheme.colors.primary)
                    } else {
                        Circle()
                            .stroke(appTheme.colors.secondary.opacity(0.3), lineWidth: 2)
                            .frame(width: 24, height: 24)
                    }
                }

                // Diet details
                HStack(spacing: appTheme.spacing.medium) {
                    dietDetail(icon: "clock", text: "\(diet.defaultWindowStartHour):00-\(diet.defaultWindowEndHour):00")
                    if diet.defaultPortionMinutes > 0 {
                        dietDetail(icon: "timer", text: "\(diet.defaultPortionMinutes)m carbs/day")
                    } else {
                        dietDetail(icon: "nosign", text: "Carbs always blocked")
                    }
                }
            }
            .padding(appTheme.spacing.medium)
            .background(appTheme.colors.surface)
            .cornerRadius(appTheme.spacing.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: appTheme.spacing.cornerRadiusMedium)
                    .stroke(isSelected ? appTheme.colors.primary : Color.clear, lineWidth: 2)
            )
        }
    }

    private func dietDetail(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(appTheme.colors.textSecondary)
            Text(text)
                .font(appTheme.fonts.labelSmall)
                .foregroundColor(appTheme.colors.textSecondary)
        }
    }
}
