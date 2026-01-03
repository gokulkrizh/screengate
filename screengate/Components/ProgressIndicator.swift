import SwiftUI

/// Reusable Step Progress Indicator Component
/// Shows current step progress with animated bars
struct StepProgressIndicator: View {
    private let appTheme = AppTheme.shared
    
    let currentStep: Int
    let totalSteps: Int
    
    init(
        currentStep: Int,
        totalSteps: Int
    ) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
    }
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { index in
                if index == currentStep {
                    // Active step - elongated
                    Capsule()
                        .fill(appTheme.colors.primary)
                        .frame(height: 6)
                        .frame(maxWidth: 32)
                        .transition(.scale)
                } else {
                    // Inactive step - small dot
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)
                        .frame(width: 8)
                }
            }
            Spacer()
        }
        .padding(.horizontal, appTheme.spacing.large)
        .padding(.vertical, appTheme.spacing.medium)
    }
}

#Preview {
    VStack(spacing: 16) {
        StepProgressIndicator(currentStep: 0, totalSteps: 5)
        StepProgressIndicator(currentStep: 2, totalSteps: 5)
        StepProgressIndicator(currentStep: 4, totalSteps: 5)
    }
    .padding()
    .background(Color(red: 0.06, green: 0.13, blue: 0.09))
}
