import SwiftUI
import FamilyControls

// MARK: - Schedule Configuration View

struct ScheduleConfigurationView: View {
    let selectedAppIdentifier: String
    let currentScheduleId: String?
    let onScheduleSelected: (String?) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var scheduleName: String = ""
    @State private var isScheduleEnabled: Bool = true
    @State private var selectedWeekdays: Set<Int> = Set(1...7)
    @State private var timeRanges: [TimeRange] = []
    @State private var restrictionDuration: TimeInterval = 3600 // 1 hour
    @State private var showingTimeRangeEditor = false
    @State private var editingTimeRangeIndex: Int?

    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerView

                    // Enable/Disable Schedule
                    scheduleToggleView

                    if isScheduleEnabled {
                        // Schedule Name
                        scheduleNameView

                        // Quick Templates
                        quickTemplatesView

                        // Weekday Selection
                        weekdaySelectionView

                        // Time Ranges
                        timeRangesView

                        // Duration Setting
                        durationView
                    } else {
                        // Always Active Option
                        alwaysActiveView
                    }

                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveSchedule()
                    }
                    .fontWeight(.semibold)
                    .disabled(isScheduleEnabled && !isValidSchedule)
                }
            }
            .sheet(isPresented: $showingTimeRangeEditor) {
                TimeRangeEditorView(
                    timeRange: editingTimeRangeIndex != nil ? timeRanges[editingTimeRangeIndex!] : nil,
                    onSave: { timeRange in
                        if let index = editingTimeRangeIndex {
                            timeRanges[index] = timeRange
                        } else {
                            timeRanges.append(timeRange)
                        }
                        editingTimeRangeIndex = nil
                    },
                    onCancel: {
                        editingTimeRangeIndex = nil
                    }
                )
            }
            .onAppear {
                loadCurrentSchedule()
            }
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Configure Schedule")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Set when this restriction should be active")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom)
    }

    // MARK: - Schedule Toggle View

    private var scheduleToggleView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Enable Schedule")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Toggle("", isOn: $isScheduleEnabled)
                    .labelsHidden()
            }

            if !isScheduleEnabled {
                Text("The restriction will be active at all times")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Schedule Name View

    private var scheduleNameView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Schedule Name")
                .font(.headline)
                .fontWeight(.semibold)

            TextField("Enter schedule name", text: $scheduleName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }

    // MARK: - Quick Templates View

    private var quickTemplatesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Templates")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickTimeButton(
                    title: "Work Hours",
                    subtitle: "9AM - 5PM",
                    startTime: 9*60,
                    endTime: 17*60
                ) {
                    applyWorkTemplate()
                }

                QuickTimeButton(
                    title: "After Hours",
                    subtitle: "6PM - 11PM",
                    startTime: 18*60,
                    endTime: 23*60
                ) {
                    applyEveningTemplate()
                }

                QuickTimeButton(
                    title: "Weekend",
                    subtitle: "All Day",
                    startTime: 9*60,
                    endTime: 22*60
                ) {
                    applyWeekendTemplate()
                }

                QuickTimeButton(
                    title: "Morning Focus",
                    subtitle: "6AM - 10AM",
                    startTime: 6*60,
                    endTime: 10*60
                ) {
                    applyMorningTemplate()
                }
            }
        }
    }

    // MARK: - Weekday Selection View

    private var weekdaySelectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Active Days")
                .font(.headline)
                .fontWeight(.semibold)

            HStack(spacing: 8) {
                ForEach(weekdayData, id: \.day) { weekday in
                    WeekdayChip(
                        weekday: weekday,
                        isSelected: selectedWeekdays.contains(weekday.day)
                    ) {
                        if selectedWeekdays.contains(weekday.day) {
                            selectedWeekdays.remove(weekday.day)
                        } else {
                            selectedWeekdays.insert(weekday.day)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Time Ranges View

    private var timeRangesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Time Ranges")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Button(action: {
                    editingTimeRangeIndex = nil
                    showingTimeRangeEditor = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.caption)

                        Text("Add Time")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.blue)
                }
            }

            if timeRanges.isEmpty {
                Text("No time ranges configured")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(Array(timeRanges.enumerated()), id: \.offset) { index, timeRange in
                        TimeRangeRow(
                            timeRange: timeRange,
                            onEdit: {
                                editingTimeRangeIndex = index
                                showingTimeRangeEditor = true
                            },
                            onDelete: {
                                timeRanges.remove(at: index)
                            }
                        )
                    }
                }
            }
        }
    }

    // MARK: - Duration View

    private var durationView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Restriction Duration")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 16) {
                // Duration Display
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)

                    Text(formatDuration(restrictionDuration))
                        .font(.title2)
                        .fontWeight(.semibold)

                    Spacer()
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)

                // Duration Slider
                VStack(alignment: .leading, spacing: 8) {
                    Text("Duration: \(formatDuration(restrictionDuration))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Slider(
                        value: $restrictionDuration,
                        in: 300...14400, // 5 minutes to 4 hours
                        step: 300
                    ) {
                        Text("Restriction Duration")
                    }
                }
            }
        }
    }

    // MARK: - Always Active View

    private var alwaysActiveView: some View {
        VStack(spacing: 12) {
            Image(systemName: "infinity")
                .font(.system(size: 32))
                .foregroundColor(.blue)

            Text("Always Active")
                .font(.title2)
                .fontWeight(.semibold)

            Text("The restriction will be active at all times without any schedule limitations")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Helper Properties

    private var weekdayData: [(day: Int, name: String)] {
        [
            (1, "Sun"),
            (2, "Mon"),
            (3, "Tue"),
            (4, "Wed"),
            (5, "Thu"),
            (6, "Fri"),
            (7, "Sat")
        ]
    }

    private var isValidSchedule: Bool {
        guard isScheduleEnabled else { return true }
        return !scheduleName.isEmpty && !selectedWeekdays.isEmpty && !timeRanges.isEmpty
    }

    // MARK: - Helper Methods

    private func loadCurrentSchedule() {
        // For now, we'll just load defaults since we're working with schedule IDs
        scheduleName = "Custom Schedule"
        isScheduleEnabled = currentScheduleId != nil
        selectedWeekdays = Set(1...7)
        restrictionDuration = 3600
    }

    private func applyWorkTemplate() {
        scheduleName = "Work Hours"
        selectedWeekdays = Set([2,3,4,5,6]) // Monday-Friday
        restrictionDuration = 8 * 3600 // 8 hours
        timeRanges = [TimeRange.from(9, 0, to: 17, 0)]
    }

    private func applyEveningTemplate() {
        scheduleName = "After Hours"
        selectedWeekdays = Set([1,2,3,4,5,6,7])
        restrictionDuration = 5 * 3600 // 5 hours
        timeRanges = [TimeRange.from(18, 0, to: 23, 0)]
    }

    private func applyWeekendTemplate() {
        scheduleName = "Weekend"
        selectedWeekdays = Set([1,7]) // Saturday-Sunday
        restrictionDuration = 13 * 3600 // 13 hours
        timeRanges = [TimeRange.from(9, 0, to: 22, 0)]
    }

    private func applyMorningTemplate() {
        scheduleName = "Morning Focus"
        selectedWeekdays = Set([1,2,3,4,5])
        restrictionDuration = 4 * 3600 // 4 hours
        timeRanges = [TimeRange.from(6, 0, to: 10, 0)]
    }

    private func saveSchedule() {
        let scheduleId: String?

        if isScheduleEnabled && isValidSchedule {
            // Create a simple schedule ID for now
            // In a real implementation, this would create a full RestrictionSchedule
            scheduleId = UUID().uuidString
        } else {
            scheduleId = nil
        }

        onScheduleSelected(scheduleId)
        dismiss()
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    private func formatTimeRange(_ timeRange: TimeRange) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: timeRange.startTime)) - \(formatter.string(from: timeRange.endTime))"
    }
}

// MARK: - Supporting Views


struct WeekdayChip: View {
    let weekday: (day: Int, name: String)
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(weekday.name)
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 32, height: 32)
                .background(isSelected ? Color.blue : Color(UIColor.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TimeRangeRow: View {
    let timeRange: TimeRange
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(formatTimeRange(timeRange))
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("Daily restriction period")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                        .font(.caption)
                }

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
    }

    private func formatTimeRange(_ timeRange: TimeRange) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: timeRange.startTime)) - \(formatter.string(from: timeRange.endTime))"
    }
}


#Preview {
    ScheduleConfigurationView(
        selectedAppIdentifier: "com.example.app",
        currentScheduleId: nil,
        onScheduleSelected: { _ in }
    )
}