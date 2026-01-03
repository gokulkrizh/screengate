import SwiftUI

/// Reusable Primary Button Component
/// Used for main call-to-action buttons with icon support
struct PrimaryButton: View {
    private let appTheme = AppTheme.shared
    
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(
        title: String,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            withAnimation {
                action()
            }
        }) {
            HStack(spacing: appTheme.spacing.small) {
                Text(title)
                    .font(appTheme.fonts.titleLarge)
                    .fontWeight(.bold)
                
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(appTheme.colors.primary)
            .foregroundColor(appTheme.colors.background)
            .cornerRadius(14)
            .shadow(color: appTheme.colors.primary.opacity(0.25), radius: 12)
        }
        .scaleEffect(1.0, anchor: .center)
    }
}

#Preview {
    let appTheme = AppTheme.shared
    
    return VStack(spacing: 16) {
        PrimaryButton(
            title: "Get Started",
            icon: "arrow.right"
        ) {
            print("Get Started tapped")
        }
        
        PrimaryButton(
            title: "Continue"
        ) {
            print("Continue tapped")
        }
    }
    .padding()
    .background(appTheme.colors.background)
}
