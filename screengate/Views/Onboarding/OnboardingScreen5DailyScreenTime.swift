import SwiftUI

/// OnboardingScreen5DailyScreenTime - Daily Screen Time Usage Selection
/// User selects how much time they spend on screens daily
struct OnboardingScreen5DailyScreenTime: View {
    @ObservedObject var data: OnboardingData
    @State private var selectedOption: Int = 2 // Pre-select "I'm glued to it"
    
    private let appTheme = AppTheme.shared
    
    let options: [(title: String, description: String)] = [
        ("I'm a casual user", "Less than 2 hours. Mostly just checking messages occasionally."),
        ("I'm moderately active", "2 to 4 hours. Social media, news, and some videos."),
        ("I'm glued to it", "4 to 6 hours. It's my primary source of entertainment and work."),
        ("I live online", "6+ hours. I feel lost without my phone in my hand.")
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.06, green: 0.13, blue: 0.09)
                .ignoresSafeArea()
            
            // Decorative gradient blobs
            VStack {
                HStack {
                    VStack(spacing: 0) {
                        Circle()
                            .fill(appTheme.colors.primary.opacity(0.05))
                            .blur(radius: 120)
                            .frame(width: 320, height: 320)
                        Spacer()
                    }
                    .offset(x: 120, y: -100)
                    
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Circle()
                            .fill(appTheme.colors.primary.opacity(0.08))
                            .blur(radius: 100)
                            .frame(width: 280, height: 280)
                    }
                    .offset(x: 80, y: 80)
                }
            }
            .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                // Header with back button and centered progress
                ZStack {
                    HStack {
                        BackButton {
                            data.currentScreen = 4
                        }
                        
                        Spacer()
                    }   
                    
                    ProgressIndicatorHeader(currentStep: 4, totalSteps: 10)
                }
                
                // Title and subtitle
                VStack(alignment: .leading, spacing: 8) {
                    Text("Daily Screen Time")
                        .font(appTheme.fonts.displaySmall)
                        .fontWeight(.bold)
                        .foregroundColor(appTheme.colors.text)
                    
                    Text("Honestly, how much time do you spend staring at screens each day?")
                        .font(appTheme.fonts.bodyLarge)
                        .foregroundColor(appTheme.colors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, appTheme.spacing.large)
                .padding(.bottom, appTheme.spacing.large)
                
                // Scrollable options
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(0..<options.count, id: \.self) { index in
                            ScreenTimeOptionCard(
                                title: options[index].title,
                                description: options[index].description,
                                isSelected: selectedOption == index
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedOption = index
                                }
                            }
                        }
                    }
                    .padding(.horizontal, appTheme.spacing.large)
                    .padding(.bottom, 140)
                }
                
                Spacer()
            }
            .zIndex(10)
            
            // Bottom button
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color(red: 0.06, green: 0.13, blue: 0.09),
                            Color(red: 0.06, green: 0.13, blue: 0.09)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 60)
                    
                    VStack(spacing: appTheme.spacing.medium) {
                        PrimaryButton(
                            title: "Continue",
                            icon: nil
                        ) {
                            data.currentScreen = 6
                        }
                    }
                    .padding(.horizontal, appTheme.spacing.large)
                    .padding(.bottom, appTheme.spacing.large)
                    .background(Color(red: 0.06, green: 0.13, blue: 0.09))
                }
                .zIndex(20)
            }
            .zIndex(20)
            .ignoresSafeArea(.keyboard)
        }
    }
}

#Preview {
    OnboardingScreen5DailyScreenTime(data: OnboardingData())
}
