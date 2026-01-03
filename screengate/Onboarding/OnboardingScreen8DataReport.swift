import SwiftUI

/// OnboardingScreen8DataReport - Personalized Data Report
/// Displays analytics and insights based on user's screen time data
struct OnboardingScreen8DataReport: View {
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
                    .frame(width: 500, height: 500)
                    .offset(y: -200)
                
                Spacer()
            }
            .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 12) {
                    Circle()
                        .fill(appTheme.colors.primary.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(appTheme.colors.primary)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("REPORT")
                            .font(.system(size: 10, weight: .bold, design: .default))
                            .tracking(1.2)
                            .foregroundColor(appTheme.colors.primary)
                        
                        Text("Your Insights")
                            .font(.system(size: 16, weight: .bold, design: .default))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 50)
                .padding(.vertical, 16)
                
                // Scrollable content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Projection Card
                        projectionCard
                        .padding(.horizontal, appTheme.spacing.large)
                        
                        // Comparison Card
                        comparisonCard
                        .padding(.horizontal, appTheme.spacing.large)

                        // Insight Card
                        insightCard
                        .padding(.horizontal, appTheme.spacing.large)
                        
                        // Next button
                        PrimaryButton(
                            title: "Continue",
                            action: {
                                data.currentScreen += 1
                            }
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }.padding(.horizontal, appTheme.spacing.extraLarge)
            .padding(.vertical, appTheme.spacing.extraLarge)
        }
    }
    
    // MARK: - Projection Card
    private var projectionCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(spacing: 8) {
                Circle()
                    .fill(appTheme.colors.primary.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(appTheme.colors.primary)
                    )
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("PROJECTION")
                        .font(.system(size: 9, weight: .bold, design: .default))
                        .tracking(1.1)
                        .foregroundColor(appTheme.colors.primary)
                }
                
                Spacer()
                
                Text("Est. 2024")
                    .font(.system(size: 9, weight: .semibold, design: .default))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.05))
                    .border(Color.white.opacity(0.1), width: 0.5)
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                // Annual impact
                VStack(alignment: .leading, spacing: 6) {
                    Text("ANNUAL IMPACT")
                        .font(.system(size: 8, weight: .bold, design: .default))
                        .tracking(1)
                        .foregroundColor(.white.opacity(0.5))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Based on your data, you'll spend")
                            .font(.system(size: 15, weight: .semibold, design: .default))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("91 days")
                            .font(.system(size: 28, weight: .bold, design: .default))
                            .foregroundColor(appTheme.colors.primary)
                        
                        Text("on your phone this year.")
                            .font(.system(size: 15, weight: .semibold, design: .default))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Divider()
                    .background(Color.white.opacity(0.05))
                
                // Lifetime impact
                VStack(alignment: .leading, spacing: 6) {
                    Text("LIFETIME IMPACT")
                        .font(.system(size: 8, weight: .bold, design: .default))
                        .tracking(1)
                        .foregroundColor(.white.opacity(0.5))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("That amounts to")
                            .font(.system(size: 15, weight: .semibold, design: .default))
                            .foregroundColor(.white.opacity(0.8))
                        
                        HStack(spacing: 0) {
                            Text("17 years")
                                .font(.system(size: 28, weight: .bold, design: .default))
                                .foregroundColor(.white)
                                .underline(true, color: appTheme.colors.primary)
                        }
                        
                        Text("of your life.")
                            .font(.system(size: 15, weight: .semibold, design: .default))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
        }
        .padding(24)
        
        .background(Color.white.opacity(0.03))
        .border(Color.white.opacity(0.05), width: 0.5)
        .cornerRadius(24)
    }
    
    // MARK: - Comparison Card
    private var comparisonCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 0) {
                Text("You vs. Average")
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(appTheme.colors.primary)
                        .frame(width: 6, height: 6)
                    
                    Text("LIVE")
                        .font(.system(size: 8, weight: .bold, design: .default))
                        .tracking(1)
                        .foregroundColor(appTheme.colors.primary)
                }
            }
            
            VStack(spacing: 16) {
                // User stats
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("You")
                            .font(.system(size: 13, weight: .bold, design: .default))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("5h 12m")
                            .font(.system(size: 16, weight: .bold, design: .default))
                            .foregroundColor(appTheme.colors.primary)
                    }
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white.opacity(0.05))
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(appTheme.colors.primary)
                                .shadow(color: appTheme.colors.primary.opacity(0.4), radius: 8)
                                .frame(width: geometry.size.width * 0.65)
                        }
                    }
                    .frame(height: 12)
                }
                
                // Average stats
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Global Avg")
                            .font(.system(size: 13, weight: .bold, design: .default))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Spacer()
                        
                        Text("6h 45m")
                            .font(.system(size: 16, weight: .bold, design: .default))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white.opacity(0.05))
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white.opacity(0.2))
                                .frame(width: geometry.size.width * 0.82)
                        }
                    }
                    .frame(height: 12)
                }
            }
            
            // Insight message
            VStack(spacing: 0) {
                Divider()
                    .background(Color.white.opacity(0.05))
                    .padding(.vertical, 16)
                
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(appTheme.colors.primary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("You are spending ")
                            .font(.system(size: 13, weight: .semibold, design: .default))
                            .foregroundColor(.white.opacity(0.8)) +
                        Text("1h 33m less")
                            .font(.system(size: 13, weight: .bold, design: .default))
                            .foregroundColor(.white) +
                        Text(" than average. Great focus!")
                            .font(.system(size: 13, weight: .semibold, design: .default))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.03))
        .border(Color.white.opacity(0.05), width: 0.5)
        .cornerRadius(20)
    }
    
    // MARK: - Insight Card
    private var insightCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(appTheme.colors.primary)
                
                Text("INSIGHT")
                    .font(.system(size: 9, weight: .bold, design: .default))
                    .tracking(1.1)
                    .foregroundColor(.white.opacity(0.5))
            }
            
            // Insight text
            Text("\"Disconnecting for 30 minutes before bed improves sleep quality by ")
                .font(.system(size: 15, weight: .semibold, design: .default))
                .foregroundColor(.white.opacity(0.8)) +
            Text("20%")
                .font(.system(size: 15, weight: .bold, design: .default))
                .foregroundColor(appTheme.colors.primary) +
            Text(".\"")
                .font(.system(size: 15, weight: .semibold, design: .default))
                .foregroundColor(.white.opacity(0.8))
            
            // Reminder button
            Button(action: {}) {
                HStack(spacing: 8) {
                    Text("Set a Reminder")
                        .font(.system(size: 14, weight: .bold, design: .default))
                        .foregroundColor(appTheme.colors.primary)
                    
                    Image(systemName: "arrow.forward")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(appTheme.colors.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(appTheme.colors.primary.opacity(0.1))
                .border(appTheme.colors.primary.opacity(0.2), width: 0.5)
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.03))
        .border(Color.white.opacity(0.05), width: 0.5)
        .cornerRadius(20)
    }
}

#Preview {
    OnboardingScreen8DataReport(data: OnboardingData())
}
