import Foundation
import Combine

// Structure to hold question responses
struct QuestionResponse: Codable {
    let screenNumber: Int
    let question: String
    let availableOptions: [String]?
    let selectedOptions: [String]
    let timestamp: Date
}

class OnboardingData: ObservableObject {
    @Published var currentScreen = 0
    
    // Array to store all question responses in JSON format
    @Published var questionResponses: [QuestionResponse] = []
    
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
    
    // MARK: - Question Response Capture
    
    /// Save a question response with all relevant data
    func saveQuestionResponse(
        screenNumber: Int,
        question: String,
        availableOptions: [String]? = nil,
        selectedOptions: [String]
    ) {
        let response = QuestionResponse(
            screenNumber: screenNumber,
            question: question,
            availableOptions: availableOptions,
            selectedOptions: selectedOptions,
            timestamp: Date()
        )
        questionResponses.append(response)
        
        // Print JSON for debugging (single response)
        if let jsonData = try? JSONEncoder().encode(response),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📊 Question Response JSON: \(jsonString)")
        }
        
        // Print all responses as pretty JSON for easier inspection
        if let allJsonData = try? JSONEncoder().encode(questionResponses),
           let jsonObject = try? JSONSerialization.jsonObject(with: allJsonData),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("📊 All Responses JSON (pretty):\n\(prettyString)")
        } else if let allJson = getAllResponsesAsJSON() {
            print("📊 All Responses JSON: \(allJson)")
        }
    }
    
    /// Get all responses as JSON string
    func getAllResponsesAsJSON() -> String? {
        guard let jsonData = try? JSONEncoder().encode(questionResponses),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
    
    /// Get all responses as dictionary array
    func getAllResponsesAsDictionary() -> [[String: Any]]? {
        guard let jsonData = try? JSONEncoder().encode(questionResponses),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
            return nil
        }
        return jsonObject
    }
}
