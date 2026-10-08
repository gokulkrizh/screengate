import SwiftUI

/// Plan suggestion — quiz-based, editable before activation.
struct PlanSuggestionView: View {
    @ObservedObject var data: OnboardingData
    @State private var selected: DietPlan?
    private let appTheme = AppTheme.shared

    var body: some View {
        ZStack {
            appTheme.colors.background.ignoresSafeArea()

            VStack(spacing: appTheme.spacing.large) {
                VStack(spacing: appTheme.spacing.small) {
                    Text("YOUR PRESCRIPTION")
                        .font(appTheme.fonts.labelSmall)
                        .foregroundColor(appTheme.colors.primary)
                        .tracking(1.5)

                    Text("We'd start you on \(suggested.displayName).")
                        .font(appTheme.fonts.headlineLarge)
                        .foregroundColor(appTheme.colors.text)
                        .multilineTextAlignment(.center)

                    Text("Based on your checkup. You can change plans anytime.")
                        .font(appTheme.fonts.bodyMedium)
                        .foregroundColor(appTheme.colors.textSecondary)
                }
                .padding(.top, appTheme.spacing.extraLarge)

                ScrollView {
                    VStack(spacing: appTheme.spacing.medium) {
                        ForEach(DietPlan.allCases) { plan in
                            planCard(plan)
                        }
                    }
                    .padding(.horizontal, appTheme.spacing.large)
                }

                Button(action: saveAndContinue) {
                    Text("Continue")
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
        .onAppear {
            if selected == nil {
                selected = data.suggestedPlan
            }
        }
    }

    private var suggested: DietPlan { data.suggestedPlan }

    private func planCard(_ plan: DietPlan) -> some View {
        let isSelected = selected == plan
        let isSuggested = suggested == plan

        return Button(action: { selected = plan }) {
            VStack(alignment: .leading, spacing: appTheme.spacing.small) {
                HStack {
                    Text(plan.icon)
                        .font(.system(size: 28))

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(plan.displayName)
                                .font(appTheme.fonts.titleLarge)
                                .foregroundColor(appTheme.colors.text)
                            if isSuggested {
                                Text("SUGGESTED")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(appTheme.colors.background)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(appTheme.colors.primary)
                                    .cornerRadius(4)
                            }
                        }
                        Text(plan.subtitle)
                            .font(appTheme.fonts.bodySmall)
                            .foregroundColor(appTheme.colors.textSecondary)
                    }

                    Spacer()

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? appTheme.colors.primary : appTheme.colors.secondary.opacity(0.4))
                }

                Text(plan.defaultPortionMinutes > 0
                     ? "\(plan.defaultPortionMinutes) min of carbs a day"
                     : "Carbs always blocked")
                    .font(appTheme.fonts.labelSmall)
                    .foregroundColor(appTheme.colors.textSecondary)
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

    private func saveAndContinue() {
        guard let plan = selected else { return }
        data.selectedPlan = plan
        data.dailyCarbLimitMinutes = plan.defaultPortionMinutes
        data.nextScreen()
    }
}
