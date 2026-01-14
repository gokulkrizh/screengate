import SwiftUI

/// Stat card component for displaying metrics with icon, value, and label
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    var height: CGFloat = 128
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(color == .red ? Color.red.opacity(0.2) : Color.white.opacity(0.05))
                .cornerRadius(8)
            
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .default))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .default))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: height)
        .background(Color(red: 0.11, green: 0.18, blue: 0.13))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

#Preview {
    HStack(spacing: 16) {
        StatCard(
            icon: "hand.tap.fill",
            value: "42",
            label: "Pickups",
            color: .white.opacity(0.5)
        )
        
        StatCard(
            icon: "nosign",
            value: "5",
            label: "Blocked Attempts",
            color: .red
        )
    }
    .padding()
    .background(Color(red: 0.06, green: 0.13, blue: 0.09))
    .preferredColorScheme(.dark)
}
