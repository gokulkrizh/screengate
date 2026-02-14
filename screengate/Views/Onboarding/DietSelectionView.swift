import SwiftUI

struct DietSelectionView: View {
    @ObservedObject var data: OnboardingData
    @State private var selectedDiet: DietType?
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
                        ForEach(DietType.allCases) { diet in
                            dietCard(diet: diet)
                        }
                    }
                    .padding(.horizontal, appTheme.spacing.large)
                }

                // Continue button
                Button(action: {
                    if let diet = selectedDiet {
                        data.selectedDietType = diet
                        data.nextScreen()
                    }
                }) {
                    Text("Continue")
                        .font(appTheme.fonts.titleMedium)
                        .foregroundColor(appTheme.colors.background)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(selectedDiet != nil ? appTheme.colors.primary : appTheme.colors.secondary)
                        .cornerRadius(appTheme.spacing.cornerRadiusLarge)
                }
                .disabled(selectedDiet == nil)
                .padding(.horizontal, appTheme.spacing.large)
                .padding(.bottom, appTheme.spacing.extraLarge)
            }
        }
    }

    private func dietCard(diet: DietType) -> some View {
        let isSelected = selectedDiet == diet

        return Button(action: { selectedDiet = diet }) {
            VStack(alignment: .leading, spacing: appTheme.spacing.medium) {
                // Header row
                HStack {
                    Text(diet.icon)
                        .font(.system(size: 32))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(diet.displayName)
                            .font(appTheme.fonts.titleLarge)
                            .foregroundColor(appTheme.colors.text)
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

                // Macro ratio bar
                macroRatioBar(ratios: diet.defaultRatios)

                // Ratio text
                Text(diet.ratioSummary)
                    .font(appTheme.fonts.labelSmall)
                    .foregroundColor(appTheme.colors.textSecondary)

                // Diet details
                HStack(spacing: appTheme.spacing.medium) {
                    dietDetail(icon: "clock", text: "\(diet.defaultWindowStartHour):00-\(diet.defaultWindowEndHour):00")
                    dietDetail(icon: "timer", text: "\(diet.defaultCarbLimitMinutes)m carbs/day")
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

    private func macroRatioBar(ratios: [FoodGroup: Int]) -> some View {
        GeometryReader { geometry in
            HStack(spacing: 1) {
                let total = geometry.size.width - 3  // 3px for gaps
                ForEach(FoodGroup.allCases) { group in
                    let ratio = CGFloat(ratios[group] ?? 0) / 100.0
                    RoundedRectangle(cornerRadius: 2)
                        .fill(colorForGroup(group))
                        .frame(width: total * ratio)
                }
            }
        }
        .frame(height: 8)
    }

    private func colorForGroup(_ group: FoodGroup) -> Color {
        switch group {
        case .protein: return appTheme.colors.primary
        case .carbs: return appTheme.colors.warning
        case .fats: return Color(red: 0.6, green: 0.4, blue: 1.0)  // purple
        case .fiber: return Color(red: 0.2, green: 0.8, blue: 0.8)  // teal
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
