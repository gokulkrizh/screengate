import SwiftUI

/// v2 onboarding shell (spec §7): themed background, header with 5-chapter progress, and the step switch.
/// Steps live in `Steps/`. `data.currentScreen` is the step number (1…19).
struct OnboardingView: View {
    @StateObject private var data = OnboardingData()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var onCompletion: () -> Void = {}

    init(initialScreen: Int = 1, onCompletion: @escaping () -> Void = {}) {
        _data = StateObject(wrappedValue: OnboardingData(initialScreen: initialScreen))
        self.onCompletion = onCompletion
    }

    private var step: OnboardingStep { OnboardingStep(rawValue: data.currentScreen) ?? .welcome }
    private var theme: KitchenTheme { step.theme }

    var body: some View {
        VStack(spacing: 0) {
            KitchenOnboardingHeader(
                chapter: step.chapter,
                fraction: Double(step.positionInChapter.index) / Double(step.positionInChapter.count),
                showsBack: step.showsBack,
                isPlus: step.isPlus,
                onBack: { data.previousScreen() })
            .padding(.top, 4)
            stepView
                .id(step)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .offset(y: 18)))
        }
        .animation(.easeInOut(duration: reduceMotion ? 0.2 : 0.4), value: step)
        .environment(\.kitchenTheme, theme)
        .foregroundStyle(theme.text)
        .kitchenBackground(theme)
        .preferredColorScheme(theme.colorScheme)
        .onChange(of: data.isOnboardingComplete) { _, completed in if completed { onCompletion(); dismiss() } }
    }

    @ViewBuilder private var stepView: some View {
        switch step {
        case .welcome: WelcomeStep(data: data)
        case .story: StoryStep(data: data)
        case .ingredients: IngredientsStep(data: data)
        case .goal: GoalStep(data: data)
        case .intention: IntentionStep(data: data)
        case .rhythm: RhythmStep(data: data)
        case .screenTime: ScreenTimeStep(data: data)
        case .carbs: PlateStep(data: data, group: .carbs)
        case .fats: PlateStep(data: data, group: .fats)
        case .protein: PlateStep(data: data, group: .protein)
        case .perspective: PerspectiveStep(data: data)
        case .plan: PlanStep(data: data)
        case .portion: PortionStep(data: data)
        case .hours: HoursStep(data: data)
        case .nightFast: NightFastStep(data: data)
        case .reminders: RemindersStep(data: data)
        case .recipe: RecipeStep(data: data)
        case .membership: MembershipStep(data: data)
        case .ready: ReadyStep(data: data)
        }
    }
}
