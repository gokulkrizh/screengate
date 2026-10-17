import SwiftUI

/// Onboarding uses the same RevenueCat offering and purchase flow as feature upgrades.
struct MembershipStep: View {
    @ObservedObject var data: OnboardingData

    var body: some View {
        PaywallView(placement: .onboardingComplete, intention: data.intention) {
            data.nextScreen()
        }
    }
}
