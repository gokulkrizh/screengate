import Foundation
import RevenueCat
import Observation
import WidgetKit

// MARK: - Placements

/// RevenueCat placement identifiers; unmapped placements use the current offering.
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
/// against RevenueCat customer info.
@Observable
final class EntitlementManager {

    /// App Store Connect product identifiers (subscription group "ScreenDiet Premium").
    static let productIDs: Set<String> = [
        "screendiet.premium.yearly",
        "screendiet.premium.monthly",
        "screendiet.premium.lifetime",
    ]

    private(set) var isPremium: Bool
    private(set) var restoreError: String?
    static let entitlementID = "premium"
    @ObservationIgnored private var customerInfoTask: Task<Void, Never>?

    /// Non-nil while a paywall should be shown (observers present the sheet).
    var activePlacement: PaywallPlacement?

    /// Views able to present the paywall, innermost last. SwiftUI can't present a
    /// sheet from a view that is already presenting one, so only the top-most
    /// presenter shows it — a paywall requested inside a sheet opens on that sheet.
    private(set) var paywallPresenters: [UUID] = []

    func registerPaywallPresenter(_ id: UUID) {
        paywallPresenters.append(id)
    }

    func unregisterPaywallPresenter(_ id: UUID) {
        paywallPresenters.removeAll { $0 == id }
    }

    /// One-time "you're back on the free plan" notice.
    var showDowngradeNotice: Bool

    @ObservationIgnored private let store = SharedStore.shared
    @ObservationIgnored private static let downgradeNoticeKey = "downgradeNoticePending"

    init() {
        self.isPremium = SharedStore.shared.load().isPremium
        self.showDowngradeNotice = UserDefaults.standard.bool(forKey: Self.downgradeNoticeKey)
        configure()
    }

    deinit { customerInfoTask?.cancel() }

    // MARK: Configuration

    /// Called once from the app entry point.
    func configure() {
        guard customerInfoTask == nil else { return }
        if !Purchases.isConfigured {
            #if DEBUG
            Purchases.logLevel = .debug
            Purchases.configure(withAPIKey: "test_oTGyjylalkzwsGWPOxYslUCPxab")
            #else
            Purchases.configure(withAPIKey: "appl_DRCWtuohDsGappugOstXLneKbDQ")
            #endif
        }
        customerInfoTask = Task { @MainActor [weak self] in
            for await info in Purchases.shared.customerInfoStream {
                guard !Task.isCancelled else { return }
                self?.apply(info)
            }
        }
    }

    /// Preserve cached access if a refresh fails, including while offline.
    @MainActor
    func refreshEntitlements() async {
        do {
            apply(try await Purchases.shared.customerInfo())
        } catch {
            print("[EntitlementManager] Refresh failed: \(error)")
        }
    }

    @MainActor
    func apply(_ info: CustomerInfo) {
        setPremium(info.entitlements[Self.entitlementID]?.isActive == true)
    }

    @MainActor
    func restorePurchases() async {
        restoreError = nil
        do {
            apply(try await Purchases.shared.restorePurchases())
        } catch {
            restoreError = "We couldn't restore purchases. Check your connection and try again."
            print("[EntitlementManager] Restore failed: \(error)")
        }
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
        WidgetCenter.shared.reloadAllTimelines()
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
