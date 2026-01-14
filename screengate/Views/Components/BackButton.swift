import SwiftUI

/// Reusable Back Button Component
/// Liquid glass circle button for navigation
struct BackButton: View {
    private let appTheme = AppTheme.shared
    
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(appTheme.colors.textSecondary)
                .frame(width: 40, height: 40)
                .glassEffect()
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
