import SwiftUI

struct DurationPickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var hours: Int
    @Binding var minutes: Int
    let title: String
    @State private var selectedHours: Int
    @State private var selectedMinutes: Int
    private let appTheme = AppTheme.shared
    
    init(hours: Binding<Int>, minutes: Binding<Int>, title: String) {
        self._hours = hours
        self._minutes = minutes
        self.title = title
        _selectedHours = State(initialValue: hours.wrappedValue)
        _selectedMinutes = State(initialValue: minutes.wrappedValue)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag Indicator
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.white.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 20)
            
            // Title
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .default))
                .foregroundColor(.white)
                .padding(.bottom, 32)
            
            // Duration Picker
            HStack(spacing: 8) {
                // Hours
                Picker("", selection: $selectedHours) {
                    ForEach(0...23, id: \.self) { hour in
                        Text(String(format: "%02d", hour))
                            .font(.system(size: 48, weight: .bold, design: .default))
                            .foregroundColor(appTheme.colors.primary)
                            .tag(hour)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 100)
                
                Text(":")
                    .font(.system(size: 48, weight: .bold, design: .default))
                    .foregroundColor(appTheme.colors.primary)
                
                // Minutes
                Picker("", selection: $selectedMinutes) {
                    ForEach(0..<60, id: \.self) { minute in
                        Text(String(format: "%02d", minute))
                            .font(.system(size: 48, weight: .bold, design: .default))
                            .foregroundColor(appTheme.colors.primary)
                            .tag(minute)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 100)
            }
            .padding(.bottom, 32)
            
            // Labels
            HStack(spacing: 0) {
                Text("Hours")
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(width: 100)
                
                Spacer()
                    .frame(width: 8)
                
                Text("Minutes")
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(width: 100)
            }
            .padding(.bottom, 32)
            
            // Save Button
            Button(action: {
                hours = selectedHours
                minutes = selectedMinutes
                dismiss()
            }) {
                HStack(spacing: 8) {
                    Text("Save Time")
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(appTheme.colors.primary)
                .cornerRadius(16)
                .shadow(color: appTheme.colors.primary.opacity(0.3), radius: 12, x: 0, y: 0)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color(red: 0.06, green: 0.13, blue: 0.09))
    }
}

#Preview {
    DurationPickerSheet(hours: .constant(1), minutes: .constant(30), title: "Set Duration")
}
