import SwiftUI

// MARK: - Shared sheet pieces (v2 design: V2A-FocusFast / V2A-ExtraServing)

private struct SheetEyebrow: View {
    @Environment(\.kitchenTheme) private var theme
    let text: String
    var body: some View { Text(text).kitchenEyebrow().foregroundStyle(theme.faint).frame(maxWidth: .infinity, alignment: .leading) }
}

private struct SheetRow: View {
    @Environment(\.kitchenTheme) private var theme
    let label: String
    let value: String
    var dot: Color? = nil
    var valueColor: Color? = nil
    var body: some View {
        HStack(spacing: 10) {
            Text(label).font(KitchenFont.body(13)).foregroundStyle(theme.muted)
            Spacer(minLength: 8)
            HStack(spacing: 6) {
                if let dot { Circle().fill(dot).frame(width: 10, height: 10) }
                Text(value).font(.custom(KitchenFont.manrope, size: 13, relativeTo: .footnote).weight(.heavy))
                    .foregroundStyle(valueColor ?? theme.text).multilineTextAlignment(.trailing)
            }
        }
        .frame(minHeight: 48)
        .accessibilityElement(children: .combine)
    }
}

private struct SheetDone<Icon: View>: View {
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let title: String
    let note: String
    @ViewBuilder var icon: () -> Icon
    @State private var shown = false
    var body: some View {
        VStack(spacing: 14) {
            icon().scaleEffect(shown || reduceMotion ? 1 : 0.3).opacity(shown ? 1 : 0)
            Text(title).font(KitchenFont.headline(28)).tracking(-0.8).multilineTextAlignment(.center).foregroundStyle(theme.text)
            Text(note).font(KitchenFont.body(14)).foregroundStyle(theme.muted).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .onAppear {
            if reduceMotion { withAnimation(.easeOut(duration: 0.2)) { shown = true } }
            else { withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { shown = true } }
        }
    }
}

private extension View {
    /// Staggered rise (0.1 s per step) for the sheet content.
    func sheetRise(_ shown: Bool, _ step: Int, reduceMotion: Bool) -> some View {
        opacity(shown ? 1 : 0)
            .offset(y: shown || reduceMotion ? 0 : 14)
            .animation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.55, dampingFraction: 0.8).delay(0.3 + Double(step) * 0.1), value: shown)
    }
}

// MARK: - Focus Fast

struct FocusFastSheet: View {
    @Environment(DietManager.self) private var diet
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var choice = "60"
    @State private var started = false
    @State private var shown = false

    private let theme = KitchenTheme.lamp
    private var protein: Color { theme.color(for: .protein) }
    private var morning: Int { max(15, diet.dietProfile?.eatingWindow.minutesUntilNextOpen() ?? 480) }

    private struct Option: Identifiable { let id: String; let big: String; let small: String; let minutes: Int }

    private var options: [Option] {
        var list = [Option(id: "15", big: "15", small: "min", minutes: 15),
                    Option(id: "30", big: "30", small: "min", minutes: 30),
                    Option(id: "60", big: "1", small: "hour", minutes: 60),
                    Option(id: "120", big: "2", small: "hours", minutes: 120)]
        let cal = Calendar.current
        if let eight = cal.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) {
            let m = Int(eight.timeIntervalSinceNow / 60)
            if m >= 15 { list.append(Option(id: "eve", big: "Until", small: "8 PM", minutes: m)) }
        }
        list.append(Option(id: "open", big: "Until", small: "opening", minutes: morning))
        return Array(list.suffix(6))
    }
    private var selected: Option { options.first { $0.id == choice } ?? options[0] }
    private func endTime(_ o: Option) -> String {
        Date().addingTimeInterval(Double(o.minutes) * 60).formatted(date: .omitted, time: .shortened)
    }
    private var durLabel: String { selected.big == "Until" ? "until \(selected.small == "opening" ? endTime(selected) : selected.small)" : "\(selected.big) \(selected.small)" }

    private func begin() {
        guard !started else { return }
        diet.startFast(minutes: selected.minutes)
        withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.55, dampingFraction: 0.8)) { started = true }
    }

    var body: some View {
        ZStack {
            KitchenBackground(theme: theme)
            if started { doneView.transition(.opacity) } else { formView }
        }
        .environment(\.kitchenTheme, theme)
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(32)
        .presentationBackground(theme.bg)
        .onAppear { shown = true }
    }

    private var doneView: some View {
        VStack {
            SheetDone(title: "Something good\nis cooking.", note: "Carbs and Fats rest until \(endTime(selected)).") {
                Image(systemName: "checkmark").font(.system(size: 30, weight: .bold)).foregroundStyle(Color(hex: "2A1A08"))
                    .frame(width: 72, height: 72).background(protein, in: Circle())
            }
            KitchenPrimaryButton(title: "Back to my kitchen") { dismiss() }
        }.padding(.horizontal, 20).padding(.bottom, 20)
    }

    private var formView: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    Image("FocusGarden").resizable().scaledToFill().frame(width: 76, height: 76)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous)).accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Focus Fast").font(KitchenFont.headline(28)).tracking(-0.8).foregroundStyle(theme.text)
                        Text("Close the kitchen for a little while.").font(KitchenFont.body(13)).foregroundStyle(theme.muted)
                    }
                    Spacer(minLength: 0)
                }.padding(.top, 24).sheetRise(shown, 0, reduceMotion: reduceMotion)

                SheetEyebrow(text: "How long?").padding(.top, 22).sheetRise(shown, 1, reduceMotion: reduceMotion)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                    ForEach(options) { o in durationChip(o) }
                }.padding(.top, 10).sheetRise(shown, 1, reduceMotion: reduceMotion)

                SheetEyebrow(text: "While you focus").padding(.top, 20).sheetRise(shown, 2, reduceMotion: reduceMotion)
                VStack(spacing: 0) {
                    SheetRow(label: "Carbs", value: "Rest", dot: theme.color(for: .carbs))
                    Divider().overlay(theme.line)
                    SheetRow(label: "Fats", value: "Rest", dot: theme.color(for: .fats))
                    Divider().overlay(theme.line)
                    SheetRow(label: "Protein", value: "Stays open", dot: protein, valueColor: protein)
                }
                .padding(.horizontal, 14).kitchenCard(theme).padding(.top, 10).sheetRise(shown, 2, reduceMotion: reduceMotion)

                if diet.isCheatMealActive {
                    Text("Starting a focus fast ends your current extra serving.").font(KitchenFont.label(12)).foregroundStyle(protein)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.top, 12)
                }
            }
            .padding(.horizontal, 20).frame(maxWidth: 600).frame(maxWidth: .infinity)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 6) {
                SlideToStart(label: "Slide to start · \(durLabel)", tint: protein, onConfirm: begin)
                Button("Start without sliding", action: begin)
                    .font(KitchenFont.label(13)).foregroundStyle(theme.faint).frame(maxWidth: .infinity, minHeight: 44)
                    .accessibilityHint("Starts a \(durLabel) Focus Fast")
            }
            .padding(.horizontal, 20).padding(.bottom, 8).frame(maxWidth: 600).frame(maxWidth: .infinity)
            .sheetRise(shown, 3, reduceMotion: reduceMotion)
        }
    }

    private func durationChip(_ o: Option) -> some View {
        let on = o.id == choice
        return Button {
            withAnimation(.easeInOut(duration: 0.25)) { choice = o.id }
        } label: {
            VStack(spacing: 0) {
                Text(o.big).font(KitchenFont.headline(20))
                Text(o.small).font(KitchenFont.label(11)).opacity(0.75)
            }
            .foregroundStyle(on ? Color(hex: "2A1A08") : theme.text)
            .frame(maxWidth: .infinity, minHeight: 64)
            .background(on ? protein : theme.surface, in: RoundedRectangle(cornerRadius: KitchenMetrics.chipRadius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: KitchenMetrics.chipRadius, style: .continuous).strokeBorder(on ? .clear : theme.line, lineWidth: 1))
        }
        .buttonStyle(TactileButtonStyle())
        .sensoryFeedback(.selection, trigger: choice)
        .accessibilityAddTraits(on ? .isSelected : [])
        .accessibilityLabel(o.big == "Until" ? "Until \(o.small == "opening" ? endTime(o) : o.small)" : "\(o.big) \(o.small)")
    }
}

/// Slide-to-confirm pill (64 pt track, 56 pt knob). Snaps back unless dragged past 85 %.
private struct SlideToStart: View {
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let label: String
    let tint: Color
    let onConfirm: () -> Void
    @State private var x: CGFloat = 0
    @State private var dragging = false
    @State private var nudge = false
    @State private var tick = 0
    @State private var done = 0
    private let knob: CGFloat = 56

    var body: some View {
        GeometryReader { geo in
            let maxX = geo.size.width - knob - 8
            ZStack(alignment: .leading) {
                Capsule().fill(theme.surface)
                Capsule().fill(tint.opacity(0.22)).frame(width: x + knob + 8)
                Text(label).font(KitchenFont.label(15)).foregroundStyle(theme.muted).lineLimit(1).minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity).padding(.leading, 56).padding(.trailing, 16)
                    .opacity(1 - Double(x / max(maxX, 1)) * 0.8)
                Image(systemName: "arrow.right").font(.system(size: 20, weight: .bold)).foregroundStyle(theme.buttonText)
                    .frame(width: knob, height: knob).background(theme.buttonBg, in: Circle())
                    .shadow(color: .black.opacity(0.35), radius: 8, y: 6)
                    .offset(x: 4 + x + (nudge && x == 0 ? 10 : 0))
            }
            .overlay(Capsule().strokeBorder(theme.line2, lineWidth: 1))
            .clipShape(Capsule())
            .contentShape(Capsule())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { v in
                        if !dragging { dragging = true; tick += 1 }
                        x = max(0, min(maxX, v.location.x - knob / 2 - 4))
                    }
                    .onEnded { _ in
                        dragging = false
                        if x > maxX * 0.85 {
                            withAnimation(.easeOut(duration: 0.15)) { x = maxX }
                            done += 1
                            onConfirm()
                        } else {
                            withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.35, dampingFraction: 0.65)) { x = 0 }
                        }
                    }
            )
        }
        .frame(height: 64)
        .sensoryFeedback(.impact(weight: .light), trigger: tick)
        .sensoryFeedback(.success, trigger: done)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.35).repeatForever(autoreverses: true).delay(1.2)) { nudge = true }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { onConfirm() }
    }
}

// MARK: - Extra serving (formerly "cheat meal")

struct CheatMealSheet: View {
    @Environment(DietManager.self) private var diet
    @Environment(EntitlementManager.self) private var entitlements
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var error: String?
    @State private var done = false
    @State private var shown = false
    @State private var endsAt = Date()

    private let theme = KitchenTheme.daylight
    private var carbs: Color { theme.color(for: .carbs) }
    private var blocked: Bool { diet.currentDietState == .nightFast || diet.currentDietState == .fastNow }
    private var minutes: Int { DietRules.cheatMealMinutes }
    private var allowed: Int {
        guard let p = diet.dietProfile else { return 0 }
        return Entitlement.clampedCheats(p.cheatsPerWeek, isPremium: diet.isPremium)
    }
    private var portion: Int { diet.dietProfile?.portionMinutes ?? 0 }
    private var served: Int { min(portion, diet.sharedState.counters.carbMinutes) }
    private var resetDay: String {
        let cal = Calendar.current
        return cal.weekdaySymbols[(cal.firstWeekday - 1) % 7]
    }

    private func use() {
        do { try diet.useCheatMeal(); endsAt = diet.cheatMealExpiresAt ?? Date().addingTimeInterval(Double(minutes) * 60)
            withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.55, dampingFraction: 0.8)) { done = true }
        } catch { self.error = error.localizedDescription }
    }

    var body: some View {
        ZStack {
            KitchenBackground(theme: theme)
            if done { doneView.transition(.opacity) } else { content }
        }
        .environment(\.kitchenTheme, theme)
        .preferredColorScheme(.light)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(32)
        .presentationBackground(theme.bg)
        .onAppear { shown = true }
    }

    private var doneView: some View {
        VStack {
            SheetDone(title: "Enjoy it.", note: "Carbs are open for \(minutes) minutes,\nuntil \(endsAt.formatted(date: .omitted, time: .shortened)).") {
                Image(systemName: "play.rectangle").font(.system(size: 20, weight: .semibold)).foregroundStyle(.white)
                    .frame(width: 40, height: 40).background(Color(hex: "C2577A"), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .frame(width: 84, height: 84).background(theme.plate, in: Circle())
                    .shadow(color: Color(hex: "5A401E").opacity(0.18), radius: 14, y: 14)
                    .overlay(Circle().stroke(theme.soft(.carbs, opacity: 0.10), lineWidth: 8).padding(-4))
            }
            KitchenPrimaryButton(title: "Back to my kitchen") { dismiss() }
        }.padding(.horizontal, 20).padding(.bottom, 20)
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    Text("+\(minutes)").font(KitchenFont.headline(26)).foregroundStyle(carbs)
                        .frame(width: 96, height: 96).background(Color.white, in: Circle())
                        .shadow(color: Color(hex: "5A401E").opacity(0.16), radius: 14, y: 14)
                        .overlay(Circle().stroke(theme.soft(.carbs, opacity: 0.10), lineWidth: 8).padding(-4))
                        .modifier(Wobble(active: !reduceMotion))
                        .accessibilityHidden(true)
                    Text("One extra serving").font(KitchenFont.headline(30)).tracking(-1).foregroundStyle(theme.text)
                    Text("\(minutes) more minutes of Carbs, right now.").font(KitchenFont.body(14)).foregroundStyle(theme.muted)
                }
                .multilineTextAlignment(.center).frame(maxWidth: .infinity).padding(.top, 36)
                .sheetRise(shown, 0, reduceMotion: reduceMotion)

                VStack(spacing: 0) {
                    SheetRow(label: "This week", value: "\(diet.cheatsRemaining) of \(allowed) left", dot: carbs)
                    Divider().overlay(theme.line)
                    SheetRow(label: "Today’s portion", value: "\(served) of \(portion) min served")
                    Divider().overlay(theme.line)
                    SheetRow(label: "Resets", value: resetDay)
                }
                .padding(.horizontal, 14).kitchenCard(theme).padding(.top, 22).sheetRise(shown, 1, reduceMotion: reduceMotion)

                Text("Night Fast and Focus Fast still apply. An extra serving only opens Carbs.")
                    .font(KitchenFont.body(12)).foregroundStyle(theme.faint).padding(.horizontal, 6).padding(.top, 10)
                    .frame(maxWidth: .infinity, alignment: .leading).sheetRise(shown, 2, reduceMotion: reduceMotion)

                if diet.isCheatMealActive {
                    notice("Your extra serving is already active. Your routine resumes afterward.")
                }
                if blocked { notice("Let this fast finish first. An extra serving can’t lift Night Fast or Focus Fast.") }
                if let error { notice(error) }
            }
            .padding(.horizontal, 20).frame(maxWidth: 600).frame(maxWidth: .infinity)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 6) {
                if blocked {
                    KitchenPrimaryButton(title: "Back to my kitchen") { dismiss() }
                } else if diet.isCheatMealActive {
                    KitchenPrimaryButton(title: "Back to my kitchen") { dismiss() }
                    Button("End extra serving early") { diet.endCheatMeal(); dismiss() }
                        .font(KitchenFont.label(14)).foregroundStyle(theme.muted).frame(maxWidth: .infinity, minHeight: 44)
                } else if diet.cheatsRemaining > 0 {
                    HoldToServe(title: "Press and hold", tint: carbs, onConfirm: use)
                    Button("Keep it for later") { dismiss() }
                        .font(KitchenFont.label(14)).foregroundStyle(theme.muted).frame(maxWidth: .infinity, minHeight: 44)
                } else {
                    KitchenPrimaryButton(title: "Explore more flexibility", systemImage: "sparkles") { entitlements.presentPaywall(.cheatOut) }
                    Button("Keep it for later") { dismiss() }
                        .font(KitchenFont.label(14)).foregroundStyle(theme.muted).frame(maxWidth: .infinity, minHeight: 44)
                }
            }
            .padding(.horizontal, 20).padding(.bottom, 8).frame(maxWidth: 600).frame(maxWidth: .infinity)
            .sheetRise(shown, 3, reduceMotion: reduceMotion)
        }
    }

    private func notice(_ text: String) -> some View {
        Text(text).font(KitchenFont.label(12)).foregroundStyle(carbs)
            .frame(maxWidth: .infinity, alignment: .leading).padding(.top, 12)
    }
}

private struct Wobble: ViewModifier {
    let active: Bool
    @State private var flip = false
    func body(content: Content) -> some View {
        content.rotationEffect(.degrees(active ? (flip ? 4 : -4) : 0))
            .onAppear { if active { withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) { flip = true } } }
    }
}

/// Press-and-hold pill: fills with the tint in ~1 s, release resets. VoiceOver confirms instantly.
private struct HoldToServe: View {
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let title: String
    let tint: Color
    let onConfirm: () -> Void
    @State private var progress: CGFloat = 0
    @State private var pressing = false
    @State private var tick = 0
    @State private var confirmed = 0
    private let hold: TimeInterval = 1.0

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule().fill(theme.buttonBg)
            GeometryReader { geo in Rectangle().fill(tint).frame(width: geo.size.width * progress) }
                .clipShape(Capsule())
            Text(pressing ? "Keep holding…" : title).font(KitchenFont.button).foregroundStyle(theme.buttonText)
                .frame(maxWidth: .infinity)
        }
        .frame(height: 60)
        .contentShape(Capsule())
        .onLongPressGesture(minimumDuration: hold, maximumDistance: 40, perform: {
            confirmed += 1
            onConfirm()
        }, onPressingChanged: { p in
            pressing = p
            if p {
                tick += 1
                if reduceMotion { withAnimation(.easeOut(duration: 0.2)) { progress = 1 } }
                else { withAnimation(.linear(duration: hold)) { progress = 1 } }
            } else {
                withAnimation(.easeOut(duration: reduceMotion ? 0.15 : 0.3)) { progress = 0 }
            }
        })
        .sensoryFeedback(.impact(weight: .light), trigger: tick)
        .sensoryFeedback(.success, trigger: confirmed)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Use your extra serving")
        .accessibilityHint("Opens Carbs for a short time")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { onConfirm() }
    }
}
