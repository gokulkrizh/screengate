import SwiftUI

/// Reusable Secondary Button Component
/// Used for alternative actions with subtle styling
struct SecondaryButton: View {
    private let appTheme = AppTheme.shared
    
    let title: String
    let action: () -> Void
    
    init(
        title: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            withAnimation {
                action()
            }
        }) {
            Text(title)
                .font(appTheme.fonts.bodyMedium)
                .fontWeight(.semibold)
                .foregroundColor(appTheme.colors.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.white.opacity(0.05))
                .cornerRadius(14)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        SecondaryButton(title: "Already have an account? Log in") {
            print("Log in tapped")
        }
        
        SecondaryButton(title: "Skip for now") {
            print("Skip tapped")
        }
    }
    .padding()
    .background(Color(red: 0.06, green: 0.13, blue: 0.09))
}
