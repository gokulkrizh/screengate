import SwiftUI
import DeviceActivity
import FamilyControls

struct KitchenView: View {
    @Environment(DietManager.self) private var diet
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showFast = false
    @State private var showCheat = false
    @State private var showSetup = false
    @State private var endFast = false
    private var active: Bool { diet.dietProfile?.isActive == true }
    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { timeline in
            ScrollView {
                VStack(spacing: 24) {
                    DietHeading(eyebrow: timeline.date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()), title: "Your Kitchen", detail: active ? "\(diet.dietProfile?.plan.displayName.capitalized ?? "Lean") routine · Week \(diet.dietProfile?.weekNumber ?? 1)" : "A fresh start is always on the menu.")
                    KitchenHero(state: diet.currentDietState, remaining: diet.carbsRemainingMinutes, portion: diet.dietProfile?.portionMinutes ?? 0, progress: diet.fastingProgress / 100, nextTime: nextTime, endsAt: diet.isCheatMealActive ? diet.cheatMealExpiresAt : diet.fastEndsAt, cheatActive: diet.isCheatMealActive)
                        .id(diet.currentDietState).transition(.opacity).editorialEntrance()
                    if !active {
                        PrimaryButton(title: "Build my routine", icon: "arrow.right") { showSetup = true }
                    } else {
                        if diet.currentDietState == .fastNow {
                            Button("End this focus fast") { endFast = true }.font(.subheadline).foregroundStyle(AppTheme.shared.colors.textSecondary).frame(minHeight: 44)
                        }
                        HStack(alignment: .top, spacing: 12) {
                            DietMetric(icon: "flame.fill", value: "\(diet.fastStreak)", label: "days within portion", tint: .orange)
                            DietMetric(icon: "ticket.fill", value: "\(diet.cheatsRemaining)", label: "cheat meals left", tint: AppTheme.shared.colors.warning)
                        }.editorialEntrance(delay: 0.1)
                        if diet.isCheatMealActive {
                            DietFeatureRow(icon: "ticket.fill", title: "A little flexibility", detail: "Your cheat meal is active. Night Fast and Focus Fast still take priority.", tint: .orange).dietCard(tint: .orange)
                            Button("End cheat meal early") { diet.endCheatMeal() }.frame(minHeight: 44).font(.caption)
                        }
                        if diet.currentDietState != .fastNow {
                            HStack(spacing: 12) {
                                actionTile("Focus Fast", subtitle: "Make some space", icon: "hourglass", tint: AppTheme.shared.colors.primary) { showFast = true }
                                actionTile("Cheat meal", subtitle: "A little flexibility", icon: "ticket", tint: .orange) { showCheat = true }
                            }.editorialEntrance(delay: 0.15)
                        }
                        VStack(alignment: .leading, spacing: 18) {
                            Text("TODAY’S SERVING").font(.caption2.bold()).tracking(1.8).foregroundStyle(AppTheme.shared.colors.primary)
                            HStack {
                                Label("Carbs", systemImage: "birthday.cake.fill").font(.subheadline)
                                Spacer()
                                Text("≈ \(diet.todayLog.carbsMinutes)m").font(.headline.monospacedDigit()).contentTransition(.numericText())
                            }.foregroundStyle(AppTheme.shared.colors.text)
                            ProgressView(value: min(1, Double(diet.todayLog.carbsMinutes) / Double(max(1, diet.dietProfile?.portionMinutes ?? 1)))).tint(AppTheme.shared.colors.primary)
                            Text("Live usage updates in approximate steps. Your report contains the system’s measured activity.").font(.caption).foregroundStyle(AppTheme.shared.colors.textSecondary)
                        }.dietCard().editorialEntrance(delay: 0.2)
                        if ReportFilters.junkSelection(state: diet.sharedState).hasAnyTokens {
                            DeviceActivityReport(DeviceActivityReport.Context(ReportContexts.today), filter: ReportFilters.today(state: diet.sharedState)).frame(height: 300).clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                    }
                    EditorialBanner(eyebrow: "Nourish your attention", title: "The good stuff stays.", detail: "Unselected apps and Protein remain available for learning, creating and real connection.", asset: "LifeReclaimed")
                }.padding(24).frame(maxWidth: 600).frame(maxWidth: .infinity)
            }.background(AppTheme.shared.colors.background.ignoresSafeArea())
        }.animation(reduceMotion ? .easeOut(duration: 0.15) : .spring(response: 0.5, dampingFraction: 0.85), value: diet.currentDietState)
            .sheet(isPresented: $showFast) { FocusFastSheet().paywallPresenter() }
            .sheet(isPresented: $showCheat) { CheatMealSheet().paywallPresenter() }
            .fullScreenCover(isPresented: $showSetup) { OnboardingView { showSetup = false }.paywallPresenter() }
            .alert("End this fast?", isPresented: $endFast) {
                Button("Keep going", role: .cancel) { }
                Button("End fast") { diet.endFast() }
            } message: { Text("Your normal routine will resume. Other scheduled rules still apply.") }
    }
    private var nextTime: String {
        guard let profile = diet.dietProfile else { return "" }
        if diet.currentDietState == .nightFast { return profile.nightFast.endTimeString }
        return diet.currentDietState == .windowOpen ? profile.eatingWindow.endTimeString : profile.eatingWindow.startTimeString
    }
    private func actionTile(_ title: String, subtitle: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon).font(.title2).foregroundStyle(tint)
                Text(title).font(.subheadline.bold()).foregroundStyle(AppTheme.shared.colors.text)
                Text(subtitle).font(.caption).foregroundStyle(AppTheme.shared.colors.textSecondary)
            }.frame(maxWidth: .infinity, alignment: .leading).dietCard(tint: tint)
        }.buttonStyle(TactileButtonStyle())
    }
}

struct KitchenHero: View {
    let state: DietState
    let remaining: Int
    let portion: Int
    let progress: Double
    let nextTime: String
    var endsAt: Date?
    var cheatActive = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var revealed = false
    private var asset: String {
        switch state { case .nightFast, .fasting: return "NightGarden"; case .fastNow: return "FocusGarden"; case .portionHit: return "LifeReclaimed"; case .inactive: return "FreshStart"; case .windowOpen: return "DigitalGarden" }
    }
    private var title: String {
        if cheatActive { return "Enjoy a little flexibility." }
        switch state { case .windowOpen: return "Your kitchen is open."; case .portionHit: return "A full plate. A fresh pause."; case .nightFast: return "Let the night be yours."; case .fastNow: return "Room to focus."; case .fasting: return "A little breathing room."; case .inactive: return "Ready for a fresh start?" }
    }
    private var detail: String {
        switch state { case .windowOpen: return "Enjoy your portion with intention. Kitchen closes at \(nextTime)."; case .portionHit: return "Your daily Carbs portion is used. Productive apps stay available."; case .nightFast: return "Carbs and Fats are resting until \(nextTime)."; case .fastNow: return "Carbs and Fats are paused. Your productive apps are still here."; case .fasting: return "Carbs are off the menu until \(nextTime). Fats and Protein remain available."; case .inactive: return "Choose your ingredients and build a routine around your life." }
    }
    var body: some View {
        VStack(spacing: 20) {
            DietArtwork(asset: asset, height: 190)
            Text(title).font(.system(.title, design: .serif).weight(.semibold)).foregroundStyle(AppTheme.shared.colors.text).multilineTextAlignment(.center)
            if state == .windowOpen && !cheatActive {
                ZStack {
                    Circle().stroke(AppTheme.shared.colors.surfaceVariant, lineWidth: 8)
                    Circle().trim(from: 0, to: revealed ? max(0, min(1, Double(remaining) / Double(max(1, portion)))) : 0)
                        .stroke(AppTheme.shared.colors.primary, style: StrokeStyle(lineWidth: 8, lineCap: .round)).rotationEffect(.degrees(-90))
                    VStack(spacing: 4) {
                        Text("≈ \(remaining)m").font(.system(.title, design: .rounded).bold()).contentTransition(.numericText())
                        Text("ON YOUR PLATE").font(.caption2.bold()).tracking(1)
                    }.foregroundStyle(AppTheme.shared.colors.primary)
                }.frame(width: 146, height: 146).accessibilityElement(children: .combine)
            } else if let endsAt, endsAt > Date(), state == .fastNow || cheatActive {
                Text(timerInterval: Date()...endsAt, countsDown: true).font(.system(.largeTitle, design: .rounded).bold()).monospacedDigit().foregroundStyle(AppTheme.shared.colors.primary)
            } else if state == .fasting {
                ProgressView(value: revealed ? max(0, min(1, progress)) : 0).tint(AppTheme.shared.colors.primary)
            }
            Text(detail).font(.subheadline).foregroundStyle(AppTheme.shared.colors.textSecondary).multilineTextAlignment(.center)
        }.frame(maxWidth: .infinity).dietCard()
            .onAppear { withAnimation(.easeOut(duration: reduceMotion ? 0.15 : 0.9)) { revealed = true } }
    }
}
