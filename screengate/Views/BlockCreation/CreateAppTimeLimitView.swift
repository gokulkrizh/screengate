import SwiftUI
import FamilyControls

struct CreateAppTimeLimitView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(BlockManager.self) private var blockManager
    
    @State private var blockName = ""
    @State private var selectedHours = 1
    @State private var selectedMinutes = 30
    @State private var selectedDays: Set<Int> = [1, 2, 3, 4, 5] // M-F
    @State private var strictMode: StrictMode = .medium
    @State private var scheduleEnabled = true
    @State private var notificationsEnabled = false
    @State private var showDurationPicker = false
    @State private var showActivityPicker = false
    @State private var activitySelection: FamilyActivitySelection = FamilyActivitySelection()
    @State private var error: String?
    @State private var isCreating = false
    
    private let appTheme = AppTheme.shared
    
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
                    
                    Text("App Time Limit")
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
                        BlockNameTextField(
                            text: $blockName,
                            icon: "timer",
                            placeholder: "Instagram Daily Limit"
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
                                            ForEach(Array(activitySelection.applicationTokens).prefix(3), id: \.self) { _ in
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
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(!activitySelection.applicationTokens.isEmpty ? "Selected Apps" : "Instagram, TikTok +2")
                                            .font(.system(size: 16, weight: .semibold, design: .default))
                                            .foregroundColor(.white)
                                        
                                        Text("Tap to change")
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
                        
                        // Daily Limit
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Daily Limit")
                                .font(.system(size: 20, weight: .bold, design: .default))
                                .foregroundColor(.white)
                            
                            Button(action: { showDurationPicker = true }) {
                                HStack {
                                    Image(systemName: "clock")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(appTheme.colors.primary)
                                    
                                    Text(String(format: "%d:%02d", selectedHours, selectedMinutes))
                                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("hours per day")
                                            .font(.system(size: 12, weight: .regular, design: .default))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
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
                            .padding(.horizontal, 16)
                        }
                        
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
                                    
                                    Text("Enable/disable on specific days")
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
                Button(action: {
                    Task {
                        await createAppTimeLimit()
                    }
                }) {
                    if isCreating {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(appTheme.colors.primary)
                    } else {
                        Text("Create Block")
                            .font(.system(size: 16, weight: .bold, design: .default))
                            .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(appTheme.colors.primary)
                .cornerRadius(12)
                .disabled(isCreating || blockName.isEmpty || activitySelection.applicationTokens.isEmpty)
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
    private func createAppTimeLimit() async {
        guard !blockName.isEmpty else {
            error = "Please enter a block name"
            return
        }
        
        guard !activitySelection.applicationTokens.isEmpty else {
            error = "Please select at least one app"
            return
        }
        
        isCreating = true
        
        let threshold = TimeInterval((selectedHours * 3600) + (selectedMinutes * 60))
        let startTime = Calendar.current.startOfDay(for: Date())
        let endTime = Calendar.current.date(byAdding: .day, value: 1, to: startTime) ?? Date()
        
        let schedule = Block.BlockSchedule(
            startTime: startTime,
            endTime: endTime,
            duration: nil,
            threshold: threshold,
            repeatDays: selectedDays.isEmpty ? nil : selectedDays,
            isRepeating: !selectedDays.isEmpty
        )
        
        let block = Block(
            name: blockName,
            type: .appTimeLimit,
            appSelection: activitySelection,
            schedule: schedule,
            strictMode: strictMode,
            isActive: false
        )
        
        do {
            try blockManager.createBlock(block)
            try await blockManager.activateBlock(block)
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }
        
        isCreating = false
    }
    
    private func dayLabel(_ day: Int) -> String {
        let days = ["M", "T", "W", "T", "F", "S", "S"]
        return days[day - 1]
    }
}

#Preview {
    CreateAppTimeLimitView()
}
