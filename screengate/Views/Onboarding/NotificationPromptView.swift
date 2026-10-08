import SwiftUI
import UserNotifications

/// Notification pre-prompt: shows a mock banner, then the system prompt.
struct NotificationPromptView: View {
    @ObservedObject var data: OnboardingData
    @State private var isRequesting = false
    private let appTheme = AppTheme.shared

    var body: some View {
        ZStack {
            appTheme.colors.background.ignoresSafeArea()

            VStack(spacing: appTheme.spacing.large) {
                VStack(spacing: appTheme.spacing.small) {
                    Text("STAY ON PLAN")
                        .font(appTheme.fonts.labelSmall)
                        .foregroundColor(appTheme.colors.primary)
                        .tracking(1.5)
                    Text("A nudge when it matters.")
                        .font(appTheme.fonts.headlineLarge)
                        .foregroundColor(appTheme.colors.text)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, appTheme.spacing.extraLarge)

                // Mock banner
                HStack(spacing: appTheme.spacing.medium) {
                    Text("🍳")
                        .font(.system(size: 28))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Kitchen opens in 10 min")
                            .font(appTheme.fonts.titleSmall)
                            .foregroundColor(appTheme.colors.text)
                        Text("45 min on your plate today.")
                            .font(appTheme.fonts.bodySmall)
                            .foregroundColor(appTheme.colors.textSecondary)
                    }
                    Spacer()
                }
                .padding(appTheme.spacing.medium)
                .background(appTheme.colors.surface)
                .cornerRadius(appTheme.spacing.cornerRadiusMedium)
                .padding(.horizontal, appTheme.spacing.large)

                VStack(alignment: .leading, spacing: appTheme.spacing.small) {
                    bullet("Kitchen opening & closing")
                    bullet("Half your portion, last 5 minutes")
                    bullet("Night Fast starting soon")
                }
                .padding(.horizontal, appTheme.spacing.large)

                Spacer()

                VStack(spacing: appTheme.spacing.medium) {
                    Button(action: requestAuthorization) {
                        HStack {
                            if isRequesting {
                                ProgressView().tint(appTheme.colors.background)
                            } else {
                                Image(systemName: "bell.badge.fill")
                                Text("Turn on reminders")
                            }
                        }
                        .font(appTheme.fonts.titleMedium)
                        .foregroundColor(appTheme.colors.background)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(appTheme.colors.primary)
                        .cornerRadius(appTheme.spacing.cornerRadiusLarge)
                    }
                    .disabled(isRequesting)

                    Button("Not now") {
                        data.nextScreen()
                    }
                    .font(appTheme.fonts.bodyMedium)
                    .foregroundColor(appTheme.colors.textSecondary)
                }
                .padding(.horizontal, appTheme.spacing.large)
                .padding(.bottom, appTheme.spacing.extraLarge)
            }
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(spacing: appTheme.spacing.small) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(appTheme.colors.primary)
            Text(text)
                .font(appTheme.fonts.bodyMedium)
                .foregroundColor(appTheme.colors.textSecondary)
        }
    }

    private func requestAuthorization() {
        isRequesting = true
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
            DispatchQueue.main.async {
                isRequesting = false
                data.nextScreen()
            }
        }
    }
}
