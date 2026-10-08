import SwiftUI

struct DietSettingsView: View {
    @Environment(DietManager.self) private var dietManager
    @Environment(EntitlementManager.self) private var entitlements
    @State private var showAdjustDiet = false
    @State private var showCheatMeal = false
    @State private var showResetConfirm = false
    @State private var showNotifications = false
    @State private var showStrictConfirm = false
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

                // Queued loosening change (24 h cooldown)
                if let pending = dietManager.sharedState.pendingProfile {
                    HStack(spacing: appTheme.spacing.medium) {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(appTheme.colors.warning)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Change queued")
                                .font(appTheme.fonts.titleSmall)
                                .foregroundColor(appTheme.colors.text)
                            Text("Takes effect \(pending.applyAt.formatted(date: .abbreviated, time: .shortened))")
                                .font(appTheme.fonts.bodySmall)
                                .foregroundColor(appTheme.colors.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(appTheme.spacing.medium)
                    .background(appTheme.colors.surface)
                    .cornerRadius(appTheme.spacing.cornerRadiusMedium)
                }

                // My Prescription
                settingsSection(title: "MY PRESCRIPTION") {
                    if let profile = dietManager.dietProfile {
                        settingsRow(icon: "fork.knife", title: "Diet Type", value: profile.plan.displayName) {
                            showAdjustDiet = true
                        }
                        settingsRow(icon: "calendar", title: "Week", value: "\(profile.weekNumber)")
                        settingsRow(icon: "target", title: "Portion", value: "\(profile.portionMinutes)m carbs")
                    }
                }

                // Schedule
                settingsSection(title: "SCHEDULE") {
                    if let profile = dietManager.dietProfile {
                        settingsRow(icon: "clock", title: "Eating Window",
                                    value: "\(profile.eatingWindow.startTimeString) - \(profile.eatingWindow.endTimeString)")
                        settingsRow(icon: "timer", title: "Carb Portion",
                                    value: "\(profile.portionMinutes)m")
                        settingsRow(icon: "moon.fill", title: "Night Fast",
                                    value: profile.nightFastTimeRange)
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

                // Strict mode
                settingsSection(title: "STRICT MODE") {
                    settingsRow(icon: "lock.shield.fill", title: "Strict Mode",
                                value: dietManager.sharedState.strictMode == true ? "ON" : "OFF") {
                        if entitlements.isPremium {
                            showStrictConfirm = true
                        } else {
                            entitlements.presentPaywall(.featureStrictMode)
                        }
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

                // Notifications
                settingsSection(title: "REMINDERS") {
                    settingsRow(icon: "bell.fill", title: "Notifications", value: "") {
                        showNotifications = true
                    }
                }

                // App
                settingsSection(title: "APP") {
                    settingsRow(icon: "arrow.counterclockwise", title: "Reset Diet", value: "") {
                        showResetConfirm = true
                    }
                    settingsRow(icon: "arrow.clockwise", title: "Reset Onboarding", value: "") {
                        OnboardingData.resetOnboarding()
                    }
                    settingsRow(icon: "arrow.clockwise", title: "Restore Purchases", value: "") {
                        Task { await entitlements.restorePurchases() }
                    }
                    settingsRow(icon: "info.circle", title: "Version", value: "1.0")
                    #if DEBUG
                    settingsRow(icon: "wrench.and.screwdriver", title: "Premium (debug)",
                                value: entitlements.isPremium ? "ON" : "OFF") {
                        entitlements.debugSetPremium(!entitlements.isPremium)
                    }
                    #endif
                }

                Text("Your diet never leaves your phone.")
                    .font(appTheme.fonts.labelSmall)
                    .foregroundColor(appTheme.colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, appTheme.spacing.medium)

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
                .paywallPresenter()
        }
        .sheet(isPresented: $showNotifications) {
            NotificationSettingsView()
                .environment(dietManager)
        }
        .sheet(isPresented: $showAdjustDiet) {
            if let profile = dietManager.dietProfile {
                AdjustDietView(profile: profile)
                    .environment(dietManager)
                    .environment(entitlements)
                    .paywallPresenter()
            }
        }
        .alert("Enable Strict Mode?", isPresented: $showStrictConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Enable", role: .destructive) {
                dietManager.setStrictMode(true)
            }
        } message: {
            Text("You won't be able to delete ScreenDiet or change the clock until you turn it off.")
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

            Text("This will temporarily allow all carb apps for \(DietRules.cheatMealMinutes) minutes. You have \(dietManager.cheatsRemaining) cheat meals remaining this week.")
                .font(appTheme.fonts.bodyMedium)
                .foregroundColor(appTheme.colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            VStack(spacing: appTheme.spacing.medium) {
                if dietManager.cheatsRemaining > 0 {
                    HoldToConfirmButton(
                        title: "Hold to use (\(DietRules.cheatMealMinutes) min)",
                        tint: appTheme.colors.warning
                    ) {
                        try? dietManager.useCheatMeal()
                        showCheatMeal = false
                    }
                } else {
                    Button(action: {
                        showCheatMeal = false
                        entitlements.presentPaywall(.cheatOut)
                    }) {
                        Text("Get more cheats")
                            .font(appTheme.fonts.titleMedium)
                            .foregroundColor(appTheme.colors.background)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(appTheme.colors.primary)
                            .cornerRadius(appTheme.spacing.cornerRadiusLarge)
                    }
                }

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

}
