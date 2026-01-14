import SwiftUI

/// Reusable strict mode selection card with icon, title, description, and radio button
struct StrictModeCard: View {
    let mode: StrictMode
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    enum StrictMode {
        case easy, medium, hard
    }
    
    private let appTheme = AppTheme.shared
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.06, green: 0.13, blue: 0.09))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.system(size: 13, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Radio Button
                ZStack {
                    Circle()
                        .stroke(isSelected ? appTheme.colors.primary : Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(appTheme.colors.primary)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(16)
            .background(Color(red: 0.09, green: 0.16, blue: 0.12))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? appTheme.colors.primary : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 12) {
        StrictModeCard(
            mode: .easy,
            icon: "cup.and.saucer.fill",
            iconColor: .green,
            title: "Easy Mode",
            description: "Gentle reminders, can bypass easily",
            isSelected: false,
            action: {}
        )
        
        StrictModeCard(
            mode: .medium,
            icon: "timer",
            iconColor: .yellow,
            title: "Medium Mode",
            description: "15s delay before you can unblock",
            isSelected: true,
            action: {}
        )
        
        StrictModeCard(
            mode: .hard,
            icon: "lock.fill",
            iconColor: .red,
            title: "Hard Mode",
            description: "Cannot bypass until session ends",
            isSelected: false,
            action: {}
        )
    }
    .padding()
    .background(Color(red: 0.06, green: 0.13, blue: 0.09))
    .preferredColorScheme(.dark)
}
