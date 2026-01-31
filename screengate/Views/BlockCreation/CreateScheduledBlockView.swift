import SwiftUI
import FamilyControls

struct CreateScheduledBlockView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(BlockManager.self) private var blockManager
    @Environment(AppListManager.self) private var appListManager
    
    @State private var blockName = "Schedule Focus Session"
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var selectedDays: Set<Int> = [2, 3, 4, 5, 6] // Mon-Fri (Calendar weekday values)
    @State private var strictMode: StrictMode = .medium
    @State private var showStartTimePicker = false
    @State private var showEndTimePicker = false
    @State private var showActivityPicker = false
    @State private var showAppListPicker = false
    @State private var activitySelection: FamilyActivitySelection = FamilyActivitySelection()
    @State private var selectedListName: String = ""
    @State private var selectedListIcon: String = ""
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
                            BlockNameTextField(
                                text: $blockName,
                                icon: "timer",
                                placeholder: "Social Media Focus"
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        
                        // Apps to Block
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Apps to Block")
                                .font(.system(size: 20, weight: .bold, design: .default))
                                .foregroundColor(.white)
                            
                            if activitySelection.applicationTokens.isEmpty && activitySelection.categoryTokens.isEmpty {
                                // Show only "From App List" button when no apps or categories selected
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
                        .padding(.horizontal, 16)
                        
                        // Focus Duration
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Focus Duration")
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(.white)
                            
                            // Start Time
                            TimeCard(
                                icon: "sun.max.fill",
                                iconColor: appTheme.colors.primary,
                                label: "START TIME",
                                time: formatTime(startTime),
                                action: { showStartTimePicker = true }
                            )
                            
                            // Connector line
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 2, height: 16)
                                .frame(maxWidth: .infinity)
                            
                            // End Time
                            TimeCard(
                                icon: "moon.fill",
                                iconColor: Color.blue,
                                label: "END TIME",
                                time: formatTime(endTime),
                                action: { showEndTimePicker = true }
                            )
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
                                        DayButton(day: dayLabel(day), isSelected: selectedDays.contains(day))
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
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 20)
                }
                
                // Activate Button
                Button(action: {
                    Task {
                        await createScheduledBlock()
                    }
                }) {
                    if isCreating {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(Color(red: 0.06, green: 0.13, blue: 0.09))
                    } else {
                        HStack(spacing: 8) {
                            Text("Activate Schedule")
                                .font(.system(size: 16, weight: .bold, design: .default))
                                .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(appTheme.colors.primary)
                .cornerRadius(12)
                .disabled(isCreating || blockName.isEmpty || (activitySelection.applicationTokens.isEmpty && activitySelection.categoryTokens.isEmpty)) // Removed app selection check for simulator testing
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
                    blockName = "Schedule Focus Session"
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    @MainActor
    private func createScheduledBlock() async {
        guard !blockName.isEmpty else {
            error = "Please enter a block name"
            return
        }
        
        // COMMENTED FOR SIMULATOR TESTING - Family Controls requires physical device
        
        guard !activitySelection.applicationTokens.isEmpty || !activitySelection.categoryTokens.isEmpty else {
            error = "Please select at least one app"
            return
        }
        
        
        guard startTime < endTime else {
            error = "Start time must be before end time"
            return
        }
        
        isCreating = true
        
        let schedule = Block.BlockSchedule(
            startTime: startTime,
            endTime: endTime,
            duration: nil,
            threshold: nil,
            repeatDays: selectedDays.isEmpty ? nil : selectedDays,
            isRepeating: !selectedDays.isEmpty
        )
        
        let block = Block(
            name: blockName,
            type: .scheduled,
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
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date).uppercased()
    }
}

#Preview {
    CreateScheduledBlockView()
}
