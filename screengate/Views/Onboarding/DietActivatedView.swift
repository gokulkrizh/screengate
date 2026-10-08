import SwiftUI
import FamilyControls

struct DietActivatedView: View {
    @ObservedObject var data: OnboardingData
    @Environment(DietManager.self) private var dietManager
    @State private var isActivating = false
    @State private var isActivated = false
    @State private var showCheckmark = false
    @State private var activationError: String?
    private let appTheme = AppTheme.shared

    var body: some View {
        ZStack {
            appTheme.colors.background.ignoresSafeArea()

            VStack(spacing: appTheme.spacing.large) {
                Spacer()

                if isActivated {
                    // Success state
                    activatedContent
                } else {
                    // Summary before activation
                    summaryContent
                }

                Spacer()

                // Action button
                if isActivated {
                    Button(action: {
                        data.completeOnboarding()
                    }) {
                        Text("Start Your Diet")
                            .font(appTheme.fonts.titleMedium)
                            .foregroundColor(appTheme.colors.background)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(appTheme.colors.primary)
                            .cornerRadius(appTheme.spacing.cornerRadiusLarge)
                    }
                    .padding(.horizontal, appTheme.spacing.large)
                } else {
                    Button(action: activateDiet) {
                        HStack {
                            if isActivating {
                                ProgressView()
                                    .tint(appTheme.colors.background)
                            } else {
                                Image(systemName: "bolt.fill")
                                Text("Activate Diet")
                            }
                        }
                        .font(appTheme.fonts.titleMedium)
                        .foregroundColor(appTheme.colors.background)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(appTheme.colors.primary)
                        .cornerRadius(appTheme.spacing.cornerRadiusLarge)
                    }
                    .disabled(isActivating)
                    .padding(.horizontal, appTheme.spacing.large)
                }

                // Back button
                if !isActivated {
                    Button(action: { data.previousScreen() }) {
                        Text("Go Back")
                            .font(appTheme.fonts.bodyMedium)
                            .foregroundColor(appTheme.colors.textSecondary)
                    }
                }

                Spacer().frame(height: appTheme.spacing.extraLarge)
            }
        }
        .alert("Can't activate this plan", isPresented: Binding(
            get: { activationError != nil },
            set: { if !$0 { activationError = nil } }
        )) {
            Button("OK", role: .cancel) { activationError = nil }
        } message: {
            Text(activationError ?? "")
        }
    }

    // MARK: - Activated Content

    private var activatedContent: some View {
        VStack(spacing: appTheme.spacing.large) {
            // Animated checkmark
            ZStack {
                Circle()
                    .fill(appTheme.colors.primary.opacity(0.15))
                    .frame(width: 120, height: 120)
                    .scaleEffect(showCheckmark ? 1.0 : 0.5)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(appTheme.colors.primary)
                    .scaleEffect(showCheckmark ? 1.0 : 0)
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showCheckmark)

            Text("Diet Activated!")
                .font(appTheme.fonts.headlineLarge)
                .foregroundColor(appTheme.colors.text)

            Text("Your digital nutrition plan is now active. Screendiet will manage your app access based on your diet.")
                .font(appTheme.fonts.bodyLarge)
                .foregroundColor(appTheme.colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, appTheme.spacing.large)
        }
    }

    // MARK: - Summary Content

    private var summaryContent: some View {
        VStack(spacing: appTheme.spacing.large) {
            // Title
            VStack(spacing: appTheme.spacing.small) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 40))
                    .foregroundColor(appTheme.colors.primary)

                Text("Your Prescription")
                    .font(appTheme.fonts.headlineLarge)
                    .foregroundColor(appTheme.colors.text)

                Text("Review your diet plan before activation")
                    .font(appTheme.fonts.bodyLarge)
                    .foregroundColor(appTheme.colors.textSecondary)
            }

            // Summary cards
            VStack(spacing: appTheme.spacing.medium) {
                if let plan = data.selectedPlan {
                    summaryRow(icon: "fork.knife", label: "Diet Type", value: plan.displayName)
                    summaryRow(icon: "clock", label: "Eating Window",
                               value: "\(formatHour(data.windowStartHour)) - \(formatHour(data.windowEndHour))")
                    summaryRow(icon: "timer", label: "Carb Portion",
                               value: data.dailyCarbLimitMinutes > 0 ? "\(data.dailyCarbLimitMinutes) minutes" : "No carbs")
                    summaryRow(icon: "moon.fill", label: "Night Fast",
                               value: "from \(formatHour(data.nightLockHour))")
                    summaryRow(icon: "ticket", label: "Weekly Cheat Meals",
                               value: "\(plan.defaultCheatsPerWeek) meals")
                }
            }
            .padding(.horizontal, appTheme.spacing.large)

            // Food group counts
            let selections = dietManager.foodGroupSelections
            if !selections.isEmpty {
                VStack(spacing: appTheme.spacing.small) {
                    Text("YOUR PANTRY")
                        .font(appTheme.fonts.labelSmall)
                        .foregroundColor(appTheme.colors.primary)
                        .tracking(1.5)

                    HStack(spacing: appTheme.spacing.medium) {
                        ForEach(FoodGroup.allCases) { group in
                            let count = (selections[group]?.applicationTokens.count ?? 0) +
                                        (selections[group]?.categoryTokens.count ?? 0)
                            VStack(spacing: 4) {
                                Text(group.emoji)
                                    .font(.system(size: 20))
                                Text("\(count)")
                                    .font(appTheme.fonts.titleMedium)
                                    .foregroundColor(appTheme.colors.text)
                                Text(group.displayName)
                                    .font(appTheme.fonts.labelSmall)
                                    .foregroundColor(appTheme.colors.textSecondary)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func summaryRow(icon: String, label: String, value: String) -> some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(appTheme.colors.primary)
                    .frame(width: 20)
                Text(label)
                    .font(appTheme.fonts.bodyMedium)
                    .foregroundColor(appTheme.colors.textSecondary)
            }
            Spacer()
            Text(value)
                .font(appTheme.fonts.titleSmall)
                .foregroundColor(appTheme.colors.text)
        }
        .padding(.vertical, appTheme.spacing.small)
        .padding(.horizontal, appTheme.spacing.medium)
        .background(appTheme.colors.surface)
        .cornerRadius(appTheme.spacing.cornerRadiusSmall)
    }

    private func formatHour(_ hour: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return "\(displayHour):00 \(period)"
    }

    private func activateDiet() {
        guard let plan = data.selectedPlan else { return }
        isActivating = true

        var profile = DietProfile.create(plan: plan)
        profile.eatingWindow = EatingWindow(
            startHour: data.windowStartHour,
            startMinute: 0,
            endHour: data.windowEndHour,
            endMinute: 0
        )
        profile.portionMinutes = data.dailyCarbLimitMinutes
        profile.nightFast = NightFast(
            isEnabled: true,
            startHour: data.nightLockHour,
            startMinute: 0,
            endHour: data.windowStartHour,
            endMinute: 0
        )
        profile.cheatsPerWeek = Entitlement.canUse(plan: plan, isPremium: dietManager.isPremium)
            ? plan.defaultCheatsPerWeek
            : Entitlement.freeCheatsPerWeek

        do {
            try dietManager.activateDiet(profile: profile)
            withAnimation {
                isActivated = true
                isActivating = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showCheckmark = true
            }
        } catch {
            isActivating = false
            activationError = error.localizedDescription
            print("Failed to activate diet: \(error)")
        }
    }
}
