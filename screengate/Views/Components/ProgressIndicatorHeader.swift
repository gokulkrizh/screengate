import SwiftUI

/// Progress indicator showing current step in onboarding flow
struct ProgressIndicatorHeader: View {
    let currentStep: Int
    let totalSteps: Int
    
    private let appTheme = AppTheme.shared
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index <= currentStep ? appTheme.colors.primary : Color.white.opacity(0.2))
                    .frame(width: index == currentStep ? 24 : 8, height: 4)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStep)
            }
        }
    }
}

#Preview {
    ZStack {
        Color(red: 0.06, green: 0.13, blue: 0.09)
            .ignoresSafeArea()
        
        ProgressIndicatorHeader(currentStep: 3, totalSteps: 10)
    }
}
