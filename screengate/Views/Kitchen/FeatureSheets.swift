import SwiftUI

struct FocusFastSheet: View {
    @Environment(DietManager.self) private var diet
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var choice = 0
    private var duration: Int { choice == 0 ? 60 : choice == 1 ? 120 : morning }
    private var morning: Int { max(15, diet.dietProfile?.eatingWindow.minutesUntilNextOpen() ?? 480) }
    var body: some View {
        NavigationStack {
            DietPage {
                DietArtwork(asset: "FocusGarden", height: 190)
                DietHeading(eyebrow: "Protect this moment", title: "What could you do\nwith a little space?", detail: "Pause Carbs and Fats. Keep your productive apps. Choose how long you want to focus.", centered: true)
                DietChoice(icon: "hourglass", title: "One focused hour", detail: "A small pocket of protected attention", selected: choice == 0) { choice = 0 }
                DietChoice(icon: "hourglass.bottomhalf.filled", title: "Two hours of space", detail: "Settle into something meaningful", selected: choice == 1) { choice = 1 }
                DietChoice(icon: "sunrise.fill", title: "Until the next kitchen opening", detail: "\(morning / 60)h \(morning % 60)m from now", selected: choice == 2) { choice = 2 }
                if diet.isCheatMealActive { Text("Starting a focus fast ends your current cheat meal.").font(.caption).foregroundStyle(AppTheme.shared.colors.warning) }
            } footer: {
                if typeSize.isAccessibilitySize {
                    PrimaryButton(title: "Start focus fast", icon: "hourglass") { diet.startFast(minutes: duration); dismiss() }
                } else {
                    SlideToFastControl(title: "Slide to protect my time", tint: AppTheme.shared.colors.primary) { diet.startFast(minutes: duration); dismiss() }
                }
                Text("You can end the fast from your Kitchen.").font(.caption2).foregroundStyle(AppTheme.shared.colors.textSecondary)
            }.navigationTitle("Focus Fast").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .cancellationAction) { DietCloseButton() } }
        }.presentationDetents([.large]).preferredColorScheme(.dark).editorialEntrance()
    }
}

struct CheatMealSheet: View {
    @Environment(DietManager.self) private var diet
    @Environment(EntitlementManager.self) private var entitlements
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var error: String?
    private func useCheatMeal() {
        do { try diet.useCheatMeal(); dismiss() } catch { self.error = error.localizedDescription }
    }
    private var blocked: Bool { diet.currentDietState == .nightFast || diet.currentDietState == .fastNow }
    var body: some View {
        NavigationStack {
            DietPage {
                DietArtwork(asset: "DigitalGarden", height: 210)
                DietHeading(eyebrow: "Flexibility is part of balance", title: "A little treat.\nThen back to your rhythm.", detail: "A cheat meal opens your selected Carbs for \(DietRules.cheatMealMinutes) minutes. Your schedule takes over afterward.", centered: true)
                HStack(spacing: 12) {
                    DietMetric(icon: "ticket.fill", value: "\(diet.cheatsRemaining)", label: "left this week", tint: .orange)
                    DietMetric(icon: "timer", value: "\(DietRules.cheatMealMinutes)m", label: "per cheat meal", tint: .orange)
                }
                if diet.isCheatMealActive { DietFeatureRow(icon: "timer", title: "Your cheat meal is already active", detail: "Enjoy the flexibility you’ve already chosen. Your routine resumes afterward.", tint: .orange).dietCard(tint: .orange) }
                if blocked { DietFeatureRow(icon: "moon.fill", title: "Let this fast finish first", detail: "Cheat meals can’t lift Night Fast or Focus Fast. Return when your fast ends.", tint: .purple).dietCard(tint: .purple) }
                if let error { Text(error).font(.caption).foregroundStyle(AppTheme.shared.colors.warning) }
            } footer: {
                if blocked { PrimaryButton(title: "Back to my Kitchen") { dismiss() } }
                else if diet.isCheatMealActive {
                    PrimaryButton(title: "Back to my Kitchen") { dismiss() }
                    Button("End cheat meal early") { diet.endCheatMeal(); dismiss() }.font(.caption).frame(minHeight: 44)
                }
                else if diet.cheatsRemaining > 0 {
                    if typeSize.isAccessibilitySize {
                        PrimaryButton(title: "Use cheat meal", icon: "ticket.fill", action: useCheatMeal)
                    } else {
                        HoldToConfirmButton(title: "Hold for my cheat meal", tint: AppTheme.shared.colors.warning, onConfirm: useCheatMeal)
                    }
                } else {
                    PrimaryButton(title: "Explore more flexibility", icon: "sparkles") { entitlements.presentPaywall(.cheatOut) }
                }
                if !typeSize.isAccessibilitySize && !blocked && !diet.isCheatMealActive && diet.cheatsRemaining > 0 { Text("Hold for two seconds to confirm.").font(.caption2).foregroundStyle(AppTheme.shared.colors.textSecondary) }
            }.navigationTitle("Cheat Meal").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .cancellationAction) { DietCloseButton() } }
        }.presentationDetents([.large]).preferredColorScheme(.dark).editorialEntrance()
    }
}
