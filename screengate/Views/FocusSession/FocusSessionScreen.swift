import SwiftUI
import Combine
import FamilyControls

/// FocusSessionScreen - Active focus session running screen
/// Shows timer, restricted apps, and session controls
struct FocusSessionScreen: View {
    @Environment(BlockManager.self) private var blockManager
    @Binding var isPresented: Bool
    @State private var timeRemaining: Int = 1499 // 24:59 in seconds
    @State private var isPaused = false
    @State private var showPauseOptions = false
    @State private var slideOffset: CGFloat = 0
    @State private var selectedPauseDuration: Int = 15 // minutes
    @State private var showFocusInterruptedModal = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    private let appTheme = AppTheme.shared
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.06, green: 0.13, blue: 0.09)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("FOCUS MODE")
                            .font(.system(size: 13, weight: .bold, design: .default))
                            .tracking(0.5)
                            .foregroundColor(.white.opacity(0.8))
                        
                        HStack(spacing: 8) {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(appTheme.colors.primary)
                                    .frame(width: 6, height: 6)
                                
                                Text("ACTIVE")
                                    .font(.system(size: 10, weight: .bold, design: .default))
                                    .tracking(0.5)
                                    .foregroundColor(appTheme.colors.primary)
                            }
                            
                            Text("•")
                                .foregroundColor(.white.opacity(0.2))
                            
                            HStack(spacing: 3) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 8, weight: .bold))
                                
                                Text("Strict")
                                    .font(.system(size: 10, weight: .semibold, design: .default))
                            }
                            .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                
                Spacer()
                
                // Main Content
                VStack(spacing: 32) {
                    // Timer Circle
                    ZStack {
                        // Glow effect
                        Circle()
                            .fill(appTheme.colors.primary.opacity(0.05))
                            .blur(radius: 80)
                            .frame(width: 320, height: 320)
                        
                        // Background circle
                        Circle()
                            .stroke(Color.white.opacity(0.05), lineWidth: 6)
                            .frame(width: 288, height: 288)
                        
                        // Progress circle
                        Circle()
                            .trim(from: 0, to: progressFraction)
                            .stroke(
                                appTheme.colors.primary,
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .frame(width: 288, height: 288)
                            .rotationEffect(.degrees(-90))
                            .shadow(color: appTheme.colors.primary.opacity(0.8), radius: 8)
                        
                        // Inner breathing circle
                        Circle()
                            .stroke(Color.white.opacity(0.08), style: StrokeStyle(lineWidth: 1, dash: [4]))
                            .frame(width: 252, height: 252)
                            .opacity(0.6)
                        
                        // Timer display
                        VStack(spacing: 4) {
                            Text(timeString)
                                .font(.system(size: 64, weight: .bold, design: .default))
                                .tracking(-2)
                                .foregroundColor(.white)
                            
                            Text(blockManager.activeBlock?.name ?? "Focus Session")
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(appTheme.colors.primary.opacity(0.9))
                        }
                    }
                    .frame(height: 320)
                    
                    // Info section
                    VStack(spacing: 8) {
                        infoSection
                        
                        Text("\"Focus on being productive instead of busy.\"")
                            .font(.system(size: 12, weight: .semibold, design: .default))
                            .italic()
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    // Restricted Apps
                    VStack(spacing: 12) {
                        HStack {
                            Text("RESTRICTED APPS")
                                .font(.system(size: 11, weight: .bold, design: .default))
                                .tracking(0.5)
                                .foregroundColor(.white.opacity(0.6))
                            
                            Spacer()
                            
                            let appCount = blockManager.activeBlock?.appSelection.applicationTokens.count ?? 0
                            Text("\(appCount) Active")
                                .font(.system(size: 11, weight: .bold, design: .default))
                                .foregroundColor(appTheme.colors.primary)
                        }
                        
                        HStack(spacing: 8) {
                            ForEach(0..<4, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.08))
                                    .frame(height: 40)
                                    .overlay(
                                        Image(systemName: "app.fill")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.3))
                                    )
                            }
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.04))
                                .frame(height: 40)
                                .border(Color.white.opacity(0.05), width: 1)
                                .overlay(
                                    Text("+8")
                                        .font(.system(size: 11, weight: .bold, design: .default))
                                        .foregroundColor(.white.opacity(0.2))
                                )
                            
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Button(action: { addTime() }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text("Add 5m")
                                    .font(.system(size: 14, weight: .bold, design: .default))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .foregroundColor(.white)
                            .background(Color.white.opacity(0.05))
                            .border(Color.white.opacity(0.1), width: 0.5)
                            .cornerRadius(16)
                        }
                        
                        Button(action: { togglePause() }) {
                            HStack(spacing: 8) {
                                Image(systemName: blockManager.isPaused ? "play.circle.fill" : "pause.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text(blockManager.isPaused ? "Resume" : "Pause")
                                    .font(.system(size: 14, weight: .bold, design: .default))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .foregroundColor(.white)
                            .background(Color.white.opacity(0.05))
                            .border(Color.white.opacity(0.1), width: 0.5)
                            .cornerRadius(16)
                        }
                    }
                    
                    // Strict mode warning
                    VStack(spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.red)
                            
                            Text("STRICT MODE ACTIVE")
                                .font(.system(size: 10, weight: .bold, design: .default))
                                .tracking(0.5)
                                .foregroundColor(.red)
                            
                            Spacer()
                            
                            Text("Ending forfeits streak")
                                .font(.system(size: 10, weight: .semibold, design: .default))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            ZStack {
                                // Striped danger pattern
                                Canvas { context, size in
                                    for i in stride(from: -size.height, through: size.width, by: 20) {
                                        var path = Path()
                                        path.move(to: CGPoint(x: i, y: 0))
                                        path.addLine(to: CGPoint(x: i + size.height, y: size.height))
                                        context.stroke(
                                            path,
                                            with: .color(Color.red.opacity(0.05)),
                                            lineWidth: 10
                                        )
                                    }
                                }
                                
                                Color(red: 0.1, green: 0.05, blue: 0.05)
                                    .opacity(0.5)
                            }
                        )
                        .border(Color.red.opacity(0.2), width: 1)
                        .cornerRadius(12)
                        
                        // Slide to give up button
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background
                                Capsule()
                                    .fill(Color(red: 0.1, green: 0.05, blue: 0.05))
                                    .frame(height: 65)
                                
                                // Text
                                HStack {
                                    Spacer()
                                    
                                    Text("SLIDE TO GIVE UP")
                                        .font(.system(size: 12, weight: .bold, design: .default))
                                        .tracking(0.2)
                                        .foregroundColor(Color.red.opacity(0.6))
                                    
                                    Spacer()
                                }

                                // Striped danger pattern overlay
                                ZStack {
                                    Canvas { context, size in
                                        for i in stride(from: -size.height, through: size.width, by: 18) {
                                            var path = Path()
                                            path.move(to: CGPoint(x: i, y: 0))
                                            path.addLine(to: CGPoint(x: i + size.height, y: size.height))
                                            context.stroke(
                                                path,
                                                with: .color(Color.red.opacity(0.15)),
                                                lineWidth: 18
                                            )
                                        }
                                    }
                                    .frame(height: 78)
                                }
                                .frame(height: 65)
                                .clipShape(Capsule())
                                
                                // Slider
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color(red: 0.8, green: 0.8, blue: 0.8), Color(red: 0.95, green: 0.95, blue: 0.95)]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                        
                                        Image(systemName: "lock.open.fill")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                                    }
                                    .frame(width: 56, height: 56)
                                    .padding(4)
                                    .offset(x: slideOffset)
                                    
                                    Spacer()
                                }
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let translation = value.translation.width
                                            let maxDrag = geometry.size.width - 70 // 56 (circle) + 4 (padding) + 10 (margin)
                                            slideOffset = max(0, min(translation, maxDrag))
                                        }
                                        .onEnded { value in
                                            let maxDrag = geometry.size.width - 70
                                            if slideOffset >= maxDrag - 10 {
                                                showFocusInterruptedModal = true
                                                slideOffset = 0
                                            } else {
                                                withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                                                    slideOffset = 0
                                                }
                                            }
                                        }
                                )
                            }
                            .frame(height: 65)
                        }
                        .frame(height: 65)
                        .padding(12)
                        .shadow(color: Color.red.opacity(0.7), radius: 10, x: 0, y: 0)
                        .padding(-12)

                    }
                }
                .padding(.horizontal, 20)
                //.padding(.bottom, 32)
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .sheet(isPresented: $showPauseOptions) {
            PauseSessionModal(
                isPresented: $showPauseOptions,
                selectedDuration: $selectedPauseDuration,
                onStartBreak: { duration in
                    Task {
                        try await blockManager.pauseBlock(for: TimeInterval(duration * 60))
                    }
                    showPauseOptions = false
                }
            )
            .presentationDetents([.fraction(0.75)])
            .presentationDragIndicator(.visible)
        }
        .overlay(
            ZStack {
                if showFocusInterruptedModal {
                    Color.clear
                        .ignoresSafeArea()
                    
                    FocusInterruptedModal(
                        isPresented: $showFocusInterruptedModal,
                        onEndSession: {
                            isPresented = false
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
        )
    }
    
    // MARK: - Computed Properties
    
    private var infoSection: some View {
        if let activeBlock = blockManager.activeBlock, let duration = activeBlock.schedule.duration, duration > elapsedTime {
            let completionTime = Date(timeIntervalSinceNow: duration - elapsedTime)
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            let completionStr = formatter.string(from: completionTime)
            
            return AnyView(Text("Expected completion: \(completionStr)")
                .font(.system(size: 12, weight: .semibold, design: .default))
                .foregroundColor(.white.opacity(0.5)))
        } else {
            return AnyView(EmptyView())
        }
    }
    
    private var timeString: String {
        guard let activeBlock = blockManager.activeBlock else {
            return "00:00"
        }
        
        let remaining: TimeInterval
        if let duration = activeBlock.schedule.duration {
            remaining = max(0, duration - elapsedTime)
        } else {
            remaining = TimeInterval(timeRemaining)
        }
        
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        let seconds = Int(remaining) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private var progressFraction: Double {
        guard let activeBlock = blockManager.activeBlock, let duration = activeBlock.schedule.duration else {
            return Double(1499 - timeRemaining) / 1499.0
        }
        
        return min(elapsedTime / duration, 1.0)
    }
    
    // MARK: - Actions
    private func addTime() {
        Task {
            try await blockManager.extendBlock(by: 5)
        }
    }
    
    private func togglePause() {
        withAnimation(.easeInOut(duration: 0.3)) {
            Task {
                try await blockManager.pauseBlock(for: TimeInterval(selectedPauseDuration * 60))
            }
        }
    }
    
    private func cancelSession() {
        Task {
            try await blockManager.cancelBlock()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isPresented = false
            }
        }
    }
    
    // MARK: - Timer Management
    
    private func startTimer() {
        stopTimer()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            guard let activeBlock = blockManager.activeBlock else {
                stopTimer()
                return
            }
            
            // Calculate elapsed time based on when block was activated
            let elapsed = Date().timeIntervalSince(activeBlock.createdAt)
            elapsedTime = elapsed
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    @Previewable @State var isPresented = true
    return FocusSessionScreen(isPresented: $isPresented)
        .preferredColorScheme(.dark)
}

// MARK: - Pause Session Modal
struct PauseSessionModal: View {
    @Binding var isPresented: Bool
    @Binding var selectedDuration: Int
    @State private var showCustomDuration = false
    var onStartBreak: (Int) -> Void
    
    let durations = [5, 10, 15, 30]
    private let appTheme = AppTheme.shared
    
    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.13, blue: 0.09)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Handle
                VStack {
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 48, height: 5)
                }
                .frame(height: 20)
                
                // Header
                HStack {
                    Spacer()
                    
                    Text("Pause Session")
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Hero section
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(appTheme.colors.primary.opacity(0.1))
                                    .frame(width: 64, height: 64)
                                
                                Image(systemName: "figure.pool.float")
                                    .font(.system(size: 32, weight: .semibold))
                                    .foregroundColor(appTheme.colors.primary)
                            }
                            
                            Text("Take a breather")
                                .font(.system(size: 28, weight: .bold, design: .default))
                                .foregroundColor(.white)
                            
                            Text("How long would you like to step away?")
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        // Duration grid
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                ForEach([5, 10], id: \.self) { duration in
                                    DurationButton(
                                        duration: duration,
                                        isSelected: selectedDuration == duration,
                                        action: { selectedDuration = duration }
                                    )
                                }
                            }
                            
                            HStack(spacing: 12) {
                                ForEach([15, 30], id: \.self) { duration in
                                    DurationButton(
                                        duration: duration,
                                        isSelected: selectedDuration == duration,
                                        action: { selectedDuration = duration }
                                    )
                                }
                            }
                        }
                        
                        // Custom duration
                        Button(action: { showCustomDuration = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "pencil.and.list.clipboard")
                                    .font(.system(size: 14, weight: .semibold))
                                
                                Text("Set custom duration")
                                    .font(.system(size: 14, weight: .semibold, design: .default))
                            }
                            .foregroundColor(.white.opacity(0.5))
                        }
                        
                        // Start break button
                        Button(action: { onStartBreak(selectedDuration) }) {
                            HStack(spacing: 8) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                
                                Text("Start Break")
                                    .font(.system(size: 16, weight: .bold, design: .default))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                            .background(appTheme.colors.primary)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
            }
        }
        .sheet(isPresented: $showCustomDuration) {
            SetCustomDurationModal(
                isPresented: $showCustomDuration,
                onSetDuration: { seconds in
                    selectedDuration = seconds / 60 // Convert to minutes
                }
            )
            .presentationDetents([.fraction(0.65)])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Duration Button Component
struct DurationButton: View {
    let duration: Int
    let isSelected: Bool
    let action: () -> Void
    private let appTheme = AppTheme.shared
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text("\(duration)")
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundColor(isSelected ? appTheme.colors.primary : .white)
                
                Text("min")
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .foregroundColor(isSelected ? appTheme.colors.primary.opacity(0.8) : .white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(Color.white.opacity(isSelected ? 0.05 : 0.02))
            .border(isSelected ? appTheme.colors.primary : Color.white.opacity(0.1), width: isSelected ? 2 : 0.5)
            .cornerRadius(20)
        }
    }
}
