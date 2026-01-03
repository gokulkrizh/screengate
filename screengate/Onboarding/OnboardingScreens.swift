import SwiftUI
import UserNotifications
import FamilyControls

// MARK: - Brain Diet Onboarding (New Streamlined Flow - 11 Screens)
// Screen 1: Welcome & Theme
// Screen 2: Daily Screen Time Estimate
// Screen 3: Identify Problem Habits
// Screen 4: Personal Goal Selection
// Screen 5: Quick Personal Survey
// Screen 6: Age & Occupation
// Screen 7: Screen Time Permission
// Screen 8: Personalized Insights
// Screen 9: Notifications & Reflections
// Screen 10: Completion

// MARK: - Modern Base Layout
struct ModernOnboardingContainer<Content: View>: View {
    let content: Content
    let action: () -> Void
    let actionLabel: String
    let showSecondaryAction: Bool
    let secondaryAction: (() -> Void)?
    let secondaryLabel: String
    let progress: (current: Int, total: Int)
    
    init(
        @ViewBuilder content: @escaping () -> Content,
        action: @escaping () -> Void,
        actionLabel: String,
        progress: (Int, Int) = (0, 0),
        showSecondaryAction: Bool = false,
        secondaryAction: (() -> Void)? = nil,
        secondaryLabel: String = ""
    ) {
        self.content = content()
        self.action = action
        self.actionLabel = actionLabel
        self.progress = progress
        self.showSecondaryAction = showSecondaryAction
        self.secondaryAction = secondaryAction
        self.secondaryLabel = secondaryLabel
    }
    
    var body: some View {
        ZStack {
            GradientAnimationBackground()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        content
                            .padding(.horizontal, 24)
                            .padding(.vertical, 32)
                        
                        Spacer(minLength: 48)
                    }
                }
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                VStack(spacing: 8) {
                    Button(action: action) {
                        Text(actionLabel)
                            .font(Font.custom("Manrope", size: 16).weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0, green: 1, blue: 0.39),
                                        Color(red: 0, green: 0.8, blue: 0.31)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: Color(red: 0, green: 1, blue: 0.39).opacity(0.3), radius: 12, x: 0, y: 8)
                    }
                    
                    if showSecondaryAction, let secondaryAction = secondaryAction {
                        Button(action: secondaryAction) {
                            Text(secondaryLabel)
                                .font(Font.custom("Manrope", size: 16).weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color(red: 0.09, green: 0.09, blue: 0.10).opacity(0.6))
                                .foregroundColor(Color(red: 0, green: 1, blue: 0.39))
                                .cornerRadius(16)
                        }
                    }
                    
                    if progress.total > 0 {
                        ProgressIndicator(current: progress.current, total: progress.total)
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.09, green: 0.09, blue: 0.10).opacity(0.7),
                            Color(red: 0.09, green: 0.09, blue: 0.10).opacity(0.5)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
        }
    }
}

// MARK: - Screen 1: Welcome & Theme
struct OnboardingScreen1: View {
    @ObservedObject var data: OnboardingData
    
    var body: some View {
        ModernOnboardingContainer(
            content: {
                VStack(spacing: 32) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.2, green: 1, blue: 0.5).opacity(0.3),
                                        Color(red: 0, green: 1, blue: 0.39).opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 160)
                        
                        VStack(spacing: 16) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 40, weight: .light))
                                .foregroundColor(Color(red: 0, green: 1, blue: 0.39))
                        }
                    }
                    
                    VStack(spacing: 16) {
                        Text("Welcome to Brain Diet")
                            .font(Font.custom("Manrope", size: 24).weight(.bold))
                            .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                        
                        VStack(spacing: 8) {
                            Text("Pause before you tap. Reclaim focus one mindful moment at a time.")
                                .font(Font.custom("Manrope", size: 14).weight(.regular))
                                .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.49))
                                .lineSpacing(1.5)
                        }
                    }
                }
            },
            action: {
                withAnimation {
                    data.nextScreen()
                }
            },
            actionLabel: "Let's Start",
            //progress: (1, 11)
        )
    }
}

// MARK: - Screen 2: Daily Screen Time Estimate
struct OnboardingScreen2: View {
    @ObservedObject var data: OnboardingData
    let screenTimeOptions = ["<1h", "1–3h", "3–5h", "5–7h", "7+h"]
    
    func isScreenTimeSelected(_ option: String) -> Bool {
        switch option {
        case "<1h": return data.estimatedScreenTime == 0.5
        case "1–3h": return data.estimatedScreenTime == 2.0
        case "3–5h": return data.estimatedScreenTime == 4.0
        case "5–7h": return data.estimatedScreenTime == 6.0
        case "7+h": return data.estimatedScreenTime == 8.0
        default: return false
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(spacing: 12) {
                    // Text("Let's understand your habits")
                    //     .font(.system(size: 16, weight: .semibold))
                    //     .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95)Secondary)
                    
                    Text("How much time do you usually spend on your phone each day?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                }
                
                VStack(spacing: 16) {
                    ForEach(0..<screenTimeOptions.count, id: \.self) { index in
                        if index % 2 == 0 {
                            HStack(spacing: 12) {
                                ForEach(0..<2, id: \.self) { col in
                                    let optionIndex = index + col
                                    if optionIndex < screenTimeOptions.count {
                                        let option = screenTimeOptions[optionIndex]
                                        let isSelected = isScreenTimeSelected(option)
                                        
                                        Button(action: {
                                            switch option {
                                            case "<1h":
                                                data.estimatedScreenTime = 0.5
                                            case "1–3h":
                                                data.estimatedScreenTime = 2.0
                                            case "3–5h":
                                                data.estimatedScreenTime = 4.0
                                            case "5–7h":
                                                data.estimatedScreenTime = 6.0
                                            case "7+h":
                                                data.estimatedScreenTime = 8.0
                                            default:
                                                data.estimatedScreenTime = 4.0
                                            }
                                            withAnimation {
                                                data.nextScreen()
                                            }
                                        }) {
                                            Text(option)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(isSelected ? Color(red: 0, green: 1, blue: 0.39) : .white)
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 54)
                                                .background(isSelected ? Color.white : Color.white.opacity(0.15))
                                                .cornerRadius(16)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(20)
        }
        .safeAreaInset(edge: .top) {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation {
                            data.previousScreen()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 44, height: 44)
                            //.background(.ultraThinMaterial)
                            .foregroundColor(Color(red: 0, green: 1, blue: 0.39))
                            .glassEffect()
                          //  .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    ProgressIndicator(current: 2, total: 11)
                }
                .padding(16)
            }
        }
    }
}

// MARK: - Screen 3: Identify Problem Habits
struct OnboardingScreen3: View {
    @ObservedObject var data: OnboardingData
    let problems = [
        ("📱", "Social Media"),
        ("💬", "Messaging"),
        ("🎮", "Games"),
        ("📰", "News"),
        ("🛍️", "Shopping"),
        ("🎯", "Other")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(spacing: 8) {
                    Text("What distracts you most?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                    
                    // Text("(Select all that apply)")
                    //     .font(.system(size: 14, weight: .regular))
                    //     .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95)Secondary)
                }
                
                VStack(spacing: 12) {
                    ForEach(0..<problems.count, id: \.self) { index in
                        if index % 2 == 0 {
                            HStack(spacing: 12) {
                                ForEach(0..<2, id: \.self) { col in
                                    let problemIndex = index + col
                                    if problemIndex < problems.count {
                                        let (emoji, title) = problems[problemIndex]
                                        let isSelected = data.selectedProblems.contains(title)
                                        
                                        Button(action: {
                                            if data.selectedProblems.contains(title) {
                                                data.selectedProblems.remove(title)
                                            } else {
                                                data.selectedProblems.insert(title)
                                            }
                                        }) {
                                            VStack(spacing: 8) {
                                                Text(emoji)
                                                    .font(.system(size: 24))
                                                
                                                Text(title)
                                                    .font(.system(size: 13, weight: .semibold))
                                                    .foregroundColor(isSelected ? Color(red: 0, green: 1, blue: 0.39) : .white)
                                                    .lineLimit(2)
                                                    .multilineTextAlignment(.center)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 100)
                                            .background(isSelected ? Color.white : Color.white.opacity(0.15))
                                            .cornerRadius(16)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(20)
        }
        .safeAreaInset(edge: .top) {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation {
                            data.previousScreen()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 44, height: 44)
                            //.background(.ultraThinMaterial)
                            .foregroundColor(Color(red: 0, green: 1, blue: 0.39))
                            .cornerRadius(12)
                            .glassEffect()
                    }
                    
                    Spacer()
                    
                    ProgressIndicator(current: 3, total: 11)
                }
                .padding(16)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                withAnimation {
                    data.nextScreen()
                }
            }) {
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        data.selectedProblems.isEmpty ?
                        Color.gray.opacity(0.5) :
                        Color(red: 0, green: 1, blue: 0.39)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(data.selectedProblems.isEmpty)
            .padding(20)
        }
    }
}

// MARK: - Screen 4: Personal Goal Selection
struct OnboardingScreen4: View {
    @ObservedObject var data: OnboardingData
    let goals = [
        ("🎯", "Focus"),
        ("😊", "Reduce Stress"),
        ("⏰", "Personal Time"),
        ("👥", "Relationships")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(spacing: 8) {
                    Text("What's your main goal with Brain Diet?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                }
                
                VStack(spacing: 12) {
                    ForEach(0..<goals.count, id: \.self) { index in
                        if index % 2 == 0 {
                            HStack(spacing: 12) {
                                ForEach(0..<2, id: \.self) { col in
                                    let goalIndex = index + col
                                    if goalIndex < goals.count {
                                        let (emoji, title) = goals[goalIndex]
                                        let isSelected = data.primaryGoal == title
                                        
                                        Button(action: {
                                            data.primaryGoal = title
                                            withAnimation {
                                                data.nextScreen()
                                            }
                                        }) {
                                            VStack(spacing: 8) {
                                                Text(emoji)
                                                    .font(.system(size: 28))
                                                
                                                Text(title)
                                                    .font(.system(size: 13, weight: .semibold))
                                                    .foregroundColor(isSelected ? Color(red: 0, green: 1, blue: 0.39) : .white)
                                                    .lineLimit(2)
                                                    .multilineTextAlignment(.center)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 110)
                                            .background(isSelected ? Color.white : Color.white.opacity(0.15))
                                            .cornerRadius(16)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(20)
        }
        .safeAreaInset(edge: .top) {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation {
                            data.previousScreen()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 44, height: 44)
                           // .background(.ultraThinMaterial)
                            .foregroundColor(Color(red: 0, green: 1, blue: 0.39))
                            .cornerRadius(12)
                            .glassEffect()
                    }
                    
                    Spacer()
                    
                    ProgressIndicator(current: 4, total: 11)
                }
                .padding(16)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                withAnimation {
                    data.nextScreen()
                }
            }) {
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color(red: 0, green: 1, blue: 0.39))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(20)
        }
    }
}

// MARK: - Screen 5: Quick Personal Survey
struct OnboardingScreen5: View {
    @ObservedObject var data: OnboardingData
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Quick Personal Survey")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                
                // Q1
                VStack(alignment: .leading, spacing: 12) {
                    Text("How often do you check your phone daily?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                    
                    HStack(spacing: 10) {
                        ForEach(["Few times", "Several", "Constantly"], id: \.self) { option in
                            let isSelected = data.phoneCheckFrequency == option
                            Button(action: { data.phoneCheckFrequency = option }) {
                                Text(option)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(isSelected ? Color(red: 0, green: 1, blue: 0.39) : .white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                                    .background(isSelected ? Color.white : Color.white.opacity(0.15))
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                
                // Q2
                VStack(alignment: .leading, spacing: 12) {
                    Text("Do notifications distract you?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                    
                    HStack(spacing: 10) {
                        ForEach(["Not really", "Occasionally", "Often"], id: \.self) { option in
                            let isSelected = data.notificationDistractionLevel == option
                            Button(action: { data.notificationDistractionLevel = option }) {
                                Text(option)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(isSelected ? Color(red: 0, green: 1, blue: 0.39) : .white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                                    .background(isSelected ? Color.white : Color.white.opacity(0.15))
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                
                // Q3
                VStack(alignment: .leading, spacing: 12) {
                    Text("Do you feel phone use affects your sleep?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                    
                    HStack(spacing: 10) {
                        ForEach(["No", "Sometimes", "Yes"], id: \.self) { option in
                            let isSelected = data.sleepAffected == option
                            Button(action: { data.sleepAffected = option }) {
                                Text(option)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(isSelected ? Color(red: 0, green: 1, blue: 0.39) : .white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                                    .background(isSelected ? Color.white : Color.white.opacity(0.15))
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                
                // Q4
                VStack(alignment: .leading, spacing: 12) {
                    Text("Do you get frustrated when you scroll too much?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                    
                    HStack(spacing: 10) {
                        ForEach(["Never", "Sometimes", "Often"], id: \.self) { option in
                            let isSelected = data.scrollFrustration == option
                            Button(action: { data.scrollFrustration = option }) {
                                Text(option)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(isSelected ? Color(red: 0, green: 1, blue: 0.39) : .white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                                    .background(isSelected ? Color.white : Color.white.opacity(0.15))
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                
                // Q5
                VStack(alignment: .leading, spacing: 12) {
                    Text("Which situations do you want Brain Diet to help most?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                    
                    HStack(spacing: 10) {
                        ForEach(["Work", "Study", "Bedtime"], id: \.self) { option in
                            let isSelected = data.situationHelp == option
                            Button(action: { data.situationHelp = option }) {
                                Text(option)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(isSelected ? Color(red: 0, green: 1, blue: 0.39) : .white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                                    .background(isSelected ? Color.white : Color.white.opacity(0.15))
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(20)
        }
        .safeAreaInset(edge: .top) {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation {
                            data.previousScreen()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 44, height: 44)
                            //.background(.ultraThinMaterial)
                            .foregroundColor(Color(red: 0, green: 1, blue: 0.39))
                            .cornerRadius(12)
                            .glassEffect()
                    }
                    
                    Spacer()
                    
                    ProgressIndicator(current: 5, total: 11)
                }
                .padding(16)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                withAnimation {
                    data.nextScreen()
                }
            }) {
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        (data.phoneCheckFrequency != nil && data.notificationDistractionLevel != nil &&
                         data.sleepAffected != nil && data.scrollFrustration != nil &&
                         data.situationHelp != nil) ? Color(red: 0, green: 1, blue: 0.39) : Color.gray.opacity(0.5)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(!(data.phoneCheckFrequency != nil && data.notificationDistractionLevel != nil &&
                       data.sleepAffected != nil && data.scrollFrustration != nil &&
                       data.situationHelp != nil))
            .padding(20)
        }
    }
}

// MARK: - Screen 6: Age & Occupation
struct OnboardingScreen6: View {
    @ObservedObject var data: OnboardingData
    
    let ageOptions = ["13-18", "19-25", "26-35", "36-45", "46-55", "55+"]
    let occupationOptions = [
        ("👨‍🎓", "Student"),
        ("💼", "Professional"),
        ("👨‍💼", "Manager"),
        ("👨‍🏫", "Educator"),
        ("🏠", "Home Maker"),
        ("🎯", "Other")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Tell us a bit about yourself")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                
                // Selected Summary
                // if data.age != nil || data.occupation != nil {
                //     VStack(spacing: 12) {
                //         if let age = data.age {
                //             HStack(spacing: 8) {
                //                 Image(systemName: "checkmark.circle.fill")
                //                     .foregroundColor(Color(red: 0, green: 1, blue: 0.39))
                //                 Text("Age: \(age)")
                //                     .font(.system(size: 14, weight: .semibold))
                //                     .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                //                 Spacer()
                //             }
                //         }
                        
                //         if let occupation = data.occupation {
                //             HStack(spacing: 8) {
                //                 Image(systemName: "checkmark.circle.fill")
                //                     .foregroundColor(Color(red: 0, green: 1, blue: 0.39))
                //                 Text("Occupation: \(occupation)")
                //                     .font(.system(size: 14, weight: .semibold))
                //                     .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                //                 Spacer()
                //             }
                //         }
                //     }
                //     .padding(12)
                //     .background(Color.white.opacity(0.08))
                //     .cornerRadius(12)
                // }
                
                // Age Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Age")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                    
                    VStack(spacing: 10) {
                        ForEach(0..<ageOptions.count, id: \.self) { index in
                            if index % 3 == 0 {
                                HStack(spacing: 10) {
                                    ForEach(0..<3, id: \.self) { col in
                                        let optionIndex = index + col
                                        if optionIndex < ageOptions.count {
                                            let option = ageOptions[optionIndex]
                                            let isSelected = data.age == option
                                            
                                            Button(action: { data.age = option }) {
                                                Text(option)
                                                    .font(.system(size: 13, weight: .semibold))
                                                    .foregroundColor(isSelected ? Color(red: 0, green: 1, blue: 0.39) : .white)
                                                    .frame(maxWidth: .infinity)
                                                    .frame(height: 44)
                                                    .background(isSelected ? Color.white : Color.white.opacity(0.15))
                                                    .cornerRadius(12)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Occupation Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Occupation")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                    
                    VStack(spacing: 10) {
                        ForEach(0..<occupationOptions.count, id: \.self) { index in
                            if index % 2 == 0 {
                                HStack(spacing: 10) {
                                    ForEach(0..<2, id: \.self) { col in
                                        let optionIndex = index + col
                                        if optionIndex < occupationOptions.count {
                                            let (emoji, title) = occupationOptions[optionIndex]
                                            let isSelected = data.occupation == title
                                            
                                            Button(action: { data.occupation = title }) {
                                                VStack(spacing: 6) {
                                                    Text(emoji)
                                                        .font(.system(size: 20))
                                                    
                                                    Text(title)
                                                        .font(.system(size: 12, weight: .semibold))
                                                        .foregroundColor(isSelected ? Color(red: 0, green: 1, blue: 0.39) : .white)
                                                        .lineLimit(2)
                                                        .multilineTextAlignment(.center)
                                                }
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 80)
                                                .background(isSelected ? Color.white : Color.white.opacity(0.15))
                                                .cornerRadius(12)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(20)
        }
        .safeAreaInset(edge: .top) {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation {
                            data.previousScreen()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial)
                            .foregroundColor(Color(red: 0, green: 1, blue: 0.39))
                            .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    ProgressIndicator(current: 6, total: 11)
                }
                .padding(16)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                withAnimation {
                    data.nextScreen()
                }
            }) {
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background((data.age != nil && data.occupation != nil) ? Color(red: 0, green: 1, blue: 0.39) : Color.gray.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(data.age == nil || data.occupation == nil)
            .padding(20)
        }
    }
}

// MARK: - Screen 7: Screen Time Permission
struct OnboardingScreen7: View {
    @ObservedObject var data: OnboardingData
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color(red: 0, green: 1, blue: 0.39))
                    
                    Text("Screen Time Permission")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                }
                
                Text("Brain Diet needs permission to track and guide your screen use.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        Text("1.")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(red: 0, green: 1, blue: 0.39))
                        Text("Tap 'Enable Access' below")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                    }
                    HStack(spacing: 12) {
                        Text("2.")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(red: 0, green: 1, blue: 0.39))
                        Text("iOS will show a permission request")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                    }
                    HStack(spacing: 12) {
                        Text("3.")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(red: 0, green: 1, blue: 0.39))
                        Text("Tap \"Allow\"")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                        Text("You're always in control. You can disable this in Settings anytime.")
                            .font(.system(size: 13))
                            .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                    }
                }
                
                Spacer()
            }
            .padding(20)
        }
        .safeAreaInset(edge: .top) {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation {
                            data.previousScreen()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 44, height: 44)
                           // .background(.ultraThinMaterial)
                            .foregroundColor(Color(red: 0, green: 1, blue: 0.39))
                            .cornerRadius(12)
                            .glassEffect()
                    }
                    
                    Spacer()
                    
                    ProgressIndicator(current: 7, total: 11)
                }
                .padding(16)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                Button(action: {
                    requestFamilyControlsPermission {
                        data.screenTimePermissionRequested = true
                        withAnimation {
                            data.nextScreen()
                        }
                    }
                }) {
                    Text("Enable Access")
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(Color(red: 0, green: 1, blue: 0.39))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    withAnimation {
                        data.nextScreen()
                    }
                }) {
                    Text("Skip for now")
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(Color(red: 0, green: 1, blue: 0.39).opacity(0.1))
                        .foregroundColor(Color(red: 0, green: 1, blue: 0.39))
                        .cornerRadius(12)
                }
            }
            .padding(20)
        }
    }
}

// MARK: - Screen 8: Personalized Insights
struct OnboardingScreen8: View {
    @ObservedObject var data: OnboardingData
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Your Personalized Projection")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                
                Text("Time lost vs. time you can reclaim")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                
                // Animated stats
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Text("⏰")
                                .font(.system(size: 20))
                            Text("Time Lost This Week")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                        }
                        Text("\(Int(data.estimatedScreenTime * 7))+ hours")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(red: 0, green: 1, blue: 0.39))
                    }
                    .padding(16)
                    .background(Color(red: 0.09, green: 0.09, blue: 0.10))
                    .cornerRadius(12)
                    
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Text("🎯")
                                .font(.system(size: 20))
                            Text("Time You Can Reclaim")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                        }
                        Text("\(Int(data.estimatedScreenTime * 3.5))+ hours/week")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(red: 0, green: 1, blue: 0.39))
                    }
                    .padding(16)
                    .background(Color(red: 0.09, green: 0.09, blue: 0.10))
                    .cornerRadius(12)
                }
                
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Text("✨")
                            .font(.system(size: 16))
                        Text("With Brain Diet, you'll unlock better focus, sleep, and presence")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                    }
                }
                
                Spacer()
            }
            .padding(20)
        }
        .safeAreaInset(edge: .top) {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation {
                            data.previousScreen()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 44, height: 44)
                           // .background(.ultraThinMaterial)
                            .foregroundColor(Color(red: 0, green: 1, blue: 0.39))
                            .cornerRadius(12)
                            .glassEffect()
                    }
                    
                    Spacer()
                    
                    ProgressIndicator(current: 8, total: 11)
                }
                .padding(16)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                withAnimation {
                    data.nextScreen()
                }
            }) {
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color(red: 0, green: 1, blue: 0.39))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(20)
        }
    }
}

// MARK: - Screen 9: Notifications & Reflections
struct OnboardingScreen9: View {
    @ObservedObject var data: OnboardingData
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color(red: 0, green: 1, blue: 0.39))
                    
                    Text("Daily Reflections")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                }
                
                Text("Enable daily & weekly reflection nudges.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                
                VStack(alignment: .leading, spacing: 16) {
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Text("📊")
                                .font(.system(size: 18))
                            Text("Daily Summary")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                        }
                        Text("See your daily screen time & wins")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                    }
                    .padding(12)
                    .background(Color(red: 0.09, green: 0.09, blue: 0.10))
                    .cornerRadius(8)
                    
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Text("📈")
                                .font(.system(size: 18))
                            Text("Weekly Insights")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                        }
                        Text("Trend analysis & actionable tips")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                    }
                    .padding(12)
                    .background(Color(red: 0.09, green: 0.09, blue: 0.10))
                    .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("No spam. No guilt trips. Just helpful guidance.")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                    
                    Text("You can customize in Settings anytime.")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                }
                
                Spacer()
            }
            .padding(20)
        }
        .safeAreaInset(edge: .top) {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation {
                            data.previousScreen()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 44, height: 44)
                            //.background(.ultraThinMaterial)
                            .foregroundColor(Color(red: 0, green: 1, blue: 0.39))
                            .cornerRadius(12)
                            .glassEffect()
                    }
                    
                    Spacer()
                    
                    ProgressIndicator(current: 9, total: 11)
                }
                .padding(16)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                Button(action: {
                    requestNotificationPermission {
                        data.notificationsEnabled = true
                        withAnimation {
                            data.nextScreen()
                        }
                    }
                }) {
                    Text("Enable Notifications")
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(Color(red: 0, green: 1, blue: 0.39))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    withAnimation {
                        data.nextScreen()
                    }
                }) {
                    Text("Maybe later")
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(Color(red: 0, green: 1, blue: 0.39).opacity(0.1))
                        .foregroundColor(Color(red: 0, green: 1, blue: 0.39))
                        .cornerRadius(12)
                }
            }
            .padding(20)
        }
    }
}

// MARK: - Screen 10: Completion
struct OnboardingScreen10: View {
    @ObservedObject var data: OnboardingData
    
    var body: some View {
        ZStack {
            GradientAnimationBackground()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 32) {
                        Spacer(minLength: 40)
                        
                        VStack(spacing: 24) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 64))
                                .foregroundColor(Color(red: 0, green: 1, blue: 0.39))
                            
                            VStack(spacing: 12) {
                                Text("You're all set!")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                                
                                Text("Tap less, pause more.")
                                    .font(.system(size: 18, weight: .regular))
                                    .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                VStack(spacing: 8) {
                    Button(action: {
                        withAnimation {
                            data.completeOnboarding()
                        }
                    }) {
                        Text("Go to Dashboard")
                            .font(Font.custom("Manrope", size: 16).weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0, green: 1, blue: 0.39),
                                        Color(red: 0, green: 1, blue: 0.39)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: Color(red: 0, green: 1, blue: 0.39).opacity(0.3), radius: 12, x: 0, y: 8)
                    }
                    
                    ProgressIndicator(current: 11, total: 11)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.09, green: 0.09, blue: 0.10).opacity(0.7),
                            Color(red: 0.09, green: 0.09, blue: 0.10).opacity(0.5)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
        }
    }
}

// MARK: - Helper Components
struct ProgressIndicator: View {
    let current: Int
    let total: Int
    
    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.4))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0, green: 1, blue: 0.39),
                                    Color(red: 0, green: 1, blue: 0.39)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(current) / CGFloat(total))
                }
            }
            .frame(height: 6)
            
            HStack {
                Text("Step \(current) of \(total)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                Spacer()
            }
        }
    }
}

// MARK: - Permission Request Functions
func requestFamilyControlsPermission(completion: @escaping () -> Void) {
    let manager = DeviceActivityManager()
    Task {
        do {
            try await manager.requestFamilyControlAuthorization()
            DispatchQueue.main.async {
                print("Family Controls permission authorized")
                completion()
            }
        } catch {
            print("Family Controls permission error: \(error)")
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}

func requestNotificationPermission(completion: @escaping () -> Void) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        DispatchQueue.main.async {
            if granted {
                print("Notification permission granted")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else if let error = error {
                print("Notification permission error: \(error)")
            } else {
                print("Notification permission denied")
            }
            completion()
        }
    }
}
