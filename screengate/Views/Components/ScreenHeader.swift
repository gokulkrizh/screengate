import SwiftUI

/// Reusable Screen Header Component
/// Displays title and subtitle with consistent styling
struct ScreenHeader: View {
    private let appTheme = AppTheme.shared
    
    let title: String
    let subtitle: String
    
    init(
        title: String,
        subtitle: String
    ) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(spacing: appTheme.spacing.medium) {
            Text(title)
                .font(appTheme.fonts.displayMedium)
                .fontWeight(.bold)
                .tracking(0.5)
                .foregroundColor(appTheme.colors.text)
            
            Text(subtitle)
                .font(appTheme.fonts.titleLarge)
                .foregroundColor(appTheme.colors.textSecondary)
                .lineLimit(4)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, appTheme.spacing.large)
    }
}

#Preview {
    ZStack {
        Color(red: 0.06, green: 0.13, blue: 0.09)
            .ignoresSafeArea()
        
        ScreenHeader(
            title: "Screendiet",
            subtitle: "Reclaim your time. Master your focus. Digital fasting for a clearer mind."
        )
    }
}
