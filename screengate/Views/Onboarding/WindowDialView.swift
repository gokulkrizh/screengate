import SwiftUI

struct WindowDialView: View {
    @ObservedObject var data: OnboardingData
    @Environment(EntitlementManager.self) private var entitlements
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var start: Double = 720
    @State private var end: Double = 1200
    @State private var night: Double = 1260
    @State private var dragging: Int?
    @State private var tick = 0
    @State private var rejected = 0
    private var detox: Bool { data.selectedPlan == .detox }
    var body: some View {
        DietPage {
            DietHeading(eyebrow: "Give your day a rhythm", title: detox ? "A little reset.\nA lot of possibility." : "Open with intention.\nClose with a little peace.", detail: detox ? "Your Detox plan keeps selected Carbs off the menu. Productive apps stay available." : "Drag the sun handles to set kitchen hours. Use the sliders below for precise times.")
            if detox { DietArtwork(asset: "FreshStart", height: 240) }
            else {
                dial.frame(height: 310).editorialEntrance()
                HStack(spacing: 12) {
                    DietMetric(icon: "sunrise", value: time(start), label: "kitchen opens")
                    DietMetric(icon: "sunset", value: time(end), label: "kitchen closes")
                }
                DisclosureGroup("Set precise times") {
                    VStack(alignment: .leading, spacing: 18) {
                        timeSlider("Opens", value: start, index: 0)
                        timeSlider("Closes", value: end, index: 1)
                        if entitlements.isPremium { timeSlider("Night Fast starts", value: night, index: 2) }
                    }.padding(.top, 16)
                }.font(.subheadline).foregroundStyle(AppTheme.shared.colors.text).tint(AppTheme.shared.colors.primary).dietCard()
                VStack(alignment: .leading, spacing: 18) {
                    HStack { Text("YOUR DAILY PORTION").font(.caption2.bold()).tracking(1.5); Spacer(); Image(systemName: "fork.knife") }.foregroundStyle(AppTheme.shared.colors.primary)
                    Text("\(data.dailyCarbLimitMinutes) minutes").font(.system(.title, design: .rounded).bold()).foregroundStyle(AppTheme.shared.colors.text).contentTransition(.numericText())
                    Slider(value: Binding(get: { Double(data.dailyCarbLimitMinutes) }, set: { data.dailyCarbLimitMinutes = Int($0) }), in: 15...180, step: 15).tint(AppTheme.shared.colors.primary).accessibilityLabel("Daily Carbs portion")
                    Text("A satisfying portion for your most tempting apps. Start with something you can repeat.").font(.caption).foregroundStyle(AppTheme.shared.colors.textSecondary)
                }.dietCard()
            }
            Button {
                if !entitlements.isPremium { entitlements.presentPaywall(.featureNightFast) }
            } label: {
                DietFeatureRow(icon: entitlements.isPremium ? "moon.stars" : "lock.fill", title: entitlements.isPremium ? "Night Fast starts at \(time(night))" : "Give your apps a bedtime · Plus", detail: entitlements.isPremium ? "Carbs and Fats rest until \(time(start))." : "Night Fast can pause social apps alongside Carbs during your nightly routine.", tint: Color(red: 0.73, green: 0.65, blue: 0.88)).dietCard(tint: .purple)
            }.buttonStyle(TactileButtonStyle())
        } footer: {
            PrimaryButton(title: "This feels right", icon: "arrow.right") {
                data.windowStartHour = Int(start) / 60; data.windowStartMinute = Int(start) % 60
                data.windowEndHour = Int(end) / 60; data.windowEndMinute = Int(end) % 60
                data.nightLockHour = Int(night) / 60; data.nightLockMinute = Int(night) % 60
                data.nextScreen()
            }
        }.sensoryFeedback(.selection, trigger: tick).sensoryFeedback(.warning, trigger: rejected)
            .onAppear {
                start = Double(data.windowStartHour * 60 + data.windowStartMinute); end = Double(data.windowEndHour * 60 + data.windowEndMinute); night = Double(data.nightLockHour * 60 + data.nightLockMinute)
                if !detox && data.dailyCarbLimitMinutes < 15 { data.dailyCarbLimitMinutes = 15 }
            }
    }
    private var dial: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let radius = size / 2 - 32
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            ZStack {
                Circle().stroke(AppTheme.shared.colors.surfaceVariant, lineWidth: 16).frame(width: radius * 2, height: radius * 2).position(center)
                arc(center, radius, start, end).stroke(AppTheme.shared.colors.primary, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                if entitlements.isPremium { arc(center, radius, night, start).stroke(Color(red: 0.73, green: 0.65, blue: 0.88), style: StrokeStyle(lineWidth: 16, lineCap: .round)) }
                ForEach(0..<24) { hour in
                    let angle = Double(hour) / 24 * 2 * Double.pi - Double.pi / 2
                    Circle().fill(AppTheme.shared.colors.textSecondary.opacity(0.4)).frame(width: hour % 6 == 0 ? 4 : 2, height: hour % 6 == 0 ? 4 : 2)
                        .position(x: center.x + (radius - 22) * cos(angle), y: center.y + (radius - 22) * sin(angle))
                }
                ForEach([0, 6, 12, 18], id: \.self) { hour in
                    let angle = Double(hour) / 24 * 2 * Double.pi - Double.pi / 2
                    Text(String(format: "%02d", hour)).font(.caption2.monospacedDigit()).foregroundStyle(AppTheme.shared.colors.textSecondary)
                        .position(x: center.x + (radius + 25) * cos(angle), y: center.y + (radius + 25) * sin(angle))
                }
                VStack(spacing: 8) {
                    Image(systemName: "sun.max.fill").font(.title2).foregroundStyle(AppTheme.shared.colors.primary)
                    Text("\(Int(span(start, end)) / 60)h \(Int(span(start, end)) % 60)m").font(.system(.title, design: .rounded).bold()).foregroundStyle(AppTheme.shared.colors.text).contentTransition(.numericText())
                    Text("KITCHEN HOURS").font(.caption2.bold()).tracking(1).foregroundStyle(AppTheme.shared.colors.textSecondary)
                }.position(center)
                dialHandle(0, value: start, center: center, radius: radius)
                dialHandle(1, value: end, center: center, radius: radius)
                if entitlements.isPremium { dialHandle(2, value: night, center: center, radius: radius) }
            }.coordinateSpace(name: "dial").accessibilityElement(children: .ignore).accessibilityLabel("Kitchen hours from \(time(start)) to \(time(end)). Use precise time sliders below to edit.")
        }
    }
    private func dialHandle(_ index: Int, value: Double, center: CGPoint, radius: Double) -> some View {
        let angle = value / 1440 * 2 * Double.pi - Double.pi / 2
        return Image(systemName: index == 0 ? "sunrise.fill" : index == 1 ? "sunset.fill" : "moon.fill")
            .font(.caption.bold()).foregroundStyle(AppTheme.shared.colors.background).frame(width: 44, height: 44)
            .background(index == 2 ? Color(red: 0.73, green: 0.65, blue: 0.88) : AppTheme.shared.colors.primary).clipShape(Circle())
            .scaleEffect(dragging == index && !reduceMotion ? 1.1 : 1)
            .position(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("dial"))
                .onChanged { value in
                    dragging = index
                    let degrees = atan2(value.location.y - center.y, value.location.x - center.x) * 180 / .pi + 90
                    update(index, value: (degrees + 360).truncatingRemainder(dividingBy: 360) / 360 * 1440)
                }.onEnded { _ in dragging = nil })
            .animation(reduceMotion ? nil : .spring(response: 0.25), value: dragging)
    }
    private func arc(_ center: CGPoint, _ radius: Double, _ from: Double, _ to: Double) -> Path {
        var path = Path(); path.addArc(center: center, radius: radius, startAngle: .degrees(from / 1440 * 360 - 90), endAngle: .degrees((from + span(from, to)) / 1440 * 360 - 90), clockwise: false); return path
    }
    private func timeSlider(_ title: String, value: Double, index: Int) -> some View {
        VStack(spacing: 10) {
            HStack { Text(title); Spacer(); Text(time(value)).monospacedDigit() }
            Slider(value: Binding(get: { index == 0 ? start : index == 1 ? end : night }, set: { update(index, value: $0) }), in: 0...1425, step: 15).accessibilityLabel(title)
        }
    }
    private func update(_ index: Int, value: Double) {
        let value = ((value / 15).rounded() * 15).truncatingRemainder(dividingBy: 1440)
        let a = index == 0 ? value : start; let b = index == 1 ? value : end; let c = index == 2 ? value : night
        let valid = span(a, b) >= 15 && (!entitlements.isPremium || (span(b, c) >= 15 && span(c, a) >= 15 && span(a, b) + span(b, c) + span(c, a) == 1440))
        guard valid else { rejected += 1; return }
        if index == 0 && start != value { start = value; tick += 1 }
        if index == 1 && end != value { end = value; tick += 1 }
        if index == 2 && night != value { night = value; tick += 1 }
    }
    private func span(_ from: Double, _ to: Double) -> Double { (to - from + 1440).truncatingRemainder(dividingBy: 1440) }
    private func time(_ value: Double) -> String { EatingWindow.formatTime(hour: Int(value) / 60, minute: Int(value) % 60) }
}
