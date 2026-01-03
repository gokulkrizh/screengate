import SwiftUI

/// OnboardingScreen11CreatingPlan - Plan Creation Processing Screen
/// Shows animated processing state while creating personalized plan
struct OnboardingScreen11CreatingPlan: View {
    @ObservedObject var data: OnboardingData
    @State private var progress: Double = 0
    @State private var isSpinning = false
    @State private var currentStep: Int = 0 // 0 = goal analysis, 1 = optimizing, 2 = finalizing
    
    private let appTheme = AppTheme.shared
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.06, green: 0.13, blue: 0.09)
                .ignoresSafeArea()
            
            // Decorative gradient blobs
            VStack {
                Circle()
                    .fill(appTheme.colors.primary.opacity(0.05))
                    .blur(radius: 100)
                    //.frame(width: 500, height: 500)
                    .offset(x: 100, y: -100)
                
                Spacer()
                
                Circle()
                    .fill(appTheme.colors.primary.opacity(0.08))
                    .blur(radius: 80)
                    .frame(width: 400, height: 400)
                    .offset(x: -150, y: 100)
            }
            .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                Spacer()
                
                // Animated loading circle
                VStack(spacing: 32) {
                    ZStack(alignment: .center) {
                        // Outer rotating ring
                        Circle()
                            .stroke(appTheme.colors.primary.opacity(0.4), lineWidth: 1.5)
                            .frame(width: 240, height: 240)
                        
                        // Middle rotating ring (darker)
                        Circle()
                            .stroke(appTheme.colors.primary.opacity(0.2), lineWidth: 1)
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(isSpinning ? 360 : 0))
                            .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: isSpinning)
                        
                        // Inner pulsing circle
                        Circle()
                            .stroke(appTheme.colors.primary.opacity(0.3), lineWidth: 1)
                            .frame(width: 120, height: 120)
                            .scaleEffect(isSpinning ? 1.05 : 0.95)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isSpinning)
                        
                        // Center circle
                        Circle()
                            .fill(Color(red: 0.06, green: 0.13, blue: 0.09))
                            .frame(width: 100, height: 100)
                            .border(appTheme.colors.primary.opacity(0.3), width: 2)
                            .overlay(
                                Image(systemName: "sparkles")
                                    .font(.system(size: 36, weight: .semibold))
                                    .foregroundColor(appTheme.colors.primary)
                            )
                        
                        // Processing badge
                        VStack(spacing: 4) {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(appTheme.colors.primary)
                                    .frame(width: 8, height: 8)
                                    .overlay(
                                        Circle()
                                            .stroke(appTheme.colors.primary, lineWidth: 1)
                                            .scaleEffect(isSpinning ? 1.5 : 1.0)
                                            .opacity(isSpinning ? 0 : 1)
                                            .animation(.easeOut(duration: 1).repeatForever(autoreverses: false), value: isSpinning)
                                    )
                                
                                Text("PROCESSING")
                                    .font(.system(size: 10, weight: .bold, design: .default))
                                    .tracking(1.2)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.1))
                            .border(appTheme.colors.primary.opacity(0.2), width: 0.5)
                            .cornerRadius(20)
                        }
                        .offset(y: 75)
                    }
                    
                    // Title and description
                    VStack(spacing: 12) {
                        VStack(spacing: 4) {
                            Text("Creating Your")
                                .font(.system(size: 28, weight: .bold, design: .default))
                                .foregroundColor(.white)
                            
                            Text("Personalized Plan")
                                .font(.system(size: 28, weight: .bold, design: .default))
                                .foregroundColor(appTheme.colors.primary)
                        }
                        
                        Text("We're tailoring your Screendiet schedule to align perfectly with your focus goals.")
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Progress section
                VStack(spacing: 16) {
                    // Progress bar
                    VStack(spacing: 8) {
                        HStack {
                            Text("ANALYSIS COMPLETE")
                                .font(.system(size: 9, weight: .bold, design: .default))
                                .tracking(1)
                                .foregroundColor(.white.opacity(0.5))
                            
                            Spacer()
                            
                            Text("\(Int(progress))%")
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(.white)
                        }
                        
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.05))
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(appTheme.colors.primary)
                                .shadow(color: appTheme.colors.primary.opacity(0.5), radius: 6)
                                .frame(width: nil, alignment: .leading)
                                .onAppear {
                                    isSpinning = true
                                }
                        }
                        .frame(height: 10)
                        .scaleEffect(x: progress / 100, anchor: .leading)
                    }
                    
                    // Status items
                    VStack(spacing: 12) {
                        // Step 1: Goal analysis complete
                        statusItem(
                            icon: "checkmark",
                            title: "Goal analysis complete",
                            isActive: currentStep == 0,
                            isCompleted: currentStep > 0
                        )
                        
                        // Step 2: Optimizing schedule
                        statusItem(
                            icon: "arrow.triangle.2.circlepath",
                            title: "Optimizing your schedule...",
                            isActive: currentStep == 1,
                            isCompleted: currentStep > 1
                        )
                        
                        // Step 3: Finalizing dashboard
                        statusItem(
                            icon: "circle",
                            title: "Finalizing dashboard",
                            isActive: currentStep == 2,
                            isCompleted: currentStep > 2
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            isSpinning = true
            
            // Animate progress from 0 to 100 over 5 seconds
            let timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                if progress < 100 {
                    progress += 1
                    
                    // Update step at 33% (1.67s)
                    if progress >= 33 && currentStep == 0 {
                        currentStep = 1
                    }
                    // Update step at 66% (3.33s)
                    else if progress >= 66 && currentStep == 1 {
                        currentStep = 2
                    }
                    // Mark all as completed at 100%
                    else if progress >= 100 && currentStep == 2 {
                        currentStep = 3
                    }
                } else {
                    // Auto-advance after progress completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        data.currentScreen += 1
                    }
                }
            }
            
            // Invalidate timer after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.05) {
                timer.invalidate()
            }
        }
    }
    
    // MARK: - Status Item Component
    private func statusItem(icon: String, title: String, isActive: Bool, isCompleted: Bool) -> some View {
        HStack(spacing: 12) {
            // Icon circle
            ZStack {
                if isActive {
                    Circle()
                        .fill(appTheme.colors.primary.opacity(0.15))
                } else if isCompleted {
                    Circle()
                        .fill(appTheme.colors.primary)
                } else {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                }
                
                if isActive {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(appTheme.colors.primary)
                        .modifier(RotatingModifier(isActive: isActive))
                } else if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color.white.opacity(0.3))
                }
            }
            .frame(width: 28, height: 28)
            
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .default))
                .foregroundColor(
                    isActive ? .white :
                    isCompleted ? .white.opacity(0.7) :
                    Color.white.opacity(0.4)
                )
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            isActive ?
            appTheme.colors.primary.opacity(0.1) :
            Color.white.opacity(0.03)
        )
        .border(
            isActive ? appTheme.colors.primary : Color.white.opacity(0.05),
            width: isActive ? 1.5 : 0.5
        )
        .cornerRadius(12)
        .opacity(isActive || isCompleted ? 1.0 : 0.5)
    }
}

// MARK: - Rotating Modifier
struct RotatingModifier: ViewModifier {
    @State private var rotation: Double = 0
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotation))
            .onAppear {
                if isActive {
                    startRotation()
                }
            }
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    rotation = 0
                    startRotation()
                }
            }
    }
    
    private func startRotation() {
        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
            rotation = 360
        }
    }
}

#Preview {
    OnboardingScreen11CreatingPlan(data: OnboardingData())
}
