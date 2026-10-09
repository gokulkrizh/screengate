import SwiftUI

/// Reusable Radio Option Card Component
/// Displays a selectable option with icon, title, and description
struct RadioOptionCard: View {
    private let appTheme = AppTheme.shared
    
    let icon: String
    let iconColor: Color?
    let iconBackgroundColor: Color?
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        DietChoice(icon: icon, title: title, detail: subtitle, selected: isSelected, tint: iconColor ?? appTheme.colors.primary, action: action)
    }
}

#Preview {
    VStack(spacing: 12) {
        RadioOptionCard(
            icon: "smartphone",
            iconColor: Color.blue,
            iconBackgroundColor: Color.blue,
            title: "Social Media Detox",
            subtitle: "I scroll too much on apps",
            isSelected: true
        ) {
            print("Selected 1")
        }
        
        RadioOptionCard(
            icon: "briefcase",
            iconColor: Color.orange,
            iconBackgroundColor: Color.orange,
            title: "Focus & Productivity",
            subtitle: "I can't focus on work/study",
            isSelected: false
        ) {
            print("Selected 2")
        }
    }
    .padding()
    .background(Color(red: 0.06, green: 0.13, blue: 0.09))
}
