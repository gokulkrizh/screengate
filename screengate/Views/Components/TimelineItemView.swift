import SwiftUI

/// Timeline item component for displaying step-by-step progress
struct TimelineItemView: View {
    let icon: String
    let title: String
    let subtitle: String
    let isActive: Bool
    let isCompleted: Bool
    
    private let appTheme = AppTheme.shared
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Circle node
            ZStack {
                if isActive {
                    Circle()
                        .fill(appTheme.colors.primary)
                        .frame(width: 56, height: 56)
                        .shadow(color: appTheme.colors.primary.opacity(0.3), radius: 8)
                } else if isCompleted {
                    Circle()
                        .fill(appTheme.colors.primary.opacity(0.2))
                        .frame(width: 48, height: 48)
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                }
                
                Image(systemName: icon)
                    .font(.system(size: isActive ? 22 : 18, weight: .semibold))
                    .foregroundColor(
                        isActive || isCompleted ? 
                        Color(red: 0.06, green: 0.13, blue: 0.09) : 
                        .white.opacity(0.4)
                    )
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .semibold, design: .default))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.top, isActive ? 12 : 8)
            
            Spacer()
        }
    }
}

#Preview {
    ZStack {
        Color(red: 0.06, green: 0.13, blue: 0.09)
            .ignoresSafeArea()
        
        VStack(spacing: 40) {
            TimelineItemView(
                icon: "lock.open.fill",
                title: "Today",
                subtitle: "Start free 7-day trial",
                isActive: false,
                isCompleted: true
            )
            
            TimelineItemView(
                icon: "bell.fill",
                title: "Day 5",
                subtitle: "We'll remind you",
                isActive: true,
                isCompleted: false
            )
            
            TimelineItemView(
                icon: "star.fill",
                title: "Day 7",
                subtitle: "Premium subscription begins",
                isActive: false,
                isCompleted: false
            )
        }
        .padding()
    }
}
