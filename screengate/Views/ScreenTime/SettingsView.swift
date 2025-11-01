import SwiftUI
import FamilyControls

// MARK: - Settings View

struct SettingsView: View {
    @StateObject private var notificationViewModel = NotificationViewModel()
    @StateObject private var restrictionViewModel = RestrictionViewModel()
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerView

                // Screen Time Authorization
                screenTimeAuthorizationView

                // Notification Settings
                notificationSettingsView()

                // Restriction Settings
                restrictionSettingsView

                // App Information
                appInfoView

                Spacer(minLength: 50)
            }
            .padding()
        }
        .onAppear {
            loadSettings()
        }
        .alert("Settings", isPresented: $showingAlert) {
            Button("OK") {
                showingAlert = false
            }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Manage your Screen Time preferences")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom)
    }

    // MARK: - Screen Time Authorization View

    private var screenTimeAuthorizationView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Screen Time Authorization")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                authorizationStatusBadge
            }

            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "shield.checkered")
                        .foregroundColor(.blue)
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Screen Time Access")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text("Required to set app restrictions and monitor usage")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if restrictionViewModel.authorizationStatus != .approved {
                        Button("Request Access") {
                            requestScreenTimeAuthorization()
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    }
                }

                if !restrictionViewModel.isAuthorized {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)

                        Text("Screen Time access was denied. Go to Settings > Screen Time to enable.")
                            .font(.caption)
                            .foregroundColor(.orange)

                        Spacer()
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding()
    }

    // MARK: - Notification Settings View

    private func notificationSettingsView() -> some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                Text("Notifications")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)

                // Settings List
                VStack(spacing: 0) {
                    // Notification Authorization
                    makeNotificationAuthRow()

                    Divider()
                        .padding(.horizontal, 16)

                    // Intention Reminders
                    makeIntentionRemindersRow()

                    Divider()
                        .padding(.horizontal, 16)

                    // Daily Digest
                    makeDailyDigestRow()

                    Divider()
                        .padding(.horizontal, 16)

                    // Progress Notifications
                    makeProgressNotificationsRow()
                }
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)
        }
    }

    private func makeNotificationAuthRow() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.fill")
                .font(.title3)
                .foregroundColor(.purple)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text("Notification Access")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("Allow ScreenGate to send notifications")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(notificationViewModel.authorizationStatusText)
                .font(.caption)
                .foregroundColor(.secondary)

            if notificationViewModel.canRequestAuthorization {
                Button("Request") {
                    requestNotificationAuthorization()
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(6)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func makeIntentionRemindersRow() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.title3)
                .foregroundColor(.teal)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text("Intention Reminders")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("Get notified about scheduled intentions")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { notificationViewModel.intentionRemindersEnabled },
                set: { _ in notificationViewModel.intentionRemindersEnabled.toggle() }
            ))
            .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func makeDailyDigestRow() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "list.bullet.clipboard")
                .font(.title3)
                .foregroundColor(.green)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text("Daily Digest")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("Receive daily summary of your progress")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { notificationViewModel.dailyDigestEnabled },
                set: { _ in notificationViewModel.dailyDigestEnabled.toggle() }
            ))
            .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func makeProgressNotificationsRow() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.title3)
                .foregroundColor(.orange)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text("Progress Updates")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("Get notified about milestones and achievements")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { notificationViewModel.progressNotificationsEnabled },
                set: { _ in notificationViewModel.progressNotificationsEnabled.toggle() }
            ))
            .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Restriction Settings View

    private var restrictionSettingsView: some View {
        VStack(spacing: 16) {
            Text("Restriction Settings")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                // Strict Mode (placeholder)
                ToggleSettingRow(
                    title: "Strict Mode",
                    subtitle: "Intentions must be completed before accessing apps",
                    icon: "lock.shield",
                    color: .red,
                    isOn: false
                ) {
                    // Feature not yet implemented
                }

                Divider()

                // Grace Period
                SettingRow(
                    title: "Grace Period",
                    subtitle: "Time allowed before restrictions take effect",
                    icon: "clock.badge",
                    color: .blue,
                    value: "30 seconds",
                    action: {
                        // Configure grace period
                    }
                )

                Divider()

                // Auto-enable (placeholder)
                ToggleSettingRow(
                    title: "Auto-enable Restrictions",
                    subtitle: "Automatically enable restrictions during focus hours",
                    icon: "power",
                    color: .green,
                    isOn: false
                ) {
                    // Feature not yet implemented
                }

                Divider()

                // Temporary Override
                SettingRow(
                    title: "Temporary Override",
                    subtitle: "Allow temporary access to restricted apps",
                    icon: "arrow.counterclockwise",
                    color: .orange,
                    value: "5 minutes",
                    action: {
                        // Configure override settings
                    }
                )
            }
        }
        .padding()
    }

    // MARK: - App Information View

    private var appInfoView: some View {
        VStack(spacing: 16) {
            Text("About")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                // Version
                SettingRow(
                    title: "Version",
                    subtitle: "ScreenGate app version",
                    icon: "info.circle",
                    color: .gray,
                    value: "1.0.0",
                    action: nil
                )

                Divider()

                // Privacy Policy
                SettingRow(
                    title: "Privacy Policy",
                    subtitle: "How we handle your data",
                    icon: "hand.raised.fill",
                    color: .blue,
                    value: "",
                    action: {
                        openPrivacyPolicy()
                    }
                )

                Divider()

                // Terms of Service
                SettingRow(
                    title: "Terms of Service",
                    subtitle: "Terms and conditions",
                    icon: "doc.text.fill",
                    color: .green,
                    value: "",
                    action: {
                        openTermsOfService()
                    }
                )

                Divider()

                // Support
                SettingRow(
                    title: "Support",
                    subtitle: "Get help and contact us",
                    icon: "questionmark.circle.fill",
                    color: .purple,
                    value: "",
                    action: {
                        openSupport()
                    }
                )
            }
        }
        .padding()
    }

    // MARK: - Helper Views

    private var authorizationStatusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(authorizationStatusColor)
                .frame(width: 8, height: 8)

            Text(authorizationStatusText)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(authorizationStatusColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(authorizationStatusColor.opacity(0.1))
        .cornerRadius(12)
    }

    private var authorizationStatusText: String {
        restrictionViewModel.isAuthorized ? "Authorized" : "Not Authorized"
    }

    private var authorizationStatusColor: Color {
        restrictionViewModel.isAuthorized ? .green : .orange
    }

    // MARK: - Helper Methods

    private func loadSettings() {
        Task {
            restrictionViewModel.checkAuthorizationStatus()
            notificationViewModel.checkNotificationAuthorization()
        }
    }

    private func requestScreenTimeAuthorization() {
        Task {
            await restrictionViewModel.requestAuthorization()
            if restrictionViewModel.isAuthorized {
                alertMessage = "Screen Time access granted successfully!"
            } else {
                alertMessage = "Screen Time access was denied. Please enable it in Settings."
            }
            showingAlert = true
        }
    }

    private func requestNotificationAuthorization() {
        Task {
            await notificationViewModel.requestNotificationAuthorization()
            if notificationViewModel.isNotificationEnabled {
                alertMessage = "Notification access granted successfully!"
            } else {
                alertMessage = "Notification access was denied. You can enable it in Settings."
            }
            showingAlert = true
        }
    }

    private func openPrivacyPolicy() {
        // Open privacy policy URL
        alertMessage = "Privacy policy would open in a web view"
        showingAlert = true
    }

    private func openTermsOfService() {
        // Open terms of service URL
        alertMessage = "Terms of service would open in a web view"
        showingAlert = true
    }

    private func openSupport() {
        // Open support interface
        alertMessage = "Support interface would open here"
        showingAlert = true
    }
}

// MARK: - Supporting Views

struct SettingRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let value: String
    let action: (() -> Void)?

    init(title: String, subtitle: String, icon: String, color: Color, value: String, action: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.value = value
        self.action = action
    }

    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if !value.isEmpty {
                    Text(value)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }
}

struct ToggleSettingRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("", isOn: .constant(isOn))
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: color))
                .onTapGesture {
                    action()
                }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
    }
}
