import SwiftUI

/// Interactive 24-hour dial: window start/end + night fast start.
/// Arcs snap to 15 minutes and never overlap.
struct WindowDialView: View {
    @ObservedObject var data: OnboardingData
    private let appTheme = AppTheme.shared

    // Minutes from midnight
    @State private var startMinutes: Double = 12 * 60
    @State private var endMinutes: Double = 20 * 60
    @State private var nightMinutes: Double = 21 * 60

    @State private var dragging: Handle?
    @State private var snapTick = 0

    private let snap = 15

    private enum Handle: Equatable {
        case start, end, night
    }

    var body: some View {
        ZStack {
            appTheme.colors.background.ignoresSafeArea()

            VStack(spacing: appTheme.spacing.large) {
                VStack(spacing: appTheme.spacing.small) {
                    Text("SET YOUR KITCHEN HOURS")
                        .font(appTheme.fonts.labelSmall)
                        .foregroundColor(appTheme.colors.primary)
                        .tracking(1.5)
                    Text("When does your kitchen open?")
                        .font(appTheme.fonts.headlineLarge)
                        .foregroundColor(appTheme.colors.text)
                        .multilineTextAlignment(.center)
                    Text("Drag the handles. Everything snaps to 15 minutes.")
                        .font(appTheme.fonts.bodyMedium)
                        .foregroundColor(appTheme.colors.textSecondary)
                }
                .padding(.top, appTheme.spacing.extraLarge)

                dial
                    .frame(height: 340)
                    .padding(.horizontal, appTheme.spacing.large)

                legend

                portionControl
                    .padding(.horizontal, appTheme.spacing.large)

                Spacer()

                Button(action: saveAndContinue) {
                    Text("Looks right")
                        .font(appTheme.fonts.titleMedium)
                        .foregroundColor(appTheme.colors.background)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(appTheme.colors.primary)
                        .cornerRadius(appTheme.spacing.cornerRadiusLarge)
                }
                .padding(.horizontal, appTheme.spacing.large)
                .padding(.bottom, appTheme.spacing.extraLarge)
            }
        }
        .sensoryFeedback(.selection, trigger: snapTick)
        .onAppear {
            startMinutes = Double(data.windowStartHour * 60 + data.windowStartMinute)
            endMinutes = Double(data.windowEndHour * 60 + data.windowEndMinute)
            nightMinutes = Double(data.nightLockHour * 60 + data.nightLockMinute)
        }
    }

    // MARK: - Dial

    private var dial: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let radius = size / 2 - 26
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

            ZStack {
                // Guide ring
                Circle()
                    .stroke(appTheme.colors.surfaceVariant, lineWidth: 22)
                    .frame(width: radius * 2, height: radius * 2)
                    .position(center)

                // Eating window arc
                arcPath(center: center, radius: radius, from: startMinutes, to: endMinutes)
                    .stroke(appTheme.colors.primary, style: StrokeStyle(lineWidth: 22, lineCap: .round))

                // Night fast arc
                arcPath(center: center, radius: radius, from: nightMinutes, to: startMinutes)
                    .stroke(Color(red: 0.6, green: 0.3, blue: 0.8), style: StrokeStyle(lineWidth: 22, lineCap: .round))
                    .opacity(0.85)

                // Handles
                handle(.start, at: startMinutes, center: center, radius: radius, color: appTheme.colors.primary)
                handle(.end, at: endMinutes, center: center, radius: radius, color: appTheme.colors.primary)
                handle(.night, at: nightMinutes, center: center, radius: radius, color: Color(red: 0.6, green: 0.3, blue: 0.8))

                // Center summary
                VStack(spacing: 4) {
                    Text(timeString(startMinutes))
                        .font(appTheme.fonts.headlineMedium)
                        .foregroundColor(appTheme.colors.text)
                    Text("to \(timeString(endMinutes))")
                        .font(appTheme.fonts.titleSmall)
                        .foregroundColor(appTheme.colors.primary)
                    Text("fast \(durationString(nightMinutes, startMinutes))")
                        .font(appTheme.fonts.labelSmall)
                        .foregroundColor(appTheme.colors.textSecondary)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in updateDrag(location: value.location, center: center) }
                    .onEnded { _ in dragging = nil }
            )
        }
    }

    private func arcPath(center: CGPoint, radius: CGFloat, from: Double, to: Double) -> Path {
        let startAngle = Angle.degrees(from / 1440 * 360)
        let endAngle = Angle.degrees(to / 1440 * 360)
        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        return path
    }

    private func handle(_ which: Handle, at minutes: Double, center: CGPoint, radius: CGFloat, color: Color) -> some View {
        let angle = Angle.degrees(minutes / 1440 * 360 - 90)
        let point = CGPoint(
            x: center.x + radius * cos(angle.radians),
            y: center.y + radius * sin(angle.radians)
        )
        let isActive = dragging == which

        return Circle()
            .fill(appTheme.colors.background)
            .overlay(Circle().stroke(color, lineWidth: 4))
            .frame(width: isActive ? 34 : 28, height: isActive ? 34 : 28)
            .position(point)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isActive)
    }

    // MARK: - Drag math

    private func updateDrag(location: CGPoint, center: CGPoint) {
        let desired = minutes(at: location, center: center)
        // Rounding near the top of the dial can produce 1440 (= 24:00); wrap it to 0.
        let snapped = wrap((desired / Double(snap)).rounded() * Double(snap))

        if dragging == nil {
            dragging = nearestHandle(to: desired)
        }

        switch dragging {
        case .start:
            startMinutes = clampStart(snapped)
        case .end:
            endMinutes = clampEnd(snapped)
        case .night:
            nightMinutes = clampNight(snapped)
        case nil:
            break
        }
    }

    private func minutes(at location: CGPoint, center: CGPoint) -> Double {
        let dx = location.x - center.x
        let dy = location.y - center.y
        var deg = atan2(dy, dx) * 180 / .pi + 90
        if deg < 0 { deg += 360 }
        if deg >= 360 { deg -= 360 }
        return deg / 360 * 1440
    }

    private func nearestHandle(to desired: Double) -> Handle {
        let candidates: [(Handle, Double)] = [
            (.start, startMinutes), (.end, endMinutes), (.night, nightMinutes),
        ]
        return candidates.min { circularDistance($0.1, desired) < circularDistance($1.1, desired) }?.0 ?? .start
    }

    private func circularDistance(_ a: Double, _ b: Double) -> Double {
        let diff = abs(a - b).truncatingRemainder(dividingBy: 1440)
        return min(diff, 1440 - diff)
    }

    private func span(_ from: Double, _ to: Double) -> Double {
        (to - from + 1440).truncatingRemainder(dividingBy: 1440)
    }

    private func clampStart(_ candidate: Double) -> Double {
        var value = candidate
        if span(value, endMinutes) < 15 { value = wrap(endMinutes - 15) }
        if span(nightMinutes, value) < 15 { value = wrap(nightMinutes + 15) }
        return notify(value, current: startMinutes)
    }

    private func clampEnd(_ candidate: Double) -> Double {
        var value = candidate
        if span(startMinutes, value) < 15 { value = wrap(startMinutes + 15) }
        if span(value, nightMinutes) < 15 { value = wrap(nightMinutes - 15) }
        return notify(value, current: endMinutes)
    }

    private func clampNight(_ candidate: Double) -> Double {
        var value = candidate
        if span(endMinutes, value) < 15 { value = wrap(endMinutes + 15) }
        if span(value, startMinutes) < 15 { value = wrap(startMinutes - 15) }
        return notify(value, current: nightMinutes)
    }

    private func notify(_ value: Double, current: Double) -> Double {
        if value != current { snapTick += 1 }
        return value
    }

    private func wrap(_ minutes: Double) -> Double {
        (minutes + 1440).truncatingRemainder(dividingBy: 1440)
    }

    private func timeString(_ minutes: Double) -> String {
        let total = Int(minutes) % 1440
        return EatingWindow.formatTime(hour: total / 60, minute: total % 60)
    }

    private func durationString(_ from: Double, _ to: Double) -> String {
        let minutes = Int(span(from, to))
        return "\(minutes / 60)h \(minutes % 60)m"
    }

    // MARK: - Legend

    private var legend: some View {
        HStack(spacing: appTheme.spacing.large) {
            legendItem(color: appTheme.colors.primary, text: "Kitchen \(timeString(startMinutes))–\(timeString(endMinutes))")
            legendItem(color: Color(red: 0.6, green: 0.3, blue: 0.8), text: "Night Fast \(timeString(nightMinutes))–\(timeString(startMinutes))")
        }
        .padding(.horizontal, appTheme.spacing.large)
    }

    private func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(text)
                .font(appTheme.fonts.labelSmall)
                .foregroundColor(appTheme.colors.textSecondary)
        }
    }

    // MARK: - Portion

    private var portionControl: some View {
        VStack(alignment: .leading, spacing: appTheme.spacing.small) {
            HStack {
                Text("DAILY CARB PORTION")
                    .font(appTheme.fonts.labelSmall)
                    .foregroundColor(appTheme.colors.textSecondary)
                    .tracking(1.0)
                Spacer()
                Text(data.dailyCarbLimitMinutes > 0 ? "\(data.dailyCarbLimitMinutes) min" : "No carbs")
                    .font(appTheme.fonts.titleSmall)
                    .foregroundColor(appTheme.colors.primary)
            }

            Slider(
                value: Binding(
                    get: { Double(data.dailyCarbLimitMinutes) },
                    set: { data.dailyCarbLimitMinutes = Int($0 / 15) * 15 }
                ),
                in: 0...180,
                step: 15
            )
            .tint(appTheme.colors.primary)
        }
        .padding(appTheme.spacing.medium)
        .background(appTheme.colors.surface)
        .cornerRadius(appTheme.spacing.cornerRadiusMedium)
    }

    private func saveAndContinue() {
        data.windowStartHour = Int(startMinutes) / 60
        data.windowStartMinute = Int(startMinutes) % 60
        data.windowEndHour = Int(endMinutes) / 60
        data.windowEndMinute = Int(endMinutes) % 60
        data.nightLockHour = Int(nightMinutes) / 60
        data.nightLockMinute = Int(nightMinutes) % 60
        data.nextScreen()
    }
}
