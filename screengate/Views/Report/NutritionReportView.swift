import SwiftUI

struct NutritionReportView: View {
    @Environment(DietManager.self) private var dietManager
    @State private var selectedPeriod = 0  // 0=This Week, 1=Last Week
    private let appTheme = AppTheme.shared

    var body: some View {
        ScrollView {
            VStack(spacing: appTheme.spacing.large) {
                // Header
                HStack {
                    Text("Nutrition Report")
                        .font(appTheme.fonts.headlineLarge)
                        .foregroundColor(appTheme.colors.text)
                    Spacer()
                }
                .padding(.top, appTheme.spacing.medium)

                // Period selector
                Picker("Period", selection: $selectedPeriod) {
                    Text("This Week").tag(0)
                    Text("Last Week").tag(1)
                }
                .pickerStyle(.segmented)

                if let summary = dietManager.getWeeklySummary() {
                    // Metabolic score
                    metabolicScoreCard(grade: summary.metabolicGrade)

                    // Digital body composition
                    bodyCompositionCard(summary: summary)

                    // Total screen time
                    screenTimeCard(summary: summary)

                    // Daily breakdown chart
                    dailyBreakdownChart(summary: summary)

                    // Issues detected
                    issuesCard

                    // Prescription link
                    prescriptionCard
                } else {
                    // No data yet
                    VStack(spacing: appTheme.spacing.medium) {
                        Image(systemName: "chart.bar")
                            .font(.system(size: 40))
                            .foregroundColor(appTheme.colors.secondary)
                        Text("No Data Yet")
                            .font(appTheme.fonts.headlineSmall)
                            .foregroundColor(appTheme.colors.text)
                        Text("Complete a full day on your diet to see your nutrition report.")
                            .font(appTheme.fonts.bodyMedium)
                            .foregroundColor(appTheme.colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(appTheme.spacing.large)
                }

                Spacer(minLength: 80)
            }
            .padding(.horizontal, appTheme.spacing.large)
        }
        .background(appTheme.colors.background.ignoresSafeArea())
    }

    // MARK: - Metabolic Score

    private func metabolicScoreCard(grade: String) -> some View {
        VStack(spacing: appTheme.spacing.medium) {
            Text("METABOLIC SCORE")
                .font(appTheme.fonts.labelSmall)
                .foregroundColor(appTheme.colors.primary)
                .tracking(1.5)

            ZStack {
                Circle()
                    .stroke(appTheme.colors.surfaceVariant, lineWidth: 6)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: gradeToProgress(grade))
                    .stroke(gradeColor(grade), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))

                Text(grade)
                    .font(appTheme.fonts.displaySmall)
                    .foregroundColor(gradeColor(grade))
            }

            Text(gradeDescription(grade))
                .font(appTheme.fonts.bodySmall)
                .foregroundColor(appTheme.colors.textSecondary)
        }
        .padding(appTheme.spacing.large)
        .background(appTheme.colors.surface)
        .cornerRadius(appTheme.spacing.cornerRadiusLarge)
    }

    // MARK: - Body Composition

    private func bodyCompositionCard(summary: WeeklyNutritionSummary) -> some View {
        VStack(alignment: .leading, spacing: appTheme.spacing.medium) {
            Text("DIGITAL BODY COMPOSITION")
                .font(appTheme.fonts.labelSmall)
                .foregroundColor(appTheme.colors.primary)
                .tracking(1.0)

            ForEach(FoodGroup.allCases) { group in
                let actual = summary.overallPercentage(for: group)
                let target = dietManager.dietProfile?.ratio(for: group) ?? 0

                HStack {
                    Text(group.emoji)
                    Text(group.displayName)
                        .font(appTheme.fonts.labelMedium)
                        .foregroundColor(appTheme.colors.textSecondary)
                        .frame(width: 70, alignment: .leading)

                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(appTheme.colors.surfaceVariant)
                                .frame(height: 8)

                            Capsule()
                                .fill(macroColor(group))
                                .frame(width: geometry.size.width * min(actual / 100, 1.0), height: 8)

                            // Target marker
                            Rectangle()
                                .fill(appTheme.colors.text.opacity(0.5))
                                .frame(width: 2, height: 14)
                                .offset(x: geometry.size.width * CGFloat(target) / 100 - 1)
                        }
                    }
                    .frame(height: 14)

                    Text("\(Int(actual))%")
                        .font(appTheme.fonts.labelSmall)
                        .foregroundColor(appTheme.colors.text)
                        .frame(width: 35, alignment: .trailing)
                }
            }
        }
        .padding(appTheme.spacing.medium)
        .background(appTheme.colors.surface)
        .cornerRadius(appTheme.spacing.cornerRadiusMedium)
    }

    // MARK: - Screen Time

    private func screenTimeCard(summary: WeeklyNutritionSummary) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("TOTAL SCREEN TIME")
                    .font(appTheme.fonts.labelSmall)
                    .foregroundColor(appTheme.colors.primary)
                    .tracking(1.0)
                Text(String(format: "%.1f hrs", summary.totalHours))
                    .font(appTheme.fonts.headlineLarge)
                    .foregroundColor(appTheme.colors.text)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("Avg/Day")
                    .font(appTheme.fonts.labelSmall)
                    .foregroundColor(appTheme.colors.textSecondary)
                Text("\(summary.averageDailyMinutes)m")
                    .font(appTheme.fonts.titleLarge)
                    .foregroundColor(appTheme.colors.text)
            }
        }
        .padding(appTheme.spacing.medium)
        .background(appTheme.colors.surface)
        .cornerRadius(appTheme.spacing.cornerRadiusMedium)
    }

    // MARK: - Daily Chart

    private func dailyBreakdownChart(summary: WeeklyNutritionSummary) -> some View {
        VStack(alignment: .leading, spacing: appTheme.spacing.medium) {
            Text("DAILY BREAKDOWN")
                .font(appTheme.fonts.labelSmall)
                .foregroundColor(appTheme.colors.primary)
                .tracking(1.0)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(summary.dailyLogs.indices, id: \.self) { index in
                    let log = summary.dailyLogs[index]
                    let maxMinutes = max(summary.dailyLogs.map { $0.totalMinutes }.max() ?? 1, 1)
                    let height = CGFloat(log.totalMinutes) / CGFloat(maxMinutes) * 100

                    VStack(spacing: 4) {
                        // Stacked bar
                        VStack(spacing: 1) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(macroColor(.protein))
                                .frame(height: max(2, height * CGFloat(log.proteinPercentage) / 100))
                            RoundedRectangle(cornerRadius: 2)
                                .fill(macroColor(.carbs))
                                .frame(height: max(2, height * CGFloat(log.carbsPercentage) / 100))
                            RoundedRectangle(cornerRadius: 2)
                                .fill(macroColor(.fats))
                                .frame(height: max(2, height * CGFloat(log.fatsPercentage) / 100))
                            RoundedRectangle(cornerRadius: 2)
                                .fill(macroColor(.fiber))
                                .frame(height: max(2, height * CGFloat(log.fiberPercentage) / 100))
                        }
                        .frame(height: max(8, height))

                        // Day label
                        Text(dayLabel(index))
                            .font(appTheme.fonts.labelSmall)
                            .foregroundColor(appTheme.colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 120)
        }
        .padding(appTheme.spacing.medium)
        .background(appTheme.colors.surface)
        .cornerRadius(appTheme.spacing.cornerRadiusMedium)
    }

    // MARK: - Issues

    private var issuesCard: some View {
        VStack(alignment: .leading, spacing: appTheme.spacing.medium) {
            Text("ISSUES DETECTED")
                .font(appTheme.fonts.labelSmall)
                .foregroundColor(appTheme.colors.warning)
                .tracking(1.0)

            issueRow(icon: "moon.fill", text: "Late-night carb usage detected on 2 days", severity: "high")
            issueRow(icon: "arrow.down", text: "Protein usage below target", severity: "medium")
            issueRow(icon: "calendar", text: "Weekend adherence dropped 30%", severity: "low")
        }
        .padding(appTheme.spacing.medium)
        .background(appTheme.colors.surface)
        .cornerRadius(appTheme.spacing.cornerRadiusMedium)
    }

    private func issueRow(icon: String, text: String, severity: String) -> some View {
        let color: Color = {
            switch severity {
            case "high": return appTheme.colors.error
            case "medium": return appTheme.colors.warning
            default: return appTheme.colors.textSecondary
            }
        }()

        return HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            Text(text)
                .font(appTheme.fonts.bodySmall)
                .foregroundColor(appTheme.colors.textSecondary)
        }
    }

    // MARK: - Prescription

    private var prescriptionCard: some View {
        VStack(spacing: appTheme.spacing.medium) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 24))
                .foregroundColor(appTheme.colors.primary)

            Text("Weekly Prescription Ready")
                .font(appTheme.fonts.titleMedium)
                .foregroundColor(appTheme.colors.text)

            Text("View your personalized adjustments for next week")
                .font(appTheme.fonts.bodySmall)
                .foregroundColor(appTheme.colors.textSecondary)
        }
        .padding(appTheme.spacing.medium)
        .frame(maxWidth: .infinity)
        .background(appTheme.colors.primary.opacity(0.08))
        .cornerRadius(appTheme.spacing.cornerRadiusMedium)
    }

    // MARK: - Helpers

    private func macroColor(_ group: FoodGroup) -> Color {
        switch group {
        case .protein: return appTheme.colors.primary
        case .carbs: return appTheme.colors.warning
        case .fats: return Color(red: 0.6, green: 0.4, blue: 1.0)
        case .fiber: return Color(red: 0.2, green: 0.8, blue: 0.8)
        }
    }

    private func gradeToProgress(_ grade: String) -> Double {
        switch grade {
        case "A+": return 0.95
        case "A": return 0.85
        case "B+": return 0.75
        case "B": return 0.65
        case "C+": return 0.55
        case "C": return 0.45
        case "D+": return 0.35
        case "D": return 0.25
        default: return 0.15
        }
    }

    private func gradeColor(_ grade: String) -> Color {
        if grade.hasPrefix("A") { return appTheme.colors.primary }
        if grade.hasPrefix("B") { return Color(red: 0.2, green: 0.8, blue: 0.8) }
        if grade.hasPrefix("C") { return appTheme.colors.warning }
        return appTheme.colors.error
    }

    private func gradeDescription(_ grade: String) -> String {
        if grade.hasPrefix("A") { return "Excellent adherence to your diet" }
        if grade.hasPrefix("B") { return "Good adherence, room for improvement" }
        if grade.hasPrefix("C") { return "Moderate adherence, needs attention" }
        return "Poor adherence, consider adjusting your plan"
    }

    private func dayLabel(_ index: Int) -> String {
        let days = ["M", "T", "W", "T", "F", "S", "S"]
        return index < days.count ? days[index] : ""
    }
}
