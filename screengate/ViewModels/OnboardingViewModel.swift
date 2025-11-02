//
//  OnboardingViewModel.swift
//  screengate
//
//  Created by gokul on 01/11/25.
//

import SwiftUI
import Foundation

// MARK: - Notification Extension
extension Notification.Name {
    static let onboardingCompleted = Notification.Name("onboardingCompleted")
}

@MainActor
@Observable
class OnboardingViewModel {
    var currentStep: OnboardingStep = .welcome
    var onboardingData = OnboardingData()
    var isCompleted = false
    var progress: Double = 0.0

    private let allSteps = OnboardingStep.allCases

    init() {
        updateProgress()
    }

    // MARK: - Navigation
    func nextStep() {
        guard let currentIndex = allSteps.firstIndex(of: currentStep),
              currentIndex < allSteps.count - 1 else {
            completeOnboarding()
            return
        }

        currentStep = allSteps[currentIndex + 1]
        updateProgress()
    }

    func previousStep() {
        guard let currentIndex = allSteps.firstIndex(of: currentStep),
              currentIndex > 0 else {
            return
        }

        currentStep = allSteps[currentIndex - 1]
        updateProgress()
    }

    func goToStep(_ step: OnboardingStep) {
        currentStep = step
        updateProgress()
    }

    func completeOnboarding() {
        isCompleted = true
        saveOnboardingData()

        // Post notification that onboarding is completed
        NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
    }

    // MARK: - Progress
    private func updateProgress() {
        guard let currentIndex = allSteps.firstIndex(of: currentStep) else {
            progress = 0.0
            return
        }
        progress = Double(currentIndex) / Double(allSteps.count - 1)
    }

    var canGoNext: Bool {
        switch currentStep {
        case .welcome, .screenTimePermission, .personalizedProjection, .gamification, .socialConnection, .notifications, .completion:
            return true
        case .dailyScreenTime:
            return onboardingData.dailyScreenTime != nil
        case .problemHabits:
            return !onboardingData.problemHabits.isEmpty
        case .personalGoal:
            return onboardingData.personalGoal != nil
        case .surveyQ1, .surveyQ2, .surveyQ3, .surveyQ4, .surveyQ5, .surveyQ6:
            return onboardingData.getSurveyAnswer(for: currentStep) != nil
        case .ageAndOccupation:
            return onboardingData.age != nil && !onboardingData.occupation.isEmpty
        case .selectDistractingApps:
            return !onboardingData.selectedApps.isEmpty
        case .mindfulPausePrompt:
            return !onboardingData.mindfulPauseMessage.isEmpty
        case .scheduling:
            return true // At least one option should be selected, but all default to some value
        }
    }

    // MARK: - Data Management
    private func saveOnboardingData() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

        // Save relevant data
        if let dailyScreenTime = onboardingData.dailyScreenTime {
            UserDefaults.standard.set(dailyScreenTime.rawValue, forKey: "dailyScreenTime")
        }

        if let personalGoal = onboardingData.personalGoal {
            UserDefaults.standard.set(personalGoal.rawValue, forKey: "personalGoal")
        }

        UserDefaults.standard.set(onboardingData.mindfulPauseMessage, forKey: "mindfulPauseMessage")
        UserDefaults.standard.set(onboardingData.gamificationEnabled, forKey: "gamificationEnabled")
        UserDefaults.standard.set(onboardingData.notificationsEnabled, forKey: "notificationsEnabled")
    }

    static func hasCompletedOnboarding() -> Bool {
        return UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
}