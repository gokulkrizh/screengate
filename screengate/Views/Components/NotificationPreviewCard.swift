import SwiftUI

/// Mock notification card for preview purposes
struct NotificationPreviewCard: View {
    let appName: String
    let title: String
    let message: String
    let iconName: String
    
    private let appTheme = AppTheme.shared
    
    init(
        appName: String = "SCREENDIET",
        title: String,
        message: String,
        iconName: String = "smartphone.fill"
    ) {
        self.appName = appName
        self.title = title
        self.message = message
        self.iconName = iconName
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                // App icon
                RoundedRectangle(cornerRadius: 8)
                    .fill(appTheme.colors.primary)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: iconName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(appName)
                            .font(.system(size: 10, weight: .bold, design: .default))
                            .tracking(0.5)
                            .foregroundColor(.white.opacity(0.5))
                        
                        Spacer()
                        
                        Text("now")
                            .font(.system(size: 9, weight: .semibold, design: .default))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    
                    Text(title)
                        .font(.system(size: 13, weight: .bold, design: .default))
                        .foregroundColor(.white)
                }
            }
            
            Text(message)
                .font(.system(size: 11, weight: .semibold, design: .default))
                .foregroundColor(.white.opacity(0.6))
                .lineLimit(2)
        }
        .padding(12)
        .background(Color.white.opacity(0.03))
        .border(Color.white.opacity(0.1), width: 0.5)
        .cornerRadius(12)
    }
}

#Preview {
    ZStack {
        Color(red: 0.06, green: 0.13, blue: 0.09)
            .ignoresSafeArea()
        
        NotificationPreviewCard(
            title: "Trial Ending Soon",
            message: "Your trial ends in 2 days. Cancel now if you don't want to be charged."
        )
        .padding()
    }
}
