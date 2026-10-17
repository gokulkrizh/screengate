import SwiftUI
import RevenueCat
import RevenueCatUI

struct PaywallView: View {
    var placement: PaywallPlacement = .onboardingComplete
    var intention: String? = nil
    var onFinished: () -> Void
    @Environment(EntitlementManager.self) private var entitlements
    @Environment(DietManager.self) private var diet
    @State private var offering: Offering?
    @State private var loading = true
    @State private var message: String?

    var body: some View {
        Group {
            if let offering {
                RevenueCatUI.PaywallView(offering: offering, displayCloseButton: true)
                    .onPurchaseCompleted { info in complete(info) }
                    .onRestoreCompleted { info in complete(info) }
                    .onRequestedDismissal { onFinished() }
            } else if loading {
                ProgressView("Loading membership...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ContentUnavailableView {
                    Label("Membership unavailable", systemImage: "wifi.exclamationmark")
                } description: {
                    Text(message ?? "Please try again later.")
                } actions: {
                    Button("Try again") { Task { await loadOffering() } }
                    Button("Continue free", action: onFinished)
                }
            }
        }
        .task { await loadOffering() }
    }

    @MainActor private func loadOffering() async {
        loading = true
        message = nil
        defer { loading = false }
        do {
            let offerings = try await Purchases.shared.offerings()
            guard let available = offerings.currentOffering(forPlacement: placement.rawValue) ?? offerings.current,
                  !available.availablePackages.isEmpty,
                  available.hasPaywall else {
                message = "Memberships are not available right now. You can continue free and upgrade later."
                return
            }
            offering = available
        } catch {
            print("[Paywall] Could not load offering: \(error)")
            message = "Memberships are not available right now. Please try again later."
        }
    }

    @MainActor private func complete(_ info: CustomerInfo) {
        entitlements.apply(info)
        diet.reloadState()
        if entitlements.isPremium { onFinished() }
    }
}
