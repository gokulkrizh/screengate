import SwiftUI

/// Reusable day selector button for weekly repeat schedules
struct DayButton: View {
    let day: String
    let isSelected: Bool
    var size: CGFloat = 40
    
    private let appTheme = AppTheme.shared
    
    var body: some View {
        Text(day)
            .font(.system(size: 14, weight: .bold, design: .default))
            .foregroundColor(isSelected ? Color(red: 0.06, green: 0.13, blue: 0.09) : .white.opacity(0.4))
            .frame(width: size, height: size)
            .background(isSelected ? appTheme.colors.primary : Color.white.opacity(0.1))
            .cornerRadius(size / 2)
            .shadow(color: isSelected ? appTheme.colors.primary.opacity(0.4) : Color.clear, radius: 8, x: 0, y: 0)
    }
}

/// Helper to convert day index to label
/// day parameter uses Calendar.component(.weekday) values:
/// 1=Sunday, 2=Monday, 3=Tuesday, 4=Wednesday, 5=Thursday, 6=Friday, 7=Saturday
func dayLabel(_ day: Int) -> String {
    ["S", "M", "T", "W", "T", "F", "S"][day - 1]
}

#Preview {
    HStack(spacing: 12) {
        ForEach(1...7, id: \.self) { day in
            DayButton(day: dayLabel(day), isSelected: day <= 5)
        }
    }
    .padding()
    .background(Color(red: 0.06, green: 0.13, blue: 0.09))
    .preferredColorScheme(.dark)
}
