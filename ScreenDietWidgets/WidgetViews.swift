import SwiftUI
import WidgetKit
import AppIntents

enum WidgetTheme {
    static let background = Color(red: 0.045, green: 0.085, blue: 0.07)
    static let surface = Color(red: 0.14, green: 0.20, blue: 0.17)
    static let primary = Color(red: 0.70, green: 0.86, blue: 0.55)
    static let warning = Color(red: 0.96, green: 0.71, blue: 0.46)
    static let purple = Color(red: 0.73, green: 0.65, blue: 0.88)
    static let text = Color(red: 0.97, green: 0.95, blue: 0.88)
    static let secondary = Color(red: 0.65, green: 0.72, blue: 0.67)
}
struct LockedWidgetView: View {
    @Environment(\.widgetFamily) private var family
    var body: some View {
        Group {
            if family == .accessoryInline { Text("ScreenDiet Plus · Your routine at a glance") }
            else if family == .accessoryCircular { Image(systemName: "lock.fill").font(.title2) }
            else if family == .accessoryRectangular { Label("ScreenDiet Plus", systemImage: "lock.fill").font(.headline) }
            else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack { Image(systemName: "leaf.fill"); Spacer(); Image(systemName: "lock.fill") }.foregroundStyle(WidgetTheme.primary)
                    Spacer(minLength: 0)
                    Text("A little intention.\nAt a glance.").font(.system(.headline, design: .serif)).foregroundStyle(WidgetTheme.text)
                    Text("Explore ScreenDiet Plus").font(.caption2).foregroundStyle(WidgetTheme.secondary)
                }
            }
        }.widgetURL(URL(string: "screengate://paywall?placement=feature_widgets"))
    }
}
struct KitchenStatusView: View {
    let entry: DietEntry
    @Environment(\.widgetFamily) private var family
    private var status: WidgetStatus { WidgetStatus.from(entry.state, at: entry.date) }
    private var icon: String {
        switch status { case .open: return "sun.max.fill"; case .closed: return "moon.fill"; case .nightFast: return "moon.stars.fill"; case .fastNow: return "hourglass"; case .plateEmpty: return "fork.knife"; case .inactive: return "leaf.fill" }
    }
    private var title: String {
        switch status { case .open: return "Kitchen open"; case .closed: return "A little breathing room"; case .nightFast: return "Quiet hours"; case .fastNow: return "Room to focus"; case .plateEmpty: return "Plate’s empty"; case .inactive: return "A fresh start" }
    }
    private var end: Date? {
        switch status { case .open(let date), .closed(let date), .nightFast(let date), .fastNow(let date), .plateEmpty(let date): return date; case .inactive: return nil }
    }
    private var caption: String {
        switch status { case .open: return "closes in"; case .closed, .plateEmpty: return "opens in"; case .nightFast: return "resting for"; case .fastNow: return "focus remaining"; case .inactive: return "Build your routine in ScreenDiet" }
    }
    private var asset: String {
        switch status { case .open: return "DigitalGarden"; case .closed, .nightFast: return "NightGarden"; case .fastNow: return "FocusGarden"; case .plateEmpty, .inactive: return "FreshStart" }
    }
    var body: some View {
        Group {
            if !entry.state.isPremium { LockedWidgetView() }
            else if family == .accessoryCircular {
                ZStack { AccessoryWidgetBackground(); Image(systemName: icon).font(.title2) }
            } else if family == .accessoryRectangular {
                VStack(alignment: .leading, spacing: 3) { Label(title, systemImage: icon).font(.caption.bold()); countdown.font(.caption.monospacedDigit()) }
            } else {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("SCREENDIET", systemImage: icon).font(.system(size: 9, weight: .bold)).tracking(1).foregroundStyle(WidgetTheme.primary)
                        Text(title).font(.system(.headline, design: .serif)).foregroundStyle(WidgetTheme.text)
                        Spacer(minLength: 0)
                        Text(caption).font(.caption2).foregroundStyle(WidgetTheme.secondary)
                        countdown.font(.system(.title3, design: .rounded).bold()).foregroundStyle(WidgetTheme.primary)
                    }
                    if family == .systemMedium { Image(asset).resizable().scaledToFit().frame(width: 110).clipShape(RoundedRectangle(cornerRadius: 20)).accessibilityHidden(true) }
                }
            }
        }.widgetURL(URL(string: entry.state.isPremium ? "screengate://kitchen" : "screengate://paywall?placement=feature_widgets"))
    }
    @ViewBuilder private var countdown: some View {
        if let end, end > entry.date { Text(timerInterval: entry.date...end, countsDown: true).monospacedDigit() }
        else { Text("—") }
    }
}
struct PlateView: View {
    let entry: DietEntry
    @Environment(\.widgetFamily) private var family
    private var portion: Int { entry.state.profile?.portionMinutes ?? 0 }
    private var remaining: Int { max(0, portion - entry.state.counters.carbMinutes) }
    private var fraction: Double { portion > 0 ? min(1, max(0, Double(remaining) / Double(portion))) : 0 }
    var body: some View {
        Group {
            if !entry.state.isPremium { LockedWidgetView() }
            else if family == .accessoryCircular {
                Gauge(value: fraction) { Image(systemName: "fork.knife") }.gaugeStyle(.accessoryCircularCapacity)
            } else {
                VStack(spacing: 12) {
                    Text("TODAY’S PORTION").font(.system(size: 9, weight: .bold)).tracking(1).foregroundStyle(WidgetTheme.primary)
                    ZStack {
                        Circle().stroke(WidgetTheme.surface, lineWidth: 8)
                        Circle().trim(from: 0, to: fraction).stroke(WidgetTheme.primary, style: StrokeStyle(lineWidth: 8, lineCap: .round)).rotationEffect(.degrees(-90))
                        VStack(spacing: 2) { Text("≈ \(remaining)m").font(.system(.title3, design: .rounded).bold()).contentTransition(.numericText()); Text("left to enjoy").font(.caption2) }.foregroundStyle(WidgetTheme.text)
                    }.frame(width: 92, height: 92)
                }
            }
        }.widgetURL(URL(string: entry.state.isPremium ? "screengate://kitchen" : "screengate://paywall?placement=feature_widgets"))
    }
}
struct StreakView: View {
    let entry: DietEntry
    @Environment(\.widgetFamily) private var family
    private var cheats: Int { max(0, Entitlement.clampedCheats(entry.state.profile?.cheatsPerWeek ?? 0, isPremium: entry.state.isPremium) - entry.state.week.cheatsUsed) }
    var body: some View {
        Group {
            if !entry.state.isPremium { LockedWidgetView() }
            else if family == .accessoryInline { Text("\(entry.state.streak) day streak · \(cheats) cheats left") }
            else {
                VStack(spacing: 8) {
                    Image(systemName: "flame.fill").font(.title2).foregroundStyle(WidgetTheme.warning)
                    Text("\(entry.state.streak)").font(.system(.largeTitle, design: .serif).bold()).foregroundStyle(WidgetTheme.text).contentTransition(.numericText())
                    Text("days within portion").font(.caption2).foregroundStyle(WidgetTheme.secondary)
                    Text("\(cheats) cheat meals left").font(.caption2).foregroundStyle(WidgetTheme.primary)
                }
            }
        }.widgetURL(URL(string: entry.state.isPremium ? "screengate://kitchen" : "screengate://paywall?placement=feature_widgets"))
    }
}
struct FastNowView: View {
    let entry: DietEntry
    @Environment(\.widgetFamily) private var family
    private var morning: Int { max(15, entry.state.profile?.eatingWindow.minutesUntilNextOpen(at: entry.date) ?? 480) }
    var body: some View {
        if !entry.state.isPremium { LockedWidgetView() }
        else {
            VStack(alignment: .leading, spacing: 10) {
                Label("Room to focus", systemImage: "hourglass").font(.system(.headline, design: .serif)).foregroundStyle(WidgetTheme.text)
                Text("Pause Carbs & Fats").font(.caption2).foregroundStyle(WidgetTheme.secondary)
                HStack(spacing: 8) { fastButton("1h", 60); fastButton("2h", 120) }
                if family == .systemMedium { fastButton("Until next opening", morning) }
            }
        }
    }
    private func fastButton(_ title: String, _ minutes: Int) -> some View {
        Button(intent: StartFastIntent(minutes: minutes)) {
            Text(title).font(.caption.bold()).foregroundStyle(WidgetTheme.background).frame(maxWidth: .infinity).padding(.vertical, 8)
        }.buttonStyle(.borderedProminent).tint(WidgetTheme.primary)
    }
}
