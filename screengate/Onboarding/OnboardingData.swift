import Foundation
import Combine

class OnboardingData: ObservableObject {
    @Published var currentScreen = 0
    
    // Screen 1: Welcome & Theme (no data needed)
    
    // Screen 2: Daily Screen Time Estimate
    @Published var estimatedScreenTime: Double = 4.0
    
    // Screen 3: Identify Problem Habits
    @Published var selectedProblems: Set<String> = []
    
    // Screen 4: Personal Goal Selection
    @Published var primaryGoal: String?
    
    // Screen 5: Quick Personal Survey
    @Published var phoneCheckFrequency: String? // Few times / Several / Constantly
    @Published var notificationDistractionLevel: String? // Not really / Occasionally / Often
    @Published var sleepAffected: String? // No / Sometimes / Yes
    @Published var scrollFrustration: String? // Never / Sometimes / Often
    @Published var situationHelp: String? // Work / Study / Bedtime
    
    // Screen 6: Age & Occupation
    @Published var age: String?
    @Published var occupation: String?
    
    // Screen 7: Screen Time Permission (no data needed, just action)
    @Published var screenTimePermissionRequested = false
    
    // Screen 8: Personalized Projection / Insights (no data needed, display only)
    
    // Screen 9: Notifications & Reflections
    @Published var notificationsEnabled = false
    
    // Screen 10: Completion (no data needed)
    
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
        // Check if onboarding has been completed before
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
