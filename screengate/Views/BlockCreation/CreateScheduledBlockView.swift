import SwiftUI

struct CreateScheduledBlockView: View {
    @Environment(\.dismiss) var dismiss
    @State private var blockName = ""
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var selectedDays: Set<Int> = [1, 2, 3, 4, 5] // M-F
    @State private var strictMode: StrictMode = .medium
    @State private var showStartTimePicker = false
    @State private var showEndTimePicker = false
    private let appTheme = AppTheme.shared
    
    enum StrictMode {
        case easy, medium, hard
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.13, blue: 0.09)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(20)
                    }
                    
                    Spacer()
                    
                    Text("Create Schedule")
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Block Name
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 0.15, green: 0.12, blue: 0.1))
                                        .frame(width: 56, height: 56)
                                    
                                    Image(systemName: "timer")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(appTheme.colors.primary)
                                }
                                
                                TextField("Social Media Focus", text: $blockName)
                                    .font(.system(size: 18, weight: .semibold, design: .default))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color(red: 0.09, green: 0.16, blue: 0.12))
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        
                        // Apps to Block
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Apps to Block")
                                .font(.system(size: 20, weight: .bold, design: .default))
                                .foregroundColor(.white)
                            
                            Button(action: {}) {
                                HStack(spacing: 12) {
                                    // Stacked Icons
                                    HStack(spacing: -12) {
                                        Circle()
                                            .fill(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.pink]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Image(systemName: "camera.fill")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.white)
                                            )
                                            .overlay(Circle().stroke(Color(red: 0.09, green: 0.16, blue: 0.12), lineWidth: 2))
                                        
                                        Circle()
                                            .fill(Color.black)
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Image(systemName: "music.note")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.white)
                                            )
                                            .overlay(Circle().stroke(Color(red: 0.09, green: 0.16, blue: 0.12), lineWidth: 2))
                                        
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Image(systemName: "chart.bar.fill")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.white)
                                            )
                                            .overlay(Circle().stroke(Color(red: 0.09, green: 0.16, blue: 0.12), lineWidth: 2))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Instagram, TikTok +2")
                                            .font(.system(size: 16, weight: .semibold, design: .default))
                                            .foregroundColor(.white)
                                        
                                        Text("Social Media & Entertainment")
                                            .font(.system(size: 12, weight: .regular, design: .default))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.4))
                                }
                                .padding(16)
                                .background(Color(red: 0.09, green: 0.16, blue: 0.12))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Focus Duration
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Focus Duration")
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(.white)
                            
                            // Start Time
                            Button(action: { showStartTimePicker = true }) {
                                timeCard(
                                    icon: "sun.max.fill",
                                    iconColor: appTheme.colors.primary,
                                    label: "START TIME",
                                    time: formatTime(startTime)
                                )
                            }
                            
                            // Connector line
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 2, height: 16)
                                .frame(maxWidth: .infinity)
                            
                            // End Time
                            Button(action: { showEndTimePicker = true }) {
                                timeCard(
                                    icon: "moon.fill",
                                    iconColor: Color.blue,
                                    label: "END TIME",
                                    time: formatTime(endTime)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Repeat On
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Repeat On")
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 12) {
                                ForEach(1...7, id: \.self) { day in
                                    Button(action: {
                                        if selectedDays.contains(day) {
                                            selectedDays.remove(day)
                                        } else {
                                            selectedDays.insert(day)
                                        }
                                    }) {
                                        dayButton(day: dayLabel(day), isSelected: selectedDays.contains(day))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Select Intensity
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Select Intensity")
                                .font(.system(size: 20, weight: .bold, design: .default))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                strictModeCard(
                                    mode: .easy,
                                    icon: "cup.and.saucer.fill",
                                    iconColor: appTheme.colors.primary,
                                    title: "Easy",
                                    description: "Allow short breaks after limit"
                                )
                                
                                strictModeCard(
                                    mode: .medium,
                                    icon: "timer",
                                    iconColor: Color(red: 1.0, green: 0.8, blue: 0.0),
                                    title: "Medium",
                                    description: "15s breathing delay on open"
                                )
                                
                                strictModeCard(
                                    mode: .hard,
                                    icon: "lock.fill",
                                    iconColor: Color(red: 1.0, green: 0.4, blue: 0.4),
                                    title: "Hard",
                                    description: "Strict cutoff. No entry after limit."
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 20)
                }
                
                // Activate Button
                Button(action: {}) {
                    HStack(spacing: 8) {
                        Text("Activate Schedule")
                            .font(.system(size: 16, weight: .bold, design: .default))
                            .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(appTheme.colors.primary)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showStartTimePicker) {
            TimePickerSheet(selectedTime: $startTime, title: "Set Start Time")
                .presentationDetents([.height(400)])
                .presentationBackground(Color(red: 0.06, green: 0.13, blue: 0.09))
        }
        .sheet(isPresented: $showEndTimePicker) {
            TimePickerSheet(selectedTime: $endTime, title: "Set End Time")
                .presentationDetents([.height(400)])
                .presentationBackground(Color(red: 0.06, green: 0.13, blue: 0.09))
        }
    }
    
    private func timeCard(icon: String, iconColor: Color, label: String, time: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 11, weight: .semibold, design: .default))
                    .foregroundColor(.white.opacity(0.5))
                    .tracking(0.5)
                
                Text(time)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Image(systemName: "chevron.down")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(16)
        .background(Color(red: 0.09, green: 0.16, blue: 0.12))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
    
    private func dayLabel(_ day: Int) -> String {
        ["M", "T", "W", "T", "F", "S", "S"][day - 1]
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date).uppercased()
    }
    
    private func dayButton(day: String, isSelected: Bool) -> some View {
        Text(day)
            .font(.system(size: 14, weight: .bold, design: .default))
            .foregroundColor(isSelected ? Color(red: 0.06, green: 0.13, blue: 0.09) : .white.opacity(0.4))
            .frame(width: 40, height: 40)
            .background(isSelected ? appTheme.colors.primary : Color.white.opacity(0.1))
            .cornerRadius(20)
            .shadow(color: isSelected ? appTheme.colors.primary.opacity(0.4) : Color.clear, radius: 8, x: 0, y: 0)
    }
    
    private func strictModeCard(mode: StrictMode, icon: String, iconColor: Color, title: String, description: String) -> some View {
        Button(action: { strictMode = mode }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.15, green: 0.12, blue: 0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Radio Button
                ZStack {
                    Circle()
                        .stroke(strictMode == mode ? appTheme.colors.primary : Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if strictMode == mode {
                        Circle()
                            .fill(appTheme.colors.primary)
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding(16)
            .background(Color(red: 0.09, green: 0.16, blue: 0.12))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(strictMode == mode ? appTheme.colors.primary : Color.white.opacity(0.1), lineWidth: strictMode == mode ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CreateScheduledBlockView()
}
