import SwiftUI

/// OnboardingScreen6Age - Age Selection with Scrollable Picker
/// User selects their age for plan customization
struct OnboardingScreen6Age: View {
    @ObservedObject var data: OnboardingData
    @State private var selectedAge: Int? = nil
    @State private var scrollOffset: CGFloat = 0
    
    private let appTheme = AppTheme.shared
    private let ageRange = 13...100
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.06, green: 0.13, blue: 0.09)
                .ignoresSafeArea()
            
            // Decorative gradient blobs
            DecorativeGradientBlobs()
            
            // Main content
            VStack(spacing: 0) {
                // Header with back button and centered progress
                OnboardingHeader(
                    currentStep: 5,
                    totalSteps: 10
                ) {
                    data.currentScreen = 5
                }
                
                // Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Let's customize")
                        .font(appTheme.fonts.displaySmall)
                        .foregroundColor(appTheme.colors.text)
                    
                    Text("your plan.")
                        .font(appTheme.fonts.displaySmall)
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
                            .font(appTheme.fonts.titleLarge)
                            .foregroundColor(appTheme.colors.textSecondary)
                        
                        Picker("Age", selection: Binding(
                            get: { selectedAge ?? -1 },
                            set: { newValue in
                                if newValue == -1 {
                                    selectedAge = nil
                                } else {
                                    selectedAge = newValue
                                }
                            }
                        )) {
                            Text("—")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(appTheme.colors.primary.opacity(0.3))
                                .tag(-1)
                            
                            ForEach(ageRange, id: \.self) { age in
                                Text("\(age)")
                                    .font(.system(size: (selectedAge == age) ? 36 : 28, weight: (selectedAge == age) ? .bold : .semibold))
                                    .foregroundColor(appTheme.colors.primary)
                                    .scaleEffect((selectedAge == age) ? 1.0 : 0.7)
                                    .opacity((selectedAge == age) ? 1.0 : 0.4)
                                    .tag(age)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 200)
                        
                        Text("years old.")
                            .font(appTheme.fonts.titleLarge)
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
                
                BottomGradientContainer {
                    VStack(spacing: appTheme.spacing.medium) {
                        PrimaryButton(
                            title: "Continue",
                            icon: nil,
                            isDisabled: selectedAge == nil
                        ) {
                            data.currentScreen = 9
                        }
                    }
                    .padding(.horizontal, appTheme.spacing.large)
                }
            }
            .zIndex(20)
            .ignoresSafeArea(.keyboard)
        }
    }
}

#Preview {
    OnboardingScreen6Age(data: OnboardingData())
}
