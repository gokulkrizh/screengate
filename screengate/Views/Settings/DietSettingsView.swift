import SwiftUI

struct DietSettingsView: View {
    @Environment(DietManager.self) private var dietManager
    @State private var showAdjustDiet = false
    @State private var showCheatMeal = false
    @State private var showResetConfirm = false
    private let appTheme = AppTheme.shared

    var body: some View {
        ScrollView {
            VStack(spacing: appTheme.spacing.large) {
                // Header
                HStack {
                    Text("Settings")
                        .font(appTheme.fonts.headlineLarge)
                        .foregroundColor(appTheme.colors.text)
                    Spacer()
                }
                .padding(.top, appTheme.spacing.medium)

                // My Prescription
                settingsSection(title: "MY PRESCRIPTION") {
                    if let profile = dietManager.dietProfile {
                        settingsRow(icon: "fork.knife", title: "Diet Type", value: profile.dietType.displayName) {
                            showAdjustDiet = true
                        }
                        settingsRow(icon: "calendar", title: "Week", value: "\(profile.weekNumber)")
                        settingsRow(icon: "target", title: "Macro Split", value: macroSplit(profile))
                    }
                }

                // Schedule
                settingsSection(title: "SCHEDULE") {
                    if let profile = dietManager.dietProfile {
                        settingsRow(icon: "clock", title: "Eating Window",
                                    value: "\(profile.eatingWindow.startTimeString) - \(profile.eatingWindow.endTimeString)")
                        settingsRow(icon: "timer", title: "Daily Carb Limit",
                                    value: "\(profile.eatingWindow.dailyCarbLimitMinutes)m")
                        settingsRow(icon: "moon.fill", title: "Night Lock",
                                    value: profile.nightLockTimeString)
                    }
                }

                // Diet Controls
                settingsSection(title: "DIET CONTROLS") {
                    settingsRow(icon: "ticket", title: "Cheat Meal",
                                value: "\(dietManager.cheatsRemaining) remaining") {
                        showCheatMeal = true
                    }

                    if dietManager.isCheatMealActive {
                        HStack {
                            Image(systemName: "fork.knife.circle.fill")
                                .foregroundColor(appTheme.colors.warning)
                            Text("Cheat meal active")
                                .font(appTheme.fonts.bodyMedium)
                                .foregroundColor(appTheme.colors.warning)
                            Spacer()
                            Button("End") {
                                dietManager.endCheatMeal()
                            }
                            .font(appTheme.fonts.labelMedium)
                            .foregroundColor(appTheme.colors.error)
                        }
                        .padding(.vertical, appTheme.spacing.small)
                    }
                }

                // Emergency
                settingsSection(title: "EMERGENCY") {
                    Button(action: {
                        dietManager.removeAllRestrictions()
                    }) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(appTheme.colors.error)
                            Text("Pause All Restrictions")
                                .font(appTheme.fonts.bodyMedium)
                                .foregroundColor(appTheme.colors.error)
                            Spacer()
                        }
                    }
                    .padding(.vertical, appTheme.spacing.small)
                }

                // App
                settingsSection(title: "APP") {
                    settingsRow(icon: "arrow.counterclockwise", title: "Reset Diet", value: "") {
                        showResetConfirm = true
                    }
                    settingsRow(icon: "arrow.clockwise", title: "Reset Onboarding", value: "") {
                        OnboardingData.resetOnboarding()
                    }
                    settingsRow(icon: "info.circle", title: "Version", value: "1.0")
                }

                Spacer(minLength: 80)
            }
            .padding(.horizontal, appTheme.spacing.large)
        }
        .background(appTheme.colors.background.ignoresSafeArea())
        .alert("Reset Diet?", isPresented: $showResetConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                dietManager.deactivateDiet()
            }
        } message: {
            Text("This will deactivate your diet and remove all restrictions. You can set up a new diet afterward.")
        }
        .sheet(isPresented: $showCheatMeal) {
            cheatMealSheet
        }
    }

    // MARK: - Components

    private func settingsSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: appTheme.spacing.small) {
            Text(title)
                .font(appTheme.fonts.labelSmall)
                .foregroundColor(appTheme.colors.primary)
                .tracking(1.0)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content()
            }
            .padding(appTheme.spacing.medium)
            .background(appTheme.colors.surface)
            .cornerRadius(appTheme.spacing.cornerRadiusMedium)
        }
    }

    private func settingsRow(icon: String, title: String, value: String, action: (() -> Void)? = nil) -> some View {
        Button(action: { action?() }) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(appTheme.colors.primary)
                    .frame(width: 24)

                Text(title)
                    .font(appTheme.fonts.bodyMedium)
                    .foregroundColor(appTheme.colors.text)

                Spacer()

                Text(value)
                    .font(appTheme.fonts.bodySmall)
                    .foregroundColor(appTheme.colors.textSecondary)

                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(appTheme.colors.textSecondary)
                }
            }
            .padding(.vertical, appTheme.spacing.small)
        }
        .buttonStyle(.plain)
    }

    private var cheatMealSheet: some View {
        VStack(spacing: appTheme.spacing.large) {
            Spacer()

            Image(systemName: "ticket.fill")
                .font(.system(size: 48))
                .foregroundColor(appTheme.colors.warning)

            Text("Use Cheat Meal?")
                .font(appTheme.fonts.headlineMedium)
                .foregroundColor(appTheme.colors.text)

            Text("This will temporarily allow all carb apps for 30 minutes. You have \(dietManager.cheatsRemaining) cheat meals remaining this week.")
                .font(appTheme.fonts.bodyMedium)
                .foregroundColor(appTheme.colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            VStack(spacing: appTheme.spacing.medium) {
                Button(action: {
                    try? dietManager.useCheatMeal()
                    showCheatMeal = false
                }) {
                    Text("Use Cheat Meal (30 min)")
                        .font(appTheme.fonts.titleMedium)
                        .foregroundColor(appTheme.colors.background)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(dietManager.cheatsRemaining > 0 ? appTheme.colors.warning : appTheme.colors.secondary)
                        .cornerRadius(appTheme.spacing.cornerRadiusLarge)
                }
                .disabled(dietManager.cheatsRemaining <= 0)

                Button("Cancel") {
                    showCheatMeal = false
                }
                .font(appTheme.fonts.bodyMedium)
                .foregroundColor(appTheme.colors.textSecondary)
            }
            .padding(.horizontal, appTheme.spacing.large)
            .padding(.bottom, appTheme.spacing.extraLarge)
        }
        .background(appTheme.colors.background.ignoresSafeArea())
        .presentationDetents([.medium])
    }

    // MARK: - Helpers

    private func macroSplit(_ profile: DietProfile) -> String {
        let p = profile.ratio(for: .protein)
        let c = profile.ratio(for: .carbs)
        let f = profile.ratio(for: .fats)
        let fi = profile.ratio(for: .fiber)
        return "\(p)/\(c)/\(f)/\(fi)"
    }
}
