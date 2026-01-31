import SwiftUI
import FamilyControls

struct CreateBlockNowView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(BlockManager.self) private var blockManager
    @Environment(AppListManager.self) private var appListManager
    
    @State private var blockName = "Focus Session"
    @State private var selectedHours = 0
    @State private var selectedMinutes = 5
    @State private var strictMode: StrictMode = .medium
    @State private var selectedPreset: Int? = nil
    @State private var showDurationPicker = false
    @State private var showActivityPicker = false
    @State private var showAppListPicker = false
    @State private var activitySelection: FamilyActivitySelection = FamilyActivitySelection()
    @State private var selectedListName: String = ""
    @State private var selectedListIcon: String = ""
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
                            
                            if activitySelection.applicationTokens.isEmpty {
                                // Show only "From App List" button when no apps selected
                                Button(action: { showAppListPicker = true }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "square.stack.3d.up.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(appTheme.colors.primary)
                                        
                                        Text(appListManager.lists.isEmpty ? "Create App List" : "From App List")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(Color.white.opacity(0.3))
                                    }
                                    .padding(16)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                                }
                            } else {
                                // Show selected apps with ability to modify
                                Button(action: { showAppListPicker = true }) {
                                    HStack(spacing: 12) {
                                        // List Icon
                                        Circle()
                                            .fill(appTheme.colors.primary.opacity(0.2))
                                            .frame(width: 48, height: 48)
                                            .overlay(
                                                Image(systemName: selectedListIcon)
                                                    .font(.system(size: 20))
                                                    .foregroundColor(appTheme.colors.primary)
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(selectedListName)
                                                .font(.system(size: 16, weight: .semibold, design: .default))
                                                .foregroundColor(.white)
                                            
                                            Text("Tap to change")
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
                                Button(action: { setPreset(10) }) {
                                    Text("10m")
                                        .font(.system(size: 14, weight: .semibold, design: .default))
                                        .foregroundColor(selectedPreset == 10 ? appTheme.colors.primary : .white)
                                        .frame(height: 36)
                                        .padding(.horizontal, 16)
                                        .background(Color(red: 0.1, green: 0.2, blue: 0.14))
                                        .cornerRadius(18)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(selectedPreset == 10 ? appTheme.colors.primary.opacity(0.3) : Color.white.opacity(0.05), lineWidth: 1)
                                        )
                                }
                                
                                Button(action: { setPreset(20) }) {
                                    Text("20m")
                                        .font(.system(size: 14, weight: .semibold, design: .default))
                                        .foregroundColor(selectedPreset == 20 ? appTheme.colors.primary : .white)
                                        .frame(height: 36)
                                        .padding(.horizontal, 16)
                                        .background(Color(red: 0.1, green: 0.2, blue: 0.14))
                                        .cornerRadius(18)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(selectedPreset == 20 ? appTheme.colors.primary.opacity(0.3) : Color.white.opacity(0.05), lineWidth: 1)
                                        )
                                }
                                
                                Button(action: { setPreset(45) }) {
                                    Text("45m")
                                        .font(.system(size: 14, weight: .semibold, design: .default))
                                        .foregroundColor(selectedPreset == 45 ? appTheme.colors.primary : .white)
                                        .frame(height: 36)
                                        .padding(.horizontal, 16)
                                        .background(Color(red: 0.1, green: 0.2, blue: 0.14))
                                        .cornerRadius(18)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(selectedPreset == 45 ? appTheme.colors.primary.opacity(0.3) : Color.white.opacity(0.05), lineWidth: 1)
                                        )
                                }
                                
                                Button(action: { setPreset(60) }) {
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
        .sheet(isPresented: $showAppListPicker) {
            AppListsView(isSelectionMode: true) { selectedList in
                activitySelection = selectedList.selection
                selectedListName = selectedList.name
                selectedListIcon = selectedList.icon
                blockName = selectedList.name
            }
        }
        .alert("Error", isPresented: .constant(error != nil), presenting: error) { _ in
            Button("OK") { error = nil }
        } message: { errorMsg in
            Text(errorMsg)
        }
        .onChange(of: appListManager.lists) { oldLists, newLists in
            // If the selected list no longer exists, clear the selection
            if !selectedListName.isEmpty {
                let selectedListExists = newLists.contains { $0.name == selectedListName && $0.icon == selectedListIcon }
                if !selectedListExists {
                    selectedListName = ""
                    selectedListIcon = ""
                    activitySelection = FamilyActivitySelection()
                    blockName = "Focus Session"
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setPreset(_ minutes: Int) {
        selectedPreset = minutes
        selectedHours = minutes / 60
        selectedMinutes = minutes % 60
    }
    
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
}

#Preview {
    CreateBlockNowView()
}
