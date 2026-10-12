import SwiftUI
import DeviceActivity
import FamilyControls

/// v2 Kitchen tab (spec §1, canvas "V2A-Kitchen"): one view whose theme, artwork and copy follow the five states.
/// `DietRules` resolves the state (fastNow > nightFast > portionHit > closed > open); this view only presents it.
struct KitchenView: View {
    @Environment(DietManager.self) private var diet
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showFast = false
    @State private var showCheat = false
    @State private var showSetup = false
    @State private var endFast = false

    private var active: Bool { diet.dietProfile?.isActive == true }
    private var state: DietState { diet.currentDietState }
    private var theme: KitchenTheme { KitchenTheme(state: state) }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { timeline in
            KitchenScreen(
                model: KitchenModel(diet: diet, now: timeline.date),
                onFocus: { diet.isFastActive ? (endFast = true) : (showFast = true) },
                onExtra: { showCheat = true },
                onSetup: { showSetup = true }
            )
        }
        .environment(\.kitchenTheme, theme)
        .kitchenBackground(theme)
        .preferredColorScheme(theme.colorScheme)
        .animation(reduceMotion ? .easeOut(duration: 0.2) : KitchenMetrics.crossFade, value: state)
        .sheet(isPresented: $showFast) { FocusFastSheet().paywallPresenter() }
        .sheet(isPresented: $showCheat) { CheatMealSheet().paywallPresenter() }
        .fullScreenCover(isPresented: $showSetup) { OnboardingView { showSetup = false }.paywallPresenter() }
        .alert("End this fast?", isPresented: $endFast) {
            Button("Keep going", role: .cancel) { }
            Button("End fast") { diet.endFast() }
        } message: { Text("Your normal routine will resume. Other scheduled rules still apply.") }
    }
}

// MARK: - Presentation model

/// Everything the Kitchen screen shows for one state, derived from `DietManager`.
struct KitchenModel {
    var state: DietState
    var date: Date
    var plan: String
    var active: Bool
    var art: String
    var pill: String
    var pillColor: KitchenPillColor
    var head: String
    var sub: String
    var ringLabel: String
    var ringValue: String
    var ringNote: String
    var ringColor: KitchenRingColor
    var ringFraction: Double
    var ringCenter: String
    var streak: Int
    var extrasLeft: Int
    var countdownEnd: Date?
    var focusTitle: String
    var focusSub: String
    var focusEnabled: Bool
    var extraSub: String
    var extraEnabled: Bool
    var extraIsPrimary: Bool
    var focusIsPrimary = false
    var windowStartHour: Double
    var windowEndHour: Double
    var nightStartHour: Double
    var nightEndHour: Double
    var nowHour: Double
    var timelineCaption: String

    enum KitchenPillColor { case fats, carbs, lamp, night, protein }
    enum KitchenRingColor { case carbs, lamp, protein }

    init(diet: DietManager, now: Date) {
        let state = diet.currentDietState
        let profile = diet.dietProfile
        let portion = max(1, profile?.portionMinutes ?? 45)
        let remaining = diet.carbsRemainingMinutes
        let nextTime: String = {
            guard let profile else { return "" }
            if state == .nightFast { return profile.nightFast.endTimeString }
            return state == .windowOpen ? profile.eatingWindow.endTimeString : profile.eatingWindow.startTimeString
        }()
        let cal = Calendar.current
        func hour(_ h: Int, _ m: Int) -> Double { Double(h) + Double(m) / 60 }

        self.state = state
        self.date = now
        self.plan = profile?.plan.kitchenName ?? "Balanced"
        self.active = profile?.isActive == true
        self.streak = diet.fastStreak
        self.extrasLeft = diet.cheatsRemaining
        self.windowStartHour = hour(profile?.eatingWindow.startHour ?? 12, profile?.eatingWindow.startMinute ?? 0)
        self.windowEndHour = hour(profile?.eatingWindow.endHour ?? 20, profile?.eatingWindow.endMinute ?? 0)
        self.nightStartHour = hour(profile?.nightFast.startHour ?? 22, profile?.nightFast.startMinute ?? 0)
        self.nightEndHour = hour(profile?.nightFast.endHour ?? 7, profile?.nightFast.endMinute ?? 0)
        self.nowHour = hour(cal.component(.hour, from: now), cal.component(.minute, from: now))
        self.timelineCaption = profile.map { "Kitchen \($0.eatingWindow.startTimeString)–\($0.eatingWindow.endTimeString)" + ($0.nightFast.isEnabled ? " · Night Fast \($0.nightFast.startTimeString)–\($0.nightFast.endTimeString)" : "") } ?? ""
        self.countdownEnd = nil

        switch state {
        case .windowOpen, .inactive:
            art = "DigitalGarden"; pill = "Now serving"; pillColor = .fats
            head = state == .inactive ? "Ready for a fresh start?" : "Your kitchen is open."
            sub = state == .inactive ? "Choose your ingredients and build a routine around your life." : "A fresh portion, served with intention."
            ringLabel = "Carbs today"; ringValue = "≈ \(remaining) min left"; ringNote = "\(portion - remaining) of \(portion) min served"
            ringColor = .carbs; ringFraction = Double(remaining) / Double(portion); ringCenter = "\(remaining)m"
            focusTitle = "Focus Fast"; focusSub = "Close for a while"; focusEnabled = true
            extraSub = "15 min of Carbs"; extraEnabled = true; extraIsPrimary = false
        case .fasting:
            art = "LifeReclaimed"; pill = "Kitchen at rest"; pillColor = .lamp
            head = "Closed for a little balance."; sub = "Opens at \(nextTime). Protein stays on the table."
            ringLabel = "Opens at"; ringValue = nextTime; ringNote = "Your \(portion) min portion is waiting"
            ringColor = .lamp; ringFraction = 1; ringCenter = "\(portion)m"
            focusTitle = "Focus Fast"; focusSub = "Fats rest too"; focusEnabled = true
            extraSub = "15 min, right now"; extraEnabled = true; extraIsPrimary = false
        case .portionHit:
            art = "BalancedPantry"; pill = "Portion served"; pillColor = .carbs
            head = "Your portion is served."; sub = "Carbs return tomorrow at \(profile?.eatingWindow.startTimeString ?? ""). Fats and Protein stay open."
            ringLabel = "Carbs today"; ringValue = "0 min left"; ringNote = "\(portion) of \(portion) min served"
            ringColor = .carbs; ringFraction = 0; ringCenter = "Done"
            focusTitle = "Focus Fast"; focusSub = "Close for a while"; focusEnabled = true
            extraSub = diet.cheatsRemaining > 0 ? "Use your \(diet.cheatsRemaining) extra" : "None left this week"
            extraEnabled = diet.cheatsRemaining > 0; extraIsPrimary = diet.cheatsRemaining > 0
        case .nightFast:
            art = "NightGarden"; pill = "Night Fast"; pillColor = .night
            head = "Let the kitchen rest."; sub = "Carbs and Fats rest until \(nextTime)."
            ringLabel = "Night Fast"; ringValue = "Until \(nextTime)"; ringNote = "Protein is still available"
            ringColor = .lamp; ringFraction = min(1, diet.fastingProgress / 100); ringCenter = "\(Int(min(100, diet.fastingProgress)))%"
            focusTitle = "Focus Fast"; focusSub = "Already resting"; focusEnabled = false
            extraSub = "Not during Night Fast"; extraEnabled = false; extraIsPrimary = false
        case .fastNow:
            art = "FocusGarden"; pill = "Focus Fast"; pillColor = .protein
            head = "Something good is cooking."; sub = "Carbs and Fats rest while you focus."
            let end = diet.fastEndsAt
            ringLabel = "Focus Fast"; ringValue = end.map { "Ends at \($0.formatted(date: .omitted, time: .shortened))" } ?? "In progress"
            ringNote = "Protein is still available"; ringColor = .protein
            ringFraction = end.map { max(0, min(1, $0.timeIntervalSince(now) / 3600)) } ?? 0.5
            ringCenter = end.map { "\(max(0, Int($0.timeIntervalSince(now) / 60)))m" } ?? "—"
            countdownEnd = end
            focusTitle = "End early"; focusSub = "Return to your rhythm"; focusEnabled = true
            extraSub = "Not during a fast"; extraEnabled = false; extraIsPrimary = false
        }
        if diet.isCheatMealActive, state == .windowOpen || state == .fasting || state == .portionHit {
            pill = "Extra serving"; pillColor = .carbs
            head = "Enjoy a little flexibility."; sub = "Night Fast and Focus Fast still take priority."
            countdownEnd = diet.cheatMealExpiresAt
        }
        focusIsPrimary = state == .fastNow
    }
}

extension DietPlan {
    /// v2 display names (spec §9). Code enums stay as they are.
    var kitchenName: String {
        switch self { case .lean: "Balanced"; case .keto: "Maker"; case .detox: "Reset"; case .custom: "Custom" }
    }
}

// MARK: - Screen

private struct KitchenScreen: View {
    @Environment(\.kitchenTheme) private var theme
    let model: KitchenModel
    let onFocus: () -> Void
    let onExtra: () -> Void
    let onSetup: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                header.editorialEntrance(delay: 0.05)
                hero.editorialEntrance(delay: 0.15)
                if model.active {
                    statusRing.editorialEntrance(delay: 0.25)
                    stats.editorialEntrance(delay: 0.35)
                    actions.editorialEntrance(delay: 0.45)
                    dayTimeline.editorialEntrance(delay: 0.55)
                } else {
                    KitchenPrimaryButton(title: "Build my routine", systemImage: "arrow.right", action: onSetup)
                        .padding(.top, 8).editorialEntrance(delay: 0.25)
                }
            }
            .padding(.horizontal, KitchenMetrics.cardMargin)
            .padding(.top, 8).padding(.bottom, 24)
            .frame(maxWidth: 600).frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .foregroundStyle(theme.text)
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text(model.date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())).kitchenEyebrow().foregroundStyle(theme.faint)
                Text("Your Kitchen").font(KitchenFont.headline(30)).tracking(-1)
            }
            Spacer()
            if model.active {
                Text(model.plan).kitchenEyebrow().tracking(1)
                    .padding(.horizontal, 12).frame(height: 30)
                    .background(theme.surface, in: Capsule()).overlay(Capsule().stroke(theme.line, lineWidth: 1))
            }
        }
    }

    private var pillColor: Color {
        switch model.pillColor {
        case .fats: theme.color(for: .fats)
        case .carbs: theme.color(for: .carbs)
        case .protein: theme.color(for: .protein)
        case .lamp: Color(hex: "B8862C")
        case .night: Color(hex: "6C74C9")
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            Color.clear.overlay { DietHeroArt(asset: model.art) }.clipped()
            LinearGradient(colors: [Color(hex: "0A0908").opacity(0), Color(hex: "0A0908").opacity(0.78)], startPoint: UnitPoint(x: 0.5, y: 0.3), endPoint: .bottom)
            VStack(alignment: .leading, spacing: 4) {
                Text(model.head).font(KitchenFont.headline(24)).tracking(0)
                Text(model.sub).font(KitchenFont.body(13)).opacity(0.88)
            }
            .foregroundStyle(Color(hex: "FFFDF8")).padding(.horizontal, 18).padding(.bottom, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack { HStack { StatusPill(text: model.pill, color: pillColor, showsDot: true, onArtwork: true); Spacer() }; Spacer() }.padding(14)
        }
        .frame(height: 196)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(theme == .daylight ? 0.12 : 0.45), radius: 20, y: 14)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(model.pill). \(model.head) \(model.sub)")
    }

    private var ringColor: Color {
        switch model.ringColor {
        case .carbs: theme.color(for: .carbs)
        case .protein: theme.color(for: .protein)
        case .lamp: theme.lamp
        }
    }

    private var statusRing: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(model.ringLabel).kitchenEyebrow().tracking(1.3).foregroundStyle(ringColor)
                Group {
                    if let end = model.countdownEnd, end > model.date {
                        Text(timerInterval: model.date...end, countsDown: true).monospacedDigit()
                    } else {
                        Text(model.ringValue)
                    }
                }
                .font(KitchenFont.bigNumber(24)).tracking(-0.6).contentTransition(.numericText())
                Text(model.ringNote).font(KitchenFont.body(12)).foregroundStyle(theme.muted)
            }
            Spacer(minLength: 8)
            ProgressRing(fraction: model.ringFraction, color: ringColor, center: model.ringCenter)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .kitchenCard(theme)
        .accessibilityElement(children: .combine)
    }

    private var stats: some View {
        HStack(spacing: 10) {
            statCard(symbol: "leaf", group: .fats, value: "\(model.streak) \(model.streak == 1 ? "day" : "days")", label: "of showing up")
            statCard(symbol: "ticket", group: .protein, value: "\(model.extrasLeft) left", label: "extra serving this week")
        }.fixedSize(horizontal: false, vertical: true)
    }

    private func statCard(symbol: String, group: KitchenFoodGroup, value: String, label: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol).font(.system(size: 16, weight: .semibold)).foregroundStyle(theme.color(for: group))
                .frame(width: 36, height: 36).background(theme.soft(group), in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 0) {
                Text(value).font(KitchenFont.body(16).weight(.heavy))
                Text(label).font(KitchenFont.body(11)).foregroundStyle(theme.muted).lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .frame(maxHeight: .infinity)
        .kitchenCard(theme, radius: 20)
        .accessibilityElement(children: .combine)
    }

    private var actions: some View {
        HStack(spacing: 10) {
            actionTile(title: model.focusTitle, sub: model.focusSub, symbol: "hourglass", primary: model.focusIsPrimary, enabled: model.focusEnabled, action: onFocus)
            actionTile(title: "Extra serving", sub: model.extraSub, symbol: "circle.circle", primary: model.extraIsPrimary, enabled: model.extraEnabled, action: onExtra)
        }
    }

    private func actionTile(title: String, sub: String, symbol: String, primary: Bool, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Label(title, systemImage: symbol).font(KitchenFont.body(14).weight(.heavy))
                Text(sub).font(KitchenFont.body(12)).opacity(0.75)
            }
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading).padding(.horizontal, 14).padding(.vertical, 12)
            .foregroundStyle(primary ? theme.buttonText : enabled ? theme.text : theme.faint)
            .background(primary ? theme.buttonBg : theme.surface, in: RoundedRectangle(cornerRadius: 20))
            .overlay { if !primary { RoundedRectangle(cornerRadius: 20).stroke(theme.line, lineWidth: 1) } }
            .opacity(enabled ? 1 : 0.7)
        }
        .buttonStyle(TactileButtonStyle())
        .disabled(!enabled)
    }

    private var dayTimeline: some View {
        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text("Today").font(KitchenFont.label(12).weight(.bold))
                Spacer()
                Text(model.timelineCaption).font(KitchenFont.label(11)).foregroundStyle(theme.muted).lineLimit(1).minimumScaleFactor(0.8)
            }
            GeometryReader { geo in
                let w = geo.size.width
                let nightColor = theme == .night ? Color(hex: "F3D9A4").opacity(0.35) : theme == .daylight ? Color(hex: "3C468C").opacity(0.22) : Color(hex: "96A0FF").opacity(0.22)
                ZStack(alignment: .leading) {
                    Capsule().fill(theme.surface2)
                    // Night Fast wraps midnight: [start, 24] and [0, end].
                    ForEach(wrapped(model.nightStartHour, model.nightEndHour), id: \.0) { r in
                        segment(from: r.0, to: r.1, width: w, color: nightColor)
                    }
                    ForEach(wrapped(model.windowStartHour, model.windowEndHour), id: \.0) { r in
                        segment(from: r.0, to: r.1, width: w, color: theme.color(for: .carbs))
                    }
                    RoundedRectangle(cornerRadius: 2).fill(theme.text).frame(width: 3, height: 20)
                        .overlay(RoundedRectangle(cornerRadius: 2).stroke(theme.surface, lineWidth: 2))
                        .offset(x: w * model.nowHour / 24 - 1)
                }
                .frame(height: 10)
                .frame(maxHeight: .infinity, alignment: .center)
            }.frame(height: 20)
            HStack {
                ForEach(Array(["12A", "6A", "12P", "6P", "12A"].enumerated()), id: \.offset) { i, t in
                    Text(t); if i < 4 { Spacer() }
                }
            }.font(KitchenFont.label(10).weight(.bold)).foregroundStyle(theme.faint)
        }
        .padding(.horizontal, 4).padding(.top, 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Today's timeline. \(model.timelineCaption)")
    }

    /// Splits a range that may cross midnight into one or two ranges inside 0…24.
    private func wrapped(_ a: Double, _ b: Double) -> [(Double, Double)] {
        b > a ? [(a, b)] : [(a, 24), (0, b)].filter { $0.1 > $0.0 }
    }

    private func segment(from a: Double, to b: Double, width: CGFloat, color: Color) -> some View {
        let s = max(0, min(24, a)), e = max(s, min(24, b))
        return Capsule().fill(color).frame(width: width * (e - s) / 24).offset(x: width * s / 24)
    }
}

/// 76 pt ring: 8 pt stroke, draws on appear.
struct ProgressRing: View {
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let fraction: Double
    let color: Color
    let center: String
    @State private var drawn = false

    var body: some View {
        ZStack {
            Circle().stroke(theme.surface2, lineWidth: 8)
            Circle().trim(from: 0, to: drawn ? max(0.001, min(1, fraction)) : 0)
                .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round)).rotationEffect(.degrees(-90))
            Text(center).font(KitchenFont.label(13).weight(.heavy)).foregroundStyle(theme.text)
        }
        .frame(width: 76, height: 76).padding(4)
        .onAppear { withAnimation(.easeOut(duration: reduceMotion ? 0.2 : 1.2).delay(0.5)) { drawn = true } }
        .onChange(of: fraction) { _, _ in drawn = true }
        .animation(.easeOut(duration: 0.6), value: fraction)
        .accessibilityHidden(true)
    }
}

/// Artwork that settles from 1.12× / 30 % opacity (spec §6 "Hero artwork").
struct DietHeroArt: View {
    let asset: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var settled = false
    var body: some View {
        Image(asset).resizable().scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scaleEffect(settled || reduceMotion ? 1 : 1.12).opacity(settled || reduceMotion ? 1 : 0.3)
            .clipped()
            .onAppear { withAnimation(.easeOut(duration: 1.4)) { settled = true } }
            .id(asset)
            .transition(.opacity)
    }
}
