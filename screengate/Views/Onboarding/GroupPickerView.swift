import SwiftUI
import FamilyControls

/// Picks the apps for a single food group (used for Carbs, then Fats).
struct GroupPickerView: View {
    @ObservedObject var data: OnboardingData
    @Environment(DietManager.self) private var dietManager
    let group: FoodGroup
    var isSkippable = false

    @State private var selection = FamilyActivitySelection()
    @State private var isPickerPresented = false
    private let appTheme = AppTheme.shared

    private var itemCount: Int {
        selection.applicationTokens.count + selection.categoryTokens.count + selection.webDomainTokens.count
    }

    private var hasSelection: Bool { itemCount > 0 }

    var body: some View {
        ZStack {
            appTheme.colors.background.ignoresSafeArea()

            VStack(spacing: appTheme.spacing.large) {
                Spacer()

                Text(group.emoji)
                    .font(.system(size: 64))

                VStack(spacing: appTheme.spacing.small) {
                    Text(group == .carbs ? "What's on the junk menu?" : "What are your social snacks?")
                        .font(appTheme.fonts.headlineLarge)
                        .foregroundColor(appTheme.colors.text)
                        .multilineTextAlignment(.center)

                    Text(group == .carbs
                         ? "Pick the apps that eat your time. These get portioned and blocked outside your kitchen hours."
                         : "Pick the apps you want blocked during fasts. They stay open otherwise.")
                        .font(appTheme.fonts.bodyLarge)
                        .foregroundColor(appTheme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, appTheme.spacing.large)
                }

                Button(action: { isPickerPresented = true }) {
                    HStack(spacing: appTheme.spacing.small) {
                        Image(systemName: group.icon)
                        Text(hasSelection ? "\(itemCount) selected — edit" : "Choose apps")
                    }
                    .font(appTheme.fonts.titleSmall)
                    .foregroundColor(hasSelection ? appTheme.colors.primary : appTheme.colors.text)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(appTheme.colors.surface)
                    .cornerRadius(appTheme.spacing.cornerRadiusLarge)
                    .overlay(
                        RoundedRectangle(cornerRadius: appTheme.spacing.cornerRadiusLarge)
                            .stroke(hasSelection ? appTheme.colors.primary.opacity(0.5) : Color.clear, lineWidth: 1.5)
                    )
                }
                .padding(.horizontal, appTheme.spacing.large)

                Spacer()

                VStack(spacing: appTheme.spacing.medium) {
                    Button(action: saveAndContinue) {
                        Text("Continue")
                            .font(appTheme.fonts.titleMedium)
                            .foregroundColor(hasSelection ? appTheme.colors.background : appTheme.colors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(hasSelection ? appTheme.colors.primary : appTheme.colors.surface)
                            .cornerRadius(appTheme.spacing.cornerRadiusLarge)
                    }
                    .disabled(!hasSelection)

                    if isSkippable {
                        Button("Skip for now") {
                            data.nextScreen()
                        }
                        .font(appTheme.fonts.bodyMedium)
                        .foregroundColor(appTheme.colors.textSecondary)
                    }
                }
                .padding(.horizontal, appTheme.spacing.large)
                .padding(.bottom, appTheme.spacing.extraLarge)
            }
        }
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $selection)
        .onAppear {
            selection = dietManager.foodGroupSelections[group] ?? FamilyActivitySelection()
        }
    }

    private func saveAndContinue() {
        dietManager.setFoodGroupSelection(selection, for: group)
        data.nextScreen()
    }
}
