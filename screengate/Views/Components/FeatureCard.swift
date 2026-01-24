import SwiftUI

/// Feature card with checkmark, typically used in paywall/feature list screens
struct FeatureCard: View {
    let title: String
    let subtitle: String?
    let isHighlighted: Bool
    
    private let appTheme = AppTheme.shared
    
    init(title: String, subtitle: String? = nil, isHighlighted: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.isHighlighted = isHighlighted
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkmark circle
            Circle()
                .fill(
                    isHighlighted ? appTheme.colors.primary : appTheme.colors.primary.opacity(0.15)
                )
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(
                            isHighlighted ? Color(red: 0.06, green: 0.13, blue: 0.09) : appTheme.colors.primary
                        )
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .foregroundColor(.white)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 11, weight: .bold, design: .default))
                        .tracking(0.8)
                        .foregroundColor(appTheme.colors.primary)
                }
            }
            
            Spacer()
        }
        .padding(14)
        .background(
            isHighlighted ? appTheme.colors.primary.opacity(0.1) : Color.white.opacity(0.03)
        )
        .border(
            isHighlighted ? appTheme.colors.primary.opacity(0.3) : Color.white.opacity(0.1),
            width: 1
        )
        .cornerRadius(12)
    }
}

#Preview {
    ZStack {
        Color(red: 0.06, green: 0.13, blue: 0.09)
            .ignoresSafeArea()
        
        VStack(spacing: 12) {
            FeatureCard(
                title: "Instant App Blocking",
                isHighlighted: false
            )
            
            FeatureCard(
                title: "7-Day Free Trial",
                subtitle: "START TODAY",
                isHighlighted: true
            )
        }
        .padding()
    }
}
