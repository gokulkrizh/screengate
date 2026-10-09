import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @Environment(DietManager.self) private var diet
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var authorized = false
    @State private var loaded = false
    @State private var error: String?
    private let groups: [(String, String, [NotificationID])] = [
        ("Your daily rhythm", "sun.max", [.kitchenOpening, .kitchenOpen, .kitchenClosing]),
        ("A little portion awareness", "fork.knife", [.portionHalf, .portionLast5, .portionEmpty, .streakRisk]),
        ("Rest & flexibility", "moon", [.nightSoon, .cheatEnding, .morningRecap]),
        ("The bigger picture", "chart.bar", [.sundayCheckin, .trialEnding])
    ]
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    DietHeading(eyebrow: "Useful, never endless", title: "Choose your nudges.", detail: "Keep the moments that help. Switch off the ones that don’t.")
                    if loaded && !authorized {
                        VStack(spacing: 16) {
                            DietFeatureRow(icon: "bell.slash", title: "Notifications are off in iOS", detail: "Your preferences below are saved. Enable iOS notifications to receive them.", tint: .orange)
                            Button("Enable in Settings") { if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) } }.frame(minHeight: 44)
                        }.dietCard(tint: .orange)
                    }
                    ForEach(Array(groups.enumerated()), id: \.offset) { index, group in
                        VStack(alignment: .leading, spacing: 18) {
                            Label(group.0, systemImage: group.1).font(.headline).foregroundStyle(AppTheme.shared.colors.primary)
                            ForEach(group.2) { id in
                                Toggle(isOn: Binding(get: { diet.sharedState.isNotificationEnabled(id) }, set: { diet.setNotification(id, enabled: $0) })) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(id.settingsTitle).font(.subheadline.weight(.semibold)).foregroundStyle(AppTheme.shared.colors.text)
                                        Text(id.settingsSubtitle).font(.caption).foregroundStyle(AppTheme.shared.colors.textSecondary)
                                    }.padding(.vertical, 4)
                                }.tint(AppTheme.shared.colors.primary)
                            }
                        }.dietCard().editorialEntrance(delay: Double(index) * 0.07)
                    }
                    Text("Usage nudges follow approximate Screen Time thresholds. Some reminders need an enabled Plus feature or an active trial.").font(.caption).foregroundStyle(AppTheme.shared.colors.textSecondary)
                    if let error { Text(error).font(.caption).foregroundStyle(.orange) }
                }.padding(24)
            }.background(AppTheme.shared.colors.background.ignoresSafeArea()).navigationTitle("Reminders").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }.preferredColorScheme(.dark).task { await checkAuthorization() }
            .onChange(of: scenePhase) { _, phase in if phase == .active { Task { await checkAuthorization() } } }
    }
    @MainActor private func checkAuthorization() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorized = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
        loaded = true
    }
}
