import SwiftUI

/// CheckboxOptionCard - Multi-select checkbox option card
struct CheckboxOptionCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    private let appTheme = AppTheme.shared
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: appTheme.spacing.medium) {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(appTheme.fonts.titleMedium)
                        .foregroundColor(appTheme.colors.text)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Checkbox
                ZStack {
                    Circle()
                        .stroke(
                            isSelected ? appTheme.colors.primary : Color.white.opacity(0.2),
                            lineWidth: 1.5
                        )
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(appTheme.colors.primary)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
            }
            .padding(appTheme.spacing.large)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? appTheme.colors.primary : Color.white.opacity(0.15),
                        lineWidth: 1.5
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 20)
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

#Preview {
    VStack(spacing: 12) {
        CheckboxOptionCard(
            title: "Right after waking up 🌅",
            isSelected: false
        ) {}
        
        CheckboxOptionCard(
            title: "During work/study breaks ☕",
            isSelected: true
        ) {}
    }
    .padding()
    .background(Color(red: 0.06, green: 0.13, blue: 0.09))
}
