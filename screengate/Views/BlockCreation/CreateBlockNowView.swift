import SwiftUI
import FamilyControls

struct CreateBlockNowView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(BlockManager.self) private var blockManager
    
    @State private var blockName = "Focus Session"
    @State private var selectedHours = 0
    @State private var selectedMinutes = 5
    @State private var strictMode: StrictMode = .medium
    @State private var selectedPreset: Int? = nil
    @State private var showDurationPicker = false
    @State private var showActivityPicker = false
    @State private var activitySelection: FamilyActivitySelection = FamilyActivitySelection()
    @State private var error: String?
    @State private var isCreating = false
    
    private let appTheme = AppTheme.shared
    
    private var isButtonEnabled: Bool {
        !isCreating && 
        !blockName.trimmingCharacters(in: .whitespaces).isEmpty && 
        !activitySelection.applicationTokens.isEmpty &&
        (selectedHours > 0 || selectedMinutes > 0)
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
                            
                            Button(action: { showActivityPicker = true }) {
                                HStack(spacing: 12) {
                                    // Stacked Icons from selection
                                    HStack(spacing: -12) {
                                        if !activitySelection.applicationTokens.isEmpty {
                                            ForEach(Array(activitySelection.applicationTokens).prefix(3), id: \.self) { token in
                                                Circle()
                                                    .fill(Color.blue.opacity(0.7))
                                                    .frame(width: 40, height: 40)
                                                    .overlay(
                                                        Image(systemName: "app.fill")
                                                            .font(.system(size: 16))
                                                            .foregroundColor(.white)
                                                    )
                                                    .overlay(Circle().stroke(Color(red: 0.09, green: 0.16, blue: 0.12), lineWidth: 2))
                                            }
                                        } else {
                                            // Show default icons
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
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        if activitySelection.applicationTokens.isEmpty {
                                            Text("Select Apps")
                                                .font(.system(size: 16, weight: .semibold, design: .default))
                                                .foregroundColor(.white.opacity(0.7))
                                        } else {
                                            Text("\(activitySelection.applicationTokens.count) Apps Selected")
                                                .font(.system(size: 16, weight: .semibold, design: .default))
                                                .foregroundColor(.white)
                                            
                                            Text("Tap to modify")
                                                .font(.system(size: 12, weight: .regular, design: .default))
                                                .foregroundColor(.white.opacity(0.5))
                                        }
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
                    .padding(.bottom, 100)
                }
                
                // Start Focusing Button
                Button(action: {
                    Task {
                        await createBlockNow()
                    }
                }) {
                    if isCreating {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(Color(red: 0.06, green: 0.13, blue: 0.09))
                    } else {
                        HStack(spacing: 8) {
                            Text("Start Focusing")
                                .font(.system(size: 16, weight: .bold, design: .default))
                                .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                            
                            Image(systemName: "play.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(isButtonEnabled ? appTheme.colors.primary : appTheme.colors.primary.opacity(0.5))
                .cornerRadius(12)
                .shadow(color: isButtonEnabled ? appTheme.colors.primary.opacity(0.25) : Color.clear, radius: 12, x: 0, y: 0)
                .disabled(!isButtonEnabled)
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
        .sheet(isPresented: $showActivityPicker) {
            FamilyActivitySelectionView(selection: $activitySelection)
        }
        .alert("Error", isPresented: .constant(error != nil), presenting: error) { _ in
            Button("OK") { error = nil }
        } message: { errorMsg in
            Text(errorMsg)
        }
    }
    
    // MARK: - Private Methods
    
    @MainActor
    private func createBlockNow() async {
        guard !blockName.trimmingCharacters(in: .whitespaces).isEmpty else {
            error = "Please enter a block name"
            return
        }
        
        guard !activitySelection.applicationTokens.isEmpty else {
            error = "Please select at least one app"
            return
        }
        
        guard (selectedHours > 0 || selectedMinutes > 0) else {
            error = "Please set a duration greater than 0"
            return
        }
        
        isCreating = true
        defer { isCreating = false }
        
        let duration = TimeInterval((selectedHours * 3600) + (selectedMinutes * 60))
        let endTime = Date(timeIntervalSinceNow: duration)
        
        let schedule = Block.BlockSchedule(
            startTime: nil,
            endTime: endTime,
            duration: duration,
            threshold: nil,
            repeatDays: nil,
            isRepeating: false
        )
        
        let block = Block(
            name: blockName,
            type: .blockNow,
            appSelection: activitySelection,
            schedule: schedule,
            strictMode: strictMode,
            isActive: false
        )
        
        do {
            try blockManager.createBlock(block)
            try await blockManager.activateBlock(block)
            DispatchQueue.main.async {
                dismiss()
            }
        } catch {
            print("Error creating block: \(error)")
            self.error = "Failed to create block: \(error.localizedDescription)"
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
}

#Preview {
    CreateBlockNowView()
}
