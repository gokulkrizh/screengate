import SwiftUI
import Combine

/// HomeScreen - Main focus/home screen after onboarding
/// Shows active session, metrics, and quick templates
struct HomeScreen: View {
    @Environment(BlockManager.self) private var blockManager
    @State private var selectedTab = 0
    @State private var showFocusSession = false
    @State private var showHowItWorks = false
    @State private var currentTime = Date()  // For live timer updates
    private let appTheme = AppTheme.shared
    
    // MARK: - Computed Properties
    
    private var elapsedTime: TimeInterval {
        guard let activeBlock = blockManager.activeBlock else { return 0 }
        
        // Calculate elapsed time from when block was created
        let elapsed = currentTime.timeIntervalSince(activeBlock.createdAt)
        
        // If paused, subtract remaining pause time
        if let pausedUntil = blockManager.pausedUntil, pausedUntil > currentTime {
            let pauseRemaining = pausedUntil.timeIntervalSince(currentTime)
            return max(0, elapsed - pauseRemaining)
        }
        
        return max(0, elapsed)
    }
    
    var body: some View {
        if showFocusSession {
            // Full screen focus session - no bottom nav
            NavigationStack {
                FocusSessionScreen(isPresented: $showFocusSession)
            }
        } else {
            // Regular home screen with tab navigation
            ZStack {
                // Background
                Color(red: 0.06, green: 0.13, blue: 0.09)
                    .ignoresSafeArea()
                
                TabView(selection: $selectedTab) {
                    // Focus Tab
                    focusContent
                        .tabItem {
                            Label("Focus", systemImage: "target")
                        }
                        .tag(0)
                    
                    // Plan Tab
                    planContent
                        .tabItem {
                            Label("Plan", systemImage: "calendar")
                        }
                        .tag(1)
                    
                    // Report Tab
                    reportContent
                        .tabItem {
                            Label("Report", systemImage: "chart.bar.fill")
                        }
                        .tag(2)
                }
                .tabViewStyle(.automatic)
                .accentColor(appTheme.colors.primary)
            }
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { time in
                currentTime = time
                // This triggers UI re-render for live timer/progress updates
            }
        }
    }
    
    // MARK: - Focus Tab Content
    private var focusContent: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(appTheme.colors.primary)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                        )
                    
                    Text("Screendiet")
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: { showHowItWorks = true }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .glassEffect()
                            
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "gear")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .glassEffect()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .sheet(isPresented: $showHowItWorks) {
                HowScreengateWorksView().presentationDragIndicator(.visible)
            }
            
            // Content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // Active Session Card
                    if let activeBlock = blockManager.activeBlock {
                        VStack(spacing: 0) {
                            HStack(spacing: 12) {
                                // Icon badge
                                ZStack {
                                    Circle()
                                        .fill(appTheme.colors.primary.opacity(0.1))
                                        .frame(width: 44, height: 44)
                                        .border(appTheme.colors.primary.opacity(0.3), width: 1)
                                    
                                    Image(systemName: "brain.head.profile")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(appTheme.colors.primary)
                                    
                                    // Pulse indicator
                                    VStack {
                                        HStack {
                                            Spacer()
                                            VStack {
                                                ZStack {
                                                    Circle()
                                                        .fill(appTheme.colors.primary)
                                                        .frame(width: 10, height: 10)
                                                        .shadow(color: appTheme.colors.primary, radius: 3)
                                                    
                                                    Circle()
                                                        .stroke(appTheme.colors.primary.opacity(0.5), lineWidth: 2)
                                                        .frame(width: 14, height: 14)
                                                        .scaleEffect(1.2)
                                                        .opacity(0.7)
                                                }
                                                Spacer()
                                            }
                                        }
                                        Spacer()
                                    }
                                    .frame(width: 44, height: 44)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(activeBlock.name)
                                        .font(.system(size: 14, weight: .bold, design: .default))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    
                                    Text(blockManager.isPaused ? "PAUSED" : "ACTIVE SESSION")
                                        .font(.system(size: 10, weight: .bold, design: .default))
                                        .tracking(0.5)
                                        .foregroundColor(blockManager.isPaused ? .orange : appTheme.colors.primary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(formatTime(elapsedTime))
                                        .font(.system(size: 20, weight: .bold, design: .default))
                                        .foregroundColor(.white)
                                    
                                    if let duration = activeBlock.schedule.duration {
                                        Text("of \(formatTime(duration)) Total")
                                            .font(.system(size: 10, weight: .semibold, design: .default))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                }
                            }
                            .padding(16)
                            
                            // Progress bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.white.opacity(0.1))
                                        .frame(height: 4)
                                    
                                    if let duration = activeBlock.schedule.duration, duration > 0 {
                                        let progress = min(elapsedTime / duration, 1.0)
                                        let barWidth = geometry.size.width * progress
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(appTheme.colors.primary)
                                            .frame(width: barWidth, height: 4)
                                            .shadow(color: appTheme.colors.primary.opacity(0.8), radius: 4)
                                    }
                                }
                            }
                            .frame(height: 4)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                        }
                        .background(Color.white.opacity(0.03))
                        .border(appTheme.colors.primary.opacity(0.2), width: 1)
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        .onTapGesture {
                            showFocusSession = true
                        }
                    } else {
                        // No active block - show empty state
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(appTheme.colors.primary.opacity(0.1))
                                    .frame(width: 56, height: 56)
                                
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(appTheme.colors.primary)
                            }
                            
                            Text("No Active Block")
                                .font(.system(size: 16, weight: .bold, design: .default))
                                .foregroundColor(.white)
                            
                            Text("Create or start a block to begin your focus session")
                                .font(.system(size: 12, weight: .regular, design: .default))
                                .foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(24)
                        .background(Color.white.opacity(0.03))
                        .border(appTheme.colors.primary.opacity(0.2), width: 1)
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                    }
                    
                    // Focus Metrics
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Focus Metrics")
                                .font(.system(size: 13, weight: .bold, design: .default))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("Today")
                                .font(.system(size: 11, weight: .semibold, design: .default))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        HStack(spacing: 12) {
                            // Score card
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .stroke(appTheme.colors.primary.opacity(0.3), lineWidth: 3)
                                        .frame(width: 48, height: 48)
                                    
                                    Circle()
                                        .trim(from: 0, to: 0.85)
                                        .stroke(appTheme.colors.primary, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                        .frame(width: 48, height: 48)
                                        .rotationEffect(.degrees(-90))
                                    
                                    Text("85")
                                        .font(.system(size: 12, weight: .bold, design: .default))
                                        .foregroundColor(.white)
                                }
                                
                                Text("SCORE")
                                    .font(.system(size: 9, weight: .bold, design: .default))
                                    .tracking(0.5)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 88)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.03))
                            .border(Color.white.opacity(0.1), width: 0.5)
                            .cornerRadius(12)
                            
                            // Screen Time card
                            VStack(spacing: 8) {
                                Image(systemName: "smartphone.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.purple)
                                    .frame(height: 48)
                                
                                Text("4h 12m")
                                    .font(.system(size: 12, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                                
                                Text("SCREEN TIME")
                                    .font(.system(size: 9, weight: .bold, design: .default))
                                    .tracking(0.5)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 88)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.03))
                            .border(Color.white.opacity(0.1), width: 0.5)
                            .cornerRadius(12)
                            
                            // Pickups card
                            VStack(spacing: 8) {
                                Image(systemName: "hand.raised.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.orange)
                                    .frame(height: 48)
                                
                                Text("42")
                                    .font(.system(size: 12, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                                
                                Text("PICKUPS")
                                    .font(.system(size: 9, weight: .bold, design: .default))
                                    .tracking(0.5)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 88)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.03))
                            .border(Color.white.opacity(0.1), width: 0.5)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Progress Overview
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Progress Overview")
                            .font(.system(size: 13, weight: .bold, design: .default))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 12) {
                            // Focus Time card
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 6) {
                                    Image(systemName: "timer.fill")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(appTheme.colors.primary)
                                    
                                    Text("FOCUS TIME")
                                        .font(.system(size: 9, weight: .bold, design: .default))
                                        .tracking(0.5)
                                        .foregroundColor(appTheme.colors.primary)
                                }
                                
                                Text("2h 15m")
                                    .font(.system(size: 20, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                                
                                // Progress bar
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.white.opacity(0.1))
                                        .frame(height: 4)
                                    
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(appTheme.colors.primary)
                                        .frame(width: 40, height: 4)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Color.white.opacity(0.03))
                            .border(Color.white.opacity(0.1), width: 0.5)
                            .cornerRadius(16)
                            
                            // Streak card
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 6) {
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.orange)
                                    
                                    Text("STREAK")
                                        .font(.system(size: 9, weight: .bold, design: .default))
                                        .tracking(0.5)
                                        .foregroundColor(.orange)
                                }
                                
                                HStack(spacing: 4) {
                                    Text("5")
                                        .font(.system(size: 20, weight: .bold, design: .default))
                                        .foregroundColor(.white)
                                    
                                    Text("Days")
                                        .font(.system(size: 12, weight: .semibold, design: .default))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                
                                Text("Personal best: 12")
                                    .font(.system(size: 10, weight: .semibold, design: .default))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Color.white.opacity(0.03))
                            .border(Color.white.opacity(0.1), width: 0.5)
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Quick Templates
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Quick Templates")
                                .font(.system(size: 13, weight: .bold, design: .default))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Text("View All")
                                    .font(.system(size: 10, weight: .bold, design: .default))
                                    .foregroundColor(appTheme.colors.primary)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                TemplateCard(
                                    icon: "brain.head.profile",
                                    title: "Deep Work",
                                    subtitle: "45 min • Strict",
                                    color: .blue
                                )
                                
                                TemplateCard(
                                    icon: "book.fill",
                                    title: "Reading",
                                    subtitle: "30 min • Soft",
                                    color: .purple
                                )
                                
                                TemplateCard(
                                    icon: "moon.stars.fill",
                                    title: "Power Nap",
                                    subtitle: "20 min • Silent",
                                    color: .indigo
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 40)
                }
                .padding(.vertical, 16)
            }
        }
        .background(Color(red: 0.06, green: 0.13, blue: 0.09))
        //.ignoresSafeArea()
    }
    
    // MARK: - Plan Tab Content
    private var planContent: some View {
        NavigationStack {
            UpcomingBlocksView()
        }
    }
    
    // MARK: - Report Tab Content
    private var reportContent: some View {
        NavigationStack {
            ReportView()
        }
        // VStack {
        //     HStack {
        //         Text("Report")
        //             .font(.system(size: 28, weight: .bold, design: .default))
        //             .foregroundColor(.white)
                
        //         Spacer()
                
        //         Button(action: {}) {
        //             Image(systemName: "gear")
        //                 .font(.system(size: 18, weight: .semibold))
        //                 .foregroundColor(.white)
        //         }
        //     }
        //     .padding(.horizontal, 20)
        //     .padding(.vertical, 16)
            
        //     Spacer()
            
        //     Text("Coming Soon")
        //         .font(.system(size: 18, weight: .semibold, design: .default))
        //         .foregroundColor(.white.opacity(0.6))
            
        //     Spacer()
        // }
        // .background(Color(red: 0.06, green: 0.13, blue: 0.09))
        // .ignoresSafeArea()
    }
    
    // MARK: - Helper Functions
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}
#Preview {
    HomeScreen()
        .preferredColorScheme(.dark)
}
