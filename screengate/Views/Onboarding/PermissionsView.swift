import SwiftUI
import FamilyControls

struct PermissionsView: View {
    @ObservedObject var data: OnboardingData
    @State private var status = AuthorizationCenter.shared.authorizationStatus
    @State private var requesting = false
    @State private var errorMessage: String?
    @Environment(\.scenePhase) private var scenePhase
    var body: some View {
        DietPage {
            DietArtwork(asset: "FocusGarden", height: 190)
            DietHeading(eyebrow: "A little help from iOS", title: "Your boundaries.\nBacked by Screen Time.", detail: "Allow ScreenDiet to apply the routine you choose. You stay in control.", centered: true)
            VStack(spacing: 20) {
                DietFeatureRow(icon: "chart.bar.fill", title: "Understand your appetite", detail: "Screen Time supplies activity for your on-device reports.")
                DietFeatureRow(icon: "hand.raised.fill", title: "Give your rules a little muscle", detail: "iOS can shield selected apps when your kitchen is closed or your portion is used.")
                DietFeatureRow(icon: "lock.shield.fill", title: "Private by design", detail: "Your diet settings and usage reports are stored on your device.")
            }.dietCard()
            if let errorMessage {
                DietFeatureRow(icon: "exclamationmark.circle", title: "Access wasn’t granted", detail: errorMessage, tint: AppTheme.shared.colors.warning).dietCard(tint: AppTheme.shared.colors.warning).transition(.opacity)
            }
            if status == .denied {
                Text("You can review Screen Time access in iOS Settings, then return here to continue.").font(.caption).foregroundStyle(AppTheme.shared.colors.textSecondary)
                Button("Open Settings") { if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) } }.frame(minHeight: 44)
            }
        } footer: {
            PrimaryButton(title: status == .approved ? "Access granted · Continue" : requesting ? "Waiting for iOS…" : "Allow Screen Time access", icon: status == .approved ? "checkmark" : "lock.open", isDisabled: requesting) {
                if status == .approved { data.nextScreen() } else { request() }
            }
            Text("The next prompt comes from Apple.").font(.caption2).foregroundStyle(AppTheme.shared.colors.textSecondary)
        }.onChange(of: scenePhase) { _, phase in if phase == .active { status = AuthorizationCenter.shared.authorizationStatus } }
    }
    private func request() {
        requesting = true; errorMessage = nil
        Task { @MainActor in
            defer { requesting = false }
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                status = AuthorizationCenter.shared.authorizationStatus
                if status == .approved { data.nextScreen() }
            } catch {
                status = AuthorizationCenter.shared.authorizationStatus
                errorMessage = "ScreenDiet needs this permission to apply your app boundaries. Try again when you’re ready."
            }
        }
    }
}
