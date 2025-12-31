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
    @Environment(\.theme) var theme
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
                            .padding(.horizontal, theme.spacing.large)
                            .padding(.vertical, theme.spacing.extraLarge)
                        
                        Spacer(minLength: theme.spacing.huge)
                    }
                }
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                VStack(spacing: theme.spacing.small) {
                    Button(action: action) {
                        Text(actionLabel)
                            .font(theme.fonts.titleMedium)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        theme.colors.primary,
                                        theme.colors.primaryDark
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(theme.spacing.cornerRadiusLarge)
                            .shadow(color: theme.colors.primary.opacity(0.3), radius: 12, x: 0, y: 8)
                    }
                    
                    if showSecondaryAction, let secondaryAction = secondaryAction {
                        Button(action: secondaryAction) {
                            Text(secondaryLabel)
                                .font(theme.fonts.titleMedium)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(theme.colors.surface.opacity(0.6))
                                .foregroundColor(theme.colors.primary)
                                .cornerRadius(theme.spacing.cornerRadiusLarge)
                        }
                    }
                    
                    if progress.total > 0 {
                        ProgressIndicator(current: progress.current, total: progress.total)
                            .padding(.top, theme.spacing.small)
                    }
                }
                .padding(.horizontal, theme.spacing.large)
                .padding(.vertical, theme.spacing.medium)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            theme.colors.surface.opacity(0.7),
                            theme.colors.surface.opacity(0.5)
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
    @Environment(\.theme) var theme
    @ObservedObject var data: OnboardingData
    
    var body: some View {
        ModernOnboardingContainer(
            content: {
                VStack(spacing: theme.spacing.extraLarge) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        theme.colors.primaryLight.opacity(0.3),
                                        theme.colors.primary.opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 160)
                        
                        VStack(spacing: theme.spacing.medium) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 40, weight: .light))
                                .foregroundColor(theme.colors.primary)
                        }
                    }
                    
                    VStack(spacing: theme.spacing.medium) {
                        Text("Welcome to Brain Diet")
                            .font(theme.fonts.headlineSmall)
                            .foregroundColor(theme.colors.text)
                        
                        VStack(spacing: theme.spacing.small) {
                            Text("Pause before you tap. Reclaim focus one mindful moment at a time.")
                                .font(theme.fonts.bodyMedium)
                                .foregroundColor(theme.colors.textSecondary)
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
    @Environment(\.theme) var theme
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
                    //     .foregroundColor(theme.colors.textSecondary)
                    
                    Text("How much time do you usually spend on your phone each day?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(theme.colors.text)
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
                                                .foregroundColor(isSelected ? theme.colors.primary : .white)
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
                            .foregroundColor(theme.colors.primary)
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
    @Environment(\.theme) var theme
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
                        .foregroundColor(theme.colors.text)
                    
                    // Text("(Select all that apply)")
                    //     .font(.system(size: 14, weight: .regular))
                    //     .foregroundColor(theme.colors.textSecondary)
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
                                                    .foregroundColor(isSelected ? theme.colors.primary : .white)
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
                            .foregroundColor(theme.colors.primary)
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
                        theme.colors.primary
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
    @Environment(\.theme) var theme
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
                        .foregroundColor(theme.colors.text)
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
                                                    .foregroundColor(isSelected ? theme.colors.primary : .white)
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
                            .foregroundColor(theme.colors.primary)
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
                    .background(theme.colors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(20)
        }
    }
}

// MARK: - Screen 5: Quick Personal Survey
struct OnboardingScreen5: View {
    @Environment(\.theme) var theme
    @ObservedObject var data: OnboardingData
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Quick Personal Survey")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(theme.colors.text)
                
                // Q1
                VStack(alignment: .leading, spacing: 12) {
                    Text("How often do you check your phone daily?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.colors.text)
                    
                    HStack(spacing: 10) {
                        ForEach(["Few times", "Several", "Constantly"], id: \.self) { option in
                            let isSelected = data.phoneCheckFrequency == option
                            Button(action: { data.phoneCheckFrequency = option }) {
                                Text(option)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(isSelected ? theme.colors.primary : .white)
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
                        .foregroundColor(theme.colors.text)
                    
                    HStack(spacing: 10) {
                        ForEach(["Not really", "Occasionally", "Often"], id: \.self) { option in
                            let isSelected = data.notificationDistractionLevel == option
                            Button(action: { data.notificationDistractionLevel = option }) {
                                Text(option)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(isSelected ? theme.colors.primary : .white)
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
                        .foregroundColor(theme.colors.text)
                    
                    HStack(spacing: 10) {
                        ForEach(["No", "Sometimes", "Yes"], id: \.self) { option in
                            let isSelected = data.sleepAffected == option
                            Button(action: { data.sleepAffected = option }) {
                                Text(option)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(isSelected ? theme.colors.primary : .white)
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
                        .foregroundColor(theme.colors.text)
                    
                    HStack(spacing: 10) {
                        ForEach(["Never", "Sometimes", "Often"], id: \.self) { option in
                            let isSelected = data.scrollFrustration == option
                            Button(action: { data.scrollFrustration = option }) {
                                Text(option)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(isSelected ? theme.colors.primary : .white)
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
                        .foregroundColor(theme.colors.text)
                    
                    HStack(spacing: 10) {
                        ForEach(["Work", "Study", "Bedtime"], id: \.self) { option in
                            let isSelected = data.situationHelp == option
                            Button(action: { data.situationHelp = option }) {
                                Text(option)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(isSelected ? theme.colors.primary : .white)
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
                            .foregroundColor(theme.colors.primary)
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
                         data.situationHelp != nil) ? theme.colors.primary : Color.gray.opacity(0.5)
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
    @Environment(\.theme) var theme
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
                    .foregroundColor(theme.colors.text)
                
                // Selected Summary
                // if data.age != nil || data.occupation != nil {
                //     VStack(spacing: 12) {
                //         if let age = data.age {
                //             HStack(spacing: 8) {
                //                 Image(systemName: "checkmark.circle.fill")
                //                     .foregroundColor(theme.colors.primary)
                //                 Text("Age: \(age)")
                //                     .font(.system(size: 14, weight: .semibold))
                //                     .foregroundColor(theme.colors.text)
                //                 Spacer()
                //             }
                //         }
                        
                //         if let occupation = data.occupation {
                //             HStack(spacing: 8) {
                //                 Image(systemName: "checkmark.circle.fill")
                //                     .foregroundColor(theme.colors.primary)
                //                 Text("Occupation: \(occupation)")
                //                     .font(.system(size: 14, weight: .semibold))
                //                     .foregroundColor(theme.colors.text)
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
                        .foregroundColor(theme.colors.text)
                    
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
                                                    .foregroundColor(isSelected ? theme.colors.primary : .white)
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
                        .foregroundColor(theme.colors.text)
                    
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
                                                        .foregroundColor(isSelected ? theme.colors.primary : .white)
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
                            .foregroundColor(theme.colors.primary)
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
                    .background((data.age != nil && data.occupation != nil) ? theme.colors.primary : Color.gray.opacity(0.5))
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
    @Environment(\.theme) var theme
    @ObservedObject var data: OnboardingData
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 48))
                        .foregroundColor(theme.colors.primary)
                    
                    Text("Screen Time Permission")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(theme.colors.text)
                }
                
                Text("Brain Diet needs permission to track and guide your screen use.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(theme.colors.textSecondary)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        Text("1.")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(theme.colors.primary)
                        Text("Tap 'Enable Access' below")
                            .font(.system(size: 14))
                            .foregroundColor(theme.colors.textSecondary)
                    }
                    HStack(spacing: 12) {
                        Text("2.")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(theme.colors.primary)
                        Text("iOS will show a permission request")
                            .font(.system(size: 14))
                            .foregroundColor(theme.colors.textSecondary)
                    }
                    HStack(spacing: 12) {
                        Text("3.")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(theme.colors.primary)
                        Text("Tap \"Allow\"")
                            .font(.system(size: 14))
                            .foregroundColor(theme.colors.textSecondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                        Text("You're always in control. You can disable this in Settings anytime.")
                            .font(.system(size: 13))
                            .foregroundColor(theme.colors.textSecondary)
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
                            .foregroundColor(theme.colors.primary)
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
                        .background(theme.colors.primary)
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
                        .background(theme.colors.primary.opacity(0.1))
                        .foregroundColor(theme.colors.primary)
                        .cornerRadius(12)
                }
            }
            .padding(20)
        }
    }
}

// MARK: - Screen 8: Personalized Insights
struct OnboardingScreen8: View {
    @Environment(\.theme) var theme
    @ObservedObject var data: OnboardingData
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Your Personalized Projection")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(theme.colors.text)
                
                Text("Time lost vs. time you can reclaim")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(theme.colors.textSecondary)
                
                // Animated stats
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Text("⏰")
                                .font(.system(size: 20))
                            Text("Time Lost This Week")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(theme.colors.textSecondary)
                        }
                        Text("\(Int(data.estimatedScreenTime * 7))+ hours")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(theme.colors.primary)
                    }
                    .padding(16)
                    .background(theme.colors.surface)
                    .cornerRadius(12)
                    
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Text("🎯")
                                .font(.system(size: 20))
                            Text("Time You Can Reclaim")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(theme.colors.textSecondary)
                        }
                        Text("\(Int(data.estimatedScreenTime * 3.5))+ hours/week")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(theme.colors.primary)
                    }
                    .padding(16)
                    .background(theme.colors.surface)
                    .cornerRadius(12)
                }
                
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Text("✨")
                            .font(.system(size: 16))
                        Text("With Brain Diet, you'll unlock better focus, sleep, and presence")
                            .font(.system(size: 14))
                            .foregroundColor(theme.colors.textSecondary)
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
                            .foregroundColor(theme.colors.primary)
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
                    .background(theme.colors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(20)
        }
    }
}

// MARK: - Screen 9: Notifications & Reflections
struct OnboardingScreen9: View {
    @Environment(\.theme) var theme
    @ObservedObject var data: OnboardingData
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 48))
                        .foregroundColor(theme.colors.primary)
                    
                    Text("Daily Reflections")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(theme.colors.text)
                }
                
                Text("Enable daily & weekly reflection nudges.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(theme.colors.textSecondary)
                
                VStack(alignment: .leading, spacing: 16) {
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Text("📊")
                                .font(.system(size: 18))
                            Text("Daily Summary")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(theme.colors.text)
                        }
                        Text("See your daily screen time & wins")
                            .font(.system(size: 12))
                            .foregroundColor(theme.colors.textSecondary)
                    }
                    .padding(12)
                    .background(theme.colors.surface)
                    .cornerRadius(8)
                    
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Text("📈")
                                .font(.system(size: 18))
                            Text("Weekly Insights")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(theme.colors.text)
                        }
                        Text("Trend analysis & actionable tips")
                            .font(.system(size: 12))
                            .foregroundColor(theme.colors.textSecondary)
                    }
                    .padding(12)
                    .background(theme.colors.surface)
                    .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("No spam. No guilt trips. Just helpful guidance.")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.colors.textSecondary)
                    
                    Text("You can customize in Settings anytime.")
                        .font(.system(size: 13))
                        .foregroundColor(theme.colors.textSecondary)
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
                            .foregroundColor(theme.colors.primary)
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
                        .background(theme.colors.primary)
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
                        .background(theme.colors.primary.opacity(0.1))
                        .foregroundColor(theme.colors.primary)
                        .cornerRadius(12)
                }
            }
            .padding(20)
        }
    }
}

// MARK: - Screen 10: Completion
struct OnboardingScreen10: View {
    @Environment(\.theme) var theme
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
                                .foregroundColor(theme.colors.primary)
                            
                            VStack(spacing: 12) {
                                Text("You're all set!")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(theme.colors.text)
                                
                                Text("Tap less, pause more.")
                                    .font(.system(size: 18, weight: .regular))
                                    .foregroundColor(theme.colors.textSecondary)
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, theme.spacing.large)
                }
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                VStack(spacing: theme.spacing.small) {
                    Button(action: {
                        withAnimation {
                            data.completeOnboarding()
                        }
                    }) {
                        Text("Go to Dashboard")
                            .font(theme.fonts.titleMedium)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        theme.colors.primary,
                                        theme.colors.primaryDark
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(theme.spacing.cornerRadiusLarge)
                            .shadow(color: theme.colors.primary.opacity(0.3), radius: 12, x: 0, y: 8)
                    }
                    
                    ProgressIndicator(current: 11, total: 11)
                        .padding(.top, theme.spacing.small)
                }
                .padding(.horizontal, theme.spacing.large)
                .padding(.vertical, theme.spacing.medium)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            theme.colors.surface.opacity(0.7),
                            theme.colors.surface.opacity(0.5)
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
    @Environment(\.theme) var theme
    
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
                                    theme.colors.primary,
                                    theme.colors.primaryDark
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
                    .foregroundColor(theme.colors.textSecondary)
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
