import SwiftUI

/// Quiz — three decisions, stored in SharedState for the hook + plan suggestion.
struct QuizView: View {
    @ObservedObject var data: OnboardingData
    @Environment(DietManager.self) private var dietManager
    private let appTheme = AppTheme.shared

    private let hourOptions: [(label: String, value: Int)] = [
        ("1-2 h", 2), ("3-4 h", 4), ("5-6 h", 6), ("6+ h", 7),
    ]
    private let timeOptions: [(label: String, value: String)] = [
        ("Morning scroll", "morning"),
        ("Afternoon slump", "afternoon"),
        ("Evening couch", "evening"),
        ("Late night", "latelight"),
    ]
    private let goalOptions: [(label: String, title: String, value: String, icon: String)] = [
        ("Cut down", "Eat less junk, keep social apps", "cutdown", "scissors"),
        ("Deep focus", "Create more, consume less", "focus", "target"),
        ("Full reset", "Block junk completely for a while", "reset", "arrow.counterclockwise"),
    ]

    var body: some View {
        ZStack {
            appTheme.colors.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: appTheme.spacing.large) {
                    VStack(alignment: .leading, spacing: appTheme.spacing.small) {
                        Text("60-SECOND CHECKUP")
                            .font(appTheme.fonts.labelSmall)
                            .foregroundColor(appTheme.colors.primary)
                            .tracking(1.5)
                        Text("Let's size your plate.")
                            .font(appTheme.fonts.headlineLarge)
                            .foregroundColor(appTheme.colors.text)
                    }
                    .padding(.top, appTheme.spacing.extraLarge)

                    question("How many hours a day on junk?") {
                        ForEach(hourOptions, id: \.value) { option in
                            RadioOptionCard(
                                icon: "clock",
                                iconColor: nil,
                                iconBackgroundColor: nil,
                                title: option.label,
                                subtitle: "",
                                isSelected: data.quizDailyHours == option.value
                            ) {
                                data.quizDailyHours = option.value
                            }
                        }
                    }

                    question("When is it worst?") {
                        ForEach(timeOptions, id: \.value) { option in
                            RadioOptionCard(
                                icon: "clock.badge.exclamationmark",
                                iconColor: nil,
                                iconBackgroundColor: nil,
                                title: option.label,
                                subtitle: "",
                                isSelected: data.quizWorstTime == option.value
                            ) {
                                data.quizWorstTime = option.value
                            }
                        }
                    }

                    question("What's the goal?") {
                        ForEach(goalOptions, id: \.value) { option in
                            RadioOptionCard(
                                icon: option.icon,
                                iconColor: nil,
                                iconBackgroundColor: nil,
                                title: option.label,
                                subtitle: option.title,
                                isSelected: data.quizGoal == option.value
                            ) {
                                data.quizGoal = option.value
                            }
                        }
                    }

                    Spacer(minLength: appTheme.spacing.large)
                }
                .padding(.horizontal, appTheme.spacing.large)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: saveAndContinue) {
                Text("Continue")
                    .font(appTheme.fonts.titleMedium)
                    .foregroundColor(isComplete ? appTheme.colors.background : appTheme.colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(isComplete ? appTheme.colors.primary : appTheme.colors.surface)
                    .cornerRadius(appTheme.spacing.cornerRadiusLarge)
            }
            .disabled(!isComplete)
            .padding(.horizontal, appTheme.spacing.large)
            .padding(.bottom, appTheme.spacing.medium)
            .background(appTheme.colors.background.opacity(0.95))
        }
    }

    private var isComplete: Bool {
        data.quizDailyHours != nil && data.quizWorstTime != nil && data.quizGoal != nil
    }

    private func question<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: appTheme.spacing.small) {
            Text(title)
                .font(appTheme.fonts.titleMedium)
                .foregroundColor(appTheme.colors.text)
            content()
        }
    }

    private func saveAndContinue() {
        // Persist quiz answers immediately so the hook (Hook B) and the report
        // extension can use them (including the "new phone" fallback).
        dietManager.saveOnboardingAnswers(data.quizAnswers)
        data.nextScreen()
    }
}
