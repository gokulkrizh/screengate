import SwiftUI

/// Settings → Notifications: per-type toggles, stored in SharedState.
struct NotificationSettingsView: View {
    @Environment(DietManager.self) private var dietManager
    @Environment(\.dismiss) private var dismiss
    private let appTheme = AppTheme.shared

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(NotificationID.allCases) { id in
                        Toggle(isOn: Binding(
                            get: { dietManager.sharedState.isNotificationEnabled(id) },
                            set: { dietManager.setNotification(id, enabled: $0) }
                        )) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(id.settingsTitle)
                                Text(id.settingsSubtitle)
                                    .font(.caption)
                                    .foregroundColor(appTheme.colors.textSecondary)
                            }
                        }
                        .tint(appTheme.colors.primary)
                    }
                } footer: {
                    Text("Approximate counters fire from 5-minute usage steps; exact numbers live in the report.")
                }
            }
            .scrollContentBackground(.hidden)
            .background(appTheme.colors.background)
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(appTheme.colors.primary)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
