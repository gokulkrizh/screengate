import SwiftUI
import StoreKit

/// Onboarding step 18 · V2-18 "Make more room for reading." Lamp theme. Purchase / restore logic mirrors `PaywallView`.
struct MembershipStep: View {
    @ObservedObject var data: OnboardingData
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(EntitlementManager.self) private var entitlements
    @Environment(DietManager.self) private var diet
    @State private var products: [Product] = []
    @State private var selectedID = "screendiet.premium.yearly"
    @State private var trialEligible = false
    @State private var busy = false
    @State private var message: String?
    @State private var glow = false

    private let planIDs = ["screendiet.premium.yearly", "screendiet.premium.monthly"]
    private var selected: Product? { products.first { $0.id == selectedID } }
    private var intention: String { data.intention?.lowercased() ?? "what matters" }

    private var trial: Product.SubscriptionOffer? {
        guard trialEligible, let offer = selected?.subscription?.introductoryOffer, offer.paymentMode == .freeTrial else { return nil }
        return offer
    }

    private let benefits: [(KitchenFoodGroup, String, String)] = [
        (.protein, "moon", "Night Fast for quieter evenings"),
        (.fats, "hourglass", "Fats plate and Focus Fast"),
        (.carbs, "circle.circle", "Maker, Reset and Custom plans"),
        (.fats, "ticket", "Up to 3 extra servings a week"),
        (.protein, "doc.text", "Full weekly nutrition reports"),
    ]

    var body: some View {
        OnboardingPage {
            VStack(alignment: .leading, spacing: 10) {
                OnboardingEyebrow(text: "Your complete kitchen").rise(1)
                OnboardingTitle(first: "Make more room", second: "for \(intention).").rise(2)
            }.padding(.top, 4)
            benefitsCard.padding(.horizontal, -4)
            VStack(spacing: 8) {
                ForEach(Array(planIDs.enumerated()), id: \.offset) { i, id in
                    planRow(id: id).editorialEntrance(delay: 0.75 + Double(i) * 0.08)
                }
            }.padding(.horizontal, -4)
            if let selected {
                Text(trial.map { "Your \(period($0.period)) free trial starts today, then \(disclosure(selected))." } ?? disclosure(selected))
                    .font(KitchenFont.label(11)).foregroundStyle(theme.faint).padding(.horizontal, 4)
            }
        } footer: {
            VStack(spacing: 2) {
                cta
                KitchenSecondaryButton(title: "Start free with the Balanced plan") { data.nextScreen() }
                HStack(spacing: 18) {
                    Button("Restore", action: restore).disabled(busy)
                    Link("Terms", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    Button("Privacy") { message = "Your diet profile and selections are stored in the app’s on-device shared container. Screen Time usage reports are rendered by Apple’s report extension. Purchases are processed by the App Store." }
                }
                .font(KitchenFont.label(12)).foregroundStyle(theme.faint).frame(minHeight: 36)
            }.editorialEntrance(delay: reduceMotion ? 0 : 1)
        }
        .task { await loadProducts() }
        .task(id: selectedID) { trialEligible = await selected?.subscription?.isEligibleForIntroOffer ?? false }
        .alert("Membership", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) { Button("OK") { message = nil } } message: { Text(message ?? "") }
        .onAppear { if !reduceMotion { withAnimation(.easeInOut(duration: 2.6).delay(1.6).repeatForever(autoreverses: true)) { glow = true } } }
    }

    // MARK: Pieces

    private var benefitsCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(benefits.enumerated()), id: \.offset) { i, b in
                if i > 0 { Divider().overlay(theme.line) }
                HStack(spacing: 12) {
                    Image(systemName: b.1).font(.system(size: 14, weight: .semibold)).foregroundStyle(theme.color(for: b.0))
                        .frame(width: 30, height: 30).background(theme.soft(b.0, opacity: 0.14), in: RoundedRectangle(cornerRadius: 10))
                    Text(b.2).font(KitchenFont.body(14).weight(.semibold)).foregroundStyle(theme.text)
                    Spacer(minLength: 0)
                }
                .frame(minHeight: 46)
                .editorialEntrance(delay: 0.35 + Double(i) * 0.07)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 4)
        .kitchenCard(theme, radius: 22)
    }

    private func planRow(id: String) -> some View {
        let on = id == selectedID
        let product = products.first { $0.id == id }
        let yearly = id.hasSuffix("yearly")
        return Button { selectedID = id } label: {
            HStack(spacing: 12) {
                Circle().strokeBorder(on ? theme.lamp : theme.line2, lineWidth: on ? 2 : 1.5).frame(width: 22, height: 22)
                    .overlay { if on { Circle().fill(theme.lamp).frame(width: 10, height: 10).transition(.scale) } }
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(yearly ? "Annual" : "Monthly").font(KitchenFont.body(15).weight(.heavy)).foregroundStyle(theme.text)
                        if yearly { StatusPill(text: "Best value", color: theme.color(for: .fats), compact: true) }
                    }
                    Text(yearly ? "Billed yearly" : "Billed monthly").font(KitchenFont.body(12)).foregroundStyle(theme.muted)
                }
                Spacer(minLength: 8)
                Text(product?.displayPrice ?? Self.placeholderPrice).font(KitchenFont.body(14).weight(.heavy)).monospacedDigit().foregroundStyle(theme.text)
            }
            .padding(.horizontal, 16).frame(maxWidth: .infinity, minHeight: 66)
            .background(on ? theme.surface2 : theme.surface, in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(on ? theme.lamp : theme.line, lineWidth: on ? 1.5 : 1))
        }
        .buttonStyle(TactileButtonStyle())
        .animation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.3, dampingFraction: 0.6), value: on)
        .sensoryFeedback(.selection, trigger: on)
        .accessibilityAddTraits(on ? .isSelected : [])
        .accessibilityLabel("\(yearly ? "Annual" : "Monthly") plan, \(product?.displayPrice ?? "price unavailable")")
    }

    private static var placeholderPrice: String {
        #if DEBUG
        "[YOUR PRICE]"
        #else
        "—"
        #endif
    }

    private var canPurchase: Bool {
        #if DEBUG
        true      // debug builds fall back to EntitlementManager's stub purchase when no products load
        #else
        selected != nil
        #endif
    }

    private var cta: some View {
        Button { purchase() } label: {
            HStack(spacing: 8) {
                Text(busy ? "Please wait…" : "Continue with Plus")
                Image(systemName: "arrow.right").font(.system(size: 15, weight: .bold))
            }
            .font(KitchenFont.button).foregroundStyle(theme.buttonText)
            .frame(maxWidth: .infinity, minHeight: KitchenMetrics.buttonHeight)
            .background(theme.buttonBg, in: Capsule())
            .shadow(color: theme.lamp.opacity(glow ? 0.42 : 0.18), radius: glow ? 20 : 16, y: 12)
            .opacity(canPurchase && !busy ? 1 : 0.4)
        }
        .buttonStyle(TactileButtonStyle())
        .disabled(!canPurchase || busy)
    }

    // MARK: StoreKit (mirrors PaywallView)

    @MainActor private func loadProducts() async {
        do {
            products = try await Product.products(for: EntitlementManager.productIDs).sorted { $0.id.hasSuffix("yearly") && !$1.id.hasSuffix("yearly") }
            trialEligible = await selected?.subscription?.isEligibleForIntroOffer ?? false
        } catch { products = [] }
    }

    private func disclosure(_ product: Product) -> String {
        guard let subscription = product.subscription else { return "\(product.displayPrice) · One-time purchase" }
        return "\(product.displayPrice) every \(period(subscription.subscriptionPeriod))"
    }

    private func period(_ period: Product.SubscriptionPeriod) -> String {
        let unit: String
        switch period.unit { case .day: unit = "day"; case .week: unit = "week"; case .month: unit = "month"; case .year: unit = "year"; @unknown default: unit = "period" }
        return "\(period.value) \(unit)\(period.value == 1 ? "" : "s")"
    }

    private func restore() {
        busy = true
        Task { @MainActor in
            defer { busy = false }
            await entitlements.restorePurchases()
            if entitlements.isPremium { diet.reloadState(); data.nextScreen() }
            else { message = "No active membership was found. Check the Apple Account used for your purchase." }
        }
    }

    private func purchase() {
        busy = true
        Task { @MainActor in
            defer { busy = false }
            guard let product = selected else {
                #if DEBUG
                if await entitlements.purchase(selectedID) { diet.reloadState(); data.nextScreen() }
                #else
                message = "Memberships aren’t available right now. You can start free and upgrade later."
                #endif
                return
            }
            do {
                switch try await product.purchase() {
                case .success(let result):
                    guard case .verified(let transaction) = result else { message = "We couldn’t verify this purchase. Please try restoring purchases."; return }
                    await transaction.finish(); await entitlements.refreshEntitlements(); diet.reloadState()
                    if entitlements.isPremium { data.nextScreen() }
                case .pending: message = "Your purchase is awaiting approval. Membership will be available once it’s approved."
                case .userCancelled: break
                @unknown default: break
                }
            } catch { message = "The purchase couldn’t be completed. Please try again." }
        }
    }
}
