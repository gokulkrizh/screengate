import SwiftUI

/// Reusable Radio Option Card Component
/// Displays a selectable option with icon, title, and description
struct RadioOptionCard: View {
    private let appTheme = AppTheme.shared
    
    let icon: String
    let iconColor: Color?
    let iconBackgroundColor: Color?
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon background (only if colors provided)
                if let iconColor = iconColor, let iconBackgroundColor = iconBackgroundColor {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(iconBackgroundColor.opacity(0.15))
                        
                        Image(systemName: icon)
                            .font(.system(size: 24))
                            .foregroundColor(iconColor)
                    }
                    .frame(width: 48, height: 48)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(appTheme.fonts.titleMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(appTheme.colors.text)
                    
                    Text(subtitle)
                        .font(appTheme.fonts.bodySmall)
                        .foregroundColor(appTheme.colors.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Radio indicator
                ZStack {
                    Circle()
                        .stroke(
                            isSelected ? appTheme.colors.primary : Color.white.opacity(0.2),
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(appTheme.colors.primary)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isSelected ? 0.1 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? appTheme.colors.primary : Color.white.opacity(0.1),
                                lineWidth: 1.5
                            )
                    )
            )
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        RadioOptionCard(
            icon: "smartphone",
            iconColor: Color.blue,
            iconBackgroundColor: Color.blue,
            title: "Social Media Detox",
            subtitle: "I scroll too much on apps",
            isSelected: true
        ) {
            print("Selected 1")
        }
        
        RadioOptionCard(
            icon: "briefcase",
            iconColor: Color.orange,
            iconBackgroundColor: Color.orange,
            title: "Focus & Productivity",
            subtitle: "I can't focus on work/study",
            isSelected: false
        ) {
            print("Selected 2")
        }
    }
    .padding()
    .background(Color(red: 0.06, green: 0.13, blue: 0.09))
}
