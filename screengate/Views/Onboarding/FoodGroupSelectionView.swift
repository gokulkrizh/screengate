import SwiftUI
import FamilyControls

struct FoodGroupSelectionView: View {
    @ObservedObject var data: OnboardingData
    @Environment(DietManager.self) private var dietManager
    @State private var proteinSelection = FamilyActivitySelection()
    @State private var carbsSelection = FamilyActivitySelection()
    @State private var fatsSelection = FamilyActivitySelection()
    @State private var activePickerGroup: FoodGroup?
    private let appTheme = AppTheme.shared

    var body: some View {
        ZStack {
            appTheme.colors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: appTheme.spacing.large) {
                    // Header
                    VStack(spacing: appTheme.spacing.small) {
                        Text("Stock Your Pantry")
                            .font(appTheme.fonts.headlineLarge)
                            .foregroundColor(appTheme.colors.text)

                        Text("Assign your apps to food groups. This determines how Screendiet manages your digital nutrition.")
                            .font(appTheme.fonts.bodyLarge)
                            .foregroundColor(appTheme.colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, appTheme.spacing.extraLarge)
                    .padding(.horizontal, appTheme.spacing.large)

                    // Food group cards
                    VStack(spacing: appTheme.spacing.medium) {
                        foodGroupCard(
                            group: .protein,
                            selection: $proteinSelection,
                            count: proteinSelection.applicationTokens.count + proteinSelection.categoryTokens.count
                        )
                        foodGroupCard(
                            group: .carbs,
                            selection: $carbsSelection,
                            count: carbsSelection.applicationTokens.count + carbsSelection.categoryTokens.count
                        )
                        foodGroupCard(
                            group: .fats,
                            selection: $fatsSelection,
                            count: fatsSelection.applicationTokens.count + fatsSelection.categoryTokens.count
                        )
                    }
                    .padding(.horizontal, appTheme.spacing.large)

                    // Continue button
                    Button(action: saveAndContinue) {
                        Text("Continue")
                            .font(appTheme.fonts.titleMedium)
                            .foregroundColor(appTheme.colors.background)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(hasMinimumSelections ? appTheme.colors.primary : appTheme.colors.secondary)
                            .cornerRadius(appTheme.spacing.cornerRadiusLarge)
                    }
                    .disabled(!hasMinimumSelections)
                    .padding(.horizontal, appTheme.spacing.large)
                    .padding(.bottom, appTheme.spacing.extraLarge)
                }
            }
        }
        .familyActivityPicker(
            isPresented: Binding(
                get: { activePickerGroup != nil },
                set: { if !$0 { activePickerGroup = nil } }
            ),
            selection: activePickerBinding
        )
        .onAppear {
            loadExistingSelections()
        }
    }

    private var hasMinimumSelections: Bool {
        // Require at least carbs to be assigned
        carbsSelection.applicationTokens.count + carbsSelection.categoryTokens.count > 0
    }

    private var activePickerBinding: Binding<FamilyActivitySelection> {
        Binding(
            get: {
                switch activePickerGroup {
                case .protein: return proteinSelection
                case .carbs: return carbsSelection
                case .fats: return fatsSelection
                case nil: return FamilyActivitySelection()
                }
            },
            set: { newValue in
                switch activePickerGroup {
                case .protein: proteinSelection = newValue
                case .carbs: carbsSelection = newValue
                case .fats: fatsSelection = newValue
                case nil: break
                }
            }
        )
    }

    private func foodGroupCard(group: FoodGroup, selection: Binding<FamilyActivitySelection>, count: Int) -> some View {
        Button(action: { activePickerGroup = group }) {
            HStack(spacing: appTheme.spacing.medium) {
                // Emoji + icon
                VStack(spacing: 4) {
                    Text(group.emoji)
                        .font(.system(size: 28))
                    Image(systemName: group.icon)
                        .font(.system(size: 12))
                        .foregroundColor(appTheme.colors.primary)
                }
                .frame(width: 50)

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(group.displayName)
                            .font(appTheme.fonts.titleMedium)
                            .foregroundColor(appTheme.colors.text)

                        if group.isUnlimited {
                            Text("UNLIMITED")
                                .font(appTheme.fonts.labelSmall)
                                .foregroundColor(appTheme.colors.primary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(appTheme.colors.primary.opacity(0.15))
                                .cornerRadius(4)
                        }
                    }

                    Text(group.subtitle)
                        .font(appTheme.fonts.bodySmall)
                        .foregroundColor(appTheme.colors.textSecondary)

                    Text(group.exampleApps)
                        .font(appTheme.fonts.labelSmall)
                        .foregroundColor(appTheme.colors.textSecondary.opacity(0.7))
                        .lineLimit(1)
                }

                Spacer()

                // Count badge
                VStack(spacing: 2) {
                    if count > 0 {
                        Text("\(count)")
                            .font(appTheme.fonts.titleMedium)
                            .foregroundColor(appTheme.colors.primary)
                        Text("apps")
                            .font(appTheme.fonts.labelSmall)
                            .foregroundColor(appTheme.colors.textSecondary)
                    } else {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 24))
                            .foregroundColor(appTheme.colors.primary.opacity(0.5))
                    }
                }
            }
            .padding(appTheme.spacing.medium)
            .background(appTheme.colors.surface)
            .cornerRadius(appTheme.spacing.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: appTheme.spacing.cornerRadiusMedium)
                    .stroke(count > 0 ? appTheme.colors.primary.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
    }

    private func saveAndContinue() {
        dietManager.setFoodGroupSelection(proteinSelection, for: .protein)
        dietManager.setFoodGroupSelection(carbsSelection, for: .carbs)
        dietManager.setFoodGroupSelection(fatsSelection, for: .fats)
        data.nextScreen()
    }

    private func loadExistingSelections() {
        if let sel = dietManager.foodGroupSelections[.protein] { proteinSelection = sel }
        if let sel = dietManager.foodGroupSelections[.carbs] { carbsSelection = sel }
        if let sel = dietManager.foodGroupSelections[.fats] { fatsSelection = sel }
    }
}
