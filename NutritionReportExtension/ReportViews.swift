import SwiftUI
import FamilyControls

// MARK: - Tokens (self-contained copy of the v2 palette; the extension cannot import app files)
//
// The report extension does not bundle Bricolage Grotesque / Manrope, so display text uses the system
// rounded face at heavy weights. The look follows the host: dark scheme = Lamp/Night tokens, light = Daylight.

struct ReportPalette {
    let dark: Bool
    init(_ scheme: ColorScheme) { dark = scheme == .dark }

    private func hex(_ s: String) -> Color {
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        return Color(.sRGB, red: Double(v >> 16 & 0xFF) / 255, green: Double(v >> 8 & 0xFF) / 255, blue: Double(v & 0xFF) / 255)
    }
    private func pick(_ lamp: String, _ day: String) -> Color { hex(dark ? lamp : day) }

    var surface: Color { pick("221E1A", "FFFDF8") }
    var surface2: Color { pick("2D2823", "EDE5D6") }
    var line: Color { dark ? hex("FFECD2").opacity(0.08) : hex("3C2814").opacity(0.09) }
    var line2: Color { dark ? hex("FFECD2").opacity(0.15) : hex("3C2814").opacity(0.16) }
    var text: Color { pick("F7F2E9", "1F1A14") }
    var muted: Color { pick("B5AC9F", "5F564A") }
    var faint: Color { pick("918778", "766B5E") }
    var lamp: Color { pick("F3D9A4", "B8862C") }
    var carbs: Color { pick("F4929F", "B83E5E") }
    var fats: Color { pick("B6D07E", "4F7A22") }
    var protein: Color { pick("EBA75A", "995A12") }
    var night: Color { hex("AEB5F2") }
    func soft(_ c: Color, _ o: Double = 0.12) -> Color { c.opacity(o) }
}

private enum RF {
    static func display(_ size: CGFloat) -> Font { .system(size: size, weight: .heavy, design: .rounded) }
    static func body(_ size: CGFloat, _ weight: Font.Weight = .medium) -> Font { .system(size: size, weight: weight) }
    static let eyebrow = Font.system(size: 11, weight: .bold)
}

func reportDuration(_ seconds: Double) -> String {
    let minutes = Int((seconds / 60).rounded())
    return minutes >= 60 ? "\(minutes / 60)h \(minutes % 60)m" : "\(minutes)m"
}

private struct ReportEntrance: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var visible = false
    var delay = 0.0
    func body(content: Content) -> some View {
        content.opacity(visible ? 1 : 0).offset(y: reduceMotion || visible ? 0 : 16)
            .onAppear { withAnimation(.easeOut(duration: reduceMotion ? 0.15 : 0.6).delay(reduceMotion ? 0 : delay)) { visible = true } }
    }
}

private struct ReportCard: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    var padding: EdgeInsets = EdgeInsets(top: 14, leading: 16, bottom: 12, trailing: 16)
    func body(content: Content) -> some View {
        let p = ReportPalette(scheme)
        content.padding(padding).frame(maxWidth: .infinity, alignment: .leading)
            .background(p.surface, in: RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(p.line, lineWidth: 1))
    }
}
private extension View {
    func reportCard(_ padding: EdgeInsets = EdgeInsets(top: 14, leading: 16, bottom: 12, trailing: 16)) -> some View { modifier(ReportCard(padding: padding)) }
    func rise(_ delay: Double = 0) -> some View { modifier(ReportEntrance(delay: delay)) }
}

private struct Eyebrow: View {
    @Environment(\.colorScheme) private var scheme
    let text: String
    var color: Color? = nil
    var body: some View {
        Text(text.uppercased()).font(RF.eyebrow).tracking(1.4).foregroundStyle(color ?? ReportPalette(scheme).faint)
    }
}

// MARK: - Week (Journal "This week" body)

struct NutritionLabelReportView: View {
    let snapshot: ReportSnapshot
    @Environment(\.colorScheme) private var scheme
    private var p: ReportPalette { ReportPalette(scheme) }

    var body: some View {
        VStack(spacing: 12) {
            if snapshot.isEmpty { ReportEmptyState().reportCard() }
            else {
                WeekChart(snapshot: snapshot).rise(0.1)
                splitCard.rise(0.2)
                HStack(spacing: 10) {
                    ReportMetric(symbol: "moon.stars.fill", tint: p.night, value: reportDuration(snapshot.lateNightSeconds), title: "Late night", note: "10 pm – 6 am")
                    ReportMetric(symbol: "hand.tap.fill", tint: p.lamp, value: "\(Int(snapshot.averagePickupsPerDay.rounded()))", title: "Pickups a day", note: "Observed days")
                }.rise(0.3)
                topApps.rise(0.4)
                Text("A little awareness can make your next choice easier.").font(RF.body(12)).foregroundStyle(p.faint).multilineTextAlignment(.center).padding(.top, 4)
            }
        }.padding(.vertical, 2)
    }

    private var splitCard: some View {
        let total = max(1, snapshot.totalSeconds)
        return VStack(spacing: 0) {
            splitRow("Carbs", seconds: snapshot.carbSeconds, total: total, tint: p.carbs, first: true)
            splitRow("Fats", seconds: snapshot.fatSeconds, total: total, tint: p.fats)
            splitRow("Protein", seconds: snapshot.otherSeconds, total: total, tint: p.protein)
        }.reportCard(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
    }

    private func splitRow(_ name: String, seconds: Double, total: Double, tint: Color, first: Bool = false) -> some View {
        HStack(spacing: 12) {
            Text(name).font(RF.body(13, .bold)).foregroundStyle(p.text).frame(width: 70, alignment: .leading)
            WideBar(fraction: min(1, seconds / total), tint: tint, track: p.surface2)
            Text(reportDuration(seconds)).font(RF.body(13, .heavy)).monospacedDigit().foregroundStyle(p.text).frame(width: 64, alignment: .trailing)
        }
        .frame(height: 44)
        .overlay(alignment: .top) { if !first { Rectangle().fill(p.line).frame(height: 1) } }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name), \(reportDuration(seconds)), \(Int((seconds / total * 100).rounded())) percent")
    }

    private var topApps: some View {
        VStack(alignment: .leading, spacing: 12) {
            Eyebrow(text: "The apps you reach for")
            if snapshot.topJunkApps.isEmpty {
                Text("No Carbs app activity was available for this period.").font(RF.body(12)).foregroundStyle(p.muted)
            }
            ForEach(Array(snapshot.topJunkApps.enumerated()), id: \.element.id) { index, usage in
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        Text(String(format: "%02d", index + 1)).font(RF.body(11, .bold)).monospacedDigit().foregroundStyle(p.faint)
                        if let token = usage.token { Label(token).labelStyle(.iconOnly).frame(width: 28, height: 28).clipShape(RoundedRectangle(cornerRadius: 8)) }
                        Text(usage.name).font(RF.body(14, .semibold)).foregroundStyle(p.text).lineLimit(1)
                        Spacer(minLength: 8)
                        Text(reportDuration(usage.seconds)).font(RF.body(13, .heavy)).monospacedDigit().foregroundStyle(p.carbs)
                    }
                    WideBar(fraction: min(1, usage.seconds / max(1, snapshot.topJunkApps.first?.seconds ?? 1)), tint: p.carbs, track: p.surface2)
                }.accessibilityElement(children: .combine)
            }
        }.reportCard(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
    }
}

/// 8 pt rounded bar that grows from the left.
private struct WideBar: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let fraction: Double
    let tint: Color
    let track: Color
    @State private var grown = false
    var body: some View {
        Capsule().fill(track).frame(height: 8)
            .overlay(alignment: .leading) {
                GeometryReader { geo in
                    Capsule().fill(tint).frame(width: geo.size.width * (grown || reduceMotion ? max(0, fraction) : 0))
                }
            }
            .onAppear { withAnimation(.easeOut(duration: reduceMotion ? 0.15 : 0.8).delay(reduceMotion ? 0 : 0.5)) { grown = true } }
    }
}

/// Stacked Carbs / Fats / Protein bars for the last seven days (Protein = total − Carbs − Fats).
private struct WeekChart: View {
    let snapshot: ReportSnapshot
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var reveal = false
    private var p: ReportPalette { ReportPalette(scheme) }

    private var days: [(key: String, date: Date)] {
        (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0 - 6, to: Date()) }.map { (DayCounters.dateKey(from: $0), $0) }
    }
    private var maximum: Double { max(1, snapshot.totalSecondsByDay.values.max() ?? 1) }
    private let chartHeight: CGFloat = 120

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your week at a glance").font(RF.body(14, .heavy)).foregroundStyle(p.text)
                Spacer(minLength: 8)
                HStack(spacing: 10) { legend("Carbs", p.carbs); legend("Fats", p.fats); legend("Protein", p.protein) }
            }
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(Array(days.enumerated()), id: \.element.key) { i, day in column(day: day, index: i) }
            }.frame(height: chartHeight + 22)
            .onAppear { withAnimation(.easeOut(duration: reduceMotion ? 0.15 : 0.7)) { reveal = true } }
        }.reportCard(EdgeInsets(top: 14, leading: 16, bottom: 12, trailing: 16))
    }

    private func legend(_ name: String, _ color: Color) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 8, height: 8)
            Text(name).font(RF.body(11, .semibold)).foregroundStyle(p.muted)
        }
    }

    private func column(day: (key: String, date: Date), index: Int) -> some View {
        let total = snapshot.totalSecondsByDay[day.key]
        let carbs = snapshot.carbSecondsByDay[day.key] ?? 0
        let fats = snapshot.fatSecondsByDay[day.key] ?? 0
        let t = total ?? 0
        let protein = max(0, t - carbs - fats)
        let h = max(4, CGFloat(t / maximum) * chartHeight)
        func seg(_ v: Double) -> CGFloat { t > 0 ? CGFloat(v / t) * h : 0 }
        return VStack(spacing: 6) {
            VStack(spacing: 0) {
                if t > 0 {
                    Rectangle().fill(p.protein).frame(height: seg(protein))
                    Rectangle().fill(p.fats).frame(height: seg(fats))
                    Rectangle().fill(p.carbs).frame(height: seg(carbs))
                } else {
                    Rectangle().fill(p.surface2)
                }
            }
            .frame(height: h).clipShape(RoundedRectangle(cornerRadius: 8))
            .scaleEffect(y: reveal ? 1 : 0.01, anchor: .bottom)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.7).delay(0.5 + Double(index) * 0.06), value: reveal)
            .frame(height: chartHeight, alignment: .bottom)
            Text(day.date.formatted(.dateTime.weekday(.narrow))).font(RF.body(11, .bold))
                .foregroundStyle(index == 6 ? p.text : p.faint)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(day.date.formatted(.dateTime.weekday(.wide))), \(total.map(reportDuration) ?? "no activity received"), Carbs \(reportDuration(carbs)), Fats \(reportDuration(fats))")
    }
}

// MARK: - Today (Journal "Today" body, Kitchen card)

struct TodayReportView: View {
    let snapshot: ReportSnapshot
    @Environment(\.colorScheme) private var scheme
    private var p: ReportPalette { ReportPalette(scheme) }

    var body: some View {
        VStack(spacing: 12) {
            if snapshot.isEmpty { ReportEmptyState(compact: true).reportCard() }
            else {
                VStack(alignment: .leading, spacing: 4) {
                    Eyebrow(text: "Today so far")
                    Text(reportDuration(snapshot.totalSeconds)).font(RF.display(40)).tracking(-1.5).monospacedDigit().foregroundStyle(p.lamp)
                    Text("Measured by Screen Time").font(RF.body(12)).foregroundStyle(p.muted)
                }
                .reportCard(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                .background(LinearGradient(colors: [p.lamp.opacity(0.14), p.lamp.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 24))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(p.lamp.opacity(0.18), lineWidth: 1))
                .rise(0.05)
                let total = max(1, snapshot.totalSeconds)
                VStack(spacing: 0) {
                    row("Carbs", snapshot.carbSeconds, total, p.carbs, first: true)
                    row("Fats", snapshot.fatSeconds, total, p.fats)
                    row("Protein", snapshot.otherSeconds, total, p.protein)
                }.reportCard(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)).rise(0.15)
                HStack(spacing: 10) {
                    ReportMetric(symbol: "hand.tap.fill", tint: p.lamp, value: "\(snapshot.pickups)", title: "Pickups", note: "Today")
                    ReportMetric(symbol: "sunrise.fill", tint: p.protein, value: snapshot.firstPickup.map { $0.formatted(date: .omitted, time: .shortened) } ?? "—", title: "First pickup", note: "Today")
                }.rise(0.25)
            }
        }
    }

    private func row(_ name: String, _ seconds: Double, _ total: Double, _ tint: Color, first: Bool = false) -> some View {
        HStack(spacing: 12) {
            Text(name).font(RF.body(13, .bold)).foregroundStyle(p.text).frame(width: 70, alignment: .leading)
            WideBar(fraction: min(1, seconds / total), tint: tint, track: p.surface2)
            Text(reportDuration(seconds)).font(RF.body(13, .heavy)).monospacedDigit().foregroundStyle(p.text).frame(width: 64, alignment: .trailing)
        }
        .frame(height: 44)
        .overlay(alignment: .top) { if !first { Rectangle().fill(p.line).frame(height: 1) } }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Grade (Journal header card)

struct WeeklyGradeReportView: View {
    let snapshot: ReportSnapshot
    let grade: String
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var revealed = false
    private var p: ReportPalette { ReportPalette(scheme) }

    private var fraction: Double {
        switch grade { case "A": 0.92; case "B": 0.78; case "C": 0.62; case "D": 0.45; case "F": 0.3; default: 0 }
    }
    private var headline: String {
        switch grade { case "A": "A nourishing week."; case "B": "A little more balanced."; case "C": "A few habits to notice."; case "D", "F": "A fresh start is always available."; default: "Your story is still taking shape." }
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().stroke(p.surface2, lineWidth: 7)
                Circle().trim(from: 0, to: revealed && !snapshot.isEmpty ? fraction : 0)
                    .stroke(p.lamp, style: StrokeStyle(lineWidth: 7, lineCap: .round)).rotationEffect(.degrees(-90))
                Text(snapshot.isEmpty ? "—" : grade).font(RF.display(40)).tracking(-1.5).foregroundStyle(p.lamp)
                    .scaleEffect(revealed || reduceMotion ? 1 : 1.6).opacity(revealed || reduceMotion ? 1 : 0)
            }.frame(width: 104, height: 104).padding(2)
            VStack(alignment: .leading, spacing: 4) {
                Eyebrow(text: "This week")
                Text(headline).font(RF.display(20)).tracking(-0.4).foregroundStyle(p.text).fixedSize(horizontal: false, vertical: true)
                Text(snapshot.isEmpty ? "We need measured activity before a grade can appear." : "A guide, not a judgment")
                    .font(RF.body(12)).foregroundStyle(p.muted).fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
        .background(LinearGradient(colors: [p.lamp.opacity(0.14), p.lamp.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(p.lamp.opacity(0.18), lineWidth: 1))
        .onAppear { withAnimation(.easeOut(duration: reduceMotion ? 0.15 : 1.0).delay(reduceMotion ? 0 : 0.3)) { revealed = true } }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("This week's grade \(snapshot.isEmpty ? "unavailable" : grade). \(headline)")
    }
}

// MARK: - Hook insight (onboarding)

struct HookInsightReportView: View {
    let content: HookInsightContent
    @Environment(\.colorScheme) private var scheme
    private var p: ReportPalette { ReportPalette(scheme) }
    private var enough: Bool { content.snapshot.carbSeconds >= 3600 }
    private var weekly: Double { enough ? content.snapshot.carbSeconds : Double(content.estimatedDailyMinutes ?? 0) * 60 * 7 }

    var body: some View {
        VStack(spacing: 12) {
            Eyebrow(text: enough ? "Last week · measured Carbs" : "Your answers · rough estimate", color: p.lamp)
            if enough || content.estimatedDailyMinutes != nil {
                Text(enough ? reportDuration(weekly) : "≈ \(content.estimatedDailyMinutes ?? 0)m / day")
                    .font(RF.display(48)).tracking(-2).foregroundStyle(p.carbs).minimumScaleFactor(0.6).lineLimit(1)
                Text("Your selected Carbs add up.").font(RF.display(20)).tracking(-0.4).foregroundStyle(p.text)
                Rectangle().fill(p.line2).frame(height: 1)
                Text("At this pace, ≈ \(Int((weekly * 52 / 86400).rounded())) days a year.").font(RF.body(16, .bold)).foregroundStyle(p.text)
                Text("A projection if this pattern continued, not time we’ve already measured.").font(RF.body(12)).foregroundStyle(p.muted).multilineTextAlignment(.center)
            } else { ReportEmptyState(compact: true) }
        }.frame(maxWidth: .infinity).reportCard(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)).rise()
    }
}

// MARK: - Small pieces

private struct ReportMetric: View {
    @Environment(\.colorScheme) private var scheme
    let symbol: String
    let tint: Color
    let value: String
    let title: String
    let note: String
    var body: some View {
        let p = ReportPalette(scheme)
        HStack(spacing: 10) {
            Image(systemName: symbol).font(.system(size: 15, weight: .bold)).foregroundStyle(tint)
                .frame(width: 36, height: 36).background(tint.opacity(0.16), in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 1) {
                Text(value).font(RF.display(18)).monospacedDigit().foregroundStyle(p.text).lineLimit(1).minimumScaleFactor(0.7)
                Text(title).font(RF.body(11, .semibold)).foregroundStyle(p.muted).lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12).padding(.vertical, 12).frame(maxWidth: .infinity, alignment: .leading)
        .background(p.surface, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(p.line, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(value). \(note)")
    }
}

private struct ReportEmptyState: View {
    @Environment(\.colorScheme) private var scheme
    var compact = false
    var body: some View {
        let p = ReportPalette(scheme)
        VStack(spacing: 10) {
            Image(systemName: "leaf.circle").font(.system(size: compact ? 30 : 44)).foregroundStyle(p.fats)
            Text("A story still growing.").font(RF.display(compact ? 18 : 22)).tracking(-0.4).foregroundStyle(p.text)
            Text("No activity was received for this period. Use your phone normally and return after Screen Time has recorded activity.")
                .font(RF.body(12)).foregroundStyle(p.muted).multilineTextAlignment(.center)
        }.frame(maxWidth: .infinity).padding(.vertical, compact ? 8 : 24)
    }
}
