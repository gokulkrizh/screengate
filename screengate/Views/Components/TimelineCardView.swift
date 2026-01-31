import SwiftUI
import FamilyControls

struct TimelineCardView: View {
    let blockName: String
    let category: String
    let startTime: Date
    let endTime: Date
    let selectedDays: Set<Int>
    let isActive: Bool
    let appSelection: FamilyActivitySelection
    
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
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isActive {
                statusBadge
            }
            mainContent
        }
    }
    
    private var statusBadge: some View {
        Text("IN PROGRESS")
            .font(.system(size: 11, weight: .bold, design: .default))
            .tracking(0.5)
            .foregroundColor(appTheme.colors.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(appTheme.colors.primary.opacity(0.2))
            .cornerRadius(8)
            .padding(.leading, 20)
            .padding(.top, 20)
    }
    
    private var mainContent: some View {
        HStack(alignment: .top, spacing: 16) {
            leftContent
            Spacer()
            if !appSelection.applicationTokens.isEmpty || !appSelection.categoryTokens.isEmpty {
                appIcons
            }
        }
    }
    
    private var leftContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(blockName)
                .font(.system(size: 24, weight: .bold, design: .default))
                .foregroundColor(.white)
                .padding(.top, isActive ? 8 : 20)
            
            timeInfo
            
            if !selectedDays.isEmpty {
                repeatsSection
            }
        }
        .padding(.leading, 20)
    }
    
    private var timeInfo: some View {
        HStack(spacing: 6) {
            Text(category)
                .font(.system(size: 15, weight: .medium, design: .default))
                .foregroundColor(.white.opacity(0.6))
            
            Text("•")
                .font(.system(size: 15, weight: .medium, design: .default))
                .foregroundColor(.white.opacity(0.4))
            
            Text("\(formatTime(startTime)) - \(formatTime(endTime))")
                .font(.system(size: 15, weight: .medium, design: .default))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.bottom, 20)
    }
    
    private var repeatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("REPEATS")
                .font(.system(size: 11, weight: .bold, design: .default))
                .tracking(0.5)
                .foregroundColor(.white.opacity(0.5))
            
            HStack(spacing: 8) {
                ForEach(1...7, id: \.self) { day in
                    DayBadge(
                        day: dayLabel(day),
                        isSelected: selectedDays.contains(day)
                    )
                }
            }
        }
        .padding(.bottom, 20)
    }
    
    private var appIcons: some View {
        HStack(spacing: -8) {
            ForEach(Array(appSelection.applicationTokens.prefix(3)), id: \.self) { token in
                Circle()
                    .fill(appTheme.colors.primary.opacity(0.3))
                    .frame(width: 48, height: 48)
            }
        }
        .padding(.trailing, 20)
        .padding(.top, isActive ? 8 : 20)
    }
    
    private var borderColor: Color {
        isActive ? appTheme.colors.primary.opacity(0.3) : Color.white.opacity(0.1)
    }
    
    private var borderWidth: CGFloat {
        isActive ? 2 : 1
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
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
                .frame(width: 36, height: 36)
            
            Text(day)
                .font(.system(size: 15, weight: .semibold, design: .default))
                .foregroundColor(isSelected ? Color(red: 0.06, green: 0.13, blue: 0.09) : .white.opacity(0.3))
        }
    }
}

#Preview {
    ZStack {
        Color(red: 0.06, green: 0.13, blue: 0.09)
            .ignoresSafeArea()
        
        VStack(spacing: 20) {
            // Active block
            TimelineCardView(
                blockName: "Deep Work Phase",
                category: "Development",
                startTime: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!,
                endTime: Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: Date())!,
                selectedDays: [2, 3, 4, 5, 6], // Mon-Fri
                isActive: true,
                appSelection: FamilyActivitySelection()
            )
            .padding(.horizontal, 16)
            
            // Inactive block
            TimelineCardView(
                blockName: "Evening Focus",
                category: "Social Media",
                startTime: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())!,
                endTime: Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: Date())!,
                selectedDays: [1, 2, 3, 4, 5, 6, 7], // Every day
                isActive: false,
                appSelection: FamilyActivitySelection()
            )
            .padding(.horizontal, 16)
        }
    }
}
