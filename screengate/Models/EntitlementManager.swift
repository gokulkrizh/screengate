import Foundation
import StoreKit
import Observation

// MARK: - Placements

/// Superwall placements. Wire these in the dashboard when the paywall goes live;
/// until then `EntitlementManager.presentPaywall` shows the local offer.
enum PaywallPlacement: String, Identifiable, CaseIterable {
    case onboardingComplete = "onboarding_complete"
    case featureNightFast = "feature_night_fast"
    case featureStrictMode = "feature_strict_mode"
    case featureCustomPlan = "feature_custom_plan"
    case featureWidgets = "feature_widgets"
    case cheatOut = "cheat_out"
    case weeklyReport = "weekly_report"
    case day3TrialReminder = "day_3_trial_reminder"

    var id: String { rawValue }
}

// MARK: - Manager

/// Owns the premium entitlement: cached in `SharedState.isPremium`, verified
/// against StoreKit 2, and (later) kept in sync with Superwall.
@Observable
final class EntitlementManager {

    /// App Store Connect product identifiers (subscription group "ScreenDiet Premium").
    static let productIDs: Set<String> = [
        "screendiet.premium.yearly",
        "screendiet.premium.monthly",
        "screendiet.premium.lifetime",
    ]

    private(set) var isPremium: Bool

    /// Non-nil while a paywall should be shown (observers present the sheet).
    var activePlacement: PaywallPlacement?

    /// One-time "you're back on the free plan" notice.
    var showDowngradeNotice: Bool

    @ObservationIgnored private let store = SharedStore.shared
    @ObservationIgnored private static let downgradeNoticeKey = "downgradeNoticePending"

    init() {
        self.isPremium = SharedStore.shared.load().isPremium
        self.showDowngradeNotice = UserDefaults.standard.bool(forKey: Self.downgradeNoticeKey)
    }

    // MARK: Configuration

    /// Called once from the app entry point.
    func configure() {
        // TODO(Superwall): when the dashboard + API key are ready:
        //
        //   Superwall.configure(apiKey: "<public key>")
        //   Superwall.shared.$subscriptionStatus
        //       .map { $0 == .active }
        //       .sink { [weak self] active in self?.setPremium(active) }
        //
        // The rest of the app already reacts to `setPremium`, so nothing else changes.
    }

    /// Verify against StoreKit 2 (offline fallback; also covers restores).
    func refreshEntitlements() async {
        var premium = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                  transaction.revocationDate == nil else { continue }
            if Self.productIDs.contains(transaction.productID) {
                premium = true
            }
        }
        setPremium(premium)
    }

    /// Stub purchase path. Superwall/StoreKit replaces this once products exist.
    func purchase(_ productID: String) async -> Bool {
        #if DEBUG
        // Debug builds unlock premium so premium flows can be tested on device.
        setPremium(true)
        activePlacement = nil
        return true
        #else
        // Products are not live yet — never grant premium for free in release.
        return false
        #endif
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
        } catch {
            print("[EntitlementManager] Restore failed: \(error)")
        }
        await refreshEntitlements()
    }

    // MARK: Entitlement

    func setPremium(_ value: Bool) {
        guard value != isPremium else { return }
        let wasPremium = isPremium
        isPremium = value

        var state = store.load()
        state.isPremium = value
        store.save(state)

        if wasPremium && !value {
            handleDowngrade()
        }
    }

    /// Debug-only override (Settings → Debug). Never compiled into release.
    #if DEBUG
    func debugSetPremium(_ value: Bool) {
        setPremium(value)
        activePlacement = nil
    }
    #endif

    // MARK: Paywall

    /// Show the paywall for a placement.
    func presentPaywall(_ placement: PaywallPlacement) {
        // TODO(Superwall): Superwall.shared.register(placement: placement.rawValue)
        activePlacement = placement
    }

    func dismissPaywall() {
        activePlacement = nil
    }

    /// Free-tier check with the standard gates.
    func canUse(_ feature: PremiumFeature) -> Bool {
        Entitlement.isUnlocked(feature, isPremium: isPremium)
    }

    func canUse(plan: DietPlan) -> Bool {
        Entitlement.canUse(plan: plan, isPremium: isPremium)
    }

    // MARK: Downgrade

    /// Keep the diet running on free rules — never leave a user blocked by a
    /// feature they can no longer edit.
    private func handleDowngrade() {
        var state = store.load()
        if var profile = state.profile {
            profile.nightFast.isEnabled = false
            profile.cheatsPerWeek = Entitlement.clampedCheats(profile.cheatsPerWeek, isPremium: false)
            if !Entitlement.canUse(plan: profile.plan, isPremium: false) {
                profile.plan = .lean
            }
            state.profile = profile
        }
        state.strictMode = false
        state.pendingProfile = nil
        store.save(state)
        DeviceActivityManager().clearStrictMode()

        showDowngradeNotice = true
        UserDefaults.standard.set(true, forKey: Self.downgradeNoticeKey)
    }

    func acknowledgeDowngrade() {
        showDowngradeNotice = false
        UserDefaults.standard.set(false, forKey: Self.downgradeNoticeKey)
    }
}
