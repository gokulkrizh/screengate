import SwiftUI
import FamilyControls

struct DietSettingsView: View {
    @Environment(DietManager.self) private var diet
    @Environment(EntitlementManager.self) private var entitlements
    @Environment(\.openURL) private var openURL
    @State private var adjust = false
    @State private var cheat = false
    @State private var notifications = false
    @State private var strict = false
    @State private var pause = false
    @State private var reset = false
    @State private var setup = false
    @State private var restoring = false
    @State private var notice: String?
    @Environment(\.kitchenTheme) private var theme

    private var plateCount: Int {
        FoodGroup.allCases.reduce(0) { sum, g in
            let s = diet.foodGroupSelections[g]
            return sum + (s?.applicationTokens.count ?? 0) + (s?.categoryTokens.count ?? 0) + (s?.webDomainTokens.count ?? 0)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                KitchenTitleBlock(eyebrow: "A kitchen that fits your life", title: "Settings").padding(.horizontal, 4).riseIn(0)
                plusCard.padding(.top, 16).riseIn(1)
                if let pending = diet.sharedState.pendingProfile {
                    HStack(spacing: 12) {
                        SettingsIconTile(symbol: "clock.arrow.circlepath", group: .protein)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("A change is on its way").font(KitchenFont.body(14).weight(.bold))
                            Text("Your relaxed rules take effect \(pending.applyAt.formatted(date: .abbreviated, time: .shortened)).").font(KitchenFont.body(12)).foregroundStyle(theme.muted)
                        }
                        Spacer(minLength: 0)
                    }.padding(14).kitchenCard(theme).padding(.top, 12).riseIn(1)
                }
                section("YOUR RECIPE", index: 2) {
                    if let profile = diet.dietProfile {
                        SettingsRow(symbol: "list.bullet.rectangle", group: .protein, title: "Plan", value: profile.plan.kitchenName, showsDivider: false) { adjust = true }
                        SettingsRow(symbol: "circle.circle", group: .carbs, title: "Carbs portion", value: profile.portionMinutes == 0 ? "None" : "\(profile.portionMinutes) min") { adjust = true }
                        SettingsRow(symbol: "clock", group: .fats, title: "Kitchen hours", value: "\(profile.eatingWindow.startTimeString) – \(profile.eatingWindow.endTimeString)") { adjust = true }
                        SettingsRow(symbol: "moon.stars", group: .carbs, title: "Night Fast", value: profile.nightFast.isEnabled ? profile.nightFastTimeRange : "Off") { adjust = true }
                        SettingsRow(symbol: "fork.knife", group: .protein, title: "Plates", value: "\(plateCount) \(plateCount == 1 ? "app" : "apps")") {
                            NotificationCenter.default.post(name: .screenDietTab, object: 2)
                        }
                    } else {
                        SettingsRow(symbol: "plus.circle", group: .protein, title: "Build your routine", value: "Start here", showsDivider: false) { setup = true }
                    }
                }
                section("GENTLE SUPPORT", index: 3) {
                    SettingsRow(symbol: "bell", group: .fats, title: "Gentle reminders", subtitle: "Opening, portion and rest nudges", showsDivider: false) { notifications = true }
                    SettingsToggleRow(symbol: "doc.text", group: .protein, title: "Weekly summary", subtitle: "Sunday evening, in Journal", isOn: Binding(
                        get: { diet.sharedState.isNotificationEnabled(.sundayCheckin) },
                        set: { diet.setNotification(.sundayCheckin, enabled: $0) }))
                }
                section("ROOM FOR FLEXIBILITY", index: 4) {
                    SettingsRow(symbol: "ticket", group: .carbs, title: "Extra servings", value: "\(diet.cheatsRemaining) left this week", showsDivider: false) { cheat = true }
                    if diet.isCheatMealActive { SettingsRow(symbol: "stop.circle", group: .carbs, title: "End current extra serving", value: "Resume routine") { diet.endCheatMeal() } }
                    SettingsRow(symbol: "lock.shield", group: .protein, title: "Strict Mode", value: diet.sharedState.strictMode == true ? "On" : "Off") {
                        if entitlements.isPremium || diet.sharedState.strictMode == true { strict = true }
                        else { entitlements.presentPaywall(.featureStrictMode) }
                    }
                }
                section("MEMBERSHIP & PRIVACY", index: 5) {
                    SettingsRow(symbol: "sparkles", group: .protein, title: "Membership", value: entitlements.isPremium ? "Plus active" : "Free", showsDivider: false) { entitlements.presentPaywall(.onboardingComplete) }
                    SettingsRow(symbol: "arrow.clockwise", group: .fats, title: "Restore purchases", value: restoring ? "Restoring…" : "") {
                        guard !restoring else { return }; restoring = true
                        Task { @MainActor in
                            await entitlements.restorePurchases(); diet.reloadState(); restoring = false
                            notice = entitlements.restoreError ?? (entitlements.isPremium ? "Your Plus membership is active." : "No active membership was found for this Apple Account.")
                        }
                    }
                    SettingsRow(symbol: "lock", group: .protein, title: "Your data", value: "On-device diet") { notice = "Your diet settings and app selections are saved in an on-device shared container. Usage reports are rendered through Screen Time. Apple and RevenueCat process purchase information to manage your membership." }
                    SettingsRow(symbol: "hand.raised", group: .protein, title: "Privacy policy", value: "ScreenDiet") {
                        openURL(URL(string: "https://gokulkrish.com/apps/screendiet/privacy/")!)
                    }
                    SettingsRow(symbol: "info.circle", group: .fats, title: "App version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                }
                section("A FRESH START", index: 6) {
                    SettingsRow(symbol: "pause.circle", group: .carbs, title: "Clear current restrictions", value: "Emergency release", showsDivider: false) { pause = true }
                    SettingsRow(symbol: "arrow.counterclockwise", group: .carbs, title: "Reset this routine", value: "Remove restrictions") { reset = true }
                    SettingsRow(symbol: "book.closed", group: .protein, title: "Replay the story", value: "Setup & personalization") { setup = true }
                    #if DEBUG
                    SettingsRow(symbol: "wrench.and.screwdriver", group: .protein, title: "Plus preview · Debug", value: entitlements.isPremium ? "On" : "Off") { entitlements.debugSetPremium(!entitlements.isPremium); diet.reloadState() }
                    #endif
                }
                Text("A little intention. A fuller life.").font(KitchenFont.body(13)).foregroundStyle(theme.faint)
                    .frame(maxWidth: .infinity).padding(.top, 24)
            }
            .padding(.horizontal, KitchenMetrics.cardMargin).padding(.top, 8).padding(.bottom, 24)
            .frame(maxWidth: 600).frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .foregroundStyle(theme.text)
        .sheet(isPresented: $adjust) { if let profile = diet.dietProfile { AdjustDietView(profile: profile).paywallPresenter() } }
        .sheet(isPresented: $cheat) { CheatMealSheet().paywallPresenter() }
        .sheet(isPresented: $notifications) { NotificationSettingsView() }
        .sheet(isPresented: $strict) { StrictModeSheet() }
        .fullScreenCover(isPresented: $setup) { OnboardingView { setup = false }.paywallPresenter() }
        .alert("Clear current restrictions?", isPresented: $pause) { Button("Keep my routine", role: .cancel) { }; Button("Clear", role: .destructive) { diet.removeAllRestrictions() } } message: { Text("This temporarily clears current restrictions. Your schedule can reapply them on the next system update. Reset your routine to stop it completely.") }
        .alert("Reset your routine?", isPresented: $reset) { Button("Cancel", role: .cancel) { }; Button("Reset", role: .destructive) { diet.deactivateDiet() } } message: { Text("Your diet will be deactivated and its restrictions removed. You can build a fresh routine afterward.") }
        .alert("ScreenDiet", isPresented: Binding(get: { notice != nil }, set: { if !$0 { notice = nil } })) { Button("OK") { notice = nil } } message: { Text(notice ?? "") }
    }

    /// Dark membership card (fixed colours on every theme, per canvas).
    private var plusCard: some View {
        Button { entitlements.presentPaywall(entitlements.isPremium ? .onboardingComplete : .featureCustomPlan) } label: {
            HStack(spacing: 12) {
                Image(systemName: "sparkle").font(.system(size: 18, weight: .bold)).foregroundStyle(Color(hex: "1D1812"))
                    .frame(width: 40, height: 40).background(Color(hex: "F3D9A4"), in: RoundedRectangle(cornerRadius: 13))
                VStack(alignment: .leading, spacing: 1) {
                    Text("ScreenDiet Plus").font(KitchenFont.body(15).weight(.heavy)).foregroundStyle(Color(hex: "F7F2E9"))
                    Text(entitlements.isPremium ? "Membership active" : "All plans, Night Fast and full reports")
                        .font(KitchenFont.body(12)).foregroundStyle(Color(hex: "B5AC9F"))
                }
                Spacer(minLength: 8)
                Text(entitlements.isPremium ? "Manage" : "Explore").font(KitchenFont.label(12).weight(.bold)).foregroundStyle(Color(hex: "F3D9A4"))
            }
            .padding(.horizontal, 16).padding(.vertical, 14).frame(maxWidth: .infinity, minHeight: 68)
            .background(Color(hex: "26221D"), in: RoundedRectangle(cornerRadius: 22))
        }
        .buttonStyle(TactileButtonStyle())
        .accessibilityHint("Opens membership")
    }

    private func section<Content: View>(_ title: String, index: Int, @ViewBuilder content: @escaping () -> Content) -> some View {
        VStack(spacing: 8) {
            SettingsSectionLabel(text: title)
            SettingsGroupCard(content: content)
        }.padding(.top, 18).riseIn(index)
    }
}

struct StrictModeSheet: View {
    @Environment(DietManager.self) private var diet
    @Environment(\.dismiss) private var dismiss
    private let theme = KitchenTheme.daylight
    private var enabled: Bool { diet.sharedState.strictMode == true }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                KitchenSheetHeader(eyebrow: "A stronger boundary", title: "Strict Mode") { dismiss() }
                Image("FocusGarden").resizable().scaledToFill().frame(height: 170).frame(maxWidth: .infinity).clipShape(RoundedRectangle(cornerRadius: 28)).accessibilityHidden(true)
                Text("Support your future intention. Strict Mode adds friction to bypassing your routine. Turn it on only if this is the support you want.")
                    .kitchenBody(14).foregroundStyle(theme.muted)
                SettingsGroupCard {
                    SettingsRow(symbol: "app.badge", group: .carbs, title: "Keep ScreenDiet installed", subtitle: "iOS prevents app removal while Strict Mode is enabled.", showsDivider: false)
                    SettingsRow(symbol: "clock", group: .fats, title: "Keep the clock honest", subtitle: "Automatic date and time are required while this is enabled.")
                    SettingsRow(symbol: "gearshape", group: .protein, title: "Stay in control", subtitle: "You can turn Strict Mode off here. Screen Time authorization still controls system access.")
                }
                KitchenPrimaryButton(title: enabled ? "Turn Strict Mode off" : "Enable Strict Mode", systemImage: "lock.shield") { diet.setStrictMode(!enabled); dismiss() }
                KitchenSecondaryButton(title: "Keep my current setting") { dismiss() }
            }.padding(20)
        }
        .foregroundStyle(theme.text)
        .daylightSheet()
        .presentationDetents([.large])
    }
}
