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
            DecorativeGradientBlobs()
            
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
                                    TimelineItemView(
                                        icon: "lock.open.fill",
                                        title: "Today",
                                        subtitle: "Start free 7-day trial",
                                        isActive: false,
                                        isCompleted: true
                                    )
                                    
                                    // Day 5: Reminder
                                    VStack(alignment: .leading, spacing: 22) {
                                        TimelineItemView(
                                            icon: "bell.fill",
                                            title: "Day 5",
                                            subtitle: "We'll remind you",
                                            isActive: true,
                                            isCompleted: false
                                        )
                                        
                                        // Notification preview card
                                        NotificationPreviewCard(
                                            title: "Trial Ending Soon",
                                            message: "Your trial ends in 2 days. Cancel now if you don't want to be charged."
                                        )
                                        .padding(.leading, 48)
                                    }
                                    
                                    // Day 7: Subscription begins
                                    TimelineItemView(
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

                BottomGradientContainer {
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
                }
            }
        }
    }
}

#Preview {
    OnboardingScreen14TrialReminder(data: OnboardingData())
}
