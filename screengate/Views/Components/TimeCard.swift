import SwiftUI

/// Time display card with icon and tap-to-adjust functionality
struct TimeCard: View {
    let icon: String
    let iconColor: Color
    let label: String
    let time: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.06, green: 0.13, blue: 0.09))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(iconColor)
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
    VStack(spacing: 12) {
        TimeCard(
            icon: "sunrise.fill",
            iconColor: .orange,
            label: "Start Time",
            time: "09:00 AM",
            action: {}
        )
        
        TimeCard(
            icon: "sunset.fill",
            iconColor: .purple,
            label: "End Time",
            time: "05:00 PM",
            action: {}
        )
    }
    .padding()
    .background(Color(red: 0.06, green: 0.13, blue: 0.09))
    .preferredColorScheme(.dark)
}
