import SwiftUI

struct UpcomingBlocksView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(BlockManager.self) private var blockManager
    @State private var showCreateBlock = false
    @State private var showScheduledBlock = false
    @State private var showOpenLimit = false
    @State private var showAppTimeLimit = false
    @State private var showBlockNow = false
    private let appTheme = AppTheme.shared
    
    // MARK: - Helper Functions
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date)
    }
    
    private func formatTimeRange(_ start: Date, _ end: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let startStr = formatter.string(from: start)
        let endStr = formatter.string(from: end)
        return "\(startStr) - \(endStr)"
    }
    
    private func formatDuration(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func getTomorrowDate() -> Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    }
    
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
                        let todayBlocks = blockManager.blocks.filter { block in
                            if let startTime = block.schedule.startTime {
                                return Calendar.current.isDateInToday(startTime)
                            }
                            return false
                        }
                        
                        if !todayBlocks.isEmpty {
                            sectionHeader(title: "Today", date: formatDate(Date()))
                            
                            ForEach(Array(todayBlocks.enumerated()), id: \.element.id) { index, block in
                                TimelineBlockView(
                                    icon: "timer.circle.fill",
                                    iconColor: appTheme.colors.primary,
                                    title: block.name,
                                    timeRange: formatTimeRange(block.schedule.startTime ?? Date(), block.schedule.endTime ?? Date()),
                                    duration: block.schedule.duration != nil ? formatDuration(block.schedule.duration!) : nil,
                                    isActive: blockManager.activeBlock?.id == block.id,
                                    isFirst: index == 0,
                                    isLast: index == todayBlocks.count - 1,
                                    actionIcon: blockManager.activeBlock?.id == block.id ? "pause.circle" : "ellipsis"
                                )
                                .contextMenu {
                                    Button(role: .destructive, action: {
                                        try? blockManager.deleteBlock(block)
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            
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
                        }
                        
                        // Tomorrow Section
                        let tomorrowBlocks = blockManager.blocks.filter { block in
                            if let startTime = block.schedule.startTime {
                                return Calendar.current.isDateInTomorrow(startTime)
                            }
                            return false
                        }
                        
                        if !tomorrowBlocks.isEmpty {
                            sectionHeader(title: "Tomorrow", date: formatDate(getTomorrowDate()))
                            
                            ForEach(Array(tomorrowBlocks.enumerated()), id: \.element.id) { index, block in
                                TimelineBlockView(
                                    icon: "timer.circle.fill",
                                    iconColor: appTheme.colors.primary,
                                    title: block.name,
                                    timeRange: formatTimeRange(block.schedule.startTime ?? Date(), block.schedule.endTime ?? Date()),
                                    duration: block.schedule.duration != nil ? formatDuration(block.schedule.duration!) : nil,
                                    isActive: false,
                                    isFirst: index == 0,
                                    isLast: index == tomorrowBlocks.count - 1,
                                    actionIcon: "ellipsis",
                                    isFuture: true
                                )
                                .contextMenu {
                                    Button(role: .destructive, action: {
                                        try? blockManager.deleteBlock(block)
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            
                            // End cap for tomorrow
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
                        }
                        
                        // Empty State
                        if todayBlocks.isEmpty && tomorrowBlocks.isEmpty {
                            VStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(appTheme.colors.primary.opacity(0.2))
                                        .frame(width: 48, height: 48)
                                    
                                    Image(systemName: "calendar.badge.plus")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(appTheme.colors.primary)
                                }
                                
                                Text("No upcoming blocks yet.")
                                    .font(.system(size: 14, weight: .medium, design: .default))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Button(action: { showCreateBlock = true }) {
                                    Text("Create your first block")
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
