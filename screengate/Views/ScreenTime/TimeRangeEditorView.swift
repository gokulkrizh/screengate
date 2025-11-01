import SwiftUI

// MARK: - Time Range Editor View

struct TimeRangeEditorView: View {
    let timeRange: TimeRange?
    let onSave: (TimeRange) -> Void
    let onCancel: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var startHour: Int = 9
    @State private var startMinute: Int = 0
    @State private var endHour: Int = 17
    @State private var endMinute: Int = 0
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                headerView

                // Time Selection
                timeSelectionView

                // Error Message
                if let errorMessage = errorMessage {
                    errorMessageView(message: errorMessage)
                }

                Spacer()
            }
            .padding()
            .navigationTitle(timeRange == nil ? "Add Time Range" : "Edit Time Range")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTimeRange()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValidTimeRange)
                }
            }
            .onAppear {
                loadCurrentTimeRange()
            }
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 8) {
            Text(timeRange == nil ? "Add Time Range" : "Edit Time Range")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Set the start and end time for the restriction period")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom)
    }

    // MARK: - Time Selection View

    private var timeSelectionView: some View {
        VStack(spacing: 24) {
            // Start Time
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "sunrise.fill")
                        .foregroundColor(.orange)
                        .font(.title2)

                    Text("Start Time")
                        .font(.title2)
                        .fontWeight(.semibold)
                }

                HStack(spacing: 16) {
                    // Hour Picker
                    VStack(spacing: 8) {
                        Text("Hour")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        Picker("Hour", selection: $startHour) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text(String(format: "%02d", hour))
                                    .tag(hour)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 80, height: 150)
                        .clipped()
                    }

                    // Minute Picker
                    VStack(spacing: 8) {
                        Text("Minute")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        Picker("Minute", selection: $startMinute) {
                            ForEach(Array(stride(from: 0, to: 60, by: 15)), id: \.self) { minute in
                                Text(String(format: "%02d", minute))
                                    .tag(minute)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 80, height: 150)
                        .clipped()
                    }

                    // Time Display
                    VStack(spacing: 8) {
                        Text("Current")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        Text(formatTime(startHour, startMinute))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                            .frame(width: 80)
                    }
                }
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)

            // End Time
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "sunset.fill")
                        .foregroundColor(.purple)
                        .font(.title2)

                    Text("End Time")
                        .font(.title2)
                        .fontWeight(.semibold)
                }

                HStack(spacing: 16) {
                    // Hour Picker
                    VStack(spacing: 8) {
                        Text("Hour")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        Picker("Hour", selection: $endHour) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text(String(format: "%02d", hour))
                                    .tag(hour)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 80, height: 150)
                        .clipped()
                    }

                    // Minute Picker
                    VStack(spacing: 8) {
                        Text("Minute")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        Picker("Minute", selection: $endMinute) {
                            ForEach(Array(stride(from: 0, to: 60, by: 15)), id: \.self) { minute in
                                Text(String(format: "%02d", minute))
                                    .tag(minute)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 80, height: 150)
                        .clipped()
                    }

                    // Time Display
                    VStack(spacing: 8) {
                        Text("Current")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        Text(formatTime(endHour, endMinute))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                            .frame(width: 80)
                    }
                }
            }
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(12)

            // Duration Display
            durationDisplayView
        }
    }

    // MARK: - Duration Display View

    private var durationDisplayView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                    .font(.title2)

                Text("Duration")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()
            }

            HStack {
                VStack(spacing: 4) {
                    Text(durationText)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)

                    Text("Total restriction time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Duration visualization
                VStack(spacing: 4) {
                    ProgressView(value: Double(durationInMinutes), total: 1440)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .frame(width: 120)

                    Text("\(durationInMinutes) minutes")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
    }

    // MARK: - Error Message View

    private func errorMessageView(message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
                .font(.title3)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.red)

            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }

    // MARK: - Helper Properties

    private var startTotalMinutes: Int {
        return startHour * 60 + startMinute
    }

    private var endTotalMinutes: Int {
        return endHour * 60 + endMinute
    }

    private var durationInMinutes: Int {
        if endTotalMinutes > startTotalMinutes {
            return endTotalMinutes - startTotalMinutes
        } else {
            // Crosses midnight
            return (1440 - startTotalMinutes) + endTotalMinutes
        }
    }

    private var durationText: String {
        let hours = durationInMinutes / 60
        let minutes = durationInMinutes % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    private var isValidTimeRange: Bool {
        // Ensure we have a valid time range (at least 15 minutes)
        return durationInMinutes >= 15 && durationInMinutes <= 1440
    }

    // MARK: - Helper Methods

    private func loadCurrentTimeRange() {
        if let timeRange = timeRange {
            let calendar = Calendar.current
            startHour = calendar.component(.hour, from: timeRange.startTime)
            startMinute = calendar.component(.minute, from: timeRange.startTime)
            endHour = calendar.component(.hour, from: timeRange.endTime)
            endMinute = calendar.component(.minute, from: timeRange.endTime)
        }
    }

    private func saveTimeRange() {
        let calendar = Calendar.current
        let now = Date()

        let startTime = calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: now) ?? now
        let endTime = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: now) ?? now

        let newTimeRange = TimeRange(
            startTime: startTime,
            endTime: endTime,
            name: "\(formatTime(startHour, startMinute)) - \(formatTime(endHour, endMinute))"
        )

        onSave(newTimeRange)
        dismiss()
    }

    private func formatTime(_ hour: Int, _ minute: Int) -> String {
        return String(format: "%02d:%02d", hour, minute)
    }
}

// MARK: - Quick Time Selection

extension TimeRangeEditorView {
    private var quickTimeSelections: some View {
        VStack(spacing: 12) {
            Text("Quick Selection")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickTimeButton(
                    title: "Morning",
                    subtitle: "6AM - 12PM",
                    startTime: 6*60,
                    endTime: 12*60
                ) {
                    setQuickTime(startHour: 6, startMinute: 0, endHour: 12, endMinute: 0)
                }

                QuickTimeButton(
                    title: "Afternoon",
                    subtitle: "12PM - 6PM",
                    startTime: 12*60,
                    endTime: 18*60
                ) {
                    setQuickTime(startHour: 12, startMinute: 0, endHour: 18, endMinute: 0)
                }

                QuickTimeButton(
                    title: "Evening",
                    subtitle: "6PM - 10PM",
                    startTime: 18*60,
                    endTime: 22*60
                ) {
                    setQuickTime(startHour: 18, startMinute: 0, endHour: 22, endMinute: 0)
                }

                QuickTimeButton(
                    title: "Night",
                    subtitle: "10PM - 6AM",
                    startTime: 22*60,
                    endTime: 6*60
                ) {
                    setQuickTime(startHour: 22, startMinute: 0, endHour: 6, endMinute: 0)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }

    private func setQuickTime(startHour: Int, startMinute: Int, endHour: Int, endMinute: Int) {
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
    }
}

// MARK: - Quick Time Button

struct QuickTimeButton: View {
    let title: String
    let subtitle: String
    let startTime: Int
    let endTime: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    TimeRangeEditorView(
        timeRange: nil,
        onSave: { _ in },
        onCancel: { }
    )
}