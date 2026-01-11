import SwiftUI

struct TimePickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedTime: Date
    let title: String
    @State private var selectedHour: Int = 9
    @State private var selectedMinute: Int = 0
    @State private var isAM: Bool = true
    private let appTheme = AppTheme.shared
    
    init(selectedTime: Binding<Date>, title: String) {
        self._selectedTime = selectedTime
        self.title = title
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: selectedTime.wrappedValue)
        let hour = components.hour ?? 9
        let minute = components.minute ?? 0
        
        _selectedHour = State(initialValue: hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour))
        _selectedMinute = State(initialValue: minute)
        _isAM = State(initialValue: hour < 12)
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
            
            // Time Picker
            HStack(spacing: 8) {
                // Hours
                Picker("", selection: $selectedHour) {
                    ForEach(1...12, id: \.self) { hour in
                        Text(String(format: "%02d", hour))
                            .font(.system(size: 48, weight: .bold, design: .default))
                            .foregroundColor(appTheme.colors.primary)
                            .tag(hour)
                        Spacer()
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 100)
                
                Text(":")
                    .font(.system(size: 48, weight: .bold, design: .default))
                    .foregroundColor(appTheme.colors.primary)
                
                // Minutes
                Picker("", selection: $selectedMinute) {
                    ForEach(0..<60, id: \.self) { minute in
                        Text(String(format: "%02d", minute))
                            .font(.system(size: 48, weight: .bold, design: .default))
                            .foregroundColor(appTheme.colors.primary)
                            .padding(.horizontal, 4)
                            .tag(minute)
                        Spacer()
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 100)
            }
            .padding(.bottom, 24)
            
            // AM/PM Toggle
            HStack(spacing: 0) {
                Button(action: { isAM = true }) {
                    Text("AM")
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(isAM ? Color(red: 0.06, green: 0.13, blue: 0.09) : .white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(isAM ? appTheme.colors.primary : Color.clear)
                        .cornerRadius(10)
                }
                
                Button(action: { isAM = false }) {
                    Text("PM")
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(!isAM ? Color(red: 0.06, green: 0.13, blue: 0.09) : .white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(!isAM ? appTheme.colors.primary : Color.clear)
                        .cornerRadius(10)
                }
            }
            .padding(4)
            .background(Color(red: 0.1, green: 0.2, blue: 0.14))
            .cornerRadius(12)
            .padding(.horizontal, 80)
            .padding(.bottom, 32)
            
            // Save Button
            Button(action: {
                saveTime()
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
    
    private func saveTime() {
        var hour = selectedHour
        if !isAM && hour != 12 {
            hour += 12
        } else if isAM && hour == 12 {
            hour = 0
        }
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: selectedTime)
        components.hour = hour
        components.minute = selectedMinute
        
        if let newDate = calendar.date(from: components) {
            selectedTime = newDate
        }
    }
}

#Preview {
    TimePickerSheet(selectedTime: .constant(Date()), title: "Set Start Time")
}
