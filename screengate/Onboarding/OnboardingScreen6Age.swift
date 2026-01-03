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
                // Header
                HStack {
                    BackButton {
                        data.currentScreen = 5
                    }
                    Spacer()
                }
                .padding(.horizontal, appTheme.spacing.large)
                .padding(.vertical, appTheme.spacing.medium)
                
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
                        
                        // Age Wheel
                        GeometryReader { geometry in
                            ScrollViewReader { proxy in
                                ScrollView(.vertical, showsIndicators: false) {
                                    VStack(spacing: 0) {
                                        // Top padding
                                        Color.clear.frame(height: 96)
                                        
                                        // Age options
                                        ForEach(ageRange, id: \.self) { age in
                                            VStack {
                                                Text("\(age)")
                                                    .font(.system(size: selectedAge == age ? 56 : 32, weight: selectedAge == age ? .bold : .semibold))
                                                    .foregroundColor(selectedAge == age ? appTheme.colors.primary : appTheme.colors.textSecondary)
                                                    .frame(height: 64)
                                                    .scaleEffect(selectedAge == age ? 1.0 : 0.7)
                                                    .opacity(selectedAge == age ? 1.0 : 0.4)
                                            }
                                            .id(age)
                                        }
                                        
                                        // Bottom padding
                                        Color.clear.frame(height: 96)
                                    }
                                }
                                .scrollTargetBehavior(.viewAligned)
                                .onScrollGeometryChange(for: CGFloat.self) { geometry in
                                    geometry.contentOffset.y
                                } action: { oldValue, newValue in
                                    let offset = newValue
                                    let itemHeight: CGFloat = 64
                                    let index = Int(round(offset / itemHeight))
                                    let age = ageRange.lowerBound + index
                                    if ageRange.contains(age) {
                                        selectedAge = age
                                    }
                                }
                                .onAppear {
                                    proxy.scrollTo(selectedAge, anchor: .center)
                                }
                            }
                        }
                        .frame(width: 80)
                        .frame(height: 256)
                        .mask(
                            VStack(spacing: 0) {
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.clear, Color.black, Color.black, Color.clear]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            }
                        )
                        
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
