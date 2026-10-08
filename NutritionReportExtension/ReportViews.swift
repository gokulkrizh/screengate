//
//  ReportViews.swift
//  NutritionReportExtension
//
//  Self-contained views rendered by the system inside the report context.
//  No app theme/fonts here — only what ships in the extension.
//

import SwiftUI
import FamilyControls

enum ReportTheme {
    static let background = Color(red: 0.06, green: 0.06, blue: 0.08)
    static let surface = Color(red: 0.11, green: 0.12, blue: 0.14)
    static let primary = Color(red: 0.0, green: 1.0, blue: 0.39)
    static let warning = Color(red: 1.0, green: 0.8, blue: 0.0)
    static let error = Color(red: 1.0, green: 0.27, blue: 0.23)
    static let purple = Color(red: 0.61, green: 0.36, blue: 1.0)
    static let text = Color(red: 0.96, green: 0.96, blue: 0.96)
    static let secondary = Color.white.opacity(0.6)
}

func reportDuration(_ seconds: Double) -> String {
    let minutes = Int((seconds / 60).rounded())
    if minutes >= 60 {
        return "\(minutes / 60)h \(minutes % 60)m"
    }
    return "\(minutes)m"
}

// MARK: - Nutrition Label (Report tab)

struct NutritionLabelReportView: View {
    let snapshot: ReportSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header("NUTRITION LABEL", subtitle: "LAST 7 DAYS")

            if snapshot.isEmpty {
                emptyState
            } else {
                proportionBar
                splitRows
                HStack(spacing: 12) {
                    statCard(icon: "moon.fill", tint: ReportTheme.purple,
                             value: reportDuration(snapshot.lateNightSeconds), label: "late night")
                    statCard(icon: "hand.tap.fill", tint: ReportTheme.primary,
                             value: "\(Int(snapshot.averagePickupsPerDay.rounded()))", label: "pickups/day")
                }
                if !snapshot.topJunkApps.isEmpty {
                    topApps
                }
            }
        }
        .padding(20)
        .background(ReportTheme.background)
    }

    private var splitRows: some View {
        VStack(spacing: 8) {
            splitRow(emoji: "🍩", name: "CARBS", seconds: snapshot.carbSeconds, tint: ReportTheme.warning)
            splitRow(emoji: "🥑", name: "FATS", seconds: snapshot.fatSeconds, tint: ReportTheme.purple)
            splitRow(emoji: "🥩", name: "PROTEIN + OTHER", seconds: snapshot.otherSeconds, tint: ReportTheme.primary)
        }
    }

    private var proportionBar: some View {
        GeometryReader { geo in
            let width = max(geo.size.width - 4, 1)
            HStack(spacing: 2) {
                Rectangle().fill(ReportTheme.warning).frame(width: width * snapshot.carbShare)
                Rectangle().fill(ReportTheme.purple).frame(width: width * fatShare)
                Rectangle().fill(ReportTheme.primary)
            }
            .clipShape(Capsule())
        }
        .frame(height: 10)
    }

    private var fatShare: Double {
        snapshot.totalSeconds > 0 ? snapshot.fatSeconds / snapshot.totalSeconds : 0
    }

    private var topApps: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TOP JUNK APPS")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(ReportTheme.secondary)
                .tracking(1.0)

            ForEach(snapshot.topJunkApps) { usage in
                HStack(spacing: 10) {
                    if let token = usage.token {
                        Label(token)
                            .labelStyle(.iconOnly)
                            .frame(width: 24, height: 24)
                    } else {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(ReportTheme.surface)
                            .frame(width: 24, height: 24)
                    }

                    Text(usage.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(ReportTheme.text)
                        .lineLimit(1)

                    Spacer()

                    Text(reportDuration(usage.seconds))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(ReportTheme.warning)
                }
            }
        }
        .padding(14)
        .background(ReportTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Today (Kitchen card)

struct TodayReportView: View {
    let snapshot: ReportSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header("TODAY'S PLATE", subtitle: "FROM THE SYSTEM")

            if snapshot.isEmpty {
                emptyState
            } else {
                splitRow(emoji: "🍩", name: "CARBS", seconds: snapshot.carbSeconds, tint: ReportTheme.warning)
                splitRow(emoji: "🥑", name: "FATS", seconds: snapshot.fatSeconds, tint: ReportTheme.purple)
                splitRow(emoji: "🥩", name: "PROTEIN + OTHER", seconds: snapshot.otherSeconds, tint: ReportTheme.primary)

                HStack(spacing: 12) {
                    statCard(icon: "hand.tap.fill", tint: ReportTheme.primary,
                             value: "\(snapshot.pickups)", label: "pickups")
                    statCard(icon: "sunrise.fill", tint: ReportTheme.warning,
                             value: snapshot.firstPickup.map { Self.timeFormatter.string(from: $0) } ?? "—",
                             label: "first pickup")
                }
            }
        }
        .padding(16)
        .background(ReportTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

// MARK: - Weekly Grade

struct WeeklyGradeReportView: View {
    let snapshot: ReportSnapshot
    let grade: String

    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                Circle()
                    .stroke(ReportTheme.surface, lineWidth: 8)
                    .frame(width: 92, height: 92)
                Text(grade)
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("WEEKLY GRADE")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(ReportTheme.secondary)
                    .tracking(1.0)
                Text(description)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(ReportTheme.text)
                if !snapshot.isEmpty {
                    Text("\(reportDuration(snapshot.carbSeconds)) of carbs · \(Int((snapshot.carbShare * 100).rounded()))% of screen time")
                        .font(.system(size: 12))
                        .foregroundStyle(ReportTheme.secondary)
                }
            }

            Spacer()
        }
        .padding(16)
        .background(ReportTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var color: Color {
        switch grade {
        case "A": return ReportTheme.primary
        case "B": return ReportTheme.primary
        case "C": return ReportTheme.warning
        default: return ReportTheme.error
        }
    }

    private var description: String {
        switch grade {
        case "A": return "Excellent week. Your diet is working."
        case "B": return "Good week. Small adjustments left."
        case "C": return "Moderate week. Watch the portions."
        case "D": return "Rough week. Check late-night carbs."
        default: return "Hard week. Let's reset on Monday."
        }
    }
}

// MARK: - Hook Insight (onboarding)

struct HookInsightReportView: View {
    let snapshot: ReportSnapshot

    var body: some View {
        VStack(spacing: 14) {
            Text("LAST WEEK")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(ReportTheme.secondary)
                .tracking(1.5)

            if snapshot.isEmpty {
                emptyState
            } else {
                Text(reportDuration(snapshot.carbSeconds))
                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                    .foregroundStyle(ReportTheme.warning)
                Text("of junk (carbs) apps")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(ReportTheme.text)

                Text("That's ≈ \(yearlyDays) days a year.")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(ReportTheme.text)
                    .padding(.top, 4)

                Text("\(Int((snapshot.junkShare * 100).rounded()))% of your screen time was junk.")
                    .font(.system(size: 13))
                    .foregroundStyle(ReportTheme.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(ReportTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var yearlyDays: Int {
        let weeklyHours = snapshot.carbSeconds / 3600
        return Int((weeklyHours * 52 / 24).rounded())
    }
}

// MARK: - Shared bits

private func header(_ title: String, subtitle: String) -> some View {
    VStack(alignment: .leading, spacing: 2) {
        Text(title)
            .font(.system(size: 16, weight: .heavy))
            .foregroundStyle(ReportTheme.text)
        Text(subtitle)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(ReportTheme.secondary)
            .tracking(1.2)
    }
}

private func splitRow(emoji: String, name: String, seconds: Double, tint: Color) -> some View {
    HStack(spacing: 8) {
        Text(emoji)
        Text(name)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(ReportTheme.secondary)
        Spacer()
        Text(reportDuration(seconds))
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(tint)
    }
}

private func statCard(icon: String, tint: Color, value: String, label: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
        Image(systemName: icon)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(tint)
        Text(value)
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundStyle(ReportTheme.text)
        Text(label)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(ReportTheme.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(12)
    .background(ReportTheme.background)
    .clipShape(RoundedRectangle(cornerRadius: 12))
}

private var emptyState: some View {
    Text("No activity data yet. Use your phone for a full day and this report will fill in.")
        .font(.system(size: 13))
        .foregroundStyle(ReportTheme.secondary)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
}
