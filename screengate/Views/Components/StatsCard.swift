import SwiftUI

/// Card displaying a stat with large number, label, and optional icon
struct StatsCard: View {
    let number: String
    let label: String
    var subtitle: String?
    var icon: String?
    var iconColor: Color = .focusAccent
    var trend: String?
    var trendIsPositive: Bool = true
    
    var body: some View {
            VStack(alignment: .leading, spacing: FocusClubSpacing.md) {
                HStack(alignment: .top, spacing: FocusClubSpacing.base) {
                    VStack(alignment: .leading, spacing: FocusClubSpacing.sm) {
                        HStack(alignment: .firstTextBaseline, spacing: FocusClubSpacing.sm) {
                            Text(number)
                                .largeNumberStyle()
                                .foregroundColor(.focusAccent)
                            
                            if let trend = trend {
                                HStack(spacing: 2) {
                                    Image(systemName: trendIsPositive ? "arrow.up.right" : "arrow.down.right")
                                        .font(.caption2.weight(.semibold))
                                    Text(trend)
                                        .font(.caption2.weight(.semibold))
                                }
                                .foregroundColor(trendIsPositive ? .focusSuccess : .red)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(trendIsPositive ? Color.focusSuccess.opacity(0.1) : Color.red.opacity(0.1))
                                .cornerRadius(4)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(label)
                                .bodyStyle()
                                .foregroundColor(.focusText)
                            
                            if let subtitle = subtitle {
                                Text(subtitle)
                                    .captionStyle()
                                    .foregroundColor(.focusTextSecondary)
                            }
                        }
                    }
                    
                    Spacer()
                
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(iconColor)
                        .frame(width: 44, height: 44)
                        .background(iconColor.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 12) {
        StatsCard(
            number: "4h 32m",
            label: "Today's Focus",
            subtitle: "2h above goal",
            icon: "target",
            trend: "+15%",
            trendIsPositive: true
        )
        
        StatsCard(
            number: "12",
            label: "Sessions",
            subtitle: "This week",
            icon: "clock",
            trend: "-8%",
            trendIsPositive: false
        )
        
        StatsCard(
            number: "87%",
            label: "Goal Progress",
            icon: "checkmark.circle.fill",
            iconColor: .focusSuccess
        )
    }
    .screenBackground()
    .screenHorizontalPadding()
}
