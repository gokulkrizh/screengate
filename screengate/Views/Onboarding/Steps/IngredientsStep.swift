import SwiftUI

/// Onboarding step 03 (canvas V2-03): three expandable food-group cards. Carbs open by default.
struct IngredientsStep: View {
    @ObservedObject var data: OnboardingData
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var open: KitchenFoodGroup? = .carbs

    private func info(_ g: KitchenFoodGroup) -> (why: String, rule: String) {
        switch g {
        case .carbs: ("Feeds, reels and quick checks. Tasty, and easy to overeat.", "One shared daily portion")
        case .fats: ("Messages and calls with the people you care about.", "Unlimited · rests during fasts")
        case .protein: ("Tools for reading, making and getting things done.", "Always on the table")
        }
    }

    var body: some View {
        OnboardingPage {
            OnboardingArtwork(asset: "BalancedPantry", height: 180,
                              alt: "Three clay bowls holding a donut, an avocado and a sprout")
                .padding(.horizontal, -4).rise(0)
            VStack(alignment: .leading, spacing: 8) {
                OnboardingEyebrow(text: "Meet your ingredients").rise(1)
                OnboardingTitle(first: "A place for", second: "every app.", emphasis: false, size: 34).rise(2)
            }
            VStack(spacing: 8) {
                ForEach(Array(KitchenFoodGroup.allCases.enumerated()), id: \.element) { i, g in
                    card(g).editorialEntrance(delay: 0.45 + Double(i) * 0.1)
                }
            }
            .padding(.horizontal, -4)
        } footer: {
            KitchenPrimaryButton(title: "Makes sense", systemImage: "arrow.right") { data.nextScreen() }
        }
    }

    private func card(_ g: KitchenFoodGroup) -> some View {
        let isOpen = open == g
        let color = theme.color(for: g)
        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .easeOut(duration: 0.3)) { open = isOpen ? nil : g }
            } label: {
                HStack(spacing: 12) {
                    UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 13, bottomTrailingRadius: 13, topTrailingRadius: 0)
                        .fill(color).frame(width: 26, height: 16).padding(.top, 12)
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(g.title).font(KitchenFont.headline(20)).tracking(-0.4).foregroundStyle(theme.text)
                        Text(g.verb.uppercased()).font(.custom(KitchenFont.manrope, size: 11, relativeTo: .caption2).weight(.bold)).tracking(1.1).foregroundStyle(color)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.down").font(.system(size: 12, weight: .heavy)).foregroundStyle(theme.muted)
                        .rotationEffect(.degrees(isOpen ? 180 : 0))
                        .frame(width: 28, height: 28)
                }
                .padding(.horizontal, 14).frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(TactileButtonStyle())
            .accessibilityValue(isOpen ? "Expanded" : "Collapsed")
            if isOpen {
                VStack(alignment: .leading, spacing: 8) {
                    Text(info(g).why).font(KitchenFont.body(13)).foregroundStyle(theme.muted).fixedSize(horizontal: false, vertical: true)
                    Text(info(g).rule).font(.custom(KitchenFont.manrope, size: 11, relativeTo: .caption2).weight(.bold)).foregroundStyle(color)
                        .padding(.horizontal, 10).frame(height: 24).background(theme.soft(g, opacity: 0.11), in: Capsule())
                }
                .padding(.leading, 52).padding(.trailing, 14).padding(.bottom, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.opacity.combined(with: .offset(y: -6)))
            }
        }
        .background(theme.surface, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(isOpen ? color : theme.line, lineWidth: isOpen ? 1.5 : 1))
        .sensoryFeedback(.selection, trigger: isOpen)
    }
}
