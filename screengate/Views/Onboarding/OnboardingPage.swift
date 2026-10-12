import SwiftUI

/// Scrolling content + pinned footer used by every onboarding step. The header (back, wordmark, chapter,
/// progress bar) and the themed background are drawn by `OnboardingView`, not by the step.
struct OnboardingPage<Content: View, Footer: View>: View {
    @ViewBuilder var content: Content
    @ViewBuilder var footer: Footer

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) { content }
                    .padding(.horizontal, KitchenMetrics.textMargin)
                    .padding(.top, 20).padding(.bottom, 16)
                    .frame(maxWidth: 600).frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
            VStack(spacing: 2) { footer }
                .padding(.horizontal, KitchenMetrics.textMargin).padding(.top, 8).padding(.bottom, 12)
                .frame(maxWidth: 600).frame(maxWidth: .infinity)
        }
    }
}

/// Headline (34–40 pt) with an optional second line in `muted`/`lamp` (spec §3). Use "\n" inside `first` for hard breaks.
struct OnboardingTitle: View {
    @Environment(\.kitchenTheme) private var theme
    let first: String
    var second: String? = nil
    var emphasis = true          // true = second line in lamp, false = muted
    var size: CGFloat = 36
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(first).foregroundStyle(theme.text)
            if let second { Text(second).foregroundStyle(emphasis ? theme.lamp : theme.muted) }
        }
        .font(KitchenFont.headline(size)).tracking(-1.2).lineSpacing(-size * 0.04)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine).accessibilityAddTraits(.isHeader)
    }
}

struct OnboardingEyebrow: View {
    @Environment(\.kitchenTheme) private var theme
    let text: String
    var body: some View { Text(text).kitchenEyebrow().foregroundStyle(theme.faint).frame(maxWidth: .infinity, alignment: .leading) }
}

struct OnboardingBody: View {
    @Environment(\.kitchenTheme) private var theme
    let text: String
    var body: some View { Text(text).kitchenBody().foregroundStyle(theme.muted).fixedSize(horizontal: false, vertical: true).frame(maxWidth: .infinity, alignment: .leading) }
}

/// Rounded artwork card (32 pt radius) that settles from 1.12× / 30 % (spec §6).
struct OnboardingArtwork: View {
    @Environment(\.kitchenTheme) private var theme
    let asset: String
    var height: CGFloat = 330
    var alt: String = ""
    var body: some View {
        Color.clear.frame(height: height).frame(maxWidth: .infinity)
            .overlay { DietHeroArt(asset: asset) }
            .clipShape(RoundedRectangle(cornerRadius: KitchenMetrics.cardRadius + 2))
            .shadow(color: .black.opacity(theme == .daylight ? 0.12 : 0.5), radius: 24, y: 16)
            .overlay(RoundedRectangle(cornerRadius: KitchenMetrics.cardRadius + 2).stroke(theme.line, lineWidth: 1))
            .accessibilityLabel(alt).accessibilityHidden(alt.isEmpty)
    }
}

extension View {
    /// Staggered entrance: rise 18 pt and fade, `index` × 0.1 s (spec §6).
    func rise(_ index: Int = 0) -> some View { editorialEntrance(delay: 0.05 + Double(index) * 0.1) }
}
