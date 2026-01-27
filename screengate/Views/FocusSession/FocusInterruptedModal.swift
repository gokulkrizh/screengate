import SwiftUI
import Combine

struct FocusInterruptedModal: View {
    @Binding var isPresented: Bool
    let strictMode: StrictMode
    @State private var countdownTimer: Int = 15
    @State private var confirmationText: String = ""
    @State private var timerSubscription: AnyCancellable?
    var onEndSession: () -> Void
    
    private let appTheme = AppTheme.shared
    
    var isConfirmationValid: Bool {
        strictMode == .hard ? confirmationText.uppercased() == "I FORFEIT" : true
    }
    
    var isEndButtonEnabled: Bool {
        switch strictMode {
        case .easy:
            return true
        case .medium:
            return countdownTimer == 0
        case .hard:
            return countdownTimer == 0 && isConfirmationValid
        }
    }
    
    var body: some View {
        ZStack {
            // Blurred backdrop
            Color.black.opacity(0.8)
                .blur(radius: 10)
                .ignoresSafeArea()
            
            // Centered modal
            VStack(spacing: 0) {
                // Modal content - Different UI based on strictMode
                if strictMode == .easy {
                    easyModeContent
                } else {
                    mediumAndHardModeContent
                }
                
                Spacer()
            }
        }
        .onAppear {
            countdownTimer = (strictMode == .easy) ? 0 : 15
            
            // Start countdown timer for MEDIUM and HARD modes
            if strictMode != .easy {
                startCountdownTimer()
            }
        }
        .onDisappear {
            timerSubscription?.cancel()
        }
    }
    
    // MARK: - Timer Management
    
    private func startCountdownTimer() {
        timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if countdownTimer > 0 {
                    countdownTimer -= 1
                }
            }
    }
    
    // MARK: - Easy Mode Content (No countdown, immediate end)
    
    private var easyModeContent: some View {
        VStack(spacing: 20) {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.1))
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.orange)
                    }
                    
                    VStack(spacing: 4) {
                        Text("End Session?")
                            .font(.system(size: 20, weight: .bold, design: .default))
                            .foregroundColor(.white)
                        
                        Text("Are you sure you want to end this session?")
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                // Simple streak info
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        VStack(spacing: 8) {
                            Text("CURRENT")
                                .font(.system(size: 10, weight: .bold, design: .default))
                                .tracking(0.5)
                                .foregroundColor(.white.opacity(0.5))
                            
                            HStack(spacing: 6) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.orange)
                                
                                Text("12")
                                    .font(.system(size: 24, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Day Streak")
                                .font(.system(size: 11, weight: .semibold, design: .default))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(spacing: 8) {
                            Text("AFTER EXIT")
                                .font(.system(size: 10, weight: .bold, design: .default))
                                .tracking(0.5)
                                .foregroundColor(.red.opacity(0.6))
                            
                            HStack(spacing: 6) {
                                Image(systemName: "x.circle.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.red)
                                
                                Text("0")
                                    .font(.system(size: 24, weight: .bold, design: .default))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            
                            Text("Streak Lost")
                                .font(.system(size: 11, weight: .semibold, design: .default))
                                .foregroundColor(.red.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(12)
                .background(Color.black.opacity(0.4))
                .border(Color.red.opacity(0.1), width: 1)
                .cornerRadius(12)
            }
            .padding(16)
            .background(
                ZStack {
                    Canvas { context, size in
                        for i in stride(from: -size.height, through: size.width, by: 20) {
                            var path = Path()
                            path.move(to: CGPoint(x: i, y: 0))
                            path.addLine(to: CGPoint(x: i + size.height, y: size.height))
                            context.stroke(
                                path,
                                with: .color(Color.red.opacity(0.08)),
                                lineWidth: 10
                            )
                        }
                    }
                    
                    Color(red: 0.15, green: 0.05, blue: 0.05)
                        .opacity(0.6)
                }
            )
            .cornerRadius(16)
            
            // Buttons - Easy mode: both enabled immediately
            HStack(spacing: 12) {
                Button(action: { isPresented = false }) {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 12, weight: .semibold))
                        
                        Text("Resume")
                            .font(.system(size: 16, weight: .bold, design: .default))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                    .background(appTheme.colors.primary)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    onEndSession()
                    isPresented = false
                }) {
                    Text("End Session")
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .foregroundColor(.red)
                        .background(Color.red.opacity(0.08))
                        .border(Color.red.opacity(0.3), width: 1)
                        .cornerRadius(12)
                }
            }
            .padding(20)
        }
        .background(Color(red: 0.06, green: 0.13, blue: 0.09))
        .cornerRadius(24)
        .padding(20)
    }
    
    // MARK: - Medium & Hard Mode Content (Countdown + optional text)
    
    private var mediumAndHardModeContent: some View {
        VStack(spacing: 20) {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.1))
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.red)
                    }
                    
                    VStack(spacing: 4) {
                        Text("Focus Interrupted?")
                            .font(.system(size: 20, weight: .bold, design: .default))
                            .foregroundColor(.white)
                        
                        Text("Ending this session early has consequences.")
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                // Streak comparison
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        VStack(spacing: 8) {
                            Text("CURRENT")
                                .font(.system(size: 10, weight: .bold, design: .default))
                                .tracking(0.5)
                                .foregroundColor(.white.opacity(0.5))
                            
                            HStack(spacing: 6) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.orange)
                                
                                Text("12")
                                    .font(.system(size: 24, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Day Streak")
                                .font(.system(size: 11, weight: .semibold, design: .default))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(spacing: 8) {
                            Text("AFTER EXIT")
                                .font(.system(size: 10, weight: .bold, design: .default))
                                .tracking(0.5)
                                .foregroundColor(.red.opacity(0.6))
                            
                            HStack(spacing: 6) {
                                Image(systemName: "x.circle.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.red)
                                
                                Text("0")
                                    .font(.system(size: 24, weight: .bold, design: .default))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            
                            Text("Streak Lost")
                                .font(.system(size: 11, weight: .semibold, design: .default))
                                .foregroundColor(.red.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(12)
                .background(Color.black.opacity(0.4))
                .border(Color.red.opacity(0.1), width: 1)
                .cornerRadius(12)
            }
            .padding(16)
            .background(
                ZStack {
                    Canvas { context, size in
                        for i in stride(from: -size.height, through: size.width, by: 20) {
                            var path = Path()
                            path.move(to: CGPoint(x: i, y: 0))
                            path.addLine(to: CGPoint(x: i + size.height, y: size.height))
                            context.stroke(
                                path,
                                with: .color(Color.red.opacity(0.08)),
                                lineWidth: 10
                            )
                        }
                    }
                    
                    Color(red: 0.15, green: 0.05, blue: 0.05)
                        .opacity(0.6)
                }
            )
            .cornerRadius(16)
            
            // Delayed confirmation - shown for both MEDIUM and HARD
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 3)
                        .frame(width: 48, height: 48)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(15 - countdownTimer) / 15)
                        .stroke(Color.white.opacity(0.4), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 48, height: 48)
                        .rotationEffect(.degrees(-90))
                    
                    Text(String(format: "%02d:%02d", countdownTimer / 60, countdownTimer % 60))
                        .font(.system(size: 12, weight: .bold, design: .default))
                        .foregroundColor(.white.opacity(0.6))
                        .monospacedDigit()
                }
                
                VStack(spacing: 4) {
                    Text("Delayed Confirmation")
                        .font(.system(size: 14, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    Text("Wait for the countdown to unlock the exit confirmation.")
                        .font(.system(size: 12, weight: .semibold, design: .default))
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(2)
                }
            }
            .padding(12)
            .background(Color(red: 0.06, green: 0.13, blue: 0.09).opacity(0.5))
            .border(Color.white.opacity(0.08), width: 1)
            .cornerRadius(12)
            
            // Challenge section - only show for HARD mode
            if strictMode == .hard {
                VStack(spacing: 12) {
                    HStack {
                        Text("STRICT MODE CHALLENGE")
                            .font(.system(size: 10, weight: .bold, design: .default))
                            .tracking(0.5)
                            .foregroundColor(.white.opacity(0.5))
                        
                        Spacer()
                        
                        Text("REQUIRED")
                            .font(.system(size: 10, weight: .bold, design: .default))
                            .tracking(0.5)
                            .foregroundColor(.red)
                    }
                    
                    HStack {
                        TextField("Type 'I FORFEIT'", text: $confirmationText)
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.4))
                            .border(isConfirmationValid ? Color.white.opacity(0.2) : Color.white.opacity(0.05), width: 1)
                            .cornerRadius(10)
                        
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.3))
                    }
                    
                    Text("Prove your intent to exit.")
                        .font(.system(size: 11, weight: .semibold, design: .default))
                        .foregroundColor(.white.opacity(0.3))
                }
                .padding(20)
            }
            
            // Buttons
            HStack(spacing: 12) {
                Button(action: { isPresented = false }) {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 12, weight: .semibold))
                        
                        Text("Resume")
                            .font(.system(size: 16, weight: .bold, design: .default))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                    .background(appTheme.colors.primary)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    if isEndButtonEnabled {
                        onEndSession()
                        isPresented = false
                    }
                }) {
                    Text("End Session")
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .foregroundColor(.red.opacity(isEndButtonEnabled ? 1 : 0.3))
                        .background(Color.red.opacity(0.08))
                        .border(Color.red.opacity(isEndButtonEnabled ? 0.3 : 0.1), width: 1)
                        .cornerRadius(12)
                }
                .disabled(!isEndButtonEnabled)
            }
            .padding(20)
        }
        .background(Color(red: 0.06, green: 0.13, blue: 0.09))
        .cornerRadius(24)
        .padding(20)
    }
}

#Preview {
    @Previewable @State var isPresented = true
    return ZStack {
        Color(red: 0.06, green: 0.13, blue: 0.09).ignoresSafeArea()
        
        FocusInterruptedModal(
            isPresented: $isPresented,
            strictMode: .hard,
            onEndSession: {}
        )
    }
}
