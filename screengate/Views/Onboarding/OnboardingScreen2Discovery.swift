import SwiftUI

/// OnboardingScreen2Discovery - Problem Discovery Survey
/// Allows user to select their main reason for joining
struct OnboardingScreen2Discovery: View {
    @ObservedObject var data: OnboardingData
    @State private var selectedOption: Int = 0
    
    private let appTheme = AppTheme.shared
    
    let options: [(icon: String, color: Color, title: String, subtitle: String)] = [
        ("smartphone", Color.blue, "Social Media Detox", "I scroll too much on apps"),
        ("briefcase", Color.orange, "Focus & Productivity", "I can't focus on work/study"),
        ("moon.stars", Color.purple, "Better Sleep", "My sleep quality is suffering"),
        ("brain", Color.cyan, "Mental Clarity", "I want to clear my mind"),
        ("person.2", Color.pink, "Child's Screen Time", "Manage my child's usage")
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
                            data.currentScreen = 1
                        }
                        Spacer()
                    }
                    
                    ProgressIndicatorHeader(currentStep: 1, totalSteps: 10)
                }
                .padding(.horizontal, appTheme.spacing.large)
                
                // Badge and heading (fixed, not scrollable)
                VStack(alignment: .leading, spacing: appTheme.spacing.medium) {
                    //Badge(label: "Discovery")
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Let's start your journey.")
                            .font(appTheme.fonts.displaySmall)
                            .fontWeight(.bold)
                            .foregroundColor(appTheme.colors.text)
                        
                        Text("What is your main reason for joining Screendiet?")
                            .font(appTheme.fonts.bodyLarge)
                            .foregroundColor(appTheme.colors.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, appTheme.spacing.large)
                .padding(.vertical, appTheme.spacing.large)
                
                // Scrollable options only
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(0..<options.count, id: \.self) { index in
                            RadioOptionCard(
                                icon: options[index].icon,
                                iconColor: options[index].color,
                                iconBackgroundColor: options[index].color,
                                title: options[index].title,
                                subtitle: options[index].subtitle,
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
                    .padding(.top, appTheme.spacing.small)
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
                    .frame(height: 20)
                    
                    VStack(spacing: appTheme.spacing.medium) {
                        PrimaryButton(
                            title: "Continue",
                            icon: "arrow.right"
                        ) {
                            data.currentScreen = 3
                        }
                    }
                    .padding(.horizontal, appTheme.spacing.large)
                   // .padding(.bottom, appTheme.spacing.large)
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
    OnboardingScreen2Discovery(data: OnboardingData())
}
