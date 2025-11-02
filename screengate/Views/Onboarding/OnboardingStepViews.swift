//
//  OnboardingStepViews.swift
//  screengate
//
//  Created by gokul on 01/11/25.
//

import SwiftUI

// MARK: - Welcome View
struct WelcomeOnboardingView: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "door.left.right.open")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            VStack(spacing: 16) {
                Text("Welcome to ScreenGate")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Your personal companion for mindful phone usage and digital wellbeing")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

            Button("Get Started") {
                onNext()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Daily Screen Time View
struct DailyScreenTimeView: View {
    @Binding var selectedOption: ScreenTimeOption?
    let onNext: () -> Void

    var body: some View {
        OnboardingQuestionView(
            title: "Daily Screen Time Estimate",
            question: "How much time do you usually spend on your phone each day?",
            canGoNext: selectedOption != nil,
            onNext: onNext
        ) {
            VStack(spacing: 12) {
                ForEach(ScreenTimeOption.allCases, id: \.self) { option in
                    SelectionButton(
                        title: option.rawValue,
                        isSelected: selectedOption == option
                    ) {
                        selectedOption = option
                    }
                }
            }
        }
    }
}

// MARK: - Problem Habits View
struct ProblemHabitsView: View {
    @Binding var selectedHabits: Set<ProblemHabit>
    let onNext: () -> Void

    var body: some View {
        OnboardingQuestionView(
            title: "Identify Problem Habits",
            question: "What distracts you most?",
            canGoNext: !selectedHabits.isEmpty,
            onNext: onNext
        ) {
            VStack(spacing: 12) {
                ForEach(ProblemHabit.allCases, id: \.self) { habit in
                    SelectionButton(
                        title: habit.rawValue,
                        isSelected: selectedHabits.contains(habit)
                    ) {
                        if selectedHabits.contains(habit) {
                            selectedHabits.remove(habit)
                        } else {
                            selectedHabits.insert(habit)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Personal Goal View
struct PersonalGoalView: View {
    @Binding var selectedGoal: PersonalGoal?
    let onNext: () -> Void

    var body: some View {
        OnboardingQuestionView(
            title: "Personal Goal Selection",
            question: "What's your main goal with ScreenGate?",
            canGoNext: selectedGoal != nil,
            onNext: onNext
        ) {
            VStack(spacing: 12) {
                ForEach(PersonalGoal.allCases, id: \.self) { goal in
                    SelectionButton(
                        title: goal.rawValue,
                        isSelected: selectedGoal == goal
                    ) {
                        selectedGoal = goal
                    }
                }
            }
        }
    }
}

// MARK: - Survey Question View
struct SurveyQuestionView: View {
    let step: OnboardingStep
    let question: String
    let options: [String]
    @Binding var selectedAnswer: String?
    let onNext: () -> Void

    var body: some View {
        OnboardingQuestionView(
            title: step.title,
            question: question,
            canGoNext: selectedAnswer != nil,
            onNext: onNext
        ) {
            VStack(spacing: 12) {
                ForEach(options, id: \.self) { option in
                    SelectionButton(
                        title: option,
                        isSelected: selectedAnswer == option
                    ) {
                        selectedAnswer = option
                    }
                }
            }
        }
    }
}

// MARK: - Age & Occupation View
struct AgeAndOccupationView: View {
    @Binding var age: String
    @Binding var occupation: String
    let onNext: () -> Void

    private var isValid: Bool {
        guard let ageNum = Int(age), ageNum > 0, ageNum <= 120 else { return false }
        return !occupation.isEmpty
    }

    var body: some View {
        OnboardingQuestionView(
            title: "About You",
            question: "Tell us a little about yourself",
            canGoNext: isValid,
            onNext: onNext
        ) {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Age")
                        .font(.headline)
                    TextField("Enter your age", text: $age)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Occupation")
                        .font(.headline)
                    TextField("Enter your occupation", text: $occupation)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
        }
    }
}

// MARK: - Screen Time Permission View
struct ScreenTimePermissionView: View {
    let onNext: () -> Void

    @StateObject private var screenTimeService = ScreenTimeService.shared
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 24) {
            // Title
            VStack(spacing: 16) {
                Text("Screen Time Access")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("We need access to your screen time data to provide personalized insights")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("ScreenGate uses Screen Time API to:")
                        .font(.headline)
                        .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: 12) {
                        PermissionRow(icon: "clock", text: "Track app usage patterns")
                        PermissionRow(icon: "chart.pie", text: "Provide personalized insights")
                        PermissionRow(icon: "bell.slash", text: "Enable mindful interruptions")
                        PermissionRow(icon: "calendar", text: "Set up scheduled focus time")
                    }

                    Button("Grant Screen Time Access") {
                        requestScreenTimeAccess()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(isLoading)
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .alert("Screen Time Access", isPresented: $showingAlert) {
            Button("OK") {
                if screenTimeService.isAuthorized {
                    onNext()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }

    private func requestScreenTimeAccess() {
        isLoading = true

        Task {
            do {
                try await screenTimeService.requestAuthorization()
                await MainActor.run {
                    isLoading = false
                    if screenTimeService.isAuthorized {
                        alertMessage = "Screen Time access granted successfully!"
                        showingAlert = true
                    } else {
                        alertMessage = "Screen Time access was denied. You can enable it later in Settings."
                        showingAlert = true
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = "Failed to request Screen Time access: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
}

// MARK: - Personalized Projection View
struct PersonalizedProjectionView: View {
    let onboardingData: OnboardingData
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Title
            VStack(spacing: 16) {
                Text("Your Personal Projection")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            }

            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 60))
                        .foregroundColor(.green)

                    VStack(spacing: 16) {
                        Text("Based on your usage patterns")
                            .font(.headline)

                        ProjectionCard(
                            title: "Time Lost Weekly",
                            value: "12.5 hours",
                            subtitle: "Across distracting apps"
                        )

                        ProjectionCard(
                            title: "Time You Can Reclaim",
                            value: "8.3 hours",
                            subtitle: "With mindful usage"
                        )

                        Text("Start your journey to reclaim your time and focus")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    Button("Continue") {
                        onNext()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }
}

// MARK: - Completion View
struct CompletionView: View {
    let onFinish: () -> Void

    @StateObject private var screenTimeService = ScreenTimeService.shared
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            VStack(spacing: 16) {
                Text("You're All Set!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Your personalized ScreenGate experience is ready")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 16) {
                if !screenTimeService.isAuthorized {
                    Text("⚠️ Screen Time Access Required")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .multilineTextAlignment(.center)

                    Button("Grant Screen Time Access") {
                        requestScreenTimeAccess()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }

                Button("Start Using ScreenGate") {
                    if screenTimeService.isAuthorized {
                        onFinish()
                    } else {
                        alertMessage = "Please grant Screen Time access to use ScreenGate's full features."
                        showingAlert = true
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isLoading && !screenTimeService.isAuthorized)
            }
            .padding(.horizontal)
        }
        .padding()
        .alert("Screen Time Access", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            // Check authorization status when view appears
            screenTimeService.checkAuthorizationStatus()
        }
    }

    private func requestScreenTimeAccess() {
        isLoading = true

        Task {
            do {
                try await screenTimeService.requestAuthorization()
                await MainActor.run {
                    isLoading = false
                    if screenTimeService.isAuthorized {
                        alertMessage = "Screen Time access granted successfully!"
                        showingAlert = true
                    } else {
                        alertMessage = "Screen Time access was denied. You can enable it later in Settings."
                        showingAlert = true
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = "Failed to request Screen Time access: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
}