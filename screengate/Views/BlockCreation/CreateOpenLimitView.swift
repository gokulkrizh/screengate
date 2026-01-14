import SwiftUI

struct CreateOpenLimitView: View {
    @Environment(\.dismiss) var dismiss
    @State private var blockName = ""
    @State private var openCount = 3
    @State private var selectedDays: Set<Int> = [1, 2, 3, 4, 5] // M-F
    @State private var strictMode: StrictMode = .medium
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
                    
                    Text("Create Open Limit")
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
                        BlockNameTextField(
                            text: $blockName,
                            icon: "timer",
                            placeholder: "Social Media Focus"
                        )
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
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.3))
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
                        
                        // Open Limit Counter
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Open Limit")
                                .font(.system(size: 20, weight: .bold, design: .default))
                                .foregroundColor(.white)
                            
                            HStack {
                                Spacer()
                                
                                // Minus Button
                                Button(action: {
                                    if openCount > 0 {
                                        openCount -= 1
                                    }
                                }) {
                                    Image(systemName: "minus")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 56, height: 56)
                                        .background(Color(red: 0.1, green: 0.2, blue: 0.14))
                                        .cornerRadius(28)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                }
                                
                                Spacer()
                                
                                // Count Display
                                Text("\(openCount)")
                                    .font(.system(size: 72, weight: .bold, design: .default))
                                    .foregroundColor(appTheme.colors.primary)
                                    .frame(minWidth: 120)
                                
                                Spacer()
                                
                                // Plus Button
                                Button(action: {
                                    openCount += 1
                                }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                                        .frame(width: 56, height: 56)
                                        .background(appTheme.colors.primary)
                                        .cornerRadius(28)
                                        .shadow(color: appTheme.colors.primary.opacity(0.3), radius: 12, x: 0, y: 0)
                                }
                                
                                Spacer()
                            }
                            .padding(.vertical, 32)
                            .background(Color(red: 0.09, green: 0.16, blue: 0.12))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
                            )
                            
                            Text("Times / Day")
                                .font(.system(size: 14, weight: .medium, design: .default))
                                .foregroundColor(.white.opacity(0.6))
                                .frame(maxWidth: .infinity, alignment: .center)
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
                                        DayButton(day: dayLabel(day), isSelected: selectedDays.contains(day))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
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
                                StrictModeCard(
                                    mode: .easy,
                                    icon: "cup.and.saucer.fill",
                                    iconColor: appTheme.colors.primary,
                                    title: "Easy",
                                    description: "Allow short breaks after limit",
                                    isSelected: strictMode == .easy,
                                    action: { strictMode = .easy }
                                )
                                
                                StrictModeCard(
                                    mode: .medium,
                                    icon: "timer",
                                    iconColor: Color(red: 1.0, green: 0.8, blue: 0.0),
                                    title: "Medium",
                                    description: "15s breathing delay on open",
                                    isSelected: strictMode == .medium,
                                    action: { strictMode = .medium }
                                )
                                
                                StrictModeCard(
                                    mode: .hard,
                                    icon: "lock.fill",
                                    iconColor: Color(red: 1.0, green: 0.4, blue: 0.4),
                                    title: "Hard",
                                    description: "Strict cutoff. No entry after limit.",
                                    isSelected: strictMode == .hard,
                                    action: { strictMode = .hard }
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
                
                // Create Button
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 0.5)
                    
                    Button(action: {}) {
                        Text("Create Open Limit")
                            .font(.system(size: 16, weight: .bold, design: .default))
                            .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(appTheme.colors.primary)
                            .cornerRadius(12)
                            .shadow(color: appTheme.colors.primary.opacity(0.25), radius: 12, x: 0, y: 0)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(Color(red: 0.06, green: 0.13, blue: 0.09).opacity(0.95))
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    CreateOpenLimitView()
}
