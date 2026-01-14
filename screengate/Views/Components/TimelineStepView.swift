import SwiftUI

/// Timeline step component for vertical progress flows
struct TimelineStepView: View {
    let icon: String
    let title: String
    let description: String
    let isLast: Bool
    var iconSize: CGFloat = 52
    var lineHeight: CGFloat = 60
    
    private let appTheme = AppTheme.shared
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline connector
            VStack(spacing: 0) {
                // Icon circle
                ZStack {
                    Circle()
                        .fill(Color(red: 0.12, green: 0.22, blue: 0.16))
                        .frame(width: iconSize, height: iconSize)
                    
                    Image(systemName: icon)
                        .font(.system(size: iconSize * 0.38, weight: .semibold))
                        .foregroundColor(appTheme.colors.primary)
                }
                
                // Connecting line
                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 1.5)
                        .frame(height: lineHeight)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(Color.gray.opacity(0.7))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 8)
            .padding(.bottom, isLast ? 0 : 8)
            
            Spacer()
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        TimelineStepView(
            icon: "lock.shield",
            title: "Select Apps to Block",
            description: "Choose which apps you want to restrict during focus time.",
            isLast: false
        )
        TimelineStepView(
            icon: "calendar",
            title: "Set Your Schedule",
            description: "Define when you want the blocks to be active.",
            isLast: true
        )
    }
    .padding()
    .background(Color(red: 0.06, green: 0.13, blue: 0.09))
    .preferredColorScheme(.dark)
}
