import SwiftUI

struct CreateAppTimeLimitView: View {
    @Environment(\.dismiss) var dismiss
    @State private var blockName = ""
    @State private var selectedHours = 1
    @State private var selectedMinutes = 30
    @State private var selectedDays: Set<Int> = [1, 2, 3, 4, 5] // M-F
    @State private var strictMode: StrictMode = .medium
    @State private var scheduleEnabled = true
    @State private var notificationsEnabled = false
    @State private var showDurationPicker = false
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
                    
                    Text("Create Block")
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Text("Save")
                            .font(.system(size: 16, weight: .bold, design: .default))
                            .foregroundColor(appTheme.colors.primary)
                    }
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
                        
                        // Daily Limit
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Daily Limit")
                                    .font(.system(size: 20, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(appTheme.colors.primary)
                                        .frame(width: 6, height: 6)
                                    
                                    Text("Daily")
                                        .font(.system(size: 14, weight: .medium, design: .default))
                                        .foregroundColor(appTheme.colors.primary)
                                }
                            }
                            
                            // Time Display
                            Button(action: { showDurationPicker = true }) {
                                VStack(spacing: 12) {
                                    HStack(spacing: 8) {
                                        Text("\(selectedHours)")
                                            .font(.system(size: 80, weight: .bold, design: .default))
                                            .foregroundColor(.white)
                                        
                                        Text("H")
                                            .font(.system(size: 32, weight: .bold, design: .default))
                                            .foregroundColor(appTheme.colors.primary)
                                            .offset(y: 10)
                                        
                                        Text("\(selectedMinutes)")
                                            .font(.system(size: 80, weight: .bold, design: .default))
                                            .foregroundColor(.white)
                                        
                                        Text("M")
                                            .font(.system(size: 32, weight: .bold, design: .default))
                                            .foregroundColor(appTheme.colors.primary)
                                            .offset(y: 10)
                                    }
                                    
                                    HStack(spacing: 6) {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white.opacity(0.5))
                                        
                                        Text("TAP TO ADJUST")
                                            .font(.system(size: 12, weight: .medium, design: .default))
                                            .foregroundColor(.white.opacity(0.5))
                                            .tracking(0.5)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 32)
                                .background(Color(red: 0.09, green: 0.16, blue: 0.12))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.1), Color.clear]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 1)
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
                        .padding(.horizontal, 16)
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.1), Color.clear]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 1)
                            .padding(.horizontal, 20)
                        
                        // Strictness Level
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Strictness Level")
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
                        .padding(.horizontal, 16)
                        
                        // Settings
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "calendar")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Schedule")
                                        .font(.system(size: 16, weight: .semibold, design: .default))
                                        .foregroundColor(.white)
                                    
                                    Text("Apply every day of the week")
                                        .font(.system(size: 13, weight: .regular, design: .default))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $scheduleEnabled)
                                    .labelsHidden()
                                    .tint(appTheme.colors.primary)
                            }
                            
                            HStack {
                                Image(systemName: "bell.slash")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Block Notifications")
                                        .font(.system(size: 16, weight: .semibold, design: .default))
                                        .foregroundColor(.white)
                                    
                                    Text("Hide alerts during block")
                                        .font(.system(size: 13, weight: .regular, design: .default))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $notificationsEnabled)
                                    .labelsHidden()
                                    .tint(appTheme.colors.primary)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 20)
                    .padding(.bottom, 80)
                }
                
                // Create Block Button
                Button(action: {}) {
                    Text("Create Block")
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
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
        .sheet(isPresented: $showDurationPicker) {
            DurationPickerSheet(hours: $selectedHours, minutes: $selectedMinutes, title: "Set Daily Limit")
                .presentationDetents([.height(400)])
                .presentationBackground(Color(red: 0.06, green: 0.13, blue: 0.09))
        }
    }
    
    private func dayLabel(_ day: Int) -> String {
        ["M", "T", "W", "T", "F", "S", "S"][day - 1]
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
    CreateAppTimeLimitView()
}
