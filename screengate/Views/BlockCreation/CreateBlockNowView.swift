import SwiftUI

struct CreateBlockNowView: View {
    @Environment(\.dismiss) var dismiss
    @State private var blockName = ""
    @State private var selectedHours = 0
    @State private var selectedMinutes = 20
    @State private var strictMode: StrictMode = .medium
    @State private var selectedPreset: Int? = 25
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
                    
                    Text("Block Now")
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                ScrollView {
                    VStack(spacing: 32) {
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
                        .padding(.horizontal, 20)
                        
                        // Timer Picker Section
                        VStack(spacing: 16) {
                            Text("SET DURATION")
                                .font(.system(size: 12, weight: .medium, design: .default))
                                .foregroundColor(.white.opacity(0.5))
                                .tracking(1)
                            
                            // Time Display
                            Button(action: { showDurationPicker = true }) {
                                VStack(spacing: 12) {
                                    HStack(spacing: 0) {
                                        Text(String(format: "%02d", selectedHours))
                                            .font(.system(size: 80, weight: .bold, design: .default))
                                            .foregroundColor(appTheme.colors.primary)
                                        
                                        Text(":")
                                            .font(.system(size: 80, weight: .bold, design: .default))
                                            .foregroundColor(appTheme.colors.primary)
                                        
                                        Text(String(format: "%02d", selectedMinutes))
                                            .font(.system(size: 80, weight: .bold, design: .default))
                                            .foregroundColor(appTheme.colors.primary)
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
                                .padding(.vertical, 40)
                                .background(Color(red: 0.09, green: 0.16, blue: 0.12))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                                )
                            }
                            
                            // Quick Presets
                            HStack(spacing: 12) {
                                presetButton(10, selected: selectedPreset == 10)
                                presetButton(25, selected: selectedPreset == 25)
                                presetButton(45, selected: selectedPreset == 45)
                                
                                Button(action: { selectedPreset = 60 }) {
                                    Text("1h")
                                        .font(.system(size: 14, weight: .semibold, design: .default))
                                        .foregroundColor(selectedPreset == 60 ? appTheme.colors.primary : .white)
                                        .frame(height: 36)
                                        .padding(.horizontal, 16)
                                        .background(Color(red: 0.1, green: 0.2, blue: 0.14))
                                        .cornerRadius(18)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(selectedPreset == 60 ? appTheme.colors.primary.opacity(0.3) : Color.white.opacity(0.05), lineWidth: 1)
                                        )
                                }
                            }
                        }                        .padding(.horizontal, 20)                        .padding(.top, 20)
                        
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
                        
                        // Select Strictness
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Select Strictness")
                                .font(.system(size: 20, weight: .bold, design: .default))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
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
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 100)
                }
                
                // Start Focusing Button
                Button(action: {}) {
                    HStack(spacing: 8) {
                        Text("Start Focusing")
                            .font(.system(size: 16, weight: .bold, design: .default))
                            .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                        
                        Image(systemName: "play.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(appTheme.colors.primary)
                    .cornerRadius(12)
                    .shadow(color: appTheme.colors.primary.opacity(0.25), radius: 12, x: 0, y: 0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showDurationPicker) {
            DurationPickerSheet(hours: $selectedHours, minutes: $selectedMinutes, title: "Set Duration")
                .presentationDetents([.height(400)])
                .presentationBackground(Color(red: 0.06, green: 0.13, blue: 0.09))
        }
    }
    
    private func presetButton(_ minutes: Int, selected: Bool) -> some View {
        Button(action: { selectedPreset = minutes }) {
            Text("\(minutes)m")
                .font(.system(size: 14, weight: .semibold, design: .default))
                .foregroundColor(selected ? appTheme.colors.primary : .white)
                .frame(height: 36)
                .padding(.horizontal, 16)
                .background(Color(red: 0.1, green: 0.2, blue: 0.14))
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(selected ? appTheme.colors.primary.opacity(0.3) : Color.white.opacity(0.05), lineWidth: 1)
                )
                .shadow(color: selected ? appTheme.colors.primary.opacity(0.1) : Color.clear, radius: 8, x: 0, y: 0)
        }
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
    CreateBlockNowView()
}
