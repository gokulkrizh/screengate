import SwiftUI

struct HowScreengateWorksView: View {
    @Environment(\.dismiss) var dismiss
    private let appTheme = AppTheme.shared
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.06, green: 0.13, blue: 0.09)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    
                    // Page indicators
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: 6, height: 6)
                        
                        Capsule()
                            .fill(appTheme.colors.primary)
                            .frame(width: 24, height: 6)
                        
                        Circle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: 6, height: 6)
                    }
                    
                    Spacer()
                    
                    // Skip button
                    Button(action: { dismiss() }) {
                        Text("Skip")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                // Compact content layout
                VStack(spacing: 16) {
                    // Hero Illustration (compact)
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(red: 0.08, green: 0.18, blue: 0.12))
                        
                        // Glow effect
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            appTheme.colors.primary.opacity(0.4),
                                            appTheme.colors.primary.opacity(0.2),
                                            Color.clear
                                        ]),
                                        center: .center,
                                        startRadius: 20,
                                        endRadius: 120
                                    )
                                )
                                .frame(width: 240, height: 240)
                            
                            // Battery/Phone icon
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(appTheme.colors.primary)
                                    .frame(width: 70, height: 100)
                                
                                // Camera notch
                                Circle()
                                    .fill(Color(red: 0.08, green: 0.18, blue: 0.12))
                                    .frame(width: 8, height: 8)
                                    .offset(y: -38)
                            }
                        }
                    }
                    .frame(height: 280)
                    .padding(.horizontal, 20)
                    
                    // Headline (compact)
                    Text("How Screendiet Works")
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    
                    // Timeline steps (compact)
                    VStack(spacing: 0) {
                        TimelineStep(
                            number: 1,
                            icon: "target",
                            title: "Define Your Limits",
                            description: "Set daily caps for specific apps that tend to drain your focus and energy.",
                            isLast: false,
                            appTheme: appTheme,
                            isCompact: true
                        )
                        
                        TimelineStep(
                            number: 2,
                            icon: "shield.fill",
                            title: "Deep Focus Mode",
                            description: "We automatically block distracting notifications during your scheduled focus hours.",
                            isLast: false,
                            appTheme: appTheme,
                            isCompact: true
                        )
                        
                        TimelineStep(
                            number: 3,
                            icon: "trophy.fill",
                            title: "Reclaim Your Time",
                            description: "Track your daily progress and gradually build healthier digital habits.",
                            isLast: true,
                            appTheme: appTheme,
                            isCompact: true
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    Spacer()
                }
                
                // Bottom action area
                Button(action: { dismiss() }) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold, design: .default))
                        .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(appTheme.colors.primary)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Timeline Step Component
private struct TimelineStep: View {
    let number: Int
    let icon: String
    let title: String
    let description: String
    let isLast: Bool
    let appTheme: AppTheme
    let isCompact: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline connector
            VStack(spacing: 0) {
                // Icon circle
                ZStack {
                    Circle()
                        .fill(Color(red: 0.12, green: 0.22, blue: 0.16))
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(appTheme.colors.primary)
                }
                
                // Connecting line
                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 1.5)
                        .frame(height: 60)
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
    HowScreengateWorksView()
}
