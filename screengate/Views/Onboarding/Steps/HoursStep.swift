import SwiftUI

/// Onboarding step 14 · V2-14 "A kitchen with opening hours".
struct HoursStep: View {
    @ObservedObject var data: OnboardingData
    @Environment(\.kitchenTheme) private var theme
    @State private var open: Double = 12      // hours 0…24, snapped to 0.25
    @State private var close: Double = 20

    private var span: Double { HoursClockDial.span(open, close) }

    var body: some View {
        OnboardingPage {
            VStack(alignment: .leading, spacing: 10) {
                OnboardingEyebrow(text: "Give your day some rhythm").rise(1)
                OnboardingTitle(first: "A kitchen with", second: "opening hours.", emphasis: false).rise(2)
            }
            HoursClockDial(open: $open, close: $close).rise(3)
                .padding(.horizontal, -4).padding(.top, 4)
            HStack(spacing: 10) {
                timeCard(title: "Opens", value: label(open), hollow: true)
                timeCard(title: "Closes", value: label(close), hollow: false)
            }
            .padding(.horizontal, -4).rise(3)
            Text("Outside these hours your Carbs apps rest. Fats and Protein stay open.")
                .font(KitchenFont.body(12)).lineSpacing(3).foregroundStyle(theme.faint)
                .padding(.horizontal, 4).rise(3)
        } footer: {
            KitchenPrimaryButton(title: "Set kitchen hours", systemImage: "arrow.right") {
                save(); data.nextScreen()
            }.rise(8)
        }
        .onAppear {
            open = Double(data.windowStartHour) + Double(data.windowStartMinute) / 60
            close = Double(data.windowEndHour) + Double(data.windowEndMinute) / 60
        }
        .onChange(of: open) { _, _ in save() }
        .onChange(of: close) { _, _ in save() }
    }

    private func save() {
        data.windowStartHour = Int(open) % 24; data.windowStartMinute = Int(((open - floor(open)) * 60).rounded())
        data.windowEndHour = Int(close) % 24; data.windowEndMinute = Int(((close - floor(close)) * 60).rounded())
    }

    private func label(_ h: Double) -> String {
        EatingWindow.formatTime(hour: Int(h) % 24, minute: Int(((h - floor(h)) * 60).rounded()))
    }

    private func timeCard(title: String, value: String, hollow: Bool) -> some View {
        let carbs = theme.color(for: .carbs)
        return VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Circle().strokeBorder(carbs, lineWidth: hollow ? 3 : 0).background(Circle().fill(hollow ? .clear : carbs)).frame(width: 10, height: 10)
                Text(title).font(KitchenFont.label(12).weight(.bold)).foregroundStyle(theme.muted)
            }
            Text(value).font(KitchenFont.bigNumber(24)).tracking(-0.6).foregroundStyle(theme.text)
                .contentTransition(.numericText()).minimumScaleFactor(0.7).lineLimit(1)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .kitchenCard(theme, radius: 20)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Kitchen \(title.lowercased()) at \(value)")
    }
}

/// The 240 pt clock dial: spins in, drag either handle, snaps to 15 minutes. Handles are also accessible adjustables.
struct HoursClockDial: View {
    @Binding var open: Double
    @Binding var close: Double
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false
    @State private var active: Handle?
    @State private var tick = 0
    @State private var rejected = 0

    enum Handle { case open, close }

    static func span(_ a: Double, _ b: Double) -> Double {
        let s = (b - a + 24).truncatingRemainder(dividingBy: 24)
        return s == 0 ? 24 : s
    }

    private let side: CGFloat = 240
    private var carbs: Color { theme.color(for: .carbs) }
    private var spanText: String {
        let s = Self.span(open, close); let h = Int(s); let m = Int(((s - floor(s)) * 60).rounded())
        return m == 0 ? "\(h)h" : "\(h)h \(m)m"
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            dial
                .rotationEffect(.degrees(appeared || reduceMotion ? 0 : -120))
                .opacity(appeared ? 1 : 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Text("Drag either handle").font(KitchenFont.label(11)).foregroundStyle(theme.faint).padding(.bottom, 12)
                .accessibilityHidden(true)
        }
        .frame(height: 290)
        .background(theme.surface, in: RoundedRectangle(cornerRadius: 32))
        .overlay(RoundedRectangle(cornerRadius: 32).stroke(theme.line, lineWidth: 1))
        .shadow(color: .black.opacity(theme == .daylight ? 0.12 : 0.4), radius: 20, y: 18)
        .sensoryFeedback(.selection, trigger: tick)
        .sensoryFeedback(.warning, trigger: rejected)
        .onAppear {
            withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .timingCurve(0.2, 0.8, 0.2, 1, duration: 1.1).delay(0.35)) { appeared = true }
        }
    }

    // MARK: Geometry (all in the 240 × 240 dial space)

    private func point(_ hour: Double, radius: CGFloat = 96) -> CGPoint {
        let a = hour / 24 * 2 * .pi
        return CGPoint(x: 120 + radius * sin(a), y: 120 - radius * cos(a))
    }

    private func hour(at p: CGPoint) -> Double {
        var a = atan2(p.x - 120, -(p.y - 120))
        if a < 0 { a += 2 * .pi }
        return (a / (2 * .pi) * 96).rounded().truncatingRemainder(dividingBy: 96) / 4
    }

    private func dist(_ a: Double, _ b: Double) -> Double { let d = abs(a - b).truncatingRemainder(dividingBy: 24); return min(d, 24 - d) }

    private func move(_ handle: Handle, to h: Double) {
        let newOpen = handle == .open ? h : open
        let newClose = handle == .close ? h : close
        guard newOpen != newClose else { rejected += 1; return }
        if handle == .open, open != h { open = h; tick += 1 }
        if handle == .close, close != h { close = h; tick += 1 }
    }

    private func nudge(_ handle: Handle, by steps: Int) {
        let current = handle == .open ? open : close
        move(handle, to: ((current + Double(steps) * 0.25) + 24).truncatingRemainder(dividingBy: 24))
    }

    private func timeLabel(_ h: Double) -> String { EatingWindow.formatTime(hour: Int(h) % 24, minute: Int(((h - floor(h)) * 60).rounded())) }

    private var arc: Path {
        var p = Path()
        let start = open / 24 * 360 - 90
        p.addArc(center: CGPoint(x: 120, y: 120), radius: 96, startAngle: .degrees(start), endAngle: .degrees(start + Self.span(open, close) / 24 * 360), clockwise: false)
        return p
    }

    private var dial: some View {
        ZStack(alignment: .topLeading) {
            Circle().stroke(theme.surface2, lineWidth: 20).frame(width: 192, height: 192).position(x: 120, y: 120)
            ForEach(0..<24, id: \.self) { i in
                Rectangle().fill(theme.line2).frame(width: 1.5, height: 5)
                    .offset(y: -74).rotationEffect(.degrees(Double(i) * 15))
                    .position(x: 120, y: 120)
            }
            arc.stroke(carbs, style: StrokeStyle(lineWidth: 20, lineCap: .round))
            marker("12 AM", x: 120, y: 60); marker("6 AM", x: 182, y: 124)
            marker("12 PM", x: 120, y: 188); marker("6 PM", x: 58, y: 124)
            handleView(.open)
            handleView(.close)
            VStack(spacing: 0) {
                Text(spanText).font(KitchenFont.bigNumber(40)).tracking(-1.5).foregroundStyle(theme.text).contentTransition(.numericText())
                Text("OPEN").font(KitchenFont.label(10).weight(.bold)).tracking(1.4).foregroundStyle(theme.muted)
            }
            .position(x: 120, y: 120).allowsHitTesting(false)
            .accessibilityHidden(true)
        }
        .frame(width: side, height: side)
        .contentShape(Rectangle())
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                let h = hour(at: value.location)
                if active == nil {
                    let s = hour(at: value.startLocation)
                    active = dist(s, open) <= dist(s, close) ? .open : .close
                }
                if let active { move(active, to: h) }
            }
            .onEnded { _ in active = nil })
        .animation(reduceMotion ? nil : .spring(response: 0.25, dampingFraction: 0.8), value: open)
        .animation(reduceMotion ? nil : .spring(response: 0.25, dampingFraction: 0.8), value: close)
        .accessibilityElement(children: .contain)
    }

    private func marker(_ text: String, x: CGFloat, y: CGFloat) -> some View {
        Text(text).font(KitchenFont.label(10).weight(.bold)).foregroundStyle(theme.faint).position(x: x, y: y)
    }

    private func handleView(_ handle: Handle) -> some View {
        let h = handle == .open ? open : close
        let p = point(h)
        let filled = handle == .close
        return ZStack {
            Circle().fill(filled ? carbs : Color(hex: "FFFDF8")).frame(width: 28, height: 28)
            Circle().stroke(filled ? Color(hex: "FFFDF8") : carbs, lineWidth: 4).frame(width: 24, height: 24)
        }
        .scaleEffect(active == handle && !reduceMotion ? 1.12 : 1)
        .frame(width: 44, height: 44)
        .position(p)
        .allowsHitTesting(false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(handle == .open ? "Kitchen opens" : "Kitchen closes")
        .accessibilityValue(timeLabel(h))
        .accessibilityHint("Swipe up or down to change by 15 minutes")
        .accessibilityAdjustableAction { dir in nudge(handle, by: dir == .increment ? 1 : -1) }
    }
}
