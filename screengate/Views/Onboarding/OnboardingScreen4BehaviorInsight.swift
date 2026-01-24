import SwiftUI

/// OnboardingScreen4BehaviorInsight - App Category Selection
/// User selects which app categories steal most of their time
struct OnboardingScreen4BehaviorInsight: View {
    @ObservedObject var data: OnboardingData
    @State private var selectedCategories: Set<Int> = [] // Pre-select Social & News
    
    private let appTheme = AppTheme.shared
    
    let categories: [(icon: String, label: String)] = [
        ("bubble.right", "Social"),
        ("play.circle", "Entertainment"),
        ("gamecontroller", "Games"),
        ("newspaper", "News & Reading"),
        ("bag", "Shopping"),
        ("heart", "Dating"),
        ("briefcase", "Productivity"),
        ("fitness.center", "Health")
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
                            data.currentScreen = 3
                        }
                        Spacer()
                    }
                    
                    ProgressIndicatorHeader(currentStep: 3, totalSteps: 10)
                }
                .padding(.horizontal, appTheme.spacing.large)
                .padding(.bottom, appTheme.spacing.medium)
                
                // Title and subtitle
                VStack(alignment: .leading, spacing: appTheme.spacing.medium) {
                    HStack(spacing: 0) {
                        Text("Which app categories ")
                            .foregroundColor(appTheme.colors.text)
                        + Text("steal most")
                            .foregroundColor(appTheme.colors.primary)
                        + Text(" of your time?")
                            .foregroundColor(appTheme.colors.text)
                    }
                    .font(appTheme.fonts.displaySmall)
                    .fontWeight(.bold)
                    
                    Text("Select all that apply to personalize your detox plan. We'll help you reclaim those hours.")
                        .font(appTheme.fonts.bodyLarge)
                        .foregroundColor(appTheme.colors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, appTheme.spacing.large)
                .padding(.bottom, appTheme.spacing.large)
                
                // Scrollable grid
                ScrollView {
                    VStack(spacing: 12) {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: appTheme.spacing.medium),
                            GridItem(.flexible(), spacing: appTheme.spacing.medium)
                        ], spacing: appTheme.spacing.medium) {
                            ForEach(0..<categories.count, id: \.self) { index in
                                CategoryCard(
                                    icon: categories[index].icon,
                                    label: categories[index].label,
                                    isSelected: selectedCategories.contains(index)
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        if selectedCategories.contains(index) {
                                            selectedCategories.remove(index)
                                        } else {
                                            selectedCategories.insert(index)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, appTheme.spacing.large)
                        .padding(.top, appTheme.spacing.small)
                        .padding(.bottom, 140)
                    }
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
                            title: "Analyze Habits",
                            icon: nil
                        ) {
                            data.currentScreen = 5
                        }
                    }
                    .padding(.horizontal, appTheme.spacing.large)
                    //.padding(.bottom, appTheme.spacing.large)
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
    OnboardingScreen4BehaviorInsight(data: OnboardingData())
}
