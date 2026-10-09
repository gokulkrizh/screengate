import SwiftUI

struct AdjustDietView: View {
    @Environment(DietManager.self) private var diet
    @Environment(EntitlementManager.self) private var entitlements
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var plan: DietPlan
    @State private var portion: Int
    @State private var start: Date
    @State private var end: Date
    @State private var nightEnabled: Bool
    @State private var nightStart: Date
    @State private var cheats: Int
    @State private var queued = false
    @State private var error: String?
    init(profile: DietProfile) {
        let calendar = Calendar.current; let base = calendar.startOfDay(for: Date())
        _plan = State(initialValue: profile.plan); _portion = State(initialValue: profile.portionMinutes)
        _start = State(initialValue: calendar.date(bySettingHour: profile.eatingWindow.startHour, minute: profile.eatingWindow.startMinute, second: 0, of: base) ?? base)
        _end = State(initialValue: calendar.date(bySettingHour: profile.eatingWindow.endHour, minute: profile.eatingWindow.endMinute, second: 0, of: base) ?? base)
        _nightEnabled = State(initialValue: profile.nightFast.isEnabled)
        _nightStart = State(initialValue: calendar.date(bySettingHour: profile.nightFast.startHour, minute: profile.nightFast.startMinute, second: 0, of: base) ?? base)
        _cheats = State(initialValue: profile.cheatsPerWeek)
    }
    var body: some View {
        NavigationStack {
            DietPage {
                DietHeading(eyebrow: "Find a rhythm you can repeat", title: "A little fine-tuning.", detail: "Tighter rules apply immediately. More relaxed rules take effect after 24 hours.")
                if queued {
                    DietArtwork(asset: "FreshStart", height: 190)
                    DietFeatureRow(icon: "clock.arrow.circlepath", title: "Your change is on its way", detail: "The cooldown gives your earlier intention a little breathing room. The new routine takes effect after 24 hours.", tint: .orange).dietCard(tint: .orange)
                } else {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("YOUR PLAN").font(.caption2.bold()).tracking(1.5).foregroundStyle(AppTheme.shared.colors.primary)
                        ForEach(DietPlan.allCases) { item in
                            DietChoice(icon: item == .lean ? "leaf" : item == .keto ? "target" : item == .detox ? "arrow.counterclockwise" : "slider.horizontal.3", title: item.displayName.capitalized + (entitlements.canUse(plan: item) ? "" : " · Plus"), detail: item.subtitle, selected: plan == item) {
                                if entitlements.canUse(plan: item) { plan = item; if item == .detox { portion = 0 } else if portion == 0 { portion = item.defaultPortionMinutes } }
                                else { entitlements.presentPaywall(.featureCustomPlan) }
                            }
                        }
                    }.editorialEntrance()
                    VStack(alignment: .leading, spacing: 18) {
                        DietFeatureRow(icon: "fork.knife", title: "Your daily portion", detail: "A conscious allowance for your selected Carbs.")
                        Text(portion == 0 ? "Carbs off the menu" : "\(portion) minutes").font(.system(.title, design: .rounded).bold()).foregroundStyle(AppTheme.shared.colors.primary).contentTransition(.numericText())
                        Slider(value: Binding(get: { Double(portion) }, set: { portion = Int($0) }), in: 0...180, step: 15).tint(AppTheme.shared.colors.primary).disabled(plan == .detox).accessibilityLabel("Daily Carbs portion")
                    }.dietCard()
                    VStack(alignment: .leading, spacing: 18) {
                        DietFeatureRow(icon: "sun.max", title: "Kitchen hours", detail: "When your Carbs can be enjoyed. No window is scheduled for Detox.")
                        DatePicker("Opens", selection: $start, displayedComponents: .hourAndMinute)
                        DatePicker("Closes", selection: $end, displayedComponents: .hourAndMinute)
                    }.foregroundStyle(AppTheme.shared.colors.text).dietCard()
                    VStack(alignment: .leading, spacing: 18) {
                        DietFeatureRow(icon: "moon.stars", title: "Night Fast", detail: "Carbs and Fats rest until your kitchen opens.", tint: .purple)
                        Toggle("A bedtime for selected apps", isOn: $nightEnabled).tint(AppTheme.shared.colors.primary)
                            .onChange(of: nightEnabled) { _, enabled in if enabled && !entitlements.isPremium { nightEnabled = false; entitlements.presentPaywall(.featureNightFast) } }
                        if nightEnabled { DatePicker("Starts", selection: $nightStart, displayedComponents: .hourAndMinute).transition(.opacity) }
                    }.foregroundStyle(AppTheme.shared.colors.text).dietCard(tint: .purple)
                    VStack(alignment: .leading, spacing: 18) {
                        DietFeatureRow(icon: "ticket", title: "Cheat meals", detail: "Free includes one per week. Plus supports up to seven.", tint: .orange)
                        Stepper("\(cheats) per week", value: $cheats, in: 0...7).foregroundStyle(AppTheme.shared.colors.text)
                            .onChange(of: cheats) { _, count in if count > 1 && !entitlements.isPremium { cheats = 1; entitlements.presentPaywall(.cheatOut) } }
                    }.dietCard(tint: .orange)
                }
                if let error { DietFeatureRow(icon: "exclamationmark.circle", title: "A small adjustment is needed", detail: error, tint: .orange).dietCard(tint: .orange) }
            } footer: {
                PrimaryButton(title: queued ? "Done" : "Save my rhythm", icon: queued ? "checkmark" : "arrow.right") { if queued { dismiss() } else { save() } }
            }.navigationTitle("Adjust Routine").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .cancellationAction) { DietCloseButton() } }
        }.preferredColorScheme(.dark).animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: nightEnabled).sensoryFeedback(.success, trigger: queued)
    }
    private func save() {
        guard var profile = diet.dietProfile else { return }
        let calendar = Calendar.current
        profile.plan = plan; profile.portionMinutes = portion
        profile.eatingWindow = EatingWindow(startHour: calendar.component(.hour, from: start), startMinute: calendar.component(.minute, from: start), endHour: calendar.component(.hour, from: end), endMinute: calendar.component(.minute, from: end))
        profile.nightFast = NightFast(isEnabled: nightEnabled, startHour: calendar.component(.hour, from: nightStart), startMinute: calendar.component(.minute, from: nightStart), endHour: profile.eatingWindow.startHour, endMinute: profile.eatingWindow.startMinute)
        profile.cheatsPerWeek = cheats
        let issues = DietRules.validate(profile)
        if !issues.isEmpty { error = issues.joined(separator: "\n"); return }
        error = nil
        if diet.requestProfileUpdate(profile) { withAnimation { queued = true } } else { dismiss() }
    }
}
