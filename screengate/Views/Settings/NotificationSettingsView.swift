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
    private let theme = KitchenTheme.daylight

    private static let tints: [KitchenFoodGroup] = [.fats, .carbs, .protein, .carbs]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                KitchenSheetHeader(eyebrow: "Useful, never endless", title: "Reminders") { dismiss() }
                Text("Keep the moments that help. Switch off the ones that don’t.").kitchenBody(14).foregroundStyle(theme.muted).padding(.top, 10).padding(.horizontal, 4)
                if loaded && !authorized {
                    HStack(spacing: 12) {
                        SettingsIconTile(symbol: "bell.slash", group: .carbs)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Notifications are off in iOS").font(KitchenFont.body(14).weight(.bold))
                            Text("Your preferences below are saved. Enable iOS notifications to receive them.").font(KitchenFont.body(12)).foregroundStyle(theme.muted)
                            Button("Enable in Settings") { if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) } }
                                .font(KitchenFont.label(13).weight(.bold)).foregroundStyle(theme.lamp).frame(minHeight: 44)
                        }
                        Spacer(minLength: 0)
                    }.padding(14).kitchenCard(theme).padding(.top, 14)
                }
                ForEach(Array(groups.enumerated()), id: \.offset) { index, group in
                    VStack(spacing: 8) {
                        SettingsSectionLabel(text: group.0.uppercased())
                        SettingsGroupCard {
                            ForEach(Array(group.2.enumerated()), id: \.element.id) { i, id in
                                SettingsToggleRow(symbol: group.1, group: Self.tints[index], title: id.settingsTitle.replacingOccurrences(of: "Cheat meal", with: "Extra serving"), subtitle: id.settingsSubtitle.replacingOccurrences(of: "cheat meal", with: "extra serving"), showsDivider: i > 0, isOn: Binding(get: { diet.sharedState.isNotificationEnabled(id) }, set: { diet.setNotification(id, enabled: $0) }))
                            }
                        }
                    }.padding(.top, 18).riseIn(index)
                }
                Text("Usage nudges follow approximate Screen Time thresholds. Some reminders need an enabled Plus feature or an active trial.")
                    .font(KitchenFont.body(12)).foregroundStyle(theme.muted).padding(.top, 18).padding(.horizontal, 4)
                if let error { Text(error).font(KitchenFont.body(12)).foregroundStyle(theme.color(for: .carbs)).padding(.top, 8) }
                KitchenPrimaryButton(title: "Done") { dismiss() }.padding(.top, 20)
            }.padding(20).frame(maxWidth: 600).frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .foregroundStyle(theme.text)
        .daylightSheet()
        .task { await checkAuthorization() }
        .onChange(of: scenePhase) { _, phase in if phase == .active { Task { await checkAuthorization() } } }
    }
    @MainActor private func checkAuthorization() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorized = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
        loaded = true
    }
}
