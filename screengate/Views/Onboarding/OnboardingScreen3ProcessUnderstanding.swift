import SwiftUI

/// OnboardingScreen3ProcessUnderstanding - Process Understanding Survey (Multi-select)
/// User selects when they find themselves using phone the most
struct OnboardingScreen3ProcessUnderstanding: View {
    @ObservedObject var data: OnboardingData
    @State private var selectedOptions: Set<Int> = [1] // Pre-select "During breaks"
    
    private let appTheme = AppTheme.shared
    
    let options: [String] = [
        "Right after waking up 🌅",
        "During work/study breaks ☕",
        "While watching TV 📺",
        "Right before sleep 🌙",
        "All day long 🔄"
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
                            data.currentScreen = 2
                        }
                        Spacer()
                    }
                    
                    ProgressIndicatorHeader(currentStep: 2, totalSteps: 10)
                }
                .padding(.horizontal, appTheme.spacing.large)
              //  .padding(.vertical, appTheme.spacing.medium)
                
                // Title and subtitle (fixed, not scrollable)
                VStack(alignment: .leading, spacing: appTheme.spacing.medium) {
                    Text("When do you find yourself using your phone the most?")
                        .font(appTheme.fonts.displaySmall)
                        .foregroundColor(appTheme.colors.text)
                        //.multilineTextAlignment(.center)
                    
                    Text("Reflecting on your habits helps us tailor your diet. Select all that apply.")
                        .font(appTheme.fonts.bodyLarge)
                        .foregroundColor(appTheme.colors.textSecondary)
                       // .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, appTheme.spacing.large)
                .padding(.vertical, appTheme.spacing.large)
                
                // Scrollable options
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(0..<options.count, id: \.self) { index in
                            CheckboxOptionCard(
                                title: options[index],
                                isSelected: selectedOptions.contains(index)
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    if selectedOptions.contains(index) {
                                        selectedOptions.remove(index)
                                    } else {
                                        selectedOptions.insert(index)
                                    }
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
                            data.currentScreen = 4
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
    OnboardingScreen3ProcessUnderstanding(data: OnboardingData())
}
