import SwiftUI

/// Onboarding step 04 (canvas V2-04): "What would a little balance give you?" Stored as `quizGoal`.
struct GoalStep: View {
    @ObservedObject var data: OnboardingData
    @Environment(\.kitchenTheme) private var theme

    private let options: [(id: String, title: String, detail: String, icon: String)] = [
        ("present", "Be more present", "Less autopilot. More moments that count.", "heart"),
        ("focus", "Find my focus", "Space to settle into meaningful work.", "hourglass"),
        ("sleep", "Sleep more peacefully", "Let the day end without one more scroll.", "moon"),
        ("control", "Feel in control again", "Pick up my phone on purpose, not by reflex.", "scope"),
    ]

    var body: some View {
        OnboardingPage {
            VStack(alignment: .leading, spacing: 12) {
                OnboardingEyebrow(text: "Your reason to begin").rise(0)
                OnboardingTitle(first: "What would a little", second: "balance give you?", emphasis: false, size: 38).rise(1)
                OnboardingBody(text: "Your diet should support the life you want.").rise(2)
            }
            .padding(.top, 12)
            VStack(spacing: 10) {
                ForEach(Array(options.enumerated()), id: \.element.id) { i, o in
                    KitchenChoiceCard(title: o.title, detail: o.detail, systemImage: o.icon, isSelected: data.quizGoal == o.id) {
                        data.quizGoal = o.id
                    }
                    .editorialEntrance(delay: 0.4 + Double(i) * 0.08)
                }
            }
            .padding(.horizontal, -4).padding(.top, 6)
        } footer: {
            KitchenPrimaryButton(title: "Continue", systemImage: "arrow.right") { data.nextScreen() }
        }
        .onAppear { if !options.contains(where: { $0.id == data.quizGoal }) { data.quizGoal = options[0].id } }
    }
}
