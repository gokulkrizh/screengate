import SwiftUI
import FamilyControls
import Combine

struct TimelineCardView: View {
    let block: Block
    let onTap: () -> Void
    
    private let appTheme = AppTheme.shared
    
    var body: some View {
        cardContent
            .background(Color.white.opacity(0.05))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            .onTapGesture { onTap() }
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            if block.isActiveAmongOverlaps {
                statusBadge
            }
            mainContent
        }
    }
    
    private var statusBadge: some View {
        Text("IN PROGRESS")
            .font(.system(size: 10, weight: .bold, design: .default))
            .tracking(0.5)
            .foregroundColor(appTheme.colors.primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(appTheme.colors.primary.opacity(0.2))
            .cornerRadius(6)
            .padding(.leading, 16)
            .padding(.top, 14)
    }
    
    private var mainContent: some View {
        let isActive = block.isActiveAmongOverlaps
        let selectedDays = block.schedule.repeatDays ?? []
        
        return HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(block.name)
                    .font(.system(size: 22, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.top, isActive ? 6 : 14)
                
                HStack(spacing: 4) {
                    Text(block.type.rawValue.capitalized)
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("•")
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.4))
                    
                    if isActive && block.schedule.endTime != nil {
                        HStack(spacing: 3) {
                            Text("Ending in")
                                .font(.system(size: 12, weight: .semibold, design: .default))
                                .foregroundColor(appTheme.colors.primary)
                            
                            if let endTime = block.schedule.endTime {
                                Text(endTime, style: .timer)
                                    .font(.system(size: 14, weight: .bold, design: .default))
                                    .foregroundColor(appTheme.colors.primary)
                                    .monospacedDigit()
                            }
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(appTheme.colors.primary.opacity(0.15))
                        .cornerRadius(5)
                    } else if let nextOccurrenceDate = getNextOccurrenceDateWithin24Hours(repeatDays: block.schedule.repeatDays ?? [], startTime: block.schedule.startTime) {
                        HStack(spacing: 3) {
                            Text("Starting in")
                                .font(.system(size: 12, weight: .semibold, design: .default))
                                .foregroundColor(appTheme.colors.primary)
                            
                            Text(nextOccurrenceDate, style: .timer)
                                .font(.system(size: 14, weight: .bold, design: .default))
                                .foregroundColor(appTheme.colors.primary)
                                .monospacedDigit()
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(appTheme.colors.primary.opacity(0.15))
                        .cornerRadius(5)
                    } else if let startTime = block.schedule.startTime, (block.schedule.repeatDays?.isEmpty ?? true) == false {
                        // Show day name for upcoming blocks > 24 hours away
                        HStack(spacing: 3) {
                            Text("Starts in")
                                .font(.system(size: 12, weight: .semibold, design: .default))
                                .foregroundColor(appTheme.colors.primary)
                            
                            Text(getNextOccurrenceDayName(repeatDays: block.schedule.repeatDays ?? []))
                                .font(.system(size: 12, weight: .semibold, design: .default))
                                .foregroundColor(appTheme.colors.primary)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(appTheme.colors.primary.opacity(0.15))
                        .cornerRadius(5)
                    }
                }
                .padding(.bottom, 8)
                
                if !selectedDays.isEmpty {
                    let startTime = block.schedule.startTime
                    let endTime = block.schedule.endTime
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 4) {
                            Text("REPEATS")
                                .font(.system(size: 10, weight: .bold, design: .default))
                                .tracking(0.5)
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text("•")
                                .font(.system(size: 10, weight: .medium, design: .default))
                                .foregroundColor(.white.opacity(0.3))
                            
                            if let startTime = startTime, let endTime = endTime {
                                Text("\(formatTime(startTime)) - \(formatTime(endTime))")
                                    .font(.system(size: 10, weight: .semibold, design: .default))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        
                        HStack(spacing: 6) {
                            ForEach(1...7, id: \.self) { day in
                                DayBadge(
                                    day: dayLabel(day),
                                    isSelected: selectedDays.contains(day)
                                )
                            }
                        }
                    }
                    .padding(.bottom, 12)
                }
            }
            .padding(.leading, 16)
            Spacer()
            if !block.appSelection.applicationTokens.isEmpty || !block.appSelection.categoryTokens.isEmpty {
                HStack(spacing: -6) {
                    ForEach(Array(block.appSelection.applicationTokens.prefix(3)), id: \.self) { token in
                        Circle()
                            .fill(appTheme.colors.primary.opacity(0.3))
                            .frame(width: 40, height: 40)
                    }
                }
                .padding(.trailing, 16)
                .padding(.top, isActive ? 6 : 14)
            }
        }
    }
    
    private var borderColor: Color {
        block.isActiveAmongOverlaps ? appTheme.colors.primary.opacity(0.3) : Color.white.opacity(0.1)
    }
    
    private var borderWidth: CGFloat {
        block.isActiveAmongOverlaps ? 2 : 1
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    private func getNextOccurrenceDateWithin24Hours(repeatDays: Set<Int>, startTime: Date?) -> Date? {
        let calendar = Calendar.current
        let now = Date()
        
        guard let startTime = startTime, !repeatDays.isEmpty else {
            return nil
        }
        
        // Extract time components from startTime
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        guard let hour = startComponents.hour, let minute = startComponents.minute else {
            return nil
        }
        
        // Start from today and check if the time has passed
        var checkDate = calendar.startOfDay(for: now)
        
        // If today's time hasn't passed yet, check today
        let weekday = calendar.component(.weekday, from: checkDate)
        if repeatDays.contains(weekday) {
            var occurrenceComponents = calendar.dateComponents([.year, .month, .day], from: checkDate)
            occurrenceComponents.hour = hour
            occurrenceComponents.minute = minute
            occurrenceComponents.second = 0
            
            if let occurrenceDate = calendar.date(from: occurrenceComponents), occurrenceDate > now {
                let timeInterval = occurrenceDate.timeIntervalSince(now)
                if timeInterval <= 86400 { // Within 24 hours
                    return occurrenceDate
                }
            }
        }
        
        // Check tomorrow and next 6 days
        for _ in 0..<7 {
            checkDate = calendar.date(byAdding: .day, value: 1, to: checkDate) ?? checkDate
            let weekday = calendar.component(.weekday, from: checkDate)
            
            if repeatDays.contains(weekday) {
                var occurrenceComponents = calendar.dateComponents([.year, .month, .day], from: checkDate)
                occurrenceComponents.hour = hour
                occurrenceComponents.minute = minute
                occurrenceComponents.second = 0
                
                if let occurrenceDate = calendar.date(from: occurrenceComponents) {
                    let timeInterval = occurrenceDate.timeIntervalSince(now)
                    if timeInterval <= 86400 { // Within 24 hours
                        return occurrenceDate
                    }
                }
            }
        }
        
        return nil
    }
    
    private func getNextOccurrenceDayName(repeatDays: Set<Int>) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        // If no repeat days set, show today
        guard !repeatDays.isEmpty else {
            return formatDayName(now)
        }
        
        // Start from today (check if today qualifies)
        var checkDate = calendar.startOfDay(for: now)
        
        // Check up to 7 days
        for _ in 0..<7 {
            let weekday = calendar.component(.weekday, from: checkDate)
            if repeatDays.contains(weekday) {
                return formatDayName(checkDate)
            }
            checkDate = calendar.date(byAdding: .day, value: 1, to: checkDate) ?? checkDate
        }
        
        // Fallback: return today's day
        return formatDayName(now)
    }
    
    private func formatDayName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    private func dayLabel(_ day: Int) -> String {
        switch day {
        case 1: return "S"
        case 2: return "M"
        case 3: return "T"
        case 4: return "W"
        case 5: return "T"
        case 6: return "F"
        case 7: return "S"
        default: return ""
        }
    }
}

struct DayBadge: View {
    let day: String
    let isSelected: Bool
    
    private let appTheme = AppTheme.shared
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? appTheme.colors.primary : Color.white.opacity(0.1))
                .frame(width: 32, height: 32)
            
            Text(day)
                .font(.system(size: 13, weight: .semibold, design: .default))
                .foregroundColor(isSelected ? Color(red: 0.06, green: 0.13, blue: 0.09) : .white.opacity(0.3))
        }
    }
}

#Preview {
    ZStack {
        Color(red: 0.06, green: 0.13, blue: 0.09)
            .ignoresSafeArea()
        
        VStack(spacing: 20) {
            let activeBlock = Block(
                name: "Deep Work Phase",
                icon: "app.fill",
                iconColor: "#66C5A8",
                type: .scheduled,
                appSelection: FamilyActivitySelection(),
                schedule: Block.BlockSchedule(
                    startTime: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!,
                    endTime: Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: Date())!,
                    duration: nil,
                    threshold: nil,
                    repeatDays: [2, 3, 4, 5, 6],
                    isRepeating: true
                ),
                strictMode: .medium,
                isActive: true,
                appListId: nil,
                appListName: nil
            )
            
            TimelineCardView(block: activeBlock, onTap: {})
                .padding(.horizontal, 16)
            
            let inactiveBlock = Block(
                name: "Evening Focus",
                icon: "moon.fill",
                iconColor: "#66C5A8",
                type: .scheduled,
                appSelection: FamilyActivitySelection(),
                schedule: Block.BlockSchedule(
                    startTime: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())!,
                    endTime: Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: Date())!,
                    duration: nil,
                    threshold: nil,
                    repeatDays: [1, 2, 3, 4, 5, 6, 7],
                    isRepeating: true
                ),
                strictMode: .medium,
                isActive: false,
                appListId: nil,
                appListName: nil
            )
            
            TimelineCardView(block: inactiveBlock, onTap: {})
                .padding(.horizontal, 16)
        }
    }
}
