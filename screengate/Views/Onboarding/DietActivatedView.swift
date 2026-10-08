import SwiftUI
import FamilyControls

/// Final onboarding step: activates the diet and celebrates.
struct DietActivatedView: View {
    @ObservedObject var data: OnboardingData
    @Environment(DietManager.self) private var dietManager

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isActivated = false
    @State private var showCheckmark = false
    @State private var pulse = false
    @State private var showConfetti = false
    @State private var activationError: String?
    private let appTheme = AppTheme.shared

    var body: some View {
        ZStack {
            appTheme.colors.background.ignoresSafeArea()

            if showConfetti && !reduceMotion {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            VStack(spacing: appTheme.spacing.large) {
                Spacer()

                // Celebration plate
                ZStack {
                    Circle()
                        .fill(appTheme.colors.primary.opacity(0.10))
                        .frame(width: 180, height: 180)
                        .scaleEffect(pulse ? 1.06 : 1.0)

                    Text("🍽️")
                        .font(.system(size: 76))
                        .scaleEffect(showCheckmark ? 1 : 0.7)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(appTheme.colors.primary)
                        .background(Circle().fill(appTheme.colors.background).frame(width: 34, height: 34))
                        .offset(x: 62, y: -62)
                        .scaleEffect(showCheckmark ? 1 : 0.01)
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showCheckmark)

                VStack(spacing: appTheme.spacing.small) {
                    Text("Kitchen is set.")
                        .font(appTheme.fonts.headlineLarge)
                        .foregroundColor(appTheme.colors.text)

                    Text(summaryLine)
                        .font(appTheme.fonts.bodyLarge)
                        .foregroundColor(appTheme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, appTheme.spacing.large)
                }

                HStack(spacing: appTheme.spacing.medium) {
                    pill(icon: "fork.knife", text: data.selectedPlan?.displayName ?? "LEAN")
                    pill(icon: "timer", text: data.dailyCarbLimitMinutes > 0 ? "\(data.dailyCarbLimitMinutes)m carbs" : "No carbs")
                    pill(icon: "ticket", text: "\(cheats) cheats")
                }
                .padding(.horizontal, appTheme.spacing.large)

                Spacer()

                Button(action: { data.completeOnboarding() }) {
                    Text("Start Your Diet")
                        .font(appTheme.fonts.titleMedium)
                        .foregroundColor(appTheme.colors.background)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(isActivated ? appTheme.colors.primary : appTheme.colors.secondary)
                        .cornerRadius(appTheme.spacing.cornerRadiusLarge)
                }
                .disabled(!isActivated)
                .padding(.horizontal, appTheme.spacing.large)
                .padding(.bottom, appTheme.spacing.extraLarge)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                pulse = true
            }
            activateDiet()
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

    private var cheats: Int {
        guard let plan = data.selectedPlan else { return Entitlement.freeCheatsPerWeek }
        return dietManager.isPremium ? plan.defaultCheatsPerWeek : Entitlement.freeCheatsPerWeek
    }

    private var summaryLine: String {
        let open = "Opens at \(formatTime(data.windowStartHour, data.windowStartMinute))"
        if dietManager.isPremium {
            return open + " · Night Fast from \(formatTime(data.nightLockHour, data.nightLockMinute))."
        }
        return open + " — Lean rules. Night Fast unlocks with Premium."
    }

    private func pill(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
            Text(text)
                .font(appTheme.fonts.labelSmall)
        }
        .foregroundColor(appTheme.colors.primary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(appTheme.colors.primary.opacity(0.1))
        .cornerRadius(8)
    }

    private func formatTime(_ hour: Int, _ minute: Int) -> String {
        EatingWindow.formatTime(hour: hour, minute: minute)
    }

    private func activateDiet() {
        guard !isActivated else { return }
        let plan = data.selectedPlan ?? .lean

        var profile = DietProfile.create(plan: plan)
        profile.eatingWindow = EatingWindow(
            startHour: data.windowStartHour,
            startMinute: data.windowStartMinute,
            endHour: data.windowEndHour,
            endMinute: data.windowEndMinute
        )
        profile.portionMinutes = data.dailyCarbLimitMinutes
        profile.nightFast = NightFast(
            isEnabled: dietManager.isPremium,
            startHour: data.nightLockHour,
            startMinute: data.nightLockMinute,
            endHour: data.windowStartHour,
            endMinute: data.windowStartMinute
        )
        profile.cheatsPerWeek = cheats
        data.selectedPlan = plan

        do {
            try dietManager.activateDiet(profile: profile)
            withAnimation {
                isActivated = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                showCheckmark = true
                if !reduceMotion {
                    showConfetti = true
                }
            }
        } catch {
            activationError = error.localizedDescription
            print("Failed to activate diet: \(error)")
        }
    }
}

// MARK: - Confetti (A10)

private struct ConfettiView: View {
    @State private var fall = false
    private let colors: [Color] = [.green, .yellow, .white, .orange, .purple]

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<32, id: \.self) { index in
                let seed = Double((index * 73) % 100) / 100.0
                let x = seed * geo.size.width
                let delay = Double((index * 37) % 18) / 100.0

                Circle()
                    .fill(colors[index % colors.count].opacity(0.9))
                    .frame(width: 5 + CGFloat(index % 3) * 3)
                    .position(x: x, y: fall ? geo.size.height + 40 : -30)
                    .animation(.easeIn(duration: 1.4).delay(delay), value: fall)
            }
        }
        .onAppear { fall = true }
    }
}
