import SwiftUI

struct UpcomingBlocksView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showCreateBlock = false
    @State private var showScheduledBlock = false
    @State private var showOpenLimit = false
    @State private var showAppTimeLimit = false
    @State private var showBlockNow = false
    private let appTheme = AppTheme.shared
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.06, green: 0.13, blue: 0.09)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top App Bar
                HStack {
                    // Back Button
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(20)
                    }
                    
                    Spacer()
                    
                    // Title
                    Text("Upcoming Blocks")
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Add Button
                    Button(action: { showCreateBlock = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                            .frame(width: 40, height: 40)
                            .background(appTheme.colors.primary)
                            .cornerRadius(20)
                            .shadow(color: appTheme.colors.primary.opacity(0.3), radius: 8, x: 0, y: 0)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(red: 0.06, green: 0.13, blue: 0.09).opacity(0.9))
                .overlay(
                    Rectangle()
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 0.5),
                    alignment: .bottom
                )
                
                // Scrollable Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Today Section
                        sectionHeader(title: "Today", date: "Wed, Oct 24")
                        
                        // Morning Focus Block (Active)
                        TimelineBlockView(
                            icon: "briefcase.fill",
                            iconColor: appTheme.colors.primary,
                            title: "Morning Focus",
                            status: "IN PROGRESS",
                            timeRange: "09:00 AM - 11:00 AM",
                            duration: nil,
                            isActive: true,
                            isFirst: true,
                            isLast: false,
                            actionIcon: "ellipsis"
                        )
                        
                        // No Social Media Block
                        TimelineBlockView(
                            icon: "nosign",
                            iconColor: Color.gray,
                            title: "No Social Media",
                            subtitle: "Detox session",
                            timeRange: "01:00 PM - 02:00 PM",
                            duration: "1h",
                            isActive: false,
                            isFirst: false,
                            isLast: false,
                            actionIcon: "chevron.right"
                        )
                        
                        // End cap for today
                        HStack(spacing: 0) {
                            VStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 6, height: 6)
                                    .padding(.top, -10)
                            }
                            .frame(width: 50)
                            
                            Spacer()
                        }
                        .padding(.bottom, 32)
                        
                        // Tomorrow Section
                        sectionHeader(title: "Tomorrow", date: "Thu, Oct 25")
                        
                        // Sleep Mode Block
                        TimelineBlockView(
                            icon: "moon.fill",
                            iconColor: Color.gray,
                            title: "Sleep Mode",
                            subtitle: "Recurring • Daily",
                            timeRange: "10:00 PM - 07:00 AM",
                            duration: nil,
                            isActive: false,
                            isFirst: true,
                            isLast: true,
                            actionIcon: "pencil",
                            isFuture: true
                        )
                        
                        // Empty State
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(appTheme.colors.primary.opacity(0.2))
                                    .frame(width: 48, height: 48)
                                
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(appTheme.colors.primary)
                            }
                            
                            Text("Plan ahead to stay focused.")
                                .font(.system(size: 14, weight: .medium, design: .default))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Button(action: {}) {
                                Text("Schedule a new block")
                                    .font(.system(size: 14, weight: .bold, design: .default))
                                    .foregroundColor(appTheme.colors.primary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                        .padding(.horizontal, 20)
                        .background(Color.white.opacity(0.03))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                .foregroundColor(Color.white.opacity(0.1))
                        )
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showCreateBlock) {
            CreateBlockView(
                onScheduled: {
                    showCreateBlock = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showScheduledBlock = true
                    }
                },
                onOpenLimit: {
                    showCreateBlock = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showOpenLimit = true
                    }
                },
                onAppTimeLimit: {
                    showCreateBlock = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showAppTimeLimit = true
                    }
                },
                onBlockNow: {
                    showCreateBlock = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showBlockNow = true
                    }
                }
            )
            .presentationDetents([.fraction(0.83)])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color(red: 0.06, green: 0.13, blue: 0.09))
        }
        .fullScreenCover(isPresented: $showScheduledBlock) {
            CreateScheduledBlockView()
        }
        .fullScreenCover(isPresented: $showOpenLimit) {
            CreateOpenLimitView()
        }
        .fullScreenCover(isPresented: $showAppTimeLimit) {
            CreateAppTimeLimitView()
        }
        .fullScreenCover(isPresented: $showBlockNow) {
            CreateBlockNowView()
        }
    }
    
    // MARK: - Section Header
    private func sectionHeader(title: String, date: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .default))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(date)
                .font(.system(size: 14, weight: .medium, design: .default))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
}

// MARK: - Timeline Block Component
struct TimelineBlockView: View {
    let icon: String
    let iconColor: Color
    let title: String
    var subtitle: String? = nil
    var status: String? = nil
    let timeRange: String
    var duration: String? = nil
    let isActive: Bool
    let isFirst: Bool
    let isLast: Bool
    let actionIcon: String
    var isFuture: Bool = false
    
    private let appTheme = AppTheme.shared
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Timeline Graphic
            VStack(spacing: 0) {
                // Top Line
                if !isFirst {
                    Rectangle()
                        .fill(Color.white.opacity(isFuture ? 0.05 : 0.1))
                        .frame(width: 2)
                        .frame(height: 8)
                        .offset(y: -8)
                } else {
                    Rectangle()
                        .fill(Color.white.opacity(isFuture ? 0.05 : 0.1))
                        .frame(width: 2, height: 24)
                        .cornerRadius(1)
                }
                
                // Icon Circle
                ZStack {
                    Circle()
                        .fill(Color(red: 0.09, green: 0.16, blue: 0.12))
                        .frame(width: 40, height: 40)
                    
                    if isActive {
                        Circle()
                            .stroke(appTheme.colors.primary, lineWidth: 2)
                            .frame(width: 40, height: 40)
                    } else {
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            .frame(width: 40, height: 40)
                    }
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                // Bottom Line
                if !isLast {
                    Rectangle()
                        .fill(Color.white.opacity(isFuture ? 0.05 : 0.1))
                        .frame(width: 2)
                        .cornerRadius(1)
                }
            }
            .frame(width: 50)
            .padding(.leading, 0)
            
            // Content Card
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .leading) {
                    // Card Background
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.09, green: 0.16, blue: 0.12))
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    // Active Indicator Strip
                    if isActive {
                        Rectangle()
                            .fill(appTheme.colors.primary)
                            .frame(width: 3)
                            .cornerRadius(1.5)
                    }
                    
                    // Card Content
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(.white)
                            
                            if let status = status {
                                Text(status)
                                    .font(.system(size: 11, weight: .bold, design: .default))
                                    .tracking(0.5)
                                    .foregroundColor(appTheme.colors.primary)
                            } else if let subtitle = subtitle {
                                Text(subtitle)
                                    .font(.system(size: 14, weight: .regular, design: .default))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            
                            // Time and Duration
                            HStack(spacing: 16) {
                                HStack(spacing: 6) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.5))
                                    
                                    Text(timeRange)
                                        .font(.system(size: 14, weight: .medium, design: .default))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.03))
                                .cornerRadius(8)
                                
                                if let duration = duration {
                                    HStack(spacing: 6) {
                                        Image(systemName: "hourglass")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.5))
                                        
                                        Text(duration)
                                            .font(.system(size: 14, weight: .medium, design: .default))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(.leading, isActive ? 12 : 0)
                        
                        Spacer()
                        
                        // Action Button
                        Button(action: {}) {
                            Image(systemName: actionIcon)
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.white.opacity(0.4))
                                .frame(width: 32, height: 32)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(8)
                        }
                    }
                    .padding(16)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                )
                .opacity(isFuture ? 0.8 : 1)
            }
            .padding(.leading, 8)
            .padding(.trailing, 20)
            .padding(.bottom, isLast ? 0 : 32)
            .padding(.top, 8)
        }
    }
}

#Preview {
    UpcomingBlocksView()
}
