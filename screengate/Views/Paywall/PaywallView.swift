import SwiftUI
import StoreKit

struct PaywallView: View {
    var placement: PaywallPlacement = .onboardingComplete
    var intention: String? = nil
    var onFinished: () -> Void
    @Environment(EntitlementManager.self) private var entitlements
    @Environment(DietManager.self) private var diet
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var products: [Product] = []
    @State private var selectedID = "screendiet.premium.yearly"
    @State private var trialEligible = false
    @State private var loading = true
    @State private var busy = false
    @State private var message: String?
    private var selected: Product? { products.first { $0.id == selectedID } }
    private var why: String { intention?.lowercased() ?? diet.sharedState.onboarding?.intention?.lowercased() ?? "what matters" }
    private var title: String {
        switch placement {
        case .weeklyReport: return "Know your habits.\nChoose your next chapter."
        case .featureNightFast: return "Quieter nights.\nMore rested mornings."
        case .cheatOut: return "A routine with\nroom to be human."
        case .featureWidgets: return "Your rhythm.\nAt a glance."
        case .featureStrictMode: return "Give your intention\na little more strength."
        default: return "Make room\nfor \(why)."
        }
    }
    private var artwork: String {
        switch placement { case .featureNightFast: return "NightGarden"; case .weeklyReport: return "FreshStart"; case .cheatOut: return "DigitalGarden"; case .featureStrictMode: return "FocusGarden"; default: return "LifeReclaimed" }
    }
    private var trial: Product.SubscriptionOffer? {
        guard trialEligible, let offer = selected?.subscription?.introductoryOffer, offer.paymentMode == .freeTrial else { return nil }
        return offer
    }
    var body: some View {
        DietPage {
            HStack {
                Label("ScreenDiet Plus", systemImage: "sparkles").font(.headline).foregroundStyle(AppTheme.shared.colors.primary)
                Spacer()
                Button(action: onFinished) { Image(systemName: "xmark").frame(width: 44, height: 44).background(AppTheme.shared.colors.surface).clipShape(Circle()) }.accessibilityLabel("Continue with Free")
            }
            DietArtwork(asset: artwork, height: 220).editorialEntrance()
            DietHeading(eyebrow: "Your attention is worth nurturing", title: title, detail: "A little more support for focused days, quieter evenings and a rhythm that feels like yours.", centered: true).editorialEntrance(delay: 0.1)
            VStack(spacing: 20) {
                DietFeatureRow(icon: "moon.stars.fill", title: "Let your evenings breathe", detail: "Night Fast puts selected Carbs and Fats to bed.", tint: .purple)
                DietFeatureRow(icon: "chart.pie.fill", title: "See the bigger picture", detail: "Measured activity, weekly trends, top apps and your grade.")
                DietFeatureRow(icon: "slider.horizontal.3", title: "Find your kind of balance", detail: "All plans, strict mode and more flexible cheat meals.", tint: .orange)
                DietFeatureRow(icon: "rectangle.stack.fill", title: "Keep your routine close", detail: "Widgets put your kitchen and portion on your Home Screen.")
            }.dietCard().editorialEntrance(delay: 0.2)
            if loading { ProgressView("Finding available memberships…").tint(AppTheme.shared.colors.primary).padding() }
            else if products.isEmpty {
                DietFeatureRow(icon: "leaf.fill", title: "Plus is coming soon", detail: "Memberships aren’t available from the App Store right now. Your free routine is ready to use.").dietCard()
                Button("Check again") { Task { await loadProducts() } }.frame(minHeight: 44)
            } else {
                VStack(spacing: 12) {
                    ForEach(products, id: \.id) { product in
                        DietChoice(icon: product.type == .nonConsumable ? "infinity" : "calendar", title: planName(product), detail: disclosure(product), selected: selectedID == product.id) { selectedID = product.id }
                    }
                }
                if let trial {
                    VStack(alignment: .leading, spacing: 18) {
                        DietFeatureRow(icon: "sparkles", title: "Today · Your \(period(trial.period)) trial begins", detail: "Explore the full routine and weekly reports.")
                        DietFeatureRow(icon: "calendar", title: "After the trial · Membership continues", detail: selected.map(disclosure) ?? "")
                        DietFeatureRow(icon: "gearshape", title: "You’re in control", detail: "Manage or cancel through your Apple subscriptions before renewal.")
                    }.dietCard()
                }
                Text(selected?.subscription == nil ? "A one-time purchase for this membership." : "Subscriptions renew automatically unless canceled. Manage or cancel in your Apple Account settings.").font(.caption).foregroundStyle(AppTheme.shared.colors.textSecondary)
            }
            HStack(spacing: 24) {
                Button("Restore purchases", action: restore).disabled(busy).frame(minHeight: 44)
                Link("Terms", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!).frame(minHeight: 44)
            }.font(.caption).foregroundStyle(AppTheme.shared.colors.textSecondary)
            Button("How your data is used") { message = "Your diet profile and selections are stored in the app’s on-device shared container. Screen Time usage reports are rendered by Apple’s report extension. Purchases are processed by the App Store." }.font(.caption).frame(minHeight: 44)
        } footer: {
            if let selected {
                PrimaryButton(title: busy ? "Please wait…" : trial.map { "Start \(period($0.period)) free" } ?? "Continue with Plus", icon: "arrow.right", isDisabled: busy) { purchase(selected) }
                Text(trial != nil ? "Then \(disclosure(selected))" : disclosure(selected)).font(.caption2).foregroundStyle(AppTheme.shared.colors.textSecondary).multilineTextAlignment(.center)
            }
            Button("Continue with Free", action: onFinished).font(.subheadline).frame(minHeight: 44)
        }.foregroundStyle(AppTheme.shared.colors.text).task { await loadProducts() }
            .task(id: selectedID) { trialEligible = await selected?.subscription?.isEligibleForIntroOffer ?? false }
            .alert("Membership", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) { Button("OK") { message = nil } } message: { Text(message ?? "") }
    }
    @MainActor private func loadProducts() async {
        loading = true
        defer { loading = false }
        do {
            products = try await Product.products(for: EntitlementManager.productIDs).sorted { order($0.id) < order($1.id) }
            if !products.contains(where: { $0.id == selectedID }), let first = products.first { selectedID = first.id }
            trialEligible = await selected?.subscription?.isEligibleForIntroOffer ?? false
        } catch { products = []; message = "Memberships couldn’t be loaded. You can continue with Free and try again later." }
    }
    private func order(_ id: String) -> Int { id.hasSuffix("yearly") ? 0 : id.hasSuffix("monthly") ? 1 : 2 }
    private func planName(_ product: Product) -> String { product.id.hasSuffix("yearly") ? "Annual membership" : product.id.hasSuffix("monthly") ? "Monthly membership" : "Lifetime membership" }
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
            if entitlements.isPremium { diet.reloadState(); onFinished() }
            else { message = "No active membership was found. Check the Apple Account used for your purchase." }
        }
    }
    private func purchase(_ product: Product) {
        busy = true
        Task { @MainActor in
            defer { busy = false }
            do {
                switch try await product.purchase() {
                case .success(let result):
                    guard case .verified(let transaction) = result else { message = "We couldn’t verify this purchase. Please try restoring purchases."; return }
                    await transaction.finish(); await entitlements.refreshEntitlements(); diet.reloadState()
                    if entitlements.isPremium { onFinished() }
                case .pending: message = "Your purchase is awaiting approval. Membership will be available once it’s approved."
                case .userCancelled: break
                @unknown default: break
                }
            } catch { message = "The purchase couldn’t be completed. Please try again." }
        }
    }
}
