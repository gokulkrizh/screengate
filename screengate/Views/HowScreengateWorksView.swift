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
                    .padding(.top, 40)
                    
                    // Headline (compact)
                    Text("How Screendiet Works")
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    
                    // Timeline steps (compact)
                    VStack(spacing: 0) {
                        TimelineStepView(
                            icon: "target",
                            title: "Define Your Limits",
                            description: "Set daily caps for specific apps that tend to drain your focus and energy.",
                            isLast: false
                        )
                        
                        TimelineStepView(
                            icon: "shield.fill",
                            title: "Deep Focus Mode",
                            description: "We automatically block distracting notifications during your scheduled focus hours.",
                            isLast: false
                        )
                        
                        TimelineStepView(
                            icon: "trophy.fill",
                            title: "Reclaim Your Time",
                            description: "Track your daily progress and gradually build healthier digital habits.",
                            isLast: true
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

#Preview {
    HowScreengateWorksView()
}
