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
    private let theme = KitchenTheme.lamp
    private let benefits: [(KitchenFoodGroup, String, String, String)] = [
        (.protein, "moon", "Let your evenings breathe", "Night Fast puts selected Carbs and Fats to bed."),
        (.carbs, "chart.pie", "See the bigger picture", "Measured activity, weekly trends, top apps and your grade."),
        (.fats, "slider.horizontal.3", "Find your kind of balance", "All plans, Strict Mode and more flexible extra servings."),
        (.protein, "rectangle.stack", "Keep your routine close", "Widgets put your kitchen and portion on your Home Screen."),
    ]

    var body: some View {
        OnboardingPage {
            HStack {
                Label("ScreenDiet Plus", systemImage: "sparkles").font(KitchenFont.label(15)).foregroundStyle(theme.lamp)
                Spacer()
                Button(action: onFinished) {
                    Image(systemName: "xmark").font(.system(size: 14, weight: .bold)).foregroundStyle(theme.text)
                        .frame(width: 44, height: 44).background(theme.surface, in: Circle()).overlay(Circle().stroke(theme.line, lineWidth: 1))
                }.accessibilityLabel("Continue with Free")
            }.rise(0)
            OnboardingArtwork(asset: artwork, height: 220).rise(1)
            VStack(alignment: .leading, spacing: 10) {
                OnboardingEyebrow(text: "Your attention is worth nurturing")
                OnboardingTitle(first: title.components(separatedBy: "\n").first ?? title, second: title.components(separatedBy: "\n").dropFirst().first)
                OnboardingBody(text: "A little more support for focused days, quieter evenings and a rhythm that feels like yours.")
            }.rise(2)
            VStack(spacing: 0) {
                ForEach(Array(benefits.enumerated()), id: \.offset) { i, b in
                    HStack(spacing: 12) {
                        Image(systemName: b.1).font(.system(size: 14, weight: .semibold)).foregroundStyle(theme.color(for: b.0))
                            .frame(width: 30, height: 30).background(theme.soft(b.0), in: RoundedRectangle(cornerRadius: 10))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(b.2).font(KitchenFont.body(14).weight(.bold))
                            Text(b.3).font(KitchenFont.body(12)).foregroundStyle(theme.muted)
                        }
                        Spacer(minLength: 0)
                    }.padding(.vertical, 10)
                    if i < benefits.count - 1 { theme.line.frame(height: 1) }
                }
            }.padding(.horizontal, 16).padding(.vertical, 4).kitchenCard(theme).rise(3)
            if loading { ProgressView("Finding available memberships…").tint(theme.lamp).padding() }
            else if products.isEmpty {
                VStack(spacing: 4) {
                    Text("Plus is coming soon").font(KitchenFont.body(15).weight(.bold))
                    Text("Memberships aren’t available from the App Store right now. Your free routine is ready to use.").font(KitchenFont.body(13)).foregroundStyle(theme.muted)
                    KitchenSecondaryButton(title: "Check again") { Task { await loadProducts() } }
                }.padding(16).kitchenCard(theme)
            } else {
                VStack(spacing: 8) {
                    ForEach(products, id: \.id) { product in
                        KitchenChoiceCard(title: planName(product), detail: disclosure(product), systemImage: product.type == .nonConsumable ? "infinity" : "calendar", isSelected: selectedID == product.id) { selectedID = product.id }
                    }
                }
                if let trial {
                    Text("Your \(period(trial.period)) trial begins today. After it, membership continues at \(selected.map(disclosure) ?? ""). Manage or cancel in your Apple subscriptions before renewal.")
                        .font(KitchenFont.label(12)).foregroundStyle(theme.muted)
                }
                Text(selected?.subscription == nil ? "A one-time purchase for this membership." : "Subscriptions renew automatically unless canceled. Manage or cancel in your Apple Account settings.")
                    .font(KitchenFont.label(11)).foregroundStyle(theme.faint)
            }
            HStack(spacing: 24) {
                Button("Restore purchases", action: restore).disabled(busy).frame(minHeight: 44)
                Link("Terms", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!).frame(minHeight: 44)
                Button("Privacy") { message = "Your diet profile and selections are stored in the app’s on-device shared container. Screen Time usage reports are rendered by Apple’s report extension. Purchases are processed by the App Store." }.frame(minHeight: 44)
            }.font(KitchenFont.label(12)).foregroundStyle(theme.faint).frame(maxWidth: .infinity)
        } footer: {
            if let selected {
                KitchenPrimaryButton(title: busy ? "Please wait…" : trial.map { "Start \(period($0.period)) free" } ?? "Continue with Plus", systemImage: "arrow.right", isEnabled: !busy) { purchase(selected) }
            }
            KitchenSecondaryButton(title: "Continue with Free", action: onFinished)
        }
        .environment(\.kitchenTheme, theme)
        .foregroundStyle(theme.text)
        .kitchenBackground(theme)
        .preferredColorScheme(.dark)
        .task { await loadProducts() }
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
