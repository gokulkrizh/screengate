import SwiftUI

/// Time display card with icon and tap-to-adjust functionality
struct TimeCard: View {
    let icon: String
    let iconColor: Color
    let label: String
    let time: String
    let action: () -> Void
    let showIcon: Bool
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if showIcon {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.06, green: 0.13, blue: 0.09))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(iconColor)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.system(size: 11, weight: .bold, design: .default))
                        .tracking(0.5)
                        .foregroundColor(.white.opacity(0.5))
                        .textCase(.uppercase)
                    
                    Text(time)
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color(red: 0.09, green: 0.16, blue: 0.12))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HStack(spacing: 12) {
        TimeCard(
            icon: "sunrise.fill",
            iconColor: .orange,
            label: "From",
            time: "09:00 AM",
            action: {},
            showIcon: false
        )
        
        TimeCard(
            icon: "sunset.fill",
            iconColor: .purple,
            label: "To",
            time: "05:00 PM",
            action: {},
            showIcon: false
        )
    }
    .frame(maxWidth: .infinity)
    .padding()
    .background(Color(red: 0.06, green: 0.13, blue: 0.09))
    .preferredColorScheme(.dark)
}
