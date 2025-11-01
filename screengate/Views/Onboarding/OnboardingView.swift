//
//  OnboardingView.swift
//  screengate
//
//  Created by gokul on 01/11/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header with back button, skip button and progress
            HStack {
                if viewModel.currentStep != .welcome {
                    OnboardingBackButton(action: viewModel.previousStep)
                } else {
                    Spacer()
                }

                Spacer()

                // Skip button (only show on non-essential steps)
                if viewModel.currentStep != .welcome &&
                   viewModel.currentStep != .screenTimePermission &&
                   viewModel.currentStep != .personalizedProjection &&
                   viewModel.currentStep != .completion {
                    Button("Skip") {
                        // Skip to next step without requiring data
                        viewModel.nextStep()
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }

                // Progress indicator
                Text("\(Int(viewModel.progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.top)

            // Progress Bar
            OnboardingProgressBar(progress: viewModel.progress)
                .padding(.horizontal)

            // Content
            Group {
                switch viewModel.currentStep {
                case .welcome:
                    WelcomeOnboardingView(onNext: viewModel.nextStep)

                case .dailyScreenTime:
                    DailyScreenTimeView(
                        selectedOption: Binding(
                            get: { viewModel.onboardingData.dailyScreenTime },
                            set: { viewModel.onboardingData.dailyScreenTime = $0 }
                        ),
                        onNext: viewModel.nextStep
                    )

                case .problemHabits:
                    ProblemHabitsView(
                        selectedHabits: Binding(
                            get: { viewModel.onboardingData.problemHabits },
                            set: { viewModel.onboardingData.problemHabits = $0 }
                        ),
                        onNext: viewModel.nextStep
                    )

                case .personalGoal:
                    PersonalGoalView(
                        selectedGoal: Binding(
                            get: { viewModel.onboardingData.personalGoal },
                            set: { viewModel.onboardingData.personalGoal = $0 }
                        ),
                        onNext: viewModel.nextStep
                    )

                case .surveyQ1:
                    SurveyQuestionView(
                        step: .surveyQ1,
                        question: "How often do you catch yourself unlocking your phone without thinking?",
                        options: ["Almost never", "A few times every hour", "I lose track of time"],
                        selectedAnswer: Binding(
                            get: {
                                guard let answer = viewModel.onboardingData.getSurveyAnswer(for: .surveyQ1) else { return nil }
                                switch answer {
                                case .option1: return "Almost never"
                                case .option2: return "A few times every hour"
                                case .option3: return "I lose track of time"
                                }
                            },
                            set: { answer in
                                if let answer = answer {
                                    if answer.contains("Almost never") {
                                        viewModel.onboardingData.setSurveyAnswer(for: .surveyQ1, answer: .option1)
                                    } else if answer.contains("few times") {
                                        viewModel.onboardingData.setSurveyAnswer(for: .surveyQ1, answer: .option2)
                                    } else if answer.contains("lose track") {
                                        viewModel.onboardingData.setSurveyAnswer(for: .surveyQ1, answer: .option3)
                                    }
                                }
                            }
                        ),
                        onNext: viewModel.nextStep
                    )

                case .surveyQ2:
                    SurveyQuestionView(
                        step: .surveyQ2,
                        question: "How often do notifications pull you away from what matters?",
                        options: ["Hardly ever", "Sometimes breaks my focus", "I can't ignore them"],
                        selectedAnswer: Binding(
                            get: {
                                guard let answer = viewModel.onboardingData.getSurveyAnswer(for: .surveyQ2) else { return nil }
                                switch answer {
                                case .option1: return "Hardly ever"
                                case .option2: return "Sometimes breaks my focus"
                                case .option3: return "I can't ignore them"
                                }
                            },
                            set: { answer in
                                if let answer = answer {
                                    if answer.contains("Hardly") {
                                        viewModel.onboardingData.setSurveyAnswer(for: .surveyQ2, answer: .option1)
                                    } else if answer.contains("Sometimes") {
                                        viewModel.onboardingData.setSurveyAnswer(for: .surveyQ2, answer: .option2)
                                    } else if answer.contains("ignore") {
                                        viewModel.onboardingData.setSurveyAnswer(for: .surveyQ2, answer: .option3)
                                    }
                                }
                            }
                        ),
                        onNext: viewModel.nextStep
                    )

                case .surveyQ3:
                    SurveyQuestionView(
                        step: .surveyQ3,
                        question: "Does your phone keep you scrolling late at night?",
                        options: ["Rarely affects me", "Occasionally scroll past bedtime", "Often stay up longer than planned"],
                        selectedAnswer: Binding(
                            get: {
                                guard let answer = viewModel.onboardingData.getSurveyAnswer(for: .surveyQ3) else { return nil }
                                switch answer {
                                case .option1: return "Rarely affects me"
                                case .option2: return "Occasionally scroll past bedtime"
                                case .option3: return "Often stay up longer than planned"
                                }
                            },
                            set: { answer in
                                if let answer = answer {
                                    if answer.contains("Rarely") {
                                        viewModel.onboardingData.setSurveyAnswer(for: .surveyQ3, answer: .option1)
                                    } else if answer.contains("Occasionally") {
                                        viewModel.onboardingData.setSurveyAnswer(for: .surveyQ3, answer: .option2)
                                    } else if answer.contains("Often") {
                                        viewModel.onboardingData.setSurveyAnswer(for: .surveyQ3, answer: .option3)
                                    }
                                }
                            }
                        ),
                        onNext: viewModel.nextStep
                    )

                case .surveyQ4:
                    SurveyQuestionView(
                        step: .surveyQ4,
                        question: "How often do you feel frustrated after losing track of time on your phone?",
                        options: ["Almost never", "Sometimes I regret it", "I frequently feel annoyed at myself"],
                        selectedAnswer: Binding(
                            get: {
                                guard let answer = viewModel.onboardingData.getSurveyAnswer(for: .surveyQ4) else { return nil }
                                switch answer {
                                case .option1: return "Almost never"
                                case .option2: return "Sometimes I regret it"
                                case .option3: return "I frequently feel annoyed at myself"
                                }
                            },
                            set: { answer in
                                if let answer = answer {
                                    if answer.contains("Almost never") {
                                        viewModel.onboardingData.setSurveyAnswer(for: .surveyQ4, answer: .option1)
                                    } else if answer.contains("Sometimes") {
                                        viewModel.onboardingData.setSurveyAnswer(for: .surveyQ4, answer: .option2)
                                    } else if answer.contains("frequently") {
                                        viewModel.onboardingData.setSurveyAnswer(for: .surveyQ4, answer: .option3)
                                    }
                                }
                            }
                        ),
                        onNext: viewModel.nextStep
                    )

                case .surveyQ5:
                    SurveyQuestionView(
                        step: .surveyQ5,
                        question: "Do you lose track of time while using your phone?",
                        options: ["Usually aware of time", "Sometimes realize it late", "Often completely lose track"],
                        selectedAnswer: Binding(
                            get: {
                                guard let answer = viewModel.onboardingData.getSurveyAnswer(for: .surveyQ5) else { return nil }
                                switch answer {
                                case .option1: return "Usually aware of time"
                                case .option2: return "Sometimes realize it late"
                                case .option3: return "Often completely lose track"
                                }
                            },
                            set: { answer in
                                if let answer = answer {
                                    if answer.contains("Usually aware") {
                                        viewModel.onboardingData.setSurveyAnswer(for: .surveyQ5, answer: .option1)
                                    } else if answer.contains("Sometimes") {
                                        viewModel.onboardingData.setSurveyAnswer(for: .surveyQ5, answer: .option2)
                                    } else if answer.contains("Often") {
                                        viewModel.onboardingData.setSurveyAnswer(for: .surveyQ5, answer: .option3)
                                    }
                                }
                            }
                        ),
                        onNext: viewModel.nextStep
                    )

                case .surveyQ6:
                    SurveyQuestionView(
                        step: .surveyQ6,
                        question: "How often does your phone interrupt your focus at work or study?",
                        options: ["Rarely interrupts me", "Occasionally distracts me", "Frequently pulls me away"],
                        selectedAnswer: Binding(
                            get: {
                                guard let answer = viewModel.onboardingData.getSurveyAnswer(for: .surveyQ6) else { return nil }
                                switch answer {
                                case .option1: return "Rarely interrupts me"
                                case .option2: return "Occasionally distracts me"
                                case .option3: return "Frequently pulls me away"
                                }
                            },
                            set: { answer in
                                if let answer = answer {
                                    if answer.contains("Rarely") {
                                        viewModel.onboardingData.setSurveyAnswer(for: .surveyQ6, answer: .option1)
                                    } else if answer.contains("Occasionally") {
                                        viewModel.onboardingData.setSurveyAnswer(for: .surveyQ6, answer: .option2)
                                    } else if answer.contains("Frequently") {
                                        viewModel.onboardingData.setSurveyAnswer(for: .surveyQ6, answer: .option3)
                                    }
                                }
                            }
                        ),
                        onNext: viewModel.nextStep
                    )

                case .ageAndOccupation:
                    AgeAndOccupationView(
                        age: Binding(
                            get: { viewModel.onboardingData.age?.description ?? "" },
                            set: { viewModel.onboardingData.age = Int($0) }
                        ),
                        occupation: Binding(
                            get: { viewModel.onboardingData.occupation },
                            set: { viewModel.onboardingData.occupation = $0 }
                        ),
                        onNext: viewModel.nextStep
                    )

                case .screenTimePermission:
                    ScreenTimePermissionView(onNext: viewModel.nextStep)

                case .personalizedProjection:
                    PersonalizedProjectionView(
                        onboardingData: viewModel.onboardingData,
                        onNext: viewModel.nextStep
                    )

                case .selectDistractingApps:
                    // Simplified version - in real app would show actual apps
                    OnboardingQuestionView(
                        title: "Select Distracting Apps",
                        question: "Choose up to 3 apps you want to limit",
                        canGoNext: !viewModel.onboardingData.selectedApps.isEmpty,
                        onNext: viewModel.nextStep
                    ) {
                        Text("App selection would be implemented here")
                            .foregroundColor(.secondary)
                    }

                case .mindfulPausePrompt:
                    OnboardingQuestionView(
                        title: "Mindful Pause",
                        question: "Customize your mindful pause message",
                        canGoNext: !viewModel.onboardingData.mindfulPauseMessage.isEmpty,
                        onNext: viewModel.nextStep
                    ) {
                        TextField("Enter your pause message", text: Binding(
                            get: { viewModel.onboardingData.mindfulPauseMessage },
                            set: { viewModel.onboardingData.mindfulPauseMessage = $0 }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                case .scheduling:
                    OnboardingQuestionView(
                        title: "Set Your Schedule",
                        question: "When should ScreenGate be active?",
                        canGoNext: true,
                        onNext: viewModel.nextStep
                    ) {
                        VStack(spacing: 12) {
                            Toggle("Work Hours", isOn: Binding(
                                get: { viewModel.onboardingData.workSchedule },
                                set: { viewModel.onboardingData.workSchedule = $0 }
                            ))
                            Toggle("Study Time", isOn: Binding(
                                get: { viewModel.onboardingData.studySchedule },
                                set: { viewModel.onboardingData.studySchedule = $0 }
                            ))
                            Toggle("Bedtime", isOn: Binding(
                                get: { viewModel.onboardingData.bedtimeSchedule },
                                set: { viewModel.onboardingData.bedtimeSchedule = $0 }
                            ))
                        }
                    }

                case .gamification:
                    OnboardingQuestionView(
                        title: "Earn Rewards",
                        question: "Get motivated with achievements and streaks",
                        canGoNext: true,
                        onNext: viewModel.nextStep
                    ) {
                        VStack(spacing: 12) {
                            Text("Earn XP, gems, and streaks for mindful pauses")
                                .multilineTextAlignment(.center)

                            Toggle("Enable Gamification", isOn: Binding(
                                get: { viewModel.onboardingData.gamificationEnabled },
                                set: { viewModel.onboardingData.gamificationEnabled = $0 }
                            ))
                        }
                    }

                case .socialConnection:
                    OnboardingQuestionView(
                        title: "Connect with Friends",
                        question: "Optional: Compare progress with friends",
                        canGoNext: true,
                        onNext: viewModel.nextStep
                    ) {
                        Toggle("Enable Social Features", isOn: Binding(
                            get: { viewModel.onboardingData.socialConnectionEnabled },
                            set: { viewModel.onboardingData.socialConnectionEnabled = $0 }
                        ))
                    }

                case .notifications:
                    OnboardingQuestionView(
                        title: "Daily Insights",
                        question: "Get regular reminders and progress updates",
                        canGoNext: true,
                        onNext: viewModel.nextStep
                    ) {
                        Toggle("Enable Notifications", isOn: Binding(
                            get: { viewModel.onboardingData.notificationsEnabled },
                            set: { viewModel.onboardingData.notificationsEnabled = $0 }
                        ))
                    }

                case .completion:
                    CompletionView(onFinish: onComplete)
                }
            }
        }
        .onChange(of: viewModel.isCompleted) {
            if viewModel.isCompleted {
                onComplete()
            }
        }
    }
}

#Preview {
    OnboardingView {
        // Handle completion
    }
}