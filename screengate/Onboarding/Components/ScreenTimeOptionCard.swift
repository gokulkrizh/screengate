import SwiftUI

/// ScreenTimeOptionCard - Single-select radio option card with title and description
struct ScreenTimeOptionCard: View {
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    private let appTheme = AppTheme.shared
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: appTheme.spacing.large) {
                // Radio button
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
                            .frame(width: 24, height: 24)
                        
                        Circle()
                            .fill(.black)
                            .frame(width: 8, height: 8)
                    }
                }
                .flexibleFrame(minWidth: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(appTheme.fonts.headlineSmall)
                        .fontWeight(.bold)
                        .foregroundColor(appTheme.colors.text)
                    
                    Text(description)
                        .font(appTheme.fonts.bodySmall)
                        .foregroundColor(appTheme.colors.textSecondary)
                        .lineLimit(3)
                }
                
                Spacer()
            }
            .padding(appTheme.spacing.large)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        isSelected ? appTheme.colors.primary : Color.white.opacity(0.1),
                        lineWidth: isSelected ? 2 : 1
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                isSelected
                                    ? appTheme.colors.primary.opacity(0.08)
                                    : Color.white.opacity(0.03)
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension View {
    func flexibleFrame(minWidth: CGFloat = 0) -> some View {
        self.frame(minWidth: minWidth)
    }
}

#Preview {
    VStack(spacing: 12) {
        ScreenTimeOptionCard(
            title: "I'm a casual user",
            description: "Less than 2 hours. Mostly just checking messages occasionally.",
            isSelected: false
        ) {}
        
        ScreenTimeOptionCard(
            title: "I'm glued to it",
            description: "4 to 6 hours. It's my primary source of entertainment and work.",
            isSelected: true
        ) {}
    }
    .padding()
    .background(Color(red: 0.06, green: 0.13, blue: 0.09))
}
