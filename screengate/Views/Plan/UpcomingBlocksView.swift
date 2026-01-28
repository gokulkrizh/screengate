import SwiftUI
import Combine

struct UpcomingBlocksView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(BlockManager.self) private var blockManager
    @State private var showCreateBlock = false
    @State private var showScheduledBlock = false
    @State private var showOpenLimit = false
    @State private var showAppTimeLimit = false
    @State private var showBlockNow = false
    @State private var showAllDays = false // Filter toggle: false = 2 days, true = 7 days
    @State private var currentTime = Date() // For real-time updates
    @State private var refreshTrigger = UUID() // Force refresh when needed
    private let appTheme = AppTheme.shared
    
    // Timer to update UI every minute
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect() // Changed to 1 second for testing
    
    // Helper struct for day data
    private struct DayData: Identifiable {
        let id: Int
        let offset: Int
        let date: Date
    }
    
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
    
    // Helper: Check if block should run on a specific date
    private func shouldRunOnDate(_ block: Block, _ date: Date) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        guard let repeatDays = block.schedule.repeatDays else {
            // One-time block: check if scheduled date matches
            if let startTime = block.schedule.startTime {
                return calendar.isDate(startTime, inSameDayAs: date)
            }
            return false
        }
        
        // Repeating block: check if weekday is in repeatDays
        return repeatDays.contains(weekday)
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
                    // Button(action: { dismiss() }) {
                    //     Image(systemName: "arrow.left")
                    //         .font(.system(size: 20, weight: .semibold))
                    //         .foregroundColor(.white)
                    //         .frame(width: 40, height: 40)
                    //         .background(Color.white.opacity(0.05))
                    //         .cornerRadius(20)
                    // }
                    
                    Spacer()
                    
                    // Title
                    Text("Upcoming Blocks")
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Filter Button
                    Button(action: { showAllDays.toggle() }) {
                        Image(systemName: showAllDays ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(showAllDays ? appTheme.colors.primary : .white)
                            .frame(width: 40, height: 40)
                            .background(showAllDays ? appTheme.colors.primary.opacity(0.2) : Color.white.opacity(0.05))
                            .cornerRadius(20)
                    }
                    
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
                    let calendar = Calendar.current
                    let today = Date()
                    
                    let daysData: [DayData] = (0..<(showAllDays ? 7 : 2)).map { offset in
                        DayData(id: offset, offset: offset, date: calendar.date(byAdding: .day, value: offset, to: today) ?? today)
                    }
                    
                    let hasAnyBlocks = daysData.contains { dayData in
                        let blocks = blockManager.blocks.filter { shouldRunOnDate($0, dayData.date) }
                        if dayData.offset == 0 {
                            // For today, check if there are any non-ended blocks
                            var currentComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: currentTime)
                            currentComponents.second = 0
                            let normalizedNow = calendar.date(from: currentComponents) ?? currentTime
                            
                            return blocks.contains { block in
                                guard let endTime = block.schedule.endTime else { return true }
                                let todayEnd: Date
                                if block.schedule.repeatDays != nil {
                                    var todayComponents = calendar.dateComponents([.year, .month, .day], from: currentTime)
                                    let endTimeComponents = calendar.dateComponents([.hour, .minute], from: endTime)
                                    todayComponents.hour = endTimeComponents.hour
                                    todayComponents.minute = endTimeComponents.minute
                                    todayComponents.second = 0
                                    todayEnd = calendar.date(from: todayComponents) ?? endTime
                                } else {
                                    todayEnd = endTime
                                }
                                return normalizedNow < todayEnd
                            }
                        }
                        return !blocks.isEmpty
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(daysData) { dayData in
                            let allDayBlocks = blockManager.blocks.filter { shouldRunOnDate($0, dayData.date) }
                            
                            let dayBlocks: [Block] = {
                                if dayData.offset == 0 {
                                    // Today: only show blocks that haven't ended yet
                                    var currentComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: currentTime)
                                    currentComponents.second = 0
                                    let normalizedNow = calendar.date(from: currentComponents) ?? currentTime
                                    
                                    return allDayBlocks.filter { block in
                                        guard let endTime = block.schedule.endTime else { return true }
                                        
                                        // Calculate today's end time for the block
                                        let todayEnd: Date
                                        if block.schedule.repeatDays != nil {
                                            var todayComponents = calendar.dateComponents([.year, .month, .day], from: currentTime)
                                            let endTimeComponents = calendar.dateComponents([.hour, .minute], from: endTime)
                                            todayComponents.hour = endTimeComponents.hour
                                            todayComponents.minute = endTimeComponents.minute
                                            todayComponents.second = 0
                                            todayEnd = calendar.date(from: todayComponents) ?? endTime
                                        } else {
                                            todayEnd = endTime
                                        }
                                        
                                        // Only include if block hasn't ended yet
                                        return normalizedNow < todayEnd
                                    }
                                } else {
                                    // Future days: show all blocks
                                    return allDayBlocks
                                }
                            }()
                            
                            let sortedBlocks = dayBlocks.sorted { ($0.schedule.startTime ?? Date()) < ($1.schedule.startTime ?? Date()) }
                            
                            if !sortedBlocks.isEmpty {
                                Group {
                                    // Section header
                                    let dayTitle: String = {
                                        if dayData.offset == 0 {
                                            return "Today"
                                        } else if dayData.offset == 1 {
                                            return "Tomorrow"
                                        } else {
                                            let formatter = DateFormatter()
                                            formatter.dateFormat = "EEEE" // Full day name
                                            return formatter.string(from: dayData.date)
                                        }
                                    }()
                                    
                                    sectionHeader(title: dayTitle, date: formatDate(dayData.date))
                                    
                                    ForEach(Array(sortedBlocks.enumerated()), id: \.element.id) { index, block in
                                        let isBlockActive: Bool = {
                                            guard dayData.offset == 0 else { return false }
                                            guard let startTime = block.schedule.startTime,
                                                  let endTime = block.schedule.endTime else { return false }
                                            
                                            let calendar = Calendar.current
                                            
                                            // Normalize current time to start of minute (ignore seconds)
                                            var currentComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: currentTime)
                                            currentComponents.second = 0
                                            let normalizedNow = calendar.date(from: currentComponents) ?? currentTime
                                            
                                            // For repeating blocks, construct today's date with the block's time
                                            let todayStart: Date
                                            let todayEnd: Date
                                            
                                            if block.schedule.repeatDays != nil {
                                                // Repeating block: use today's date + block's time components
                                                var todayComponents = calendar.dateComponents([.year, .month, .day], from: currentTime)
                                                let startTimeComponents = calendar.dateComponents([.hour, .minute], from: startTime)
                                                let endTimeComponents = calendar.dateComponents([.hour, .minute], from: endTime)
                                                
                                                todayComponents.hour = startTimeComponents.hour
                                                todayComponents.minute = startTimeComponents.minute
                                                todayComponents.second = 0
                                                todayStart = calendar.date(from: todayComponents) ?? startTime
                                                
                                                todayComponents.hour = endTimeComponents.hour
                                                todayComponents.minute = endTimeComponents.minute
                                                todayComponents.second = 0
                                                todayEnd = calendar.date(from: todayComponents) ?? endTime
                                            } else {
                                                // One-time block: use stored dates
                                                todayStart = startTime
                                                todayEnd = endTime
                                            }
                                            
                                            let result = normalizedNow >= todayStart && normalizedNow < todayEnd
                                            
                                            // Debug logging
                                            let formatter = DateFormatter()
                                            formatter.timeStyle = .short
                                            print("🔍 Block: \(block.name)")
                                            print("   Current: \(formatter.string(from: normalizedNow))")
                                            print("   Start: \(formatter.string(from: todayStart))")
                                            print("   End: \(formatter.string(from: todayEnd))")
                                            print("   Active: \(result)")
                                            
                                            return result
                                        }()
                                        
                                        TimelineBlockView(
                                            icon: "timer.circle.fill",
                                            iconColor: appTheme.colors.primary,
                                            title: block.name,
                                            timeRange: formatTimeRange(block.schedule.startTime ?? Date(), block.schedule.endTime ?? Date()),
                                            duration: block.schedule.duration != nil ? formatDuration(block.schedule.duration!) : nil,
                                            isActive: isBlockActive,
                                            isFirst: index == 0,
                                            isLast: index == dayBlocks.count - 1,
                                            actionIcon: isBlockActive ? "pause.circle" : "ellipsis",
                                            isFuture: dayData.offset > 0
                                        )
                                        .contextMenu {
                                            Button(role: .destructive, action: {
                                                try? blockManager.deleteBlock(block)
                                            }) {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
                                    
                                    // End cap
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
                            }
                        }
                        
                        // Empty State
                        if !hasAnyBlocks {
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
                .padding(.horizontal, 12)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            currentTime = Date() // Refresh time when view appears
        }
        .onReceive(timer) { _ in
            currentTime = Date() // Update current time every minute to refresh active block highlighting
        }
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
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
            // Timer for preview
        }
}
