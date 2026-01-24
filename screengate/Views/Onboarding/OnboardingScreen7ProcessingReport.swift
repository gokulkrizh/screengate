import SwiftUI

/// OnboardingScreen7ProcessingReport - Report Processing Animation
/// Shows animated loading state while analyzing user data
struct OnboardingScreen7ProcessingReport: View {
    @ObservedObject var data: OnboardingData
    @State private var progress: Double = 0
    @State private var completedSteps: Set<Int> = []
    @State private var isAnimating = false
    
    private let appTheme = AppTheme.shared
    
    let steps: [String] = [
        "Screen time numbers crunched",
        "Distraction patterns identified",
        "Generating insights..."
    ]
    
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
                    .offset(y: -150)
                
                Spacer()
            }
            .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                
                // Animated circular loader
                VStack(spacing: appTheme.spacing.extraLarge) {
                    ZStack {
                        // Outer pulsing rings
                        Circle()
                            .stroke(
                                appTheme.colors.primary.opacity(0.2),
                                lineWidth: 1
                            )
                            .frame(width: 280, height: 280)
                            .scaleEffect(isAnimating ? 1.5 : 1.0)
                            .opacity(isAnimating ? 0 : 0.2)
                            .animation(
                                Animation.easeOut(duration: 3).repeatForever(autoreverses: false),
                                value: isAnimating
                            )
                        
                        Circle()
                            .stroke(
                                appTheme.colors.primary.opacity(0.15),
                                lineWidth: 1
                            )
                            .frame(width: 240, height: 240)
                            .scaleEffect(isAnimating ? 1.3 : 1.0)
                            .opacity(isAnimating ? 0 : 0.15)
                            .animation(
                                Animation.easeOut(duration: 2.5).repeatForever(autoreverses: false),
                                value: isAnimating
                            )
                        
                        // Main circle
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.1, green: 0.2, blue: 0.15))
                                .frame(width: 140, height: 140)
                            
                            // Dashed border
                            Circle()
                                .stroke(
                                    style: StrokeStyle(
                                        lineWidth: 1.5,
                                        dash: [4, 6]
                                    )
                                )
                                .foregroundColor(appTheme.colors.primary.opacity(0.3))
                                .frame(width: 140, height: 140)
                                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                                .animation(
                                    Animation.linear(duration: 4).repeatForever(autoreverses: false),
                                    value: isAnimating
                                )
                            
                            // Glow effect
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            appTheme.colors.primary.opacity(0.3),
                                            appTheme.colors.primary.opacity(0.1),
                                            Color.clear
                                        ]),
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 100
                                    )
                                )
                                .frame(width: 140, height: 140)
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(
                                    Animation.easeInOut(duration: 2).repeatForever(autoreverses: true),
                                    value: isAnimating
                                )
                            
                            // Center image - clipped to circle
                            Image("processingReport")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .opacity(0.4)
                                .shadow(color: appTheme.colors.primary.opacity(0.1), radius: 15)
                            
                            Image(systemName: "brain.fill")
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundColor(appTheme.colors.primary)
                                .shadow(color: appTheme.colors.primary.opacity(0.8), radius: 15)
                        }
                    }
                    .frame(height: 200)
                    
                    // Title and subtitle
                    VStack(alignment: .center, spacing: 8) {
                        Text("Processing Your Report")
                            .font(appTheme.fonts.displaySmall)
                            .fontWeight(.bold)
                            .foregroundColor(appTheme.colors.text)
                        
                        Text("We're analyzing your daily usage patterns to personalize your digital diet.")
                            .font(appTheme.fonts.bodyLarge)
                            .foregroundColor(appTheme.colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, appTheme.spacing.large)
                }
                
                Spacer()
                
                // Glass panel with progress
                VStack(spacing: appTheme.spacing.extraLarge) {
                    // Progress section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("CALCULATING FOCUS SCORE")
                                .font(.system(size: 10, weight: .bold, design: .default))
                                .tracking(0.5)
                                .foregroundColor(appTheme.colors.primary)
                            
                            Spacer()
                            
                            Text("\(Int(progress))%")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(Color.white)
                        }
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.white.opacity(0.1))
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(appTheme.colors.primary)
                                    .frame(width: geometry.size.width * (progress / 100))
                                    .shadow(color: appTheme.colors.primary.opacity(0.6), radius: 8)
                                    .animation(.easeOut(duration: 0.15), value: progress)
                            }
                        }
                        .frame(height: 8)
                    }
                    
                    // Steps
                    VStack(spacing: appTheme.spacing.large) {
                        ForEach(0..<steps.count, id: \.self) { index in
                            HStack(spacing: appTheme.spacing.medium) {
                                // Status icon
                                if completedSteps.contains(index) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(appTheme.colors.primary)
                                        .frame(width: 20, height: 20)
                                } else {
                                    ZStack {
                                        Circle()
                                            .stroke(appTheme.colors.primary, lineWidth: 2)
                                            .frame(width: 20, height: 20)
                                        
                                        Circle()
                                            .trim(from: 0, to: 0.75)
                                            .stroke(appTheme.colors.primary, lineWidth: 2)
                                            .frame(width: 20, height: 20)
                                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                                            .animation(
                                                Animation.linear(duration: 1).repeatForever(autoreverses: false),
                                                value: isAnimating
                                            )
                                    }
                                    .frame(width: 20, height: 20)
                                }
                                
                                Text(steps[index])
                                    .font(appTheme.fonts.bodyLarge)
                                    .foregroundColor(
                                        completedSteps.contains(index)
                                            ? appTheme.colors.textSecondary.opacity(0.6)
                                            : appTheme.colors.text
                                    )
                                    .strikethrough(completedSteps.contains(index))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Spacer()
                            }
                        }
                    }
                }
                .padding(appTheme.spacing.large)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.04))
                        .backdrop()
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .padding(.horizontal, appTheme.spacing.extraLarge)
                .padding(.vertical, appTheme.spacing.extraLarge)
                
                Spacer()
            }
            .padding(.horizontal, appTheme.spacing.extraLarge)
            .padding(.vertical, appTheme.spacing.extraLarge)
        }
        .onAppear {
            isAnimating = true
            
            // Animate progress from 0 to 100 smoothly with higher frequency updates
            var currentProgress: Double = 0
            let timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
                currentProgress += 0.4
                progress = min(currentProgress, 100)
                
                if currentProgress >= 100 {
                    // Timer stops automatically when progress reaches 100
                }
            }
            
            // Complete steps at specific times: 1.67s, 3.33s, 5s
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.67) {
                completedSteps.insert(0)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.33) {
                completedSteps.insert(1)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                completedSteps.insert(2)
                timer.invalidate()
                
                // Auto-advance after progress completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        data.currentScreen = 8
                    }
                }
            }
        }
    }
}

// Backdrop effect helper
struct BackdropView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

extension View {
    func backdrop() -> some View {
        self
    }
}

#Preview {
    OnboardingScreen7ProcessingReport(data: OnboardingData())
}
