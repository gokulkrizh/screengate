import SwiftUI

/// OnboardingScreen6Age - Age Selection with Scrollable Picker
/// User selects their age for plan customization
struct OnboardingScreen6Age: View {
    @ObservedObject var data: OnboardingData
    @State private var selectedAge: Int = 24
    @State private var scrollOffset: CGFloat = 0
    
    private let appTheme = AppTheme.shared
    private let ageRange = 13...100
    
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
                            data.currentScreen = 5
                        }
                        Spacer()
                    }
                    
                    ProgressIndicatorHeader(currentStep: 5, totalSteps: 10)
                }
                .padding(.horizontal, appTheme.spacing.large)
            //    .padding(.vertical, appTheme.spacing.medium)
                
                // Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Let's customize")
                        .font(appTheme.fonts.displaySmall)
                        .fontWeight(.bold)
                        .foregroundColor(appTheme.colors.text)
                    
                    Text("your plan.")
                        .font(appTheme.fonts.displaySmall)
                        .fontWeight(.bold)
                        .foregroundColor(appTheme.colors.text)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, appTheme.spacing.large)
                .padding(.vertical, appTheme.spacing.large)
                
                Spacer()
                
                // Age Picker
                VStack(spacing: appTheme.spacing.medium) {
                    HStack(spacing: appTheme.spacing.medium) {
                        Text("I am")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(appTheme.colors.textSecondary)
                        
                        Picker("Age", selection: $selectedAge) {
                            ForEach(ageRange, id: \.self) { age in
                                Text("\(age)")
                                    .font(.system(size: age == selectedAge ? 36 : 28, weight: age == selectedAge ? .bold : .semibold))
                                    .foregroundColor(appTheme.colors.primary)
                                    .scaleEffect(age == selectedAge ? 1.0 : 0.7)
                                    .opacity(age == selectedAge ? 1.0 : 0.4)
                                    .tag(age)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 200)
                        
                        Text("years old.")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(appTheme.colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, appTheme.spacing.large)
                
                Spacer()
                
                // Privacy notice
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.6))
                    
                    Text("Used for benchmarking focus stats.")
                        .font(appTheme.fonts.bodySmall)
                        .foregroundColor(Color.white.opacity(0.6))
                }
                .padding(.horizontal, appTheme.spacing.large)
                .padding(.bottom, appTheme.spacing.large)
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
                            data.currentScreen = 7
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
    OnboardingScreen6Age(data: OnboardingData())
}
