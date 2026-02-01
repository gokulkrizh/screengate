import SwiftUI

struct StrictModePickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedMode: StrictMode?
    private let appTheme = AppTheme.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // // Drag Indicator
            // RoundedRectangle(cornerRadius: 2.5)
            //     .fill(Color.white.opacity(0.3))
            //     .frame(width: 40, height: 5)
            //     .padding(.top, 12)
            //     .padding(.bottom, 20)
            
            // // Title
            // Text("Select Intensity")
            //     .font(.system(size: 20, weight: .bold, design: .default))
            //     .foregroundColor(.white)
            //     .padding(.bottom, 32)
            
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(20)
                }
                
                Spacer()
                
                Text("Select Intensity")
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Spacer for alignment
                Color.clear
                    .frame(width: 40, height: 40)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 12)

            // Mode Selection
            VStack(spacing: 12) {
                StrictModeCard(
                    mode: .easy,
                    icon: "cup.and.saucer.fill",
                    iconColor: appTheme.colors.primary,
                    title: "Easy",
                    description: "Allow short breaks after limit",
                    isSelected: selectedMode == .easy,
                    action: { selectedMode = .easy }
                )
                
                StrictModeCard(
                    mode: .medium,
                    icon: "timer",
                    iconColor: Color(red: 1.0, green: 0.8, blue: 0.0),
                    title: "Medium",
                    description: "15s breathing delay on open",
                    isSelected: selectedMode == .medium,
                    action: { selectedMode = .medium }
                )
                
                StrictModeCard(
                    mode: .hard,
                    icon: "lock.fill",
                    iconColor: Color(red: 1.0, green: 0.4, blue: 0.4),
                    title: "Hard",
                    description: "Strict cutoff. No entry after limit.",
                    isSelected: selectedMode == .hard,
                    action: { selectedMode = .hard }
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
            
            // Confirm Button
            Button(action: {
                dismiss()
            }) {
                HStack(spacing: 8) {
                    Text(selectedMode == nil ? "Cancel" : "Confirm Selection")
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                    
                    if selectedMode != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(selectedMode == nil ? Color.white.opacity(0.1) : appTheme.colors.primary)
                .cornerRadius(16)
                .shadow(color: (selectedMode != nil ? appTheme.colors.primary : .clear).opacity(0.3), radius: 12, x: 0, y: 0)
            }
            .padding(.horizontal, 20)
            //.padding(.bottom, 20)
        }
        .background(Color(red: 0.06, green: 0.13, blue: 0.09))
    }
}

#Preview {
    StrictModePickerSheet(selectedMode: .constant(nil))
}
