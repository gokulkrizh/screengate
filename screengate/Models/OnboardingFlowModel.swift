//
//  OnboardingFlowModel.swift
//  screengate
//
//  Created by gokul on 01/11/25.
//

import SwiftUI

// MARK: - Onboarding Flow Steps
enum OnboardingStep: CaseIterable {
    case welcome
    case dailyScreenTime
    case problemHabits
    case personalGoal
    case surveyQ1
    case surveyQ2
    case surveyQ3
    case surveyQ4
    case surveyQ5
    case surveyQ6
    case ageAndOccupation
    case screenTimePermission
    case personalizedProjection
    case selectDistractingApps
    case mindfulPausePrompt
    case scheduling
    case gamification
    case socialConnection
    case notifications
    case completion

    var title: String {
        switch self {
        case .welcome: return "Welcome to ScreenGate"
        case .dailyScreenTime: return "Daily Screen Time"
        case .problemHabits: return "Identify Problem Habits"
        case .personalGoal: return "Personal Goal Selection"
        case .surveyQ1: return "Phone Usage Awareness"
        case .surveyQ2: return "Notification Impact"
        case .surveyQ3: return "Night Time Habits"
        case .surveyQ4: return "Frustration Level"
        case .surveyQ5: return "Time Tracking"
        case .surveyQ6: return "Focus Interruption"
        case .ageAndOccupation: return "About You"
        case .screenTimePermission: return "Screen Time Access"
        case .personalizedProjection: return "Your Personal Projection"
        case .selectDistractingApps: return "Select Distracting Apps"
        case .mindfulPausePrompt: return "Mindful Pause"
        case .scheduling: return "Set Your Schedule"
        case .gamification: return "Earn Rewards"
        case .socialConnection: return "Connect with Friends"
        case .notifications: return "Daily Insights"
        case .completion: return "You're All Set!"
        }
    }

    var question: String? {
        switch self {
        case .dailyScreenTime: return "How much time do you usually spend on your phone each day?"
        case .problemHabits: return "What distracts you most?"
        case .personalGoal: return "What's your main goal with ScreenGate?"
        case .surveyQ1: return "How often do you catch yourself unlocking your phone without thinking?"
        case .surveyQ2: return "How often do notifications pull you away from what matters?"
        case .surveyQ3: return "Does your phone keep you scrolling late at night?"
        case .surveyQ4: return "How often do you feel frustrated after losing track of time on your phone?"
        case .surveyQ5: return "Do you lose track of time while using your phone?"
        case .surveyQ6: return "How often does your phone interrupt your focus at work or study?"
        case .ageAndOccupation: return "Tell us a little about yourself"
        case .mindfulPausePrompt: return "Customize your mindful pause message"
        default: return nil
        }
    }
}

// MARK: - Onboarding Options
enum ScreenTimeOption: String, CaseIterable {
    case lessThan1Hour = "<1h"
    case oneTo3Hours = "1-3h"
    case threeTo5Hours = "3-5h"
    case fiveTo7Hours = "5-7h"
    case moreThan7Hours = "7+h"
}

enum ProblemHabit: String, CaseIterable {
    case socialMedia = "Social Media"
    case messaging = "Messaging"
    case games = "Games"
    case news = "News"
    case shopping = "Shopping"
    case other = "Other"
}

enum PersonalGoal: String, CaseIterable {
    case focus = "Focus"
    case reduceStress = "Reduce stress"
    case personalTime = "Personal time"
    case relationships = "Relationships"
    case healthyHabits = "Healthy habits"
}

enum SurveyAnswer: String, CaseIterable {
    case option1, option2, option3
}

// MARK: - Onboarding Data Model
@Observable
class OnboardingData {
    var dailyScreenTime: ScreenTimeOption?
    var problemHabits: Set<ProblemHabit> = []
    var personalGoal: PersonalGoal?
    var surveyAnswers: [OnboardingStep: SurveyAnswer] = [:]
    var age: Int?
    var occupation: String = ""
    var selectedApps: Set<String> = []
    var mindfulPauseMessage: String = "Pause — why are you opening this?"
    var workSchedule: Bool = true
    var studySchedule: Bool = false
    var bedtimeSchedule: Bool = true
    var customSchedule: Bool = false
    var gamificationEnabled: Bool = true
    var socialConnectionEnabled: Bool = false
    var notificationsEnabled: Bool = true
    var permissionsGranted: Bool = false

    func getSurveyAnswer(for step: OnboardingStep) -> SurveyAnswer? {
        return surveyAnswers[step]
    }

    func setSurveyAnswer(for step: OnboardingStep, answer: SurveyAnswer) {
        surveyAnswers[step] = answer
    }
}