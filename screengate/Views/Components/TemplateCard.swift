import SwiftUI

/// Reusable card component for focus templates and quick actions
struct TemplateCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    var width: CGFloat = 144
    var height: CGFloat = 120
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .default))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 10, weight: .semibold, design: .default))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
        .frame(width: width, height: height, alignment: .topLeading)
        .padding(12)
        .background(Color.white.opacity(0.03))
        .border(Color.white.opacity(0.1), width: 0.5)
        .cornerRadius(12)
    }
}

#Preview {
    TemplateCard(
        icon: "brain.head.profile",
        title: "Deep Work",
        subtitle: "45 min • Strict",
        color: .blue
    )
    .preferredColorScheme(.dark)
}
