import SwiftUI

/// Presents the paywall for `EntitlementManager.activePlacement`.
///
/// Apply `.paywallPresenter()` to the app root and to the root of every sheet or
/// full-screen cover that can request a paywall. Presenters register in order, and
/// only the most recent one presents, so the paywall always opens on top of the
/// sheet the user is looking at instead of being queued behind it.
private struct PaywallPresenterModifier: ViewModifier {
    @Environment(EntitlementManager.self) private var entitlements
    @State private var id = UUID()

    func body(content: Content) -> some View {
        content
            .sheet(item: placementBinding) { placement in
                PaywallView(placement: placement) {
                    entitlements.dismissPaywall()
                }
                .environment(entitlements)
            }
            .onAppear { entitlements.registerPaywallPresenter(id) }
            .onDisappear { entitlements.unregisterPaywallPresenter(id) }
    }

    private var placementBinding: Binding<PaywallPlacement?> {
        Binding(
            get: {
                entitlements.paywallPresenters.last == id ? entitlements.activePlacement : nil
            },
            set: { newValue in
                if newValue == nil { entitlements.dismissPaywall() }
            }
        )
    }
}

extension View {
    func paywallPresenter() -> some View {
        modifier(PaywallPresenterModifier())
    }
}
