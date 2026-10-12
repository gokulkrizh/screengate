import Foundation
import Combine

class OnboardingData: ObservableObject {
    /// Step number, 1…19 (see `OnboardingStep`).
    @Published var currentScreen = 1

    // Quiz answers (step 3)
    @Published var intention: String?
    @Published var quizDailyHours: Int?
    @Published var quizWorstTime: String?
    @Published var quizGoal: String?

    // Diet setup
    @Published var selectedPlan: DietPlan?
    @Published var windowStartHour: Int = 12
    @Published var windowStartMinute: Int = 0
    @Published var windowEndHour: Int = 20
    @Published var windowEndMinute: Int = 0
    @Published var nightLockHour: Int = 22
    @Published var nightLockMinute: Int = 0
    @Published var nightFastEnabled: Bool = true   // Night Fast step toggle (becomes real with Plus)
    @Published var remindersEnabled: Bool = false
    @Published var dailyCarbLimitMinutes: Int = DebugConfig.defaultPortionMinutes

    // Track completion
    @Published var isOnboardingComplete: Bool {
        didSet {
            if isOnboardingComplete {
                saveOnboardingCompletion()
            }
        }
    }

    private static let onboardingCompletionKey = "isOnboardingCompleted"

    init(initialScreen: Int = 1) {
        self.isOnboardingComplete = false
        self.currentScreen = min(19, max(1, initialScreen))
        #if DEBUG
        if DesignReviewView.launchRoute != nil {
            quizDailyHours = 4; quizWorstTime = "evening"; quizGoal = "cutdown"
            intention = "Reading"; selectedPlan = .lean; dailyCarbLimitMinutes = 45
        }
        #endif
    }

    // MARK: - Navigation

    func nextScreen() {
        currentScreen = min(19, currentScreen + 1)
    }

    func previousScreen() {
        if currentScreen > 1 {
            currentScreen -= 1
        }
    }

    func goToScreen(_ screen: Int) {
        currentScreen = screen
    }

    // MARK: - Quiz

    var quizAnswers: OnboardingAnswers {
        OnboardingAnswers(
            dailyHours: quizDailyHours,
            worstTime: quizWorstTime,
            goal: quizGoal,
            intention: intention
        )
    }

    /// Suggested plan from the quiz (user can still edit it).
    var suggestedPlan: DietPlan {
        if quizGoal == "reset" { return .detox }
        if quizGoal == "focus" { return .keto }
        if let hours = quizDailyHours, hours >= 6 { return .keto }
        return .lean
    }

    // MARK: - Completion

    func completeOnboarding() {
        isOnboardingComplete = true
    }

    private func saveOnboardingCompletion() {
        UserDefaults.standard.set(true, forKey: Self.onboardingCompletionKey)
    }

    static func hasCompletedOnboarding() -> Bool {
        return UserDefaults.standard.bool(forKey: onboardingCompletionKey)
    }

    static func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: onboardingCompletionKey)
    }
}
