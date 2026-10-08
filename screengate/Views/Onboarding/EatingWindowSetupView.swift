import SwiftUI

struct EatingWindowSetupView: View {
    @ObservedObject var data: OnboardingData
    @State private var windowStartHour: Int = 12
    @State private var windowEndHour: Int = 18
    @State private var dailyCarbLimit: Int = DebugConfig.defaultPortionMinutes
    @State private var nightLockHour: Int = 21
    private let appTheme = AppTheme.shared

    var body: some View {
        ZStack {
            appTheme.colors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: appTheme.spacing.extraLarge) {
                    // Header
                    VStack(spacing: appTheme.spacing.small) {
                        Text("Set Your Schedule")
                            .font(appTheme.fonts.headlineLarge)
                            .foregroundColor(appTheme.colors.text)

                        Text("Define when your kitchen opens for carbs, daily limits, and night lock.")
                            .font(appTheme.fonts.bodyLarge)
                            .foregroundColor(appTheme.colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, appTheme.spacing.extraLarge)
                    .padding(.horizontal, appTheme.spacing.large)

                    // Eating window
                    VStack(alignment: .leading, spacing: appTheme.spacing.medium) {
                        sectionHeader(icon: "clock.fill", title: "EATING WINDOW", subtitle: "When carb apps are accessible")

                        // Visual timeline
                        timelineVisual

                        // Start time
                        HStack {
                            Text("Opens at")
                                .font(appTheme.fonts.bodyMedium)
                                .foregroundColor(appTheme.colors.textSecondary)
                            Spacer()
                            Picker("Start", selection: $windowStartHour) {
                                ForEach(5..<24, id: \.self) { hour in
                                    Text(formatHour(hour)).tag(hour)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(appTheme.colors.primary)
                        }

                        // End time
                        HStack {
                            Text("Closes at")
                                .font(appTheme.fonts.bodyMedium)
                                .foregroundColor(appTheme.colors.textSecondary)
                            Spacer()
                            Picker("End", selection: $windowEndHour) {
                                ForEach(windowStartHour + 1...23, id: \.self) { hour in
                                    Text(formatHour(hour)).tag(hour)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(appTheme.colors.primary)
                        }
                    }
                    .padding(appTheme.spacing.medium)
                    .background(appTheme.colors.surface)
                    .cornerRadius(appTheme.spacing.cornerRadiusMedium)
                    .padding(.horizontal, appTheme.spacing.large)

                    // Daily carb limit
                    VStack(alignment: .leading, spacing: appTheme.spacing.medium) {
                        sectionHeader(icon: "timer", title: "DAILY CARB LIMIT", subtitle: "Maximum minutes of carb apps per day")

                        HStack {
                            Text("\(dailyCarbLimit) min")
                                .font(appTheme.fonts.headlineMedium)
                                .foregroundColor(appTheme.colors.primary)
                            Spacer()
                        }

                        Slider(
                            value: Binding(
                                get: { Double(dailyCarbLimit) },
                                set: { dailyCarbLimit = Int($0) }
                            ),
                            in: 15...180,
                            step: 15
                        )
                        .tint(appTheme.colors.primary)

                        HStack {
                            Text("15 min")
                                .font(appTheme.fonts.labelSmall)
                                .foregroundColor(appTheme.colors.textSecondary)
                            Spacer()
                            Text("3 hrs")
                                .font(appTheme.fonts.labelSmall)
                                .foregroundColor(appTheme.colors.textSecondary)
                        }
                    }
                    .padding(appTheme.spacing.medium)
                    .background(appTheme.colors.surface)
                    .cornerRadius(appTheme.spacing.cornerRadiusMedium)
                    .padding(.horizontal, appTheme.spacing.large)

                    // Night lock
                    VStack(alignment: .leading, spacing: appTheme.spacing.medium) {
                        sectionHeader(icon: "moon.fill", title: "NIGHT LOCK", subtitle: "Everything except protein is locked")

                        HStack {
                            Text("Locks at")
                                .font(appTheme.fonts.bodyMedium)
                                .foregroundColor(appTheme.colors.textSecondary)
                            Spacer()
                            Picker("Night lock", selection: $nightLockHour) {
                                ForEach(windowEndHour...23, id: \.self) { hour in
                                    Text(formatHour(hour)).tag(hour)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(appTheme.colors.primary)
                        }

                        Text("From \(formatHour(nightLockHour)) until \(formatHour(windowStartHour))")
                            .font(appTheme.fonts.bodySmall)
                            .foregroundColor(appTheme.colors.textSecondary)
                    }
                    .padding(appTheme.spacing.medium)
                    .background(appTheme.colors.surface)
                    .cornerRadius(appTheme.spacing.cornerRadiusMedium)
                    .padding(.horizontal, appTheme.spacing.large)

                    // Continue button
                    Button(action: saveAndContinue) {
                        Text("Activate Diet")
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
        }
        .onAppear {
            loadDefaults()
        }
    }

    // MARK: - Timeline Visual

    private var timelineVisual: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let hourWidth = width / 24.0

            ZStack(alignment: .leading) {
                // Full day background
                RoundedRectangle(cornerRadius: 4)
                    .fill(appTheme.colors.surfaceVariant)
                    .frame(height: 32)

                // Fasting (before window)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(red: 0.3, green: 0.3, blue: 0.5).opacity(0.3))
                    .frame(width: hourWidth * CGFloat(windowStartHour), height: 32)

                // Eating window
                RoundedRectangle(cornerRadius: 4)
                    .fill(appTheme.colors.primary.opacity(0.3))
                    .frame(width: hourWidth * CGFloat(windowEndHour - windowStartHour), height: 32)
                    .offset(x: hourWidth * CGFloat(windowStartHour))

                // Night lock
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.red.opacity(0.2))
                    .frame(width: hourWidth * CGFloat(24 - nightLockHour), height: 32)
                    .offset(x: hourWidth * CGFloat(nightLockHour))

                // Labels
                HStack {
                    Text("Fast")
                        .font(appTheme.fonts.labelSmall)
                        .foregroundColor(appTheme.colors.textSecondary)
                        .offset(x: hourWidth * CGFloat(windowStartHour / 2) - 12)

                    Spacer()
                }
                .frame(height: 32)
            }
        }
        .frame(height: 32)
    }

    // MARK: - Helpers

    private func sectionHeader(icon: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(appTheme.colors.primary)
                Text(title)
                    .font(appTheme.fonts.labelMedium)
                    .foregroundColor(appTheme.colors.primary)
                    .tracking(1.0)
            }
            Text(subtitle)
                .font(appTheme.fonts.bodySmall)
                .foregroundColor(appTheme.colors.textSecondary)
        }
    }

    private func formatHour(_ hour: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return "\(displayHour):00 \(period)"
    }

    private func loadDefaults() {
        if let diet = data.selectedDietType {
            windowStartHour = diet.defaultWindowStartHour
            windowEndHour = diet.defaultWindowEndHour
            dailyCarbLimit = diet.defaultCarbLimitMinutes
        }
    }

    private func saveAndContinue() {
        data.windowStartHour = windowStartHour
        data.windowEndHour = windowEndHour
        data.dailyCarbLimitMinutes = dailyCarbLimit
        data.nightLockHour = nightLockHour
        data.nextScreen()
    }
}
