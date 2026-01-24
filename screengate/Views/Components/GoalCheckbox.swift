import SwiftUI

/// Checkbox card for goal selection with rounded corners and highlight state
struct GoalCheckbox: View {
    let id: String
    let title: String
    let isSelected: Bool
    let onToggle: () -> Void
    
    private let appTheme = AppTheme.shared
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(appTheme.fonts.titleMedium)
                        .foregroundColor(appTheme.colors.text)
                }
                
                Spacer()
                
                // Checkbox circle
                Circle()
                    .fill(isSelected ? appTheme.colors.primary : Color.white.opacity(0.1))
                    .frame(width: 24, height: 24)
                    .overlay(
                        isSelected ?
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                        : nil
                    )
                    .scaleEffect(isSelected ? 1.1 : 1.0)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isSelected ? 0.1 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? appTheme.colors.primary : Color.white.opacity(0.1),
                                lineWidth: 1.5
                            )
                    )
            )
            .cornerRadius(12)
        }
    }
}

#Preview {
    ZStack {
        Color(red: 0.06, green: 0.13, blue: 0.09)
            .ignoresSafeArea()
        
        VStack(spacing: 12) {
            GoalCheckbox(
                id: "reclaim_time",
                title: "Reclaiming 2 hours a day",
                isSelected: true
            ) {
                print("Toggled")
            }
            
            GoalCheckbox(
                id: "deep_work",
                title: "Deep work without distractions",
                isSelected: false
            ) {
                print("Toggled")
            }
        }
        .padding()
    }
}
