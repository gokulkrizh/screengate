import SwiftUI

/// CategoryCard - App category selection card for grid layout
struct CategoryCard: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    private let appTheme = AppTheme.shared
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)
                }
                
                // Label
                Text(label)
                    .font(appTheme.fonts.labelLarge)
                    .fontWeight(.bold)
                    .foregroundColor(appTheme.colors.text)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(isSelected ? 0.08 : 0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? appTheme.colors.primary : Color.white.opacity(0.1),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .overlay(
                VStack {
                    HStack {
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(appTheme.colors.primary)
                                .padding(12)
                        }
                    }
                    Spacer()
                },
                alignment: .topTrailing
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HStack(spacing: 12) {
        CategoryCard(
            icon: "bubble.right",
            label: "Social",
            isSelected: true
        ) {}
        
        CategoryCard(
            icon: "play.circle",
            label: "Entertainment",
            isSelected: false
        ) {}
    }
    .padding()
    .background(Color(red: 0.06, green: 0.13, blue: 0.09))
}
