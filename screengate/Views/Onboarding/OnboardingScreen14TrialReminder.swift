import SwiftUI

/// OnboardingScreen14TrialReminder - Trial Reminder Timeline Screen
/// Shows users the trial timeline with reminder notification on Day 5
struct OnboardingScreen14TrialReminder: View {
    @ObservedObject var data: OnboardingData
    
    private let appTheme = AppTheme.shared
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.06, green: 0.13, blue: 0.09)
                .ignoresSafeArea()
            
            // Decorative gradient blob
            VStack {
                Circle()
                    .fill(appTheme.colors.primary.opacity(0.08))
                    .blur(radius: 150)
                //    .frame(width: 500, height: 500)
                    .offset(y: -150)
                
                Spacer()
            }
            .ignoresSafeArea()
            
            VStack {
                // Title and description
                VStack(alignment: .center, spacing: 12) {
                    Text("No surprise charges")
                        .font(appTheme.fonts.displayMedium)
                        .multilineTextAlignment(.center)
                        .foregroundColor(appTheme.colors.text)
                        .padding(.horizontal, 20)
                    
                    Text("We'll send you a notification 2 days before your trial ends, so you're always in control.")
                        .font(appTheme.fonts.bodyLarge)
                        .foregroundColor(appTheme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 45)
                }
                .padding(.bottom, 32)
                .padding(.top, appTheme.spacing.large)

                // Content
                GeometryReader { geometry in
                    ScrollView(.vertical, showsIndicators: false) {
                        
                        VStack(spacing: 50) {
                            
                            // Timeline
                            HStack {
                                Spacer()
                                
                                ZStack(alignment: .topLeading) {
                                // Vertical connector line (behind items)
                                VStack(spacing: 30) {
                                    // Spacer for first item height (56) + spacing (28)
                                    Spacer()
                                        .frame(height: 55)
                                    
                                    // Gradient line (increased height)
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            appTheme.colors.primary,
                                            appTheme.colors.primary.opacity(0.4),
                                            Color.white.opacity(0.1)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .frame(width: 2, height: 270)
                                }
                                .padding(.leading, 48)
                                
                                // Timeline items
                                VStack(spacing: 40) {
                                    // Day 0: Today
                                    timelineItem(
                                        icon: "lock.open.fill",
                                        title: "Today",
                                        subtitle: "Start free 7-day trial",
                                        isActive: false,
                                        isCompleted: true
                                    )
                                    
                                    // Day 5: Reminder
                                    VStack(alignment: .leading, spacing: 22) {
                                        timelineItem(
                                            icon: "bell.fill",
                                            title: "Day 5",
                                            subtitle: "We'll remind you",
                                            isActive: true,
                                            isCompleted: false
                                        )
                                        
                                        // Notification preview card
                                        VStack(alignment: .leading, spacing: 10) {
                                            HStack(spacing: 12) {
                                                // App icon
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(appTheme.colors.primary)
                                                    .frame(width: 40, height: 40)
                                                    .overlay(
                                                        Image(systemName: "smartphone.fill")
                                                            .font(.system(size: 16, weight: .semibold))
                                                            .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                                                    )
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    HStack(spacing: 8) {
                                                        Text("SCREENDIET")
                                                            .font(.system(size: 10, weight: .bold, design: .default))
                                                            .tracking(0.5)
                                                            .foregroundColor(.white.opacity(0.5))
                                                        
                                                        Spacer()
                                                        
                                                        Text("now")
                                                            .font(.system(size: 9, weight: .semibold, design: .default))
                                                            .foregroundColor(.white.opacity(0.4))
                                                    }
                                                    
                                                    Text("Trial Ending Soon")
                                                        .font(.system(size: 13, weight: .bold, design: .default))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                            
                                            Text("Your trial ends in 2 days. Cancel now if you don't want to be charged.")
                                                .font(.system(size: 11, weight: .semibold, design: .default))
                                                .foregroundColor(.white.opacity(0.6))
                                                .lineLimit(2)
                                        }
                                        .padding(12)
                                        .background(Color.white.opacity(0.03))
                                        .border(Color.white.opacity(0.1), width: 0.5)
                                        .cornerRadius(12)
                                        .padding(.leading, 48)
                                    }
                                    
                                    // Day 7: Subscription begins
                                    timelineItem(
                                        icon: "star.fill",
                                        title: "Day 7",
                                        subtitle: "Premium subscription begins",
                                        isActive: false,
                                        isCompleted: false
                                    )
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                            }
                            
                            Spacer()
                        }
                        
                        }
                        .padding(.bottom, 32)
                        .frame(maxWidth: .infinity, minHeight: geometry.size.height)
                    }
                    .scrollDisabled(true)
                }

                VStack(spacing: 0) {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color(red: 0.06, green: 0.13, blue: 0.09),
                            Color(red: 0.06, green: 0.13, blue: 0.09)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 20)
                    
                    VStack(spacing: 8) {
                        PrimaryButton(
                            title: "Enable remainders",
                        ) {
                            data.currentScreen += 1
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(appTheme.colors.primary)
                            
                            Text("We'll remind you 2 days before trial ends")
                                .font(.system(size: 12, weight: .semibold, design: .default))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    .padding(.horizontal, appTheme.spacing.large)
                    .background(Color(red: 0.06, green: 0.13, blue: 0.09))
                }
                .zIndex(20)
                .ignoresSafeArea(.keyboard)
            }
        }
    }
    
    // MARK: - Timeline Item Component
    private func timelineItem(
        icon: String,
        title: String,
        subtitle: String,
        isActive: Bool,
        isCompleted: Bool
    ) -> some View {
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
                        .stroke(appTheme.colors.primary, lineWidth: 2)
                        .frame(width: 56, height: 56)
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 36, height: 36)
                       // .border(Color.white.opacity(0.1), width: 2)
                }
                
                Image(systemName: icon)
                    .font(.system(size: (!isActive && !isCompleted) ? 12 : 22, weight: .semibold))
                    .foregroundColor(
                        isActive ? Color(red: 0.06, green: 0.13, blue: 0.09) :
                        isCompleted ? appTheme.colors.primary :
                        Color.white.opacity(0.4)
                    )
            }
            .frame(width: 56, height: 56)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .foregroundColor(
                        isActive ? appTheme.colors.primary :
                        Color.white.opacity(0.6)
                    )
            }
            .padding(.top, 4)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingScreen14TrialReminder(data: OnboardingData())
}
