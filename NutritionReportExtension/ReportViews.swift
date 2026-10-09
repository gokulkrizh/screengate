import SwiftUI
import FamilyControls

enum ReportTheme {
    static let background = Color(red: 0.045, green: 0.085, blue: 0.07)
    static let surface = Color(red: 0.08, green: 0.13, blue: 0.11)
    static let primary = Color(red: 0.70, green: 0.86, blue: 0.55)
    static let warning = Color(red: 0.96, green: 0.71, blue: 0.46)
    static let purple = Color(red: 0.73, green: 0.65, blue: 0.88)
    static let text = Color(red: 0.97, green: 0.95, blue: 0.88)
    static let secondary = Color(red: 0.65, green: 0.72, blue: 0.67)
}
func reportDuration(_ seconds: Double) -> String {
    let minutes = Int((seconds / 60).rounded())
    return minutes >= 60 ? "\(minutes / 60)h \(minutes % 60)m" : "\(minutes)m"
}
private struct ReportEntrance: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var visible = false
    func body(content: Content) -> some View {
        content.opacity(visible ? 1 : 0).offset(y: reduceMotion || visible ? 0 : 12)
            .onAppear { withAnimation(.easeOut(duration: reduceMotion ? 0.15 : 0.6)) { visible = true } }
    }
}
private extension View {
    func reportCard() -> some View {
        padding(20).frame(maxWidth: .infinity, alignment: .leading).background(ReportTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(ReportTheme.primary.opacity(0.12)))
    }
}

struct NutritionLabelReportView: View {
    let snapshot: ReportSnapshot
    var body: some View {
        VStack(spacing: 20) {
            if snapshot.isEmpty { ReportEmptyState() }
            else {
                VStack(spacing: 18) {
                    reportHeader("YOUR DIGITAL NUTRITION", "Measured by Screen Time · Last 7 days")
                    NutritionDonut(snapshot: snapshot)
                    splitRow("Carbs", icon: "birthday.cake.fill", seconds: snapshot.carbSeconds, total: snapshot.totalSeconds, tint: ReportTheme.warning)
                    splitRow("Fats", icon: "leaf.fill", seconds: snapshot.fatSeconds, total: snapshot.totalSeconds, tint: ReportTheme.purple)
                    splitRow("Protein & other", icon: "pencil.and.outline", seconds: snapshot.otherSeconds, total: snapshot.totalSeconds, tint: ReportTheme.primary)
                    Text("Protein & other includes activity outside your Carbs and Fats selections.").font(.caption2).foregroundStyle(ReportTheme.secondary)
                }.reportCard()
                DailyActivityChart(snapshot: snapshot).reportCard()
                HStack(alignment: .top, spacing: 12) {
                    ReportMetric(icon: "moon.stars.fill", value: reportDuration(snapshot.lateNightSeconds), label: "10 pm – 6 am", tint: ReportTheme.purple)
                    ReportMetric(icon: "hand.tap.fill", value: "\(Int(snapshot.averagePickupsPerDay.rounded()))", label: "pickups / observed day", tint: ReportTheme.primary)
                }
                VStack(alignment: .leading, spacing: 16) {
                    reportHeader("THE APPS YOU REACH FOR", "Top Carbs · Ranked by measured time")
                    if snapshot.topJunkApps.isEmpty { Text("No Carbs app activity was available for this period.").font(.caption).foregroundStyle(ReportTheme.secondary) }
                    ForEach(Array(snapshot.topJunkApps.enumerated()), id: \.element.id) { index, usage in
                        VStack(spacing: 10) {
                            HStack(spacing: 12) {
                                Text(String(format: "%02d", index + 1)).font(.caption.monospacedDigit()).foregroundStyle(ReportTheme.secondary)
                                if let token = usage.token { Label(token).labelStyle(.iconOnly).frame(width: 32, height: 32) }
                                Text(usage.name).font(.subheadline.weight(.semibold)).foregroundStyle(ReportTheme.text).lineLimit(1)
                                Spacer()
                                Text(reportDuration(usage.seconds)).font(.subheadline.monospacedDigit()).foregroundStyle(ReportTheme.warning)
                            }
                            ProgressView(value: min(1, usage.seconds / max(1, snapshot.topJunkApps.first?.seconds ?? 1))).tint(ReportTheme.warning)
                        }.accessibilityElement(children: .combine)
                    }
                }.reportCard()
                Text("A little awareness can make your next choice easier.").font(.system(.subheadline, design: .serif)).foregroundStyle(ReportTheme.secondary).multilineTextAlignment(.center)
            }
        }.modifier(ReportEntrance()).padding(.vertical, 4)
    }
}

private struct NutritionDonut: View {
    let snapshot: ReportSnapshot
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var revealed = false
    private var carbs: Double { min(1, max(0, snapshot.carbShare)) }
    private var fats: Double { min(1, max(0, snapshot.fatSeconds / max(1, snapshot.totalSeconds))) }
    var body: some View {
        ZStack {
            Circle().stroke(ReportTheme.primary, lineWidth: 18)
            Circle().trim(from: 0, to: carbs).stroke(ReportTheme.warning, lineWidth: 18)
            Circle().trim(from: carbs, to: min(1, carbs + fats)).stroke(ReportTheme.purple, lineWidth: 18)
            VStack(spacing: 6) {
                Text(reportDuration(snapshot.totalSeconds)).font(.system(.largeTitle, design: .rounded).bold()).lineLimit(1).minimumScaleFactor(0.5).foregroundStyle(ReportTheme.text)
                Text("SCREEN TIME").font(.caption2.bold()).tracking(1.2).foregroundStyle(ReportTheme.secondary)
            }.rotationEffect(.degrees(90))
        }.rotationEffect(.degrees(-90)).frame(width: 190, height: 190).padding(12)
            .opacity(revealed ? 1 : 0).scaleEffect(revealed || reduceMotion ? 1 : 0.92)
            .onAppear { withAnimation(.easeOut(duration: reduceMotion ? 0.15 : 0.8)) { revealed = true } }
            .accessibilityElement(children: .ignore).accessibilityLabel("Screen time \(reportDuration(snapshot.totalSeconds)). Carbs \(Int(carbs * 100)) percent. Fats \(Int(fats * 100)) percent.")
    }
}

private struct DailyActivityChart: View {
    let snapshot: ReportSnapshot
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var reveal = false
    private var keys: [String] { (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0 - 6, to: Date()) }.map { DayCounters.dateKey(from: $0) } }
    private var maximum: Double { max(1, snapshot.totalSecondsByDay.values.max() ?? 1) }
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            reportHeader("A WEEK OF ATTENTION", "Total activity · Carbs highlighted in apricot")
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(keys, id: \.self) { key in
                    let total = snapshot.totalSecondsByDay[key]
                    let carbs = snapshot.carbSecondsByDay[key] ?? 0
                    VStack(spacing: 10) {
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 6).fill(ReportTheme.primary.opacity(0.3)).frame(height: reveal ? max(4, (total ?? 0) / maximum * 100) : 4)
                            RoundedRectangle(cornerRadius: 6).fill(ReportTheme.warning).frame(height: reveal ? min(100, carbs / maximum * 100) : 0)
                            if total == nil { Text("—").font(.caption).foregroundStyle(ReportTheme.secondary) }
                        }.frame(height: 100, alignment: .bottom)
                        Text(String(key.suffix(2))).font(.caption2.monospacedDigit()).foregroundStyle(ReportTheme.secondary)
                    }.frame(maxWidth: .infinity)
                        .accessibilityElement(children: .ignore).accessibilityLabel("\(key), \(total.map(reportDuration) ?? "no activity received"), Carbs \(reportDuration(carbs))")
                }
            }.onAppear { withAnimation(.easeOut(duration: reduceMotion ? 0.15 : 0.7)) { reveal = true } }
            Text("Missing bars mean no activity was received for that day.").font(.caption2).foregroundStyle(ReportTheme.secondary)
        }
    }
}

struct TodayReportView: View {
    let snapshot: ReportSnapshot
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            reportHeader("TODAY, FROM SCREEN TIME", "Measured activity · Your on-device report")
            if snapshot.isEmpty { ReportEmptyState(compact: true) }
            else {
                splitRow("Carbs", icon: "birthday.cake.fill", seconds: snapshot.carbSeconds, total: snapshot.totalSeconds, tint: ReportTheme.warning)
                splitRow("Fats", icon: "leaf.fill", seconds: snapshot.fatSeconds, total: snapshot.totalSeconds, tint: ReportTheme.purple)
                splitRow("Protein & other", icon: "pencil.and.outline", seconds: snapshot.otherSeconds, total: snapshot.totalSeconds, tint: ReportTheme.primary)
                HStack(spacing: 12) {
                    ReportMetric(icon: "hand.tap", value: "\(snapshot.pickups)", label: "pickups", tint: ReportTheme.primary)
                    ReportMetric(icon: "sunrise", value: snapshot.firstPickup.map { $0.formatted(date: .omitted, time: .shortened) } ?? "—", label: "first pickup", tint: ReportTheme.warning)
                }
            }
        }.reportCard().modifier(ReportEntrance())
    }
}

struct WeeklyGradeReportView: View {
    let snapshot: ReportSnapshot
    let grade: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var revealed = false
    private var color: Color { grade == "A" || grade == "B" ? ReportTheme.primary : ReportTheme.warning }
    private var description: String {
        switch grade { case "A": return "A nourishing week."; case "B": return "A little balance is taking shape."; case "C": return "A few habits to notice."; case "D", "F": return "A fresh start is always available."; default: return "Your story is still taking shape." }
    }
    var body: some View {
        HStack(spacing: 24) {
            ZStack {
                Circle().stroke(ReportTheme.primary.opacity(0.12), lineWidth: 8)
                Circle().trim(from: 0, to: revealed && !snapshot.isEmpty ? 1 : 0).stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round)).rotationEffect(.degrees(-90))
                Text(snapshot.isEmpty ? "—" : grade).font(.system(size: 44, weight: .bold, design: .serif)).foregroundStyle(color)
                    .rotation3DEffect(.degrees(revealed || reduceMotion ? 0 : 90), axis: (x: 0, y: 1, z: 0))
            }.frame(width: 90, height: 90)
            VStack(alignment: .leading, spacing: 10) {
                Text("THIS WEEK’S GRADE").font(.caption2.bold()).tracking(1.3).foregroundStyle(ReportTheme.primary)
                Text(description).font(.system(.title3, design: .serif).weight(.semibold)).foregroundStyle(ReportTheme.text)
                Text(snapshot.isEmpty ? "We need measured activity before a grade can appear." : "A guide based on portions, Carbs share, nighttime use and pickups. Not a judgment.").font(.caption).foregroundStyle(ReportTheme.secondary)
            }
        }.reportCard().onAppear { withAnimation(.easeOut(duration: reduceMotion ? 0.15 : 0.85)) { revealed = true } }
    }
}

struct HookInsightReportView: View {
    let content: HookInsightContent
    private var enough: Bool { content.snapshot.carbSeconds >= 3600 }
    private var weekly: Double { enough ? content.snapshot.carbSeconds : Double(content.estimatedDailyMinutes ?? 0) * 60 * 7 }
    var body: some View {
        VStack(spacing: 18) {
            Text(enough ? "LAST WEEK · MEASURED CARBS" : "YOUR ANSWERS · ROUGH ESTIMATE").font(.caption2.bold()).tracking(1.5).foregroundStyle(ReportTheme.primary)
            if enough || content.estimatedDailyMinutes != nil {
                Text(enough ? reportDuration(weekly) : "≈ \(content.estimatedDailyMinutes ?? 0)m / day").font(.system(.largeTitle, design: .rounded).bold()).foregroundStyle(ReportTheme.warning)
                Text("Your selected Carbs add up.").font(.system(.title3, design: .serif)).foregroundStyle(ReportTheme.text)
                Divider().overlay(ReportTheme.primary.opacity(0.15))
                Text("At this pace, ≈ \(Int((weekly * 52 / 86400).rounded())) days a year.").font(.headline).foregroundStyle(ReportTheme.text)
                Text("A projection if this pattern continued, not time we’ve already measured.").font(.caption).foregroundStyle(ReportTheme.secondary).multilineTextAlignment(.center)
            } else { ReportEmptyState(compact: true) }
        }.frame(maxWidth: .infinity).reportCard().modifier(ReportEntrance())
    }
}

private struct ReportMetric: View {
    let icon: String
    let value: String
    let label: String
    let tint: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).foregroundStyle(tint)
            Text(value).font(.system(.title3, design: .rounded).bold()).foregroundStyle(ReportTheme.text)
            Text(label).font(.caption2).foregroundStyle(ReportTheme.secondary)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(14).background(ReportTheme.background).clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
private struct ReportEmptyState: View {
    var compact = false
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.circle").font(.system(size: compact ? 32 : 52)).foregroundStyle(ReportTheme.primary)
            Text("A story still growing.").font(.system(.title2, design: .serif)).foregroundStyle(ReportTheme.text)
            Text("No activity was received for this period. Use your phone normally and return after Screen Time has recorded activity.").font(.caption).foregroundStyle(ReportTheme.secondary).multilineTextAlignment(.center)
        }.frame(maxWidth: .infinity).padding(.vertical, compact ? 8 : 32)
    }
}
private func reportHeader(_ title: String, _ detail: String) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(title).font(.caption2.bold()).tracking(1.5).foregroundStyle(ReportTheme.primary)
        Text(detail).font(.caption).foregroundStyle(ReportTheme.secondary)
    }.frame(maxWidth: .infinity, alignment: .leading)
}
private func splitRow(_ title: String, icon: String, seconds: Double, total: Double, tint: Color) -> some View {
    HStack(spacing: 12) {
        Image(systemName: icon).foregroundStyle(tint).frame(width: 22)
        Text(title).font(.subheadline).foregroundStyle(ReportTheme.text)
        Spacer()
        VStack(alignment: .trailing, spacing: 3) {
            Text(reportDuration(seconds)).font(.subheadline.bold()).foregroundStyle(tint)
            Text("\(Int((seconds / max(1, total) * 100).rounded()))%").font(.caption2.monospacedDigit()).foregroundStyle(ReportTheme.secondary)
        }
    }.accessibilityElement(children: .combine)
}
