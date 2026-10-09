import SwiftUI

struct DietActivatedView: View {
    @ObservedObject var data: OnboardingData
    @Environment(DietManager.self) private var diet
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var activated = false
    @State private var reveal = false
    @State private var error: String?
    var body: some View {
        ZStack {
            DietPage {
                ZStack(alignment: .topTrailing) {
                    DietArtwork(asset: "FreshStart", height: 260)
                    Image(systemName: "checkmark.seal.fill").font(.largeTitle).foregroundStyle(AppTheme.shared.colors.primary).scaleEffect(reveal ? 1 : reduceMotion ? 1 : 0.5).opacity(reveal ? 1 : 0).padding(16)
                }
                DietHeading(eyebrow: activated ? "Your fresh start" : "Setting your table", title: activated ? "Your Kitchen\nis ready." : "A little intention\nis taking shape.", detail: "Here’s to more room for \(data.intention?.lowercased() ?? "what matters").", centered: true)
                VStack(spacing: 18) {
                    DietFeatureRow(icon: "leaf.fill", title: "\(data.selectedPlan?.displayName.capitalized ?? "Lean") routine", detail: "A starting point you can build on.")
                    DietFeatureRow(icon: "sunrise", title: "Kitchen opens at \(EatingWindow.formatTime(hour: data.windowStartHour, minute: data.windowStartMinute))", detail: "Your chosen Carbs follow your daily schedule.")
                    DietFeatureRow(icon: "pencil.and.outline", title: "Keep creating freely", detail: "Productive apps remain available.")
                }.dietCard().editorialEntrance(delay: 0.15)
                if let error {
                    DietFeatureRow(icon: "exclamationmark.circle", title: "Your routine needs an adjustment", detail: error, tint: .orange).dietCard(tint: .orange)
                    Button("Adjust my routine") { data.goToScreen(13) }.frame(minHeight: 44)
                }
            } footer: {
                PrimaryButton(title: activated ? "Show me my first day" : "Try activation again", icon: "arrow.right") { if activated { data.nextScreen() } else { activate() } }
            }
            if reveal && !reduceMotion { CelebrationParticles().allowsHitTesting(false).accessibilityHidden(true) }
        }.onAppear { activate() }
    }
    private func activate() {
        #if DEBUG
        if DesignReviewView.launchRoute != nil { activated = true; reveal = true; return }
        #endif
        guard !activated else { return }
        var profile = DietProfile.create(plan: data.selectedPlan ?? .lean)
        profile.eatingWindow = EatingWindow(startHour: data.windowStartHour, startMinute: data.windowStartMinute, endHour: data.windowEndHour, endMinute: data.windowEndMinute)
        profile.portionMinutes = data.dailyCarbLimitMinutes
        profile.nightFast = NightFast(isEnabled: diet.isPremium, startHour: data.nightLockHour, startMinute: data.nightLockMinute, endHour: data.windowStartHour, endMinute: data.windowStartMinute)
        profile.cheatsPerWeek = diet.isPremium ? profile.plan.defaultCheatsPerWeek : Entitlement.freeCheatsPerWeek
        do {
            try diet.activateDiet(profile: profile); error = nil; activated = true
            withAnimation(reduceMotion ? .easeOut(duration: 0.15) : .spring(response: 0.6, dampingFraction: 0.7)) { reveal = true }
        } catch { self.error = error.localizedDescription }
    }
}

struct CelebrationParticles: View {
    @State private var fall = false
    private let colors: [Color] = [AppTheme.shared.colors.primary, .orange, .purple, .white]
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<24) { index in
                Circle().fill(colors[index % colors.count]).frame(width: CGFloat(4 + index % 5), height: CGFloat(4 + index % 5))
                    .position(x: CGFloat((index * 73) % 100) / 100 * geo.size.width, y: fall ? geo.size.height + 20 : -20)
                    .opacity(fall ? 0 : 1)
                    .animation(.easeIn(duration: 2).delay(Double(index % 7) * 0.07), value: fall)
            }
        }.onAppear { fall = true }
    }
}
