import SwiftUI
import FamilyControls

struct PermissionsView: View {
    @ObservedObject var data: OnboardingData
    @State private var authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    @State private var isRequesting = false
    private let appTheme = AppTheme.shared

    var body: some View {
        ZStack {
            appTheme.colors.background.ignoresSafeArea()

            VStack(spacing: appTheme.spacing.large) {
                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(appTheme.colors.primary.opacity(0.15))
                        .frame(width: 120, height: 120)

                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 48))
                        .foregroundColor(appTheme.colors.primary)
                }

                // Title
                Text("Screen Time Access")
                    .font(appTheme.fonts.headlineLarge)
                    .foregroundColor(appTheme.colors.text)
                    .multilineTextAlignment(.center)

                // Description
                Text("Screendiet needs Screen Time access to monitor your app usage and apply your diet plan. This data stays on your device.")
                    .font(appTheme.fonts.bodyLarge)
                    .foregroundColor(appTheme.colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, appTheme.spacing.large)

                Spacer()

                // Permission cards
                VStack(spacing: appTheme.spacing.medium) {
                    permissionCard(
                        icon: "eye.fill",
                        title: "Monitor Usage",
                        description: "Track which food groups you consume"
                    )
                    permissionCard(
                        icon: "hand.raised.fill",
                        title: "Apply Restrictions",
                        description: "Block apps during fasting periods"
                    )
                    permissionCard(
                        icon: "lock.fill",
                        title: "On-Device Only",
                        description: "Your data never leaves your phone"
                    )
                }
                .padding(.horizontal, appTheme.spacing.large)

                Spacer()

                // Grant button
                VStack(spacing: appTheme.spacing.medium) {
                    if authorizationStatus == .approved {
                        // Already granted - show continue
                        Button(action: { data.nextScreen() }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Access Granted - Continue")
                            }
                            .font(appTheme.fonts.titleMedium)
                            .foregroundColor(appTheme.colors.background)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(appTheme.colors.primary)
                            .cornerRadius(appTheme.spacing.cornerRadiusLarge)
                        }
                    } else {
                        Button(action: requestAuthorization) {
                            HStack {
                                if isRequesting {
                                    ProgressView()
                                        .tint(appTheme.colors.background)
                                } else {
                                    Image(systemName: "lock.open.fill")
                                    Text("Grant Access")
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
                    }
                }
                .padding(.horizontal, appTheme.spacing.large)
                .padding(.bottom, appTheme.spacing.extraLarge)
            }
        }
        .onAppear {
            authorizationStatus = AuthorizationCenter.shared.authorizationStatus
        }
    }

    private func requestAuthorization() {
        isRequesting = true
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                await MainActor.run {
                    authorizationStatus = AuthorizationCenter.shared.authorizationStatus
                    isRequesting = false
                    if authorizationStatus == .approved {
                        data.nextScreen()
                    }
                }
            } catch {
                await MainActor.run {
                    isRequesting = false
                    print("Authorization failed: \(error)")
                }
            }
        }
    }

    private func permissionCard(icon: String, title: String, description: String) -> some View {
        HStack(spacing: appTheme.spacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(appTheme.colors.primary)
                .frame(width: 40, height: 40)
                .background(appTheme.colors.primary.opacity(0.1))
                .cornerRadius(appTheme.spacing.cornerRadiusSmall)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(appTheme.fonts.titleSmall)
                    .foregroundColor(appTheme.colors.text)
                Text(description)
                    .font(appTheme.fonts.bodySmall)
                    .foregroundColor(appTheme.colors.textSecondary)
            }

            Spacer()
        }
        .padding(appTheme.spacing.medium)
        .background(appTheme.colors.surface)
        .cornerRadius(appTheme.spacing.cornerRadiusMedium)
    }
}
