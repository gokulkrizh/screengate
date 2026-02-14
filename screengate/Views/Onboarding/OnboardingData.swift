import Foundation
import Combine

class OnboardingData: ObservableObject {
    @Published var currentScreen = 0

    // Diet setup data
    @Published var selectedDietType: DietType?
    @Published var windowStartHour: Int = 12
    @Published var windowEndHour: Int = 18
    @Published var dailyCarbLimitMinutes: Int = 60
    @Published var nightLockHour: Int = 21

    // Track completion
    @Published var isOnboardingComplete: Bool {
        didSet {
            if isOnboardingComplete {
                saveOnboardingCompletion()
            }
        }
    }

    private let onboardingCompletionKey = "isOnboardingCompleted"

    init() {
        self.isOnboardingComplete = UserDefaults.standard.bool(forKey: onboardingCompletionKey)
    }

    func nextScreen() {
        currentScreen += 1
    }

    func previousScreen() {
        if currentScreen > 0 {
            currentScreen -= 1
        }
    }

    func goToScreen(_ screen: Int) {
        currentScreen = screen
    }

    func completeOnboarding() {
        isOnboardingComplete = true
    }

    private func saveOnboardingCompletion() {
        UserDefaults.standard.set(true, forKey: onboardingCompletionKey)
    }

    static func hasCompletedOnboarding() -> Bool {
        return UserDefaults.standard.bool(forKey: "isOnboardingCompleted")
    }

    static func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "isOnboardingCompleted")
    }
}
