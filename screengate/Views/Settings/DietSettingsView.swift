import SwiftUI

struct DietSettingsView: View {
    @Environment(DietManager.self) private var diet
    @Environment(EntitlementManager.self) private var entitlements
    @State private var adjust = false
    @State private var cheat = false
    @State private var notifications = false
    @State private var strict = false
    @State private var pause = false
    @State private var reset = false
    @State private var setup = false
    @State private var restoring = false
    @State private var notice: String?
    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                DietHeading(eyebrow: "Keep it sustainable", title: "Your Routine", detail: "Fine-tune the structure. Keep the intention.")
                EditorialBanner(eyebrow: entitlements.isPremium ? "ScreenDiet Plus" : "Your free routine", title: entitlements.isPremium ? "A little more support." : "Small steps count.", detail: entitlements.isPremium ? "All plans, Night Fast and full weekly reports." : "Lean, kitchen hours, a daily portion and one weekly cheat meal.", asset: "FreshStart")
                if !entitlements.isPremium { PrimaryButton(title: "Explore ScreenDiet Plus", icon: "sparkles") { entitlements.presentPaywall(.featureCustomPlan) } }
                if let pending = diet.sharedState.pendingProfile {
                    DietFeatureRow(icon: "clock.arrow.circlepath", title: "A change is on its way", detail: "Your relaxed rules take effect \(pending.applyAt.formatted(date: .abbreviated, time: .shortened)).", tint: .orange).dietCard(tint: .orange)
                }
                section("YOUR DAILY RHYTHM", delay: 0.05) {
                    if let profile = diet.dietProfile {
                        row("leaf.fill", "Plan", profile.plan.displayName.capitalized) { adjust = true }
                        row("fork.knife", "Daily portion", profile.portionMinutes == 0 ? "No Carbs" : "\(profile.portionMinutes) min") { adjust = true }
                        row("sun.max", "Kitchen hours", "\(profile.eatingWindow.startTimeString) – \(profile.eatingWindow.endTimeString)") { adjust = true }
                        row("moon.stars", "Night Fast", profile.nightFast.isEnabled ? profile.nightFastTimeRange : "Off") { adjust = true }
                    } else {
                        row("plus.circle", "Build your routine", "Start here") { setup = true }
                    }
                }
                section("ROOM FOR FLEXIBILITY", delay: 0.1) {
                    row("ticket", "Cheat meals", "\(diet.cheatsRemaining) left this week") { cheat = true }
                    if diet.isCheatMealActive { row("stop.circle", "End current cheat meal", "Resume routine") { diet.endCheatMeal() } }
                    row("lock.shield", "Strict Mode", diet.sharedState.strictMode == true ? "On" : "Off") {
                        if entitlements.isPremium || diet.sharedState.strictMode == true { strict = true }
                        else { entitlements.presentPaywall(.featureStrictMode) }
                    }
                }
                section("GENTLE REMINDERS", delay: 0.15) {
                    row("bell", "Choose your nudges", "Notifications") { notifications = true }
                }
                section("MEMBERSHIP & PRIVACY", delay: 0.2) {
                    row("sparkles", "Membership", entitlements.isPremium ? "Plus active" : "Free") { entitlements.presentPaywall(.onboardingComplete) }
                    row("arrow.clockwise", "Restore purchases", restoring ? "Restoring…" : "") {
                        guard !restoring else { return }; restoring = true
                        Task { @MainActor in
                            await entitlements.restorePurchases(); diet.reloadState(); restoring = false
                            notice = entitlements.isPremium ? "Your Plus membership is active." : "No active membership was found for this Apple Account."
                        }
                    }
                    row("lock", "Your data", "On-device diet") { notice = "Your diet settings and app selections are saved in an on-device shared container. Usage reports are rendered through Screen Time. Purchases are processed by the App Store." }
                    row("info.circle", "App version", Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                }
                section("A FRESH START", delay: 0.25) {
                    row("pause.circle", "Clear current restrictions", "Emergency release") { pause = true }
                    row("arrow.counterclockwise", "Reset this routine", "Remove restrictions") { reset = true }
                    row("book.closed", "Revisit the guided setup", "Story & personalization") { setup = true }
                    #if DEBUG
                    row("wrench.and.screwdriver", "Plus preview · Debug", entitlements.isPremium ? "On" : "Off") { entitlements.debugSetPremium(!entitlements.isPremium); diet.reloadState() }
                    #endif
                }
                Text("A little intention. A fuller life.").font(.system(.subheadline, design: .serif)).foregroundStyle(AppTheme.shared.colors.textSecondary).padding(.vertical, 16)
            }.padding(24).frame(maxWidth: 600).frame(maxWidth: .infinity)
        }.background(AppTheme.shared.colors.background.ignoresSafeArea())
            .sheet(isPresented: $adjust) { if let profile = diet.dietProfile { AdjustDietView(profile: profile).paywallPresenter() } }
            .sheet(isPresented: $cheat) { CheatMealSheet().paywallPresenter() }
            .sheet(isPresented: $notifications) { NotificationSettingsView() }
            .sheet(isPresented: $strict) { StrictModeSheet() }
            .fullScreenCover(isPresented: $setup) { OnboardingView { setup = false }.paywallPresenter() }
            .alert("Clear current restrictions?", isPresented: $pause) { Button("Keep my routine", role: .cancel) { }; Button("Clear", role: .destructive) { diet.removeAllRestrictions() } } message: { Text("This temporarily clears current restrictions. Your schedule can reapply them on the next system update. Reset your routine to stop it completely.") }
            .alert("Reset your routine?", isPresented: $reset) { Button("Cancel", role: .cancel) { }; Button("Reset", role: .destructive) { diet.deactivateDiet() } } message: { Text("Your diet will be deactivated and its restrictions removed. You can build a fresh routine afterward.") }
            .alert("ScreenDiet", isPresented: Binding(get: { notice != nil }, set: { if !$0 { notice = nil } })) { Button("OK") { notice = nil } } message: { Text(notice ?? "") }
    }
    private func section<Content: View>(_ title: String, delay: Double, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.caption2.bold()).tracking(1.8).foregroundStyle(AppTheme.shared.colors.primary).padding(.leading, 4)
            VStack(spacing: 0, content: content).dietCard()
        }.editorialEntrance(delay: delay)
    }
    private func row(_ icon: String, _ title: String, _ value: String, action: (() -> Void)? = nil) -> some View {
        let content = HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(AppTheme.shared.colors.primary).frame(width: 28)
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(AppTheme.shared.colors.text)
                if !value.isEmpty { Text(value).font(.caption).foregroundStyle(AppTheme.shared.colors.textSecondary) }
            }
            Spacer()
            if action != nil { Image(systemName: "chevron.right").font(.caption).foregroundStyle(AppTheme.shared.colors.textSecondary) }
        }.frame(minHeight: 64).contentShape(Rectangle())
        return Group {
            if let action { Button(action: action) { content }.buttonStyle(TactileButtonStyle()) }
            else { content }
        }
    }
}

struct StrictModeSheet: View {
    @Environment(DietManager.self) private var diet
    @Environment(\.dismiss) private var dismiss
    private var enabled: Bool { diet.sharedState.strictMode == true }
    var body: some View {
        NavigationStack {
            DietPage {
                DietArtwork(asset: "FocusGarden", height: 220)
                DietHeading(eyebrow: "A stronger boundary", title: "Support your\nfuture intention.", detail: "Strict Mode adds friction to bypassing your routine. Turn it on only if this is the support you want.", centered: true)
                VStack(spacing: 20) {
                    DietFeatureRow(icon: "app.badge", title: "Keep ScreenDiet installed", detail: "iOS prevents app removal while Strict Mode is enabled.")
                    DietFeatureRow(icon: "clock", title: "Keep the clock honest", detail: "Automatic date and time are required while this is enabled.")
                    DietFeatureRow(icon: "gearshape", title: "Stay in control", detail: "You can turn Strict Mode off here. Screen Time authorization still controls system access.")
                }.dietCard()
            } footer: {
                PrimaryButton(title: enabled ? "Turn Strict Mode off" : "Enable Strict Mode", icon: "lock.shield") { diet.setStrictMode(!enabled); dismiss() }
                Button("Keep my current setting") { dismiss() }.font(.caption).frame(minHeight: 44)
            }.navigationTitle("Strict Mode").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .cancellationAction) { DietCloseButton() } }
        }.presentationDetents([.large]).preferredColorScheme(.dark)
    }
}
