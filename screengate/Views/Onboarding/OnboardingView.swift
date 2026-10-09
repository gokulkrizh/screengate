import SwiftUI

struct OnboardingView: View {
    @StateObject private var data = OnboardingData()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var onCompletion: () -> Void = {}
    init(initialScreen: Int = 0, onCompletion: @escaping () -> Void = {}) {
        _data = StateObject(wrappedValue: OnboardingData(initialScreen: initialScreen))
        self.onCompletion = onCompletion
    }
    private let total = 19
    private var chapter: String {
        switch data.currentScreen {
        case 0...2: return "A little perspective"
        case 3...6: return "Make it personal"
        case 7...10: return "Know your ingredients"
        case 11...14: return "Build your routine"
        default: return "Your fresh start"
        }
    }
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                if data.currentScreen > 0 && data.currentScreen < 16 {
                    Button { data.previousScreen() } label: { Image(systemName: "arrow.left").frame(width: 44, height: 44) }.accessibilityLabel("Previous page")
                } else { Image(systemName: "leaf.fill").frame(width: 44, height: 44).accessibilityHidden(true) }
                VStack(alignment: .leading, spacing: 6) {
                    Text(chapter).font(.caption.weight(.semibold))
                    ProgressView(value: Double(data.currentScreen + 1), total: Double(total)).tint(AppTheme.shared.colors.primary)
                }
                Text("\(data.currentScreen + 1)/\(total)").font(.caption2.monospacedDigit()).foregroundStyle(AppTheme.shared.colors.textSecondary)
            }.foregroundStyle(AppTheme.shared.colors.primary).padding(.horizontal, 16).padding(.top, 4).padding(.bottom, 8)
            Group {
                switch data.currentScreen {
                case 0...2: StoryChapterView(data: data, chapter: data.currentScreen)
                case 3: QuizView(data: data, question: .goal)
                case 4: IntentionView(data: data)
                case 5: QuizView(data: data, question: .hours)
                case 6: QuizView(data: data, question: .time)
                case 7: PersonalPlanPreview(data: data)
                case 8: PermissionsView(data: data)
                case 9: GroupPickerView(data: data, group: .carbs)
                case 10: HookBView(data: data)
                case 11: GroupPickerView(data: data, group: .fats, isSkippable: true)
                case 12: PlanSuggestionView(data: data)
                case 13: WindowDialView(data: data)
                case 14: NotificationPromptView(data: data)
                case 15: PlanReviewView(data: data)
                case 16: PaywallView(placement: .onboardingComplete, intention: data.intention) { data.nextScreen() }
                case 17: DietActivatedView(data: data)
                default: FirstDayView(data: data)
                }
            }.id(data.currentScreen).transition(reduceMotion ? .opacity : .opacity.combined(with: .offset(y: 16)))
                .animation(.easeInOut(duration: reduceMotion ? 0.15 : 0.35), value: data.currentScreen)
        }.background(AppTheme.shared.colors.background.ignoresSafeArea())
            .onChange(of: data.isOnboardingComplete) { _, completed in if completed { onCompletion(); dismiss() } }
    }
}
