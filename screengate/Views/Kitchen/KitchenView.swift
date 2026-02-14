import SwiftUI
import Combine

struct KitchenView: View {
    @Environment(DietManager.self) private var dietManager
    @State private var currentTime = Date()
    private let appTheme = AppTheme.shared
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView {
            VStack(spacing: appTheme.spacing.large) {
                // Header
                header

                // State-dependent content
                switch dietManager.currentDietState {
                case .fasting:
                    fastingContent
                case .windowOpen:
                    windowOpenContent
                case .limitReached:
                    limitReachedContent
                case .nightLock:
                    nightLockContent
                case .inactive:
                    inactiveContent
                }

                // Today's nutrition breakdown
                nutritionBreakdown

                Spacer(minLength: 80)
            }
            .padding(.horizontal, appTheme.spacing.large)
        }
        .background(appTheme.colors.background.ignoresSafeArea())
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "leaf.fill")
                        .foregroundColor(appTheme.colors.primary)
                    Text("Screendiet")
                        .font(appTheme.fonts.titleLarge)
                        .foregroundColor(appTheme.colors.text)
                }
                if let profile = dietManager.dietProfile {
                    Text("\(profile.dietType.displayName) Diet - Week \(profile.weekNumber)")
                        .font(appTheme.fonts.labelSmall)
                        .foregroundColor(appTheme.colors.textSecondary)
                }
            }
            Spacer()
            stateIndicator
        }
        .padding(.top, appTheme.spacing.medium)
    }

    private var stateIndicator: some View {
        let state = dietManager.currentDietState
        let (icon, color, label): (String, Color, String) = {
            switch state {
            case .fasting: return ("moon.fill", Color(red: 0.4, green: 0.4, blue: 0.8), "FASTING")
            case .windowOpen: return ("checkmark.circle.fill", appTheme.colors.primary, "KITCHEN OPEN")
            case .limitReached: return ("exclamationmark.octagon.fill", appTheme.colors.error, "LIMIT REACHED")
            case .nightLock: return ("lock.fill", Color(red: 0.6, green: 0.3, blue: 0.8), "NIGHT LOCK")
            case .inactive: return ("pause.circle.fill", appTheme.colors.secondary, "INACTIVE")
            }
        }()

        return HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(label)
                .font(appTheme.fonts.labelSmall)
                .tracking(0.5)
        }
        .foregroundColor(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.15))
        .cornerRadius(appTheme.spacing.cornerRadiusSmall)
    }

    // MARK: - Fasting Content

    private var fastingContent: some View {
        VStack(spacing: appTheme.spacing.large) {
            // Fasting progress
            VStack(spacing: appTheme.spacing.medium) {
                ZStack {
                    Circle()
                        .stroke(appTheme.colors.surfaceVariant, lineWidth: 8)
                        .frame(width: 160, height: 160)

                    Circle()
                        .trim(from: 0, to: dietManager.fastingProgress / 100)
                        .stroke(Color(red: 0.4, green: 0.4, blue: 0.8), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 4) {
                        Image(systemName: "moon.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.8))

                        Text("\(Int(dietManager.fastingProgress))%")
                            .font(appTheme.fonts.headlineLarge)
                            .foregroundColor(appTheme.colors.text)

                        Text("Fasting")
                            .font(appTheme.fonts.labelSmall)
                            .foregroundColor(appTheme.colors.textSecondary)
                    }
                }

                // Time until window opens
                if let profile = dietManager.dietProfile {
                    let minutesUntil = profile.eatingWindow.minutesUntilOpen(at: currentTime)
                    let hours = minutesUntil / 60
                    let mins = minutesUntil % 60

                    Text("Kitchen opens in \(hours)h \(mins)m")
                        .font(appTheme.fonts.bodyLarge)
                        .foregroundColor(appTheme.colors.textSecondary)

                    Text("Window: \(profile.eatingWindow.startTimeString) - \(profile.eatingWindow.endTimeString)")
                        .font(appTheme.fonts.labelSmall)
                        .foregroundColor(appTheme.colors.textSecondary)
                }
            }
            .padding(appTheme.spacing.large)
            .background(appTheme.colors.surface)
            .cornerRadius(appTheme.spacing.cornerRadiusLarge)

            // Streak
            streakCard

            // Always-available protein
            proteinCard
        }
    }

    // MARK: - Window Open Content

    private var windowOpenContent: some View {
        VStack(spacing: appTheme.spacing.large) {
            // Carb window status
            VStack(spacing: appTheme.spacing.medium) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("KITCHEN OPEN")
                            .font(appTheme.fonts.labelMedium)
                            .foregroundColor(appTheme.colors.primary)
                            .tracking(1.0)
                        if let profile = dietManager.dietProfile {
                            let remaining = profile.eatingWindow.minutesUntilClose(at: currentTime)
                            Text("\(remaining / 60)h \(remaining % 60)m remaining")
                                .font(appTheme.fonts.bodyLarge)
                                .foregroundColor(appTheme.colors.textSecondary)
                        }
                    }
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(appTheme.colors.primary)
                }

                // Carb usage progress
                if let profile = dietManager.dietProfile {
                    let used = dietManager.todayLog.carbsMinutes
                    let limit = profile.eatingWindow.dailyCarbLimitMinutes
                    let progress = limit > 0 ? min(1.0, Double(used) / Double(limit)) : 0

                    VStack(spacing: appTheme.spacing.small) {
                        HStack {
                            Text("Carb Budget")
                                .font(appTheme.fonts.labelMedium)
                                .foregroundColor(appTheme.colors.textSecondary)
                            Spacer()
                            Text("\(used)/\(limit) min")
                                .font(appTheme.fonts.titleSmall)
                                .foregroundColor(progress > 0.8 ? appTheme.colors.warning : appTheme.colors.text)
                        }

                        ProgressView(value: progress)
                            .tint(progress > 0.8 ? appTheme.colors.warning : appTheme.colors.primary)
                    }
                }
            }
            .padding(appTheme.spacing.large)
            .background(appTheme.colors.surface)
            .cornerRadius(appTheme.spacing.cornerRadiusLarge)

            // Quick stats
            HStack(spacing: appTheme.spacing.medium) {
                statCard(title: "Remaining", value: "\(dietManager.carbsRemainingMinutes)m", icon: "timer", color: appTheme.colors.primary)
                statCard(title: "Cheats Left", value: "\(dietManager.cheatsRemaining)", icon: "ticket", color: appTheme.colors.warning)
            }

            proteinCard
        }
    }

    // MARK: - Limit Reached Content

    private var limitReachedContent: some View {
        VStack(spacing: appTheme.spacing.large) {
            // Limit reached banner
            VStack(spacing: appTheme.spacing.medium) {
                Image(systemName: "exclamationmark.octagon.fill")
                    .font(.system(size: 40))
                    .foregroundColor(appTheme.colors.error)

                Text("Daily Carb Limit Reached")
                    .font(appTheme.fonts.headlineSmall)
                    .foregroundColor(appTheme.colors.text)

                if let profile = dietManager.dietProfile {
                    Text("\(profile.eatingWindow.dailyCarbLimitMinutes)/\(profile.eatingWindow.dailyCarbLimitMinutes) minutes consumed")
                        .font(appTheme.fonts.bodyMedium)
                        .foregroundColor(appTheme.colors.textSecondary)
                }

                // Cheat meal button
                if dietManager.cheatsRemaining > 0 {
                    Button(action: {
                        try? dietManager.useCheatMeal()
                    }) {
                        HStack {
                            Image(systemName: "ticket")
                            Text("Use Cheat Meal (\(dietManager.cheatsRemaining) left)")
                        }
                        .font(appTheme.fonts.titleSmall)
                        .foregroundColor(appTheme.colors.background)
                        .padding(.horizontal, appTheme.spacing.large)
                        .padding(.vertical, appTheme.spacing.medium)
                        .background(appTheme.colors.warning)
                        .cornerRadius(appTheme.spacing.cornerRadiusMedium)
                    }
                }
            }
            .padding(appTheme.spacing.large)
            .background(appTheme.colors.surface)
            .cornerRadius(appTheme.spacing.cornerRadiusLarge)

            // Alternatives
            VStack(alignment: .leading, spacing: appTheme.spacing.medium) {
                Text("AVAILABLE ALTERNATIVES")
                    .font(appTheme.fonts.labelSmall)
                    .foregroundColor(appTheme.colors.primary)
                    .tracking(1.0)

                Text("Protein and fiber apps are still available. Try creating something or learning something new.")
                    .font(appTheme.fonts.bodyMedium)
                    .foregroundColor(appTheme.colors.textSecondary)
            }
            .padding(appTheme.spacing.medium)
            .background(appTheme.colors.surface)
            .cornerRadius(appTheme.spacing.cornerRadiusMedium)

            proteinCard
        }
    }

    // MARK: - Night Lock Content

    private var nightLockContent: some View {
        VStack(spacing: appTheme.spacing.large) {
            VStack(spacing: appTheme.spacing.medium) {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color(red: 0.6, green: 0.3, blue: 0.8))

                Text("Night Lock Active")
                    .font(appTheme.fonts.headlineSmall)
                    .foregroundColor(appTheme.colors.text)

                Text("All apps except protein are locked until the kitchen opens tomorrow.")
                    .font(appTheme.fonts.bodyMedium)
                    .foregroundColor(appTheme.colors.textSecondary)
                    .multilineTextAlignment(.center)

                if let profile = dietManager.dietProfile {
                    Text("Kitchen opens at \(profile.eatingWindow.startTimeString)")
                        .font(appTheme.fonts.titleSmall)
                        .foregroundColor(appTheme.colors.primary)
                }
            }
            .padding(appTheme.spacing.large)
            .background(appTheme.colors.surface)
            .cornerRadius(appTheme.spacing.cornerRadiusLarge)

            proteinCard
        }
    }

    // MARK: - Inactive Content

    private var inactiveContent: some View {
        VStack(spacing: appTheme.spacing.large) {
            Image(systemName: "leaf")
                .font(.system(size: 40))
                .foregroundColor(appTheme.colors.secondary)

            Text("No Active Diet")
                .font(appTheme.fonts.headlineSmall)
                .foregroundColor(appTheme.colors.text)

            Text("Set up your digital diet in Settings to start managing your screen time nutrition.")
                .font(appTheme.fonts.bodyMedium)
                .foregroundColor(appTheme.colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(appTheme.spacing.large)
        .background(appTheme.colors.surface)
        .cornerRadius(appTheme.spacing.cornerRadiusLarge)
    }

    // MARK: - Shared Components

    private var streakCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("FAST STREAK")
                    .font(appTheme.fonts.labelSmall)
                    .foregroundColor(appTheme.colors.primary)
                    .tracking(1.0)
                Text("\(dietManager.fastStreak) days")
                    .font(appTheme.fonts.headlineMedium)
                    .foregroundColor(appTheme.colors.text)
            }
            Spacer()
            Image(systemName: "flame.fill")
                .font(.system(size: 28))
                .foregroundColor(appTheme.colors.warning)
        }
        .padding(appTheme.spacing.medium)
        .background(appTheme.colors.surface)
        .cornerRadius(appTheme.spacing.cornerRadiusMedium)
    }

    private var proteinCard: some View {
        HStack(spacing: appTheme.spacing.medium) {
            Text("🥩")
                .font(.system(size: 28))

            VStack(alignment: .leading, spacing: 2) {
                Text("PROTEIN - Always Available")
                    .font(appTheme.fonts.labelMedium)
                    .foregroundColor(appTheme.colors.primary)
                Text("Creative & productive apps are unrestricted")
                    .font(appTheme.fonts.bodySmall)
                    .foregroundColor(appTheme.colors.textSecondary)
            }

            Spacer()

            Image(systemName: "arrow.right")
                .foregroundColor(appTheme.colors.primary)
        }
        .padding(appTheme.spacing.medium)
        .background(appTheme.colors.primary.opacity(0.08))
        .cornerRadius(appTheme.spacing.cornerRadiusMedium)
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: appTheme.spacing.small) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            Text(value)
                .font(appTheme.fonts.headlineSmall)
                .foregroundColor(appTheme.colors.text)
            Text(title)
                .font(appTheme.fonts.labelSmall)
                .foregroundColor(appTheme.colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(appTheme.spacing.medium)
        .background(appTheme.colors.surface)
        .cornerRadius(appTheme.spacing.cornerRadiusMedium)
    }

    // MARK: - Nutrition Breakdown

    private var nutritionBreakdown: some View {
        VStack(alignment: .leading, spacing: appTheme.spacing.medium) {
            Text("TODAY'S NUTRITION")
                .font(appTheme.fonts.labelSmall)
                .foregroundColor(appTheme.colors.primary)
                .tracking(1.0)

            ForEach(FoodGroup.allCases) { group in
                let minutes = dietManager.todayLog.minutes(for: group)
                let percentage = dietManager.todayLog.percentage(for: group)

                HStack {
                    Text(group.emoji)
                    Text(group.displayName)
                        .font(appTheme.fonts.labelMedium)
                        .foregroundColor(appTheme.colors.textSecondary)
                    Spacer()
                    Text("\(minutes)m")
                        .font(appTheme.fonts.titleSmall)
                        .foregroundColor(appTheme.colors.text)
                    Text("(\(Int(percentage))%)")
                        .font(appTheme.fonts.labelSmall)
                        .foregroundColor(appTheme.colors.textSecondary)
                        .frame(width: 40, alignment: .trailing)
                }
            }
        }
        .padding(appTheme.spacing.medium)
        .background(appTheme.colors.surface)
        .cornerRadius(appTheme.spacing.cornerRadiusMedium)
    }
}
