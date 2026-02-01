import SwiftUI
import FamilyControls

struct CreateScheduledBlockView: View {
    @Environment(\.dismiss) var dismiss
    let editingBlock: Block?
    
    private var isEditing: Bool {
        editingBlock != nil
    }
    @Environment(BlockManager.self) private var blockManager
    @Environment(AppListManager.self) private var appListManager
    
    @State private var blockName = "Schedule Focus Session"
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var selectedDays: Set<Int> = [2, 3, 4, 5, 6] // Mon-Fri (Calendar weekday values)
    @State private var strictMode: StrictMode? = nil
    @State private var showStrictModePicker = false
    @State private var showStartTimePicker = false
    @State private var showEndTimePicker = false
    @State private var showActivityPicker = false
    @State private var showAppListPicker = false
    @State private var activitySelection: FamilyActivitySelection = FamilyActivitySelection()
    @State private var selectedListName: String = ""
    @State private var selectedListIcon: String = ""
    @State private var error: String?
    @State private var isCreating = false
    @State private var selectedAppListId: UUID?
    @State private var selectedBlockIcon = "app.fill"
    @State private var selectedBlockIconColor = "#66C5A8"
    @State private var showIconPicker = false
    
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
                    
                    Text(isEditing ? "Edit Block" : "Create Schedule")
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
                        
                        // Block Icon
                        // VStack(alignment: .leading, spacing: 12) {
                        //     Text("Icon")
                        //         .font(.system(size: 16, weight: .semibold, design: .default))
                        //         .foregroundColor(.white)
                            
                        //     Button(action: { showIconPicker.toggle() }) {
                        //         HStack(spacing: 12) {
                        //             Circle()
                        //                 .fill(appTheme.colors.primary.opacity(0.2))
                        //                 .frame(width: 48, height: 48)
                        //                 .overlay(
                        //                     Image(systemName: selectedBlockIcon)
                        //                         .font(.system(size: 20))
                        //                         .foregroundColor(appTheme.colors.primary)
                        //                 )
                                    
                        //             Text("Choose Icon")
                        //                 .font(.system(size: 16, weight: .medium))
                        //                 .foregroundColor(.white)
                                    
                        //             Spacer()
                                    
                        //             Image(systemName: "chevron.right")
                        //                 .font(.system(size: 14, weight: .semibold))
                        //                 .foregroundColor(Color.white.opacity(0.3))
                        //         }
                        //         .padding(16)
                        //         .background(Color.white.opacity(0.05))
                        //         .cornerRadius(12)
                        //     }
                            
                        //     if showIconPicker {
                        //         LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 12) {
                        //             ForEach([
                        //                 "app.fill", "flame.fill", "star.fill", "heart.fill",
                        //                 "bolt.fill", "moon.fill", "sun.max.fill", "timer",
                        //                 "calendar", "square.stack.3d.up.fill", "tray.fill", "folder.fill"
                        //             ], id: \.self) { icon in
                        //                 Button(action: {
                        //                     selectedBlockIcon = icon
                        //                     showIconPicker = false
                        //                 }) {
                        //                     Circle()
                        //                         .fill(selectedBlockIcon == icon ? appTheme.colors.primary.opacity(0.3) : Color.white.opacity(0.05))
                        //                         .frame(width: 60, height: 60)
                        //                         .overlay(
                        //                             Image(systemName: icon)
                        //                                 .font(.system(size: 24))
                        //                                 .foregroundColor(selectedBlockIcon == icon ? appTheme.colors.primary : .white)
                        //                         )
                        //                 }
                        //             }
                        //         }
                        //         .padding(16)
                        //         .background(Color.white.opacity(0.03))
                        //         .cornerRadius(12)
                        //     }
                        // }
                        // .padding(.horizontal, 20)
                        
                        // Apps to Block
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Apps to Block")
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(.white)
                            
                            let shouldShowPlaceholder = (activitySelection.applicationTokens.isEmpty && activitySelection.categoryTokens.isEmpty) && selectedListName.isEmpty
                            if shouldShowPlaceholder {
                                // Show only "From App List" button when no apps or categories selected and no list name
                                let _ = print("🔵 [CreateScheduledBlockView] UI: Showing 'From App List' placeholder - appSelection.isEmpty=\(activitySelection.applicationTokens.isEmpty && activitySelection.categoryTokens.isEmpty), selectedListName.isEmpty=\(selectedListName.isEmpty)")
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
                            
                            HStack(spacing: 12) {
                                // Start Time
                                TimeCard(
                                    icon: "sun.max.fill",
                                    iconColor: appTheme.colors.primary,
                                    label: "FROM",
                                    time: formatTime(startTime),
                                    action: { showStartTimePicker = true },
                                    showIcon: false
                                )
                                .frame(maxWidth: .infinity)
                                
                                // End Time
                                TimeCard(
                                    icon: "moon.fill",
                                    iconColor: Color.blue,
                                    label: "TO",
                                    time: formatTime(endTime),
                                    action: { showEndTimePicker = true },
                                    showIcon: false
                                )
                                .frame(maxWidth: .infinity)
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
                                        DayButton(day: dayLabel(day), isSelected: selectedDays.contains(day))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Select Intensity
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Select Intensity")
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(.white)
                            
                            Button(action: { showStrictModePicker = true }) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(red: 0.06, green: 0.13, blue: 0.09))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: strictModeIcon)
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(strictModeIconColor)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("INTENSITY")
                                            .font(.system(size: 11, weight: .bold, design: .default))
                                            .tracking(0.5)
                                            .foregroundColor(.white.opacity(0.5))
                                            .textCase(.uppercase)
                                        
                                        Text(strictMode?.displayName ?? "Not selected")
                                            .font(.system(size: 16, weight: .bold, design: .default))
                                            .foregroundColor(strictMode == nil ? .white.opacity(0.5) : .white)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.4))
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 0.09, green: 0.16, blue: 0.12))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 20)
                }
                .scrollIndicators(.hidden)
                
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
                            Text(isEditing ? "Save Changes" : "Activate Schedule")
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
                .disabled(isCreating || blockName.isEmpty || strictMode == nil || (activitySelection.applicationTokens.isEmpty && activitySelection.categoryTokens.isEmpty)) // Removed app selection check for simulator testing
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
            AppListsView(isSelectionMode: true, currentlySelectedListId: selectedAppListId) { selectedList in
                print("✅ [CreateScheduledBlockView] App list selected: id=\(selectedList.id), name=\(selectedList.name)")
                activitySelection = selectedList.selection
                selectedAppListId = selectedList.id
                selectedListName = selectedList.name
                selectedListIcon = selectedList.icon
                print("✅ [CreateScheduledBlockView] App list assigned to state: appSelection apps=\(selectedList.selection.applicationTokens.count), categories=\(selectedList.selection.categoryTokens.count)")
                if blockName == "Schedule Focus Session" {
                    blockName = selectedList.name
                    print("✅ [CreateScheduledBlockView] Block name auto-updated to: \(selectedList.name)")
                }
            }
        }
        .sheet(isPresented: $showStrictModePicker) {
            StrictModePickerSheet(selectedMode: $strictMode)
                .presentationDetents([.height(500)])
                .presentationBackground(Color(red: 0.06, green: 0.13, blue: 0.09))
        }
        .alert("Error", isPresented: .constant(error != nil), presenting: error) { _ in
            Button("OK") { error = nil }
        } message: { errorMsg in
            Text(errorMsg)
        }
        .onAppear {
            if let editingBlock = editingBlock {
                print("\n🟢 [CreateScheduledBlockView] onAppear: Entering edit mode for block: \(editingBlock.name)")
                blockName = editingBlock.name
                startTime = editingBlock.schedule.startTime ?? Date()
                endTime = editingBlock.schedule.endTime ?? Date()
                selectedDays = editingBlock.schedule.repeatDays ?? []
                strictMode = editingBlock.strictMode
                activitySelection = editingBlock.appSelection
                print("🟢 [CreateScheduledBlockView] Pre-filled activity selection: apps=\(editingBlock.appSelection.applicationTokens.count), categories=\(editingBlock.appSelection.categoryTokens.count)")
                selectedBlockIcon = editingBlock.icon
                selectedBlockIconColor = editingBlock.iconColor
                
                print("🟢 [CreateScheduledBlockView] App list metadata: appListId=\(editingBlock.appListId?.uuidString ?? "nil"), appListName=\(editingBlock.appListName ?? "nil")")
                
                if let appListId = editingBlock.appListId {
                    print("🟢 [CreateScheduledBlockView] Attempting to pre-fill by UUID: \(appListId.uuidString)")
                    if let appList = appListManager.getList(id: appListId) {
                        selectedAppListId = appList.id
                        selectedListName = appList.name
                        selectedListIcon = appList.icon
                        print("✅ [CreateScheduledBlockView] Pre-filled app list by UUID: \(appList.name) (icon: \(appList.icon))")
                    } else {
                        selectedListName = ""
                        print("⚠️ [CreateScheduledBlockView] App list with ID \(appListId.uuidString) not found - was deleted")
                    }
                } else if let appListName = editingBlock.appListName {
                    print("🟢 [CreateScheduledBlockView] Attempting to pre-fill by name fallback: \(appListName)")
                    if let appList = appListManager.lists.first(where: { $0.name == appListName }) {
                        selectedAppListId = appList.id
                        selectedListName = appList.name
                        selectedListIcon = appList.icon
                        print("✅ [CreateScheduledBlockView] Pre-filled app list by name: \(appList.name) (icon: \(appList.icon))")
                    } else {
                        selectedListName = ""
                        print("⚠️ [CreateScheduledBlockView] App list '\(appListName)' not found - was deleted")
                    }
                } else {
                    print("ℹ️ [CreateScheduledBlockView] Block has no associated app list metadata")
                    selectedListName = ""
                }
                print("🟢 [CreateScheduledBlockView] onAppear complete - selectedListName=\(selectedListName.isEmpty ? "empty" : selectedListName)\n")
            } else {
                print("🟢 [CreateScheduledBlockView] onAppear: Entering create mode (new block)")
                // ⭐ CRITICAL: Reset all state for new block creation
                blockName = "Schedule Focus Session"
                startTime = Date()
                endTime = Date()
                selectedDays = [2, 3, 4, 5, 6]  // Mon-Fri
                strictMode = nil
                showStrictModePicker = false
                showStartTimePicker = false
                showEndTimePicker = false
                showActivityPicker = false
                showAppListPicker = false
                activitySelection = FamilyActivitySelection()
                selectedListName = ""  // ⭐ CLEAR app list name
                selectedListIcon = ""  // ⭐ CLEAR app list icon
                selectedAppListId = nil  // ⭐ CLEAR app list ID
                selectedBlockIcon = "app.fill"  // ⭐ Reset block icon
                selectedBlockIconColor = "#66C5A8"  // ⭐ Reset block icon color
                error = nil
                isCreating = false
                print("🟢 [CreateScheduledBlockView] Create mode state reset complete")
            }
        }
        .onChange(of: appListManager.lists) { oldLists, newLists in
            // If the selected list no longer exists, clear the selection
            if !selectedListName.isEmpty {
                print("🔄 [CreateScheduledBlockView] App list manager changed - verifying selected list exists")
                let selectedListExists = newLists.contains { $0.name == selectedListName && $0.icon == selectedListIcon }
                if !selectedListExists {
                    print("⚠️ [CreateScheduledBlockView] Selected app list '\(selectedListName)' no longer exists - clearing selection")
                    selectedListName = ""
                    selectedListIcon = ""
                    activitySelection = FamilyActivitySelection()
                    blockName = "Schedule Focus Session"
                } else {
                    print("✅ [CreateScheduledBlockView] Selected app list '\(selectedListName)' still exists")
                }
            }
        }
    }
    
    init(editingBlock: Block? = nil) {
        self.editingBlock = editingBlock
    }
    
    // MARK: - Private Methods
    
    @MainActor
    private func createScheduledBlock() async {
        print("\n🟡 [CreateScheduledBlockView] createScheduledBlock() called - mode=\(isEditing ? "EDIT" : "CREATE")")
        
        guard !blockName.isEmpty else {
            error = "Please enter a block name"
            print("❌ [CreateScheduledBlockView] Validation failed: empty block name")
            return
        }
        
        guard !activitySelection.applicationTokens.isEmpty || !activitySelection.categoryTokens.isEmpty else {
            error = "Please select at least one app"
            print("❌ [CreateScheduledBlockView] Validation failed: no apps selected")
            return
        }
        
        let duration = endTime.timeIntervalSince(startTime)
        guard duration >= 15 * 60 else {
            error = "Duration must be at least 15 minutes"
            return
        }
        
        guard startTime < endTime else {
            error = "Start time must be before end time"
            print("❌ [CreateScheduledBlockView] Validation failed: start time after end time")
            return
        }
        
        guard let strictMode = strictMode else {
            error = "Please select an intensity mode"
            print("❌ [CreateScheduledBlockView] Validation failed: no strict mode selected")
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
        
        if let editingBlock = editingBlock {
            print("🟡 [CreateScheduledBlockView] EDIT MODE")
            
            do {
                // Detect if enforcement-related data changed
                let scheduleChanged = editingBlock.schedule.startTime != startTime || 
                                     editingBlock.schedule.endTime != endTime
                let daysChanged = editingBlock.schedule.repeatDays != selectedDays
                let appsChanged = editingBlock.appSelection.applicationTokens != activitySelection.applicationTokens ||
                                 editingBlock.appSelection.categoryTokens != activitySelection.categoryTokens
                let appListChanged = editingBlock.appListId != selectedAppListId
                
                let enforcementChanged = scheduleChanged || daysChanged || appsChanged || appListChanged
                
                print("🔍 [CreateScheduledBlockView] Change detection:")
                print("   scheduleChanged: \(scheduleChanged)")
                print("   daysChanged: \(daysChanged)")
                print("   appsChanged: \(appsChanged)")
                print("   appListChanged: \(appListChanged)")
                print("   → enforcementChanged: \(enforcementChanged)")
                
                // Stop monitors if enforcement data changed
                if enforcementChanged {
                    print("⏹️ [CreateScheduledBlockView] Stopping monitors (enforcement data changed)")
                    await blockManager.stopAllMonitorsForBlock(editingBlock)
                } else {
                    print("⏭️ [CreateScheduledBlockView] Skipping monitor stop (only metadata changed)")
                }
                
                // Update block
                var updatedBlock = editingBlock
                updatedBlock.name = blockName
                updatedBlock.icon = selectedBlockIcon
                updatedBlock.iconColor = selectedBlockIconColor
                updatedBlock.schedule = schedule
                updatedBlock.strictMode = strictMode
                updatedBlock.appSelection = activitySelection
                updatedBlock.appListId = selectedAppListId
                updatedBlock.appListName = selectedListName
                
                print("🟡 [CreateScheduledBlockView] Updated block:")
                print("   appListId: \(updatedBlock.appListId?.uuidString ?? "nil")")
                print("   appListName: \(updatedBlock.appListName ?? "nil")")
                print("   apps: \(updatedBlock.appSelection.applicationTokens.count) tokens, \(updatedBlock.appSelection.categoryTokens.count) categories")
                
                // Save to UserDefaults
                try blockManager.updateBlock(updatedBlock)
                print("✅ [CreateScheduledBlockView] Block metadata saved to UserDefaults")
                
                // Restart monitors if enforcement data changed
                if enforcementChanged {
                    print("▶️ [CreateScheduledBlockView] Starting new monitors with updated config")
                    try await blockManager.activateBlock(updatedBlock)
                    print("✅ [CreateScheduledBlockView] Monitors restarted with new enforcement data")
                } else {
                    print("✅ [CreateScheduledBlockView] No monitor restart needed (metadata-only update)")
                }
            } catch {
                self.error = error.localizedDescription
                print("❌ [CreateScheduledBlockView] Edit error: \(error.localizedDescription)")
                isCreating = false
                return
            }
        } else {
            print("🟡 [CreateScheduledBlockView] CREATE MODE: Creating new block")
            do {
                let block = Block(
                    name: blockName,
                    icon: selectedBlockIcon,
                    iconColor: selectedBlockIconColor,
                    type: .scheduled,
                    appSelection: activitySelection,
                    schedule: schedule,
                    strictMode: strictMode,
                    isActive: false,
                    appListId: selectedAppListId,
                    appListName: selectedListName
                )
                print("🟡 [CreateScheduledBlockView] New block: id=\(block.id.uuidString)")
                print("   appListId: \(block.appListId?.uuidString ?? "nil")")
                print("   appListName: \(block.appListName ?? "nil")")
                print("   apps: \(block.appSelection.applicationTokens.count) tokens, \(block.appSelection.categoryTokens.count) categories")
                
                try blockManager.createBlock(block)
                print("✅ [CreateScheduledBlockView] Block saved to UserDefaults")
                
                try await blockManager.activateBlock(block)
                print("✅ [CreateScheduledBlockView] Monitors started for new block")
            } catch {
                self.error = error.localizedDescription
                print("❌ [CreateScheduledBlockView] Create error: \(error.localizedDescription)")
                isCreating = false
                return
            }
        }
        
        print("✅ [CreateScheduledBlockView] \(isEditing ? "Edit" : "Create") completed successfully\n")
        dismiss()
        isCreating = false
    }
    
    private var strictModeIcon: String {
        switch strictMode {
        case .easy: return "cup.and.saucer.fill"
        case .medium: return "timer"
        case .hard: return "lock.fill"
        case .none: return "questionmark.circle"
        }
    }
    
    private var strictModeIconColor: Color {
        switch strictMode {
        case .easy: return appTheme.colors.primary
        case .medium: return Color(red: 1.0, green: 0.8, blue: 0.0)
        case .hard: return Color(red: 1.0, green: 0.4, blue: 0.4)
        case .none: return .white.opacity(0.3)
        }
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
