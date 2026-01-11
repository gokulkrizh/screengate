import SwiftUI

/// Reusable Back Button Component
/// Standard back button for navigation
struct BackButton: View {
    private let appTheme = AppTheme.shared
    
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(appTheme.colors.textSecondary)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
        }
    }
}

#Preview {
    ZStack {
        Color(red: 0.06, green: 0.13, blue: 0.09)
            .ignoresSafeArea()
        
        VStack {
            BackButton {
                print("Back tapped")
            }
            Spacer()
        }
        .padding()
    }
}
