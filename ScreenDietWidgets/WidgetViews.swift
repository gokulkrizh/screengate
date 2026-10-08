import SwiftUI
import WidgetKit
import AppIntents

// MARK: - Theme

enum WidgetTheme {
    static let background = Color(red: 0.06, green: 0.06, blue: 0.08)
    static let surface = Color(red: 0.11, green: 0.12, blue: 0.14)
    static let primary = Color(red: 0.0, green: 1.0, blue: 0.39)
    static let warning = Color(red: 1.0, green: 0.8, blue: 0.0)
    static let purple = Color(red: 0.61, green: 0.36, blue: 1.0)
    static let text = Color(red: 0.96, green: 0.96, blue: 0.96)
    static let secondary = Color.white.opacity(0.6)
}

// MARK: - Locked (free tier)

struct LockedWidgetView: View {
    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            if family == .accessoryInline {
                Text("🔒 ScreenDiet Premium")
            } else {
                Link(destination: URL(string: "screengate://paywall?placement=feature_widgets")!) {
                    VStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: family == .systemSmall ? 22 : 18))
                            .foregroundStyle(WidgetTheme.primary)
                        Text("Premium")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(WidgetTheme.text)
                    }
                }
            }
        }
    }
}

// MARK: - Kitchen Status

struct KitchenStatusView: View {
    let entry: DietEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        if !entry.state.isPremium {
            LockedWidgetView()
        } else {
            switch family {
            case .accessoryCircular: circular
            case .accessoryRectangular: rectangular
            default: full
            }
        }
    }

    private var status: WidgetStatus { WidgetStatus.from(entry.state, at: entry.date) }

    private var icon: String {
        switch status {
        case .open: return "checkmark.circle.fill"
        case .closed, .nightFast: return "moon.fill"
        case .fastNow: return "bolt.fill"
        case .plateEmpty: return "xmark.circle.fill"
        case .inactive: return "fork.knife"
        }
    }

    private var title: String {
        switch status {
        case .open: return "KITCHEN OPEN"
        case .closed: return "KITCHEN CLOSED"
        case .nightFast: return "NIGHT FAST"
        case .fastNow: return "FOCUS FAST"
        case .plateEmpty: return "PLATE'S EMPTY"
        case .inactive: return "NO DIET"
        }
    }

    private var countdownEnd: Date? {
        switch status {
        case .open(let date): return date
        case .closed(let date): return date
        case .nightFast(let date): return date
        case .fastNow(let date): return date
        case .plateEmpty(let date): return date
        case .inactive: return nil
        }
    }

    private var countdownLabel: String {
        switch status {
        case .open: return "closes in"
        case .closed: return "opens in"
        case .nightFast: return "until morning"
        case .fastNow: return "remaining"
        case .plateEmpty: return "tomorrow in"
        case .inactive: return ""
        }
    }

    private var full: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(WidgetTheme.primary)
                Text(title)
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(WidgetTheme.text)
            }

            Spacer(minLength: 0)

            Text(countdownLabel)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(WidgetTheme.secondary)

            if let end = countdownEnd {
                Text(timerInterval: entry.date...end, countsDown: true)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(WidgetTheme.primary)
                    .monospacedDigit()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var circular: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                if let end = countdownEnd {
                    Text(timerInterval: entry.date...end, countsDown: true)
                        .font(.system(size: 9, weight: .bold))
                        .monospacedDigit()
                }
            }
        }
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title)
                .font(.system(size: 12, weight: .heavy))
            if let end = countdownEnd {
                Text(timerInterval: entry.date...end, countsDown: true)
                    .font(.system(size: 11))
                    .monospacedDigit()
            }
        }
    }
}

// MARK: - Plate

struct PlateView: View {
    let entry: DietEntry
    @Environment(\.widgetFamily) private var family

    private var portion: Int { entry.state.profile?.portionMinutes ?? 0 }
    private var used: Int { min(entry.state.counters.carbMinutes, portion) }
    private var remaining: Int { max(0, portion - used) }
    private var progress: Double {
        portion > 0 ? min(1, Double(used) / Double(portion)) : 1
    }

    var body: some View {
        if !entry.state.isPremium {
            LockedWidgetView()
        } else if family == .accessoryCircular {
            Gauge(value: progress) {
                Image(systemName: "takeoutbag.and.cup.and.straw")
            }
            .gaugeStyle(.accessoryCircularCapacity)
        } else {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(WidgetTheme.surface, lineWidth: 10)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            progress >= 1 ? WidgetTheme.warning : WidgetTheme.primary,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 0) {
                        Text(portion > 0 ? "≈ \(remaining)m" : "0m")
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .foregroundStyle(WidgetTheme.text)
                        Text("left")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(WidgetTheme.secondary)
                    }
                }
                .frame(width: 92, height: 92)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Streak

struct StreakView: View {
    let entry: DietEntry
    @Environment(\.widgetFamily) private var family

    private var cheatsRemaining: Int {
        guard let profile = entry.state.profile else { return 0 }
        let allowed = Entitlement.clampedCheats(profile.cheatsPerWeek, isPremium: entry.state.isPremium)
        return max(0, allowed - entry.state.week.cheatsUsed)
    }

    var body: some View {
        if !entry.state.isPremium {
            LockedWidgetView()
        } else if family == .accessoryInline {
            Text("🔥 \(entry.state.streak) · \(cheatsRemaining) cheats left")
        } else {
            VStack(spacing: 6) {
                Text("🔥")
                    .font(.system(size: 26))
                Text("\(entry.state.streak)")
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundStyle(WidgetTheme.text)
                Text("day streak · \(cheatsRemaining) cheats")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(WidgetTheme.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Fast Now (interactive)

struct FastNowView: View {
    let entry: DietEntry

    private var morningMinutes: Int {
        guard let profile = entry.state.profile else { return 480 }
        let minutes = profile.eatingWindow.minutesUntilOpen(at: entry.date)
        return max(DietRules.minimumScheduleMinutes, minutes)
    }

    var body: some View {
        if !entry.state.isPremium {
            LockedWidgetView()
        } else {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .foregroundStyle(WidgetTheme.primary)
                    Text("FAST NOW")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(WidgetTheme.text)
                }

                HStack(spacing: 8) {
                    fastButton("1h", minutes: 60)
                    fastButton("2h", minutes: 120)
                    fastButton("Morning", minutes: morningMinutes)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }

    private func fastButton(_ label: String, minutes: Int) -> some View {
        Button(intent: StartFastIntent(minutes: minutes)) {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(WidgetTheme.primary)
    }
}
