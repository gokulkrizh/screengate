import SwiftUI
import UserNotifications

struct NotificationPromptView: View {
    @ObservedObject var data: OnboardingData
    @State private var requesting = false
    @State private var message: String?
    var body: some View {
        DietPage {
            DietArtwork(asset: "NightGarden", height: 210)
            DietHeading(eyebrow: "A gentle nudge", title: "A reminder.\nThen back to life.", detail: "Helpful moments, without another feed to check.", centered: true)
            VStack(alignment: .leading, spacing: 12) {
                HStack { Label("SCREENDIET", systemImage: "leaf.fill").font(.caption2.bold()); Spacer(); Text("Preview").font(.caption2) }.foregroundStyle(AppTheme.shared.colors.primary)
                Text("Your kitchen opens in 10 minutes").font(.headline).foregroundStyle(AppTheme.shared.colors.text)
                Text("A fresh portion is on its way. Enjoy it with intention.").font(.caption).foregroundStyle(AppTheme.shared.colors.textSecondary)
            }.dietCard().editorialEntrance(delay: 0.15)
            VStack(spacing: 18) {
                DietFeatureRow(icon: "sun.max", title: "Your daily rhythm", detail: "A heads-up when the kitchen opens and closes.")
                DietFeatureRow(icon: "timer", title: "A little portion awareness", detail: "Know when you’re nearing your allowance.")
                DietFeatureRow(icon: "moon", title: "A quieter evening", detail: "Night Fast reminders when that feature is enabled.")
            }
            if let message { Text(message).font(.caption).foregroundStyle(AppTheme.shared.colors.warning) }
        } footer: {
            PrimaryButton(title: requesting ? "Waiting for iOS…" : "Enable gentle reminders", icon: "bell", isDisabled: requesting) { request() }
            Button("Not now") { data.nextScreen() }.font(.caption).frame(minHeight: 44)
        }
    }
    private func request() {
        requesting = true
        Task { @MainActor in
            defer { requesting = false }
            do {
                _ = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
                data.nextScreen()
            } catch { message = "Reminders couldn’t be enabled. You can try again or continue without them." }
        }
    }
}
