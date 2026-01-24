import SwiftUI

/// OnboardingScreen12SolutionPreview - Solution Preview Screen
/// Shows the personalized plan with potential focus time gains and strategy recommendations
struct OnboardingScreen12SolutionPreview: View {
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
                   // .frame(width: 500, height: 500)
                    .offset(y: -150)
                
                Spacer()
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with back button and centered progress
                VStack(spacing: 12) {
                    ZStack {
                        HStack {
                            BackButton {
                                data.currentScreen -= 1
                            }

                            Spacer()
                        }
                        
                        ProgressIndicatorHeader(currentStep: 11, totalSteps: 10)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 12)
                
                // Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Title
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 0) {
                                    Text(makeHeadline())
                                         .font(appTheme.fonts.displaySmall)
                                        //.foregroundColor(.white)
                                    
                                    // Text("Focus")
                                    //     .font(.system(size: 28, weight: .bold, design: .default))
                                    //     .foregroundColor(appTheme.colors.primary)
                                }
                                
                                // Text(".")
                                //     .font(.system(size: 28, weight: .bold, design: .default))
                                //     .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(makeSubHeadline())
                                    .font(appTheme.fonts.bodyLarge)
                                    .foregroundColor(appTheme.colors.textSecondary)
                                
                                // HStack(spacing: 4) {
                                //     Text("14 hours")
                                //         .font(.system(size: 14, weight: .bold, design: .default))
                                //         .foregroundColor(.white)
                                    
                                //     Text("this week.")
                                //         .font(.system(size: 14, weight: .semibold, design: .default))
                                //         .foregroundColor(.white.opacity(0.6))
                                // }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Focus Time Card
                        focusTimeCard
                        
                        // Strategy Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Your Strategy")
                                    .font(appTheme.fonts.titleMedium)
                                    .foregroundColor(appTheme.colors.text)
                                
                                Spacer()
                            }
                            
                            strategyCard(
                                icon: "app_blocking",
                                title: "Strict App Limits",
                                description: "Stop doomscrolling automatically."
                            )
                            
                            strategyCard(
                                icon: "do_not_disturb_on",
                                title: "Deep Focus Mode",
                                description: "Block distractions during work hours."
                            )
                            
                            strategyCard(
                                icon: "analytics",
                                title: "Daily Insights",
                                description: "Track your reclaimed time daily."
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Testimonial
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: "quote.opening")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(appTheme.colors.primary)
                                
                                Text("I didn't realize how much time I was losing until I saw the data. Screendiet changed my daily routine.")
                                    .font(.system(size: 13, weight: .semibold, design: .default))
                                    .foregroundColor(.white.opacity(0.7))
                                    .italic()
                            }
                            
                            HStack(spacing: 8) {
                                Capsule()
                                    .fill(appTheme.colors.primary.opacity(0.4))
                                    .frame(width: 24, height: 1)
                                
                                Text("SARAH K., BETA USER")
                                    .font(.system(size: 10, weight: .bold, design: .default))
                                    .tracking(0.8)
                                    .foregroundColor(appTheme.colors.primary)
                            }
                            .padding(.top, 4)
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.03))
                        .border(Color.white.opacity(0.05), width: 0.5)
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
                
                // Continue button
                VStack(spacing: 12) {
                    PrimaryButton(
                        title: "Set Up My Screen Diet",
                        action: {
                            data.currentScreen += 1
                        }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
    }
    
    // MARK: - Focus Time Card
    private var focusTimeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "timelapse")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(appTheme.colors.primary)
                    
                    Text("POTENTIAL FOCUS TIME")
                        .font(.system(size: 9, weight: .bold, design: .default))
                        .tracking(1)
                        .foregroundColor(.white.opacity(0.5))
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("+2.5 hrs")
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    Text("/day")
                        .font(.system(size: 13, weight: .semibold, design: .default))
                        .foregroundColor(.white.opacity(0.5))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "trending.up")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(appTheme.colors.primary)
                        
                        Text("25%")
                            .font(.system(size: 13, weight: .bold, design: .default))
                            .foregroundColor(appTheme.colors.primary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(appTheme.colors.primary.opacity(0.15))
                    .border(appTheme.colors.primary.opacity(0.2), width: 0.5)
                    .cornerRadius(8)
                }
            }
            
            // Line chart visualization
            VStack(spacing: 8) {
                ZStack(alignment: .bottom) {
                    // Grid background
                    GeometryReader { geometry in
                        VStack(spacing: 0) {
                            ForEach(0..<4, id: \.self) { index in
                                if index > 0 {
                                    Rectangle()
                                        .fill(Color.white.opacity(0.08))
                                        .frame(height: 1)
                                }
                                if index < 3 {
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    // Line chart path
                    Canvas { context, size in
                        var path = Path()
                        
                        let chartHeight = size.height * 0.7
                        let chartBottom = size.height * 0.9
                        
                        // Points: now, wk1, wk2, wk3, goal
                        // Start line near the "NOW" text position (lower on chart)
                        let points: [(x: CGFloat, y: CGFloat)] = [
                            (x: 0, y: chartBottom - chartHeight * 0.10),
                            (x: size.width * 0.2, y: chartBottom - chartHeight * 0.5),
                            (x: size.width * 0.35, y: chartBottom - chartHeight * 0.45),
                            (x: size.width * 0.55, y: chartBottom - chartHeight * 0.80),
                            (x: size.width * 0.65, y: chartBottom - chartHeight * 0.78),
                            (x: size.width, y: chartBottom - chartHeight * 1.10)
                        ]
                        
                        // Draw smooth curve with more pronounced curves
                        if let first = points.first {
                            path.move(to: CGPoint(x: first.x, y: first.y))
                        }
                        
                        for i in 1..<points.count {
                            let current = points[i]
                            let previous = points[i - 1]
                            let midX = (previous.x + current.x) / 2
                            
                            // Create more pronounced curves
                            let control1X = previous.x + (midX - previous.x) * 0.7
                            let control2X = current.x - (current.x - midX) * 0.7
                            
                            path.addCurve(
                                to: CGPoint(x: current.x, y: current.y),
                                control1: CGPoint(x: control1X, y: previous.y),
                                control2: CGPoint(x: control2X, y: current.y)
                            )
                        }
                        
                        // Draw main line
                        context.stroke(
                            path,
                            with: .color(appTheme.colors.primary),
                            lineWidth: 3
                        )
                        
                        // Draw gradient fill under curve - larger portion
                        var fillPath = path
                        if let last = points.last {
                            fillPath.addLine(to: CGPoint(x: last.x, y: chartBottom))
                            fillPath.addLine(to: CGPoint(x: 0, y: chartBottom))
                        }
                        fillPath.closeSubpath()
                        
                        // Create gradient with even more gradual fade over larger area
                        let gradient = Gradient(stops: [
                            .init(color: appTheme.colors.primary.opacity(0.4), location: 0.0),
                            .init(color: appTheme.colors.primary.opacity(0.32), location: 0.15),
                            .init(color: appTheme.colors.primary.opacity(0.24), location: 0.3),
                            .init(color: appTheme.colors.primary.opacity(0.16), location: 0.45),
                            .init(color: appTheme.colors.primary.opacity(0.1), location: 0.6),
                            .init(color: appTheme.colors.primary.opacity(0.05), location: 0.75),
                            .init(color: appTheme.colors.primary.opacity(0.02), location: 0.9),
                            .init(color: appTheme.colors.primary.opacity(0.0), location: 1.0)
                        ])
                        
                        let startPoint = CGPoint(x: size.width / 2, y: 0)
                        let endPoint = CGPoint(x: size.width / 2, y: chartBottom)
                        
                        context.fill(
                            fillPath,
                            with: .linearGradient(
                                gradient,
                                startPoint: startPoint,
                                endPoint: endPoint
                            )
                        )
                        
                        // Draw end point circles
                        if let last = points.last {
                            // Outer glow
                            // context.fill(
                            //     Path(ellipseIn: CGRect(x: last.x - 8, y: last.y - 8, width: 16, height: 16)),
                            //     with: .color(appTheme.colors.primary.opacity(0.4))
                            // )
                            
                            // Main circle
                            context.fill(
                                Path(ellipseIn: CGRect(x: last.x - 10, y: last.y - 5, width: 10, height: 10)),
                                with: .color(appTheme.colors.primary)
                            )
                            
                            // Inner black circle
                            context.fill(
                                Path(ellipseIn: CGRect(x: last.x - 7.5, y: last.y - 2.5, width: 5, height: 5)),
                                with: .color(Color.black)
                            )
                        }
                    }
                    .frame(height: 140)
                    .padding(.top, 10)
                    .padding(.horizontal, 0)
                }
                .frame(height: 150)
                
                HStack(spacing: 0) {
                    Text("NOW")
                        .font(.system(size: 9, weight: .bold, design: .default))
                        .tracking(0.5)
                        .foregroundColor(.white.opacity(0.3))
                    
                    Spacer()
                    
                    Text("WK 1")
                        .font(.system(size: 9, weight: .bold, design: .default))
                        .tracking(0.5)
                        .foregroundColor(.white.opacity(0.3))
                    
                    Spacer()
                    
                    Text("WK 2")
                        .font(.system(size: 9, weight: .bold, design: .default))
                        .tracking(0.5)
                        .foregroundColor(.white.opacity(0.3))
                    
                    Spacer()
                    
                    Text("WK 3")
                        .font(.system(size: 9, weight: .bold, design: .default))
                        .tracking(0.5)
                        .foregroundColor(.white.opacity(0.3))
                    
                    Spacer()
                    
                    Text("GOAL")
                        .font(.system(size: 9, weight: .bold, design: .default))
                        .tracking(0.5)
                        .foregroundColor(appTheme.colors.primary)
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.03))
        .border(Color.white.opacity(0.05), width: 0.5)
        .cornerRadius(20)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Strategy Card Component
    private func strategyCard(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(appTheme.colors.primary.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(appTheme.colors.primary)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 12, weight: .semibold, design: .default))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.03))
        .border(Color.white.opacity(0.05), width: 0.5)
        .cornerRadius(14)
    }

     private func makeHeadline() -> AttributedString {
        var full = AttributedString("We've built a plan for your Focus.")
        
        // Apply base color to entire string
        full.foregroundColor = appTheme.colors.text
        
        // Highlight the word "Focus"
        if let range = full.range(of: "Focus") {
            full[range].foregroundColor = appTheme.colors.primary
        }
        
        return full
    }

    private func makeSubHeadline() -> AttributedString {
        var full = AttributedString("Based on your answers, Screendiet can help you reclaim 14 hours this week.")
        
        // Apply base color to entire string
        full.foregroundColor = appTheme.colors.text
        
        // Highlight the word "Focus"
        if let range = full.range(of: "14 hours") {
            full[range].foregroundColor = appTheme.colors.primary
        }
        
        return full
    }
}

#Preview {
    OnboardingScreen12SolutionPreview(data: OnboardingData())
}
