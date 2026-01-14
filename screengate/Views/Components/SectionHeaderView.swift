import SwiftUI

/// Section header with label and icon
struct SectionHeaderView: View {
    let icon: String?
    let iconColor: Color?
    let title: String
    var fontSize: CGFloat = 11
    
    var body: some View {
        HStack(spacing: 6) {
            if let icon = icon, let iconColor = iconColor {
                Image(systemName: icon)
                    .font(.system(size: fontSize, weight: .bold))
                    .foregroundColor(iconColor)
            }
            
            Text(title)
                .font(.system(size: fontSize, weight: .bold, design: .default))
                .tracking(0.5)
                .foregroundColor(.white.opacity(0.5))
                .textCase(.uppercase)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        SectionHeaderView(
            icon: "calendar",
            iconColor: .green,
            title: "Schedule"
        )
        
        SectionHeaderView(
            icon: nil,
            iconColor: nil,
            title: "Daily Limit"
        )
    }
    .padding()
    .background(Color(red: 0.06, green: 0.13, blue: 0.09))
    .preferredColorScheme(.dark)
}
