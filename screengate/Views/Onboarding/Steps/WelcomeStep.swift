import SwiftUI

/// Onboarding step 01 (canvas V2-01): hero artwork with group chips, headline, one CTA.
struct WelcomeStep: View {
    @ObservedObject var data: OnboardingData
    @Environment(\.kitchenTheme) private var theme
    var body: some View {
        OnboardingPage {
            OnboardingArtwork(asset: "DigitalGarden", height: 360,
                              alt: "A clay phone resting on a dinner plate beside an avocado and a donut")
                .overlay(alignment: .bottomLeading) {
                    HStack(spacing: 6) {
                        ForEach(KitchenFoodGroup.allCases, id: \.self) { WelcomeGroupChip(group: $0) }
                    }
                    .padding(16)
                }
                .padding(.horizontal, -4)
                .rise(0)
            VStack(alignment: .leading, spacing: 12) {
                OnboardingTitle(first: "Your apps.\nYour plate.", second: "Your balance.", size: 40).rise(1)
                OnboardingBody(text: "A kitchen for your digital life. Choose what you consume, when, and how much feels right.").rise(2)
            }
            .padding(.top, 6)
        } footer: {
            KitchenPrimaryButton(title: "Prepare my digital diet", systemImage: "arrow.right") { data.nextScreen() }
            Text("About 3 minutes · Everything stays on your iPhone")
                .font(KitchenFont.body(12)).foregroundStyle(theme.faint).padding(.top, 10)
        }
    }
}

private struct WelcomeGroupChip: View {
    @Environment(\.kitchenTheme) private var theme
    let group: KitchenFoodGroup
    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(theme.color(for: group)).frame(width: 6, height: 6)
            Text(group.title).font(.custom(KitchenFont.manrope, size: 11, relativeTo: .caption2).weight(.bold))
        }
        .foregroundStyle(theme.color(for: group))
        .padding(.horizontal, 11).frame(height: 28)
        .background(Color(hex: "15120F").opacity(0.72), in: Capsule())
        .background(.ultraThinMaterial, in: Capsule())
    }
}
