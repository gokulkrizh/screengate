import SwiftUI
import FamilyControls

struct PantryView: View {
    @Environment(DietManager.self) private var dietManager
    @State private var activePickerGroup: FoodGroup?
    @State private var editingSelection = FamilyActivitySelection()
    private let appTheme = AppTheme.shared

    var body: some View {
        ScrollView {
            VStack(spacing: appTheme.spacing.large) {
                // Header
                HStack {
                    Text("Your Pantry")
                        .font(appTheme.fonts.headlineLarge)
                        .foregroundColor(appTheme.colors.text)
                    Spacer()
                }
                .padding(.top, appTheme.spacing.medium)

                Text("Manage what apps belong to each food group")
                    .font(appTheme.fonts.bodyMedium)
                    .foregroundColor(appTheme.colors.textSecondary)

                // Food group sections
                ForEach(FoodGroup.allCases) { group in
                    foodGroupSection(group: group)
                }

                Spacer(minLength: 80)
            }
            .padding(.horizontal, appTheme.spacing.large)
        }
        .background(appTheme.colors.background.ignoresSafeArea())
        .familyActivityPicker(
            isPresented: Binding(
                get: { activePickerGroup != nil },
                set: { if !$0 {
                    if let group = activePickerGroup {
                        dietManager.setFoodGroupSelection(editingSelection, for: group)
                    }
                    activePickerGroup = nil
                }}
            ),
            selection: $editingSelection
        )
    }

    private func foodGroupSection(group: FoodGroup) -> some View {
        let selection = dietManager.foodGroupSelections[group]
        let appCount = selection?.applicationTokens.count ?? 0
        let categoryCount = selection?.categoryTokens.count ?? 0
        let totalCount = appCount + categoryCount

        return VStack(alignment: .leading, spacing: appTheme.spacing.medium) {
            // Section header
            HStack {
                Text(group.emoji)
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(group.displayName)
                            .font(appTheme.fonts.titleMedium)
                            .foregroundColor(appTheme.colors.text)

                        if group.isUnlimited {
                            Text("UNLIMITED")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(appTheme.colors.primary)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(appTheme.colors.primary.opacity(0.15))
                                .cornerRadius(4)
                        }
                    }

                    Text(group.subtitle)
                        .font(appTheme.fonts.bodySmall)
                        .foregroundColor(appTheme.colors.textSecondary)
                }

                Spacer()

                // Today's usage
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(dietManager.todayLog.minutes(for: group))m")
                        .font(appTheme.fonts.titleSmall)
                        .foregroundColor(appTheme.colors.text)
                    Text("today")
                        .font(appTheme.fonts.labelSmall)
                        .foregroundColor(appTheme.colors.textSecondary)
                }
            }

            // App count and edit button
            HStack {
                Text("\(totalCount) apps/categories assigned")
                    .font(appTheme.fonts.bodySmall)
                    .foregroundColor(appTheme.colors.textSecondary)

                Spacer()

                Button(action: {
                    editingSelection = selection ?? FamilyActivitySelection()
                    activePickerGroup = group
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.system(size: 12))
                        Text("Edit")
                            .font(appTheme.fonts.labelMedium)
                    }
                    .foregroundColor(appTheme.colors.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(appTheme.colors.primary.opacity(0.1))
                    .cornerRadius(appTheme.spacing.cornerRadiusSmall)
                }
            }

            // Status indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(statusColor(for: group))
                    .frame(width: 8, height: 8)
                Text(statusText(for: group))
                    .font(appTheme.fonts.labelSmall)
                    .foregroundColor(appTheme.colors.textSecondary)
            }
        }
        .padding(appTheme.spacing.medium)
        .background(appTheme.colors.surface)
        .cornerRadius(appTheme.spacing.cornerRadiusMedium)
    }

    private func statusColor(for group: FoodGroup) -> Color {
        switch dietManager.currentDietState {
        case .fasting:
            // Only carbs are blocked during fasting; protein, fats, fiber remain available
            return group == .carbs ? appTheme.colors.error : appTheme.colors.primary
        case .windowOpen:
            return appTheme.colors.primary
        case .limitReached:
            return group == .carbs ? appTheme.colors.error : appTheme.colors.primary
        case .nightLock:
            return group == .protein ? appTheme.colors.primary : appTheme.colors.error
        case .inactive:
            return appTheme.colors.secondary
        }
    }

    private func statusText(for group: FoodGroup) -> String {
        switch dietManager.currentDietState {
        case .fasting:
            // Only carbs are blocked during fasting; protein, fats, fiber remain available
            return group == .carbs ? "Blocked (fasting)" : "Available"
        case .windowOpen:
            if group == .carbs {
                return "Open (\(dietManager.carbsRemainingMinutes)m remaining)"
            }
            return "Available"
        case .limitReached:
            return group == .carbs ? "Blocked (limit reached)" : "Available"
        case .nightLock:
            return group == .protein ? "Available" : "Blocked (night lock)"
        case .inactive:
            return "Inactive"
        }
    }
}
