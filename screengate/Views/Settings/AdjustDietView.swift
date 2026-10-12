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
    private let theme = KitchenTheme.daylight

    private func planIcon(_ item: DietPlan) -> String {
        item == .lean ? "leaf" : item == .keto ? "scope" : item == .detox ? "arrow.counterclockwise" : "slider.horizontal.3"
    }

    private func card<C: View>(_ title: String, _ detail: String, group: KitchenFoodGroup, symbol: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                SettingsIconTile(symbol: symbol, group: group)
                VStack(alignment: .leading, spacing: 1) {
                    Text(title).font(KitchenFont.body(15).weight(.bold))
                    Text(detail).font(KitchenFont.body(12)).foregroundStyle(theme.muted).fixedSize(horizontal: false, vertical: true)
                }
            }
            content()
        }.padding(16).frame(maxWidth: .infinity, alignment: .leading).kitchenCard(theme)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                KitchenSheetHeader(eyebrow: "Find a rhythm you can repeat", title: "Adjust routine") { dismiss() }
                Text("Tighter rules apply immediately. More relaxed rules take effect after 24 hours.")
                    .kitchenBody(14).foregroundStyle(theme.muted).padding(.horizontal, 4)
                if queued {
                    Image("FreshStart").resizable().scaledToFill().frame(height: 170).frame(maxWidth: .infinity).clipShape(RoundedRectangle(cornerRadius: 28)).accessibilityHidden(true)
                    card("Your change is on its way", "The cooldown gives your earlier intention a little breathing room. The new routine takes effect after 24 hours.", group: .protein, symbol: "clock.arrow.circlepath") { EmptyView() }
                } else {
                    SettingsSectionLabel(text: "YOUR PLAN")
                    VStack(spacing: 10) {
                        ForEach(DietPlan.allCases) { item in
                            KitchenChoiceCard(title: item.kitchenName, detail: item.subtitle, systemImage: planIcon(item), badge: entitlements.canUse(plan: item) ? nil : "Plus", isSelected: plan == item) {
                                if entitlements.canUse(plan: item) { plan = item; if item == .detox { portion = 0 } else if portion == 0 { portion = item.defaultPortionMinutes } }
                                else { entitlements.presentPaywall(.featureCustomPlan) }
                            }
                        }
                    }
                    card("Your daily portion", "A conscious allowance for your selected Carbs.", group: .carbs, symbol: "circle.circle") {
                        Text(portion == 0 ? "Carbs off the menu" : "\(portion) minutes").font(KitchenFont.bigNumber(34)).tracking(-1.5)
                            .foregroundStyle(theme.color(for: .carbs)).contentTransition(.numericText())
                        Slider(value: Binding(get: { Double(portion) }, set: { portion = Int($0) }), in: 0...180, step: 15)
                            .tint(theme.color(for: .carbs)).disabled(plan == .detox).accessibilityLabel("Daily Carbs portion")
                    }
                    card("Kitchen hours", "When your Carbs can be enjoyed. No window is scheduled for Reset.", group: .fats, symbol: "clock") {
                        DatePicker("Opens", selection: $start, displayedComponents: .hourAndMinute)
                        DatePicker("Closes", selection: $end, displayedComponents: .hourAndMinute)
                    }
                    card("Night Fast", "Carbs and Fats rest until your kitchen opens.", group: .carbs, symbol: "moon.stars") {
                        HStack {
                            Text("A bedtime for selected apps").font(KitchenFont.body(14).weight(.semibold))
                            Spacer()
                            KitchenSwitch(isOn: $nightEnabled, label: "A bedtime for selected apps")
                        }
                        if nightEnabled { DatePicker("Starts", selection: $nightStart, displayedComponents: .hourAndMinute).transition(.opacity) }
                    }
                    card("Extra servings", "Free includes one per week. Plus supports up to seven.", group: .protein, symbol: "ticket") {
                        Stepper("\(cheats) per week", value: $cheats, in: 0...7)
                    }
                }
                if let error {
                    card("A small adjustment is needed", error, group: .carbs, symbol: "exclamationmark.circle") { EmptyView() }
                }
                KitchenPrimaryButton(title: queued ? "Done" : "Save my rhythm", systemImage: queued ? "checkmark" : "arrow.right") { if queued { dismiss() } else { save() } }
                    .padding(.top, 6)
            }
            .padding(20).frame(maxWidth: 600).frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .foregroundStyle(theme.text)
        .daylightSheet()
        .onChange(of: nightEnabled) { _, enabled in if enabled && !entitlements.isPremium { nightEnabled = false; entitlements.presentPaywall(.featureNightFast) } }
        .onChange(of: cheats) { _, count in if count > 1 && !entitlements.isPremium { cheats = 1; entitlements.presentPaywall(.cheatOut) } }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: nightEnabled)
        .sensoryFeedback(.success, trigger: queued)
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
