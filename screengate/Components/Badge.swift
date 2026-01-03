import SwiftUI

/// Reusable Badge Component
/// Displays a labeled badge with primary color
struct Badge: View {
    private let appTheme = AppTheme.shared
    
    let label: String
    
    var body: some View {
        Text(label)
            .font(appTheme.fonts.labelSmall)
            .fontWeight(.bold)
            .tracking(1.2)
            .foregroundColor(appTheme.colors.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(appTheme.colors.primary.opacity(0.15))
            .cornerRadius(20)
    }
}

#Preview {
    VStack(spacing: 16) {
        Badge(label: "Discovery")
        Badge(label: "Step 1")
        Badge(label: "Problem Solving")
    }
    .padding()
    .background(Color(red: 0.06, green: 0.13, blue: 0.09))
}
