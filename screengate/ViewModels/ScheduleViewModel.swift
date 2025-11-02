import Foundation
import SwiftUI
import Combine
import DeviceActivity

// MARK: - Schedule ViewModel

@MainActor
class ScheduleViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var schedules: [RestrictionSchedule] = []
    @Published var selectedSchedule: RestrictionSchedule?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isDeviceMonitoringActive: Bool = false
    @Published var activeSchedules: [RestrictionSchedule] = []

    // MARK: - Private Properties
    private let scheduleManager = ScheduleManager()
    private let screenTimeService = ScreenTimeService.shared
    private var cancellables = Set<AnyCancellable>()
    private var scheduleTimer: Timer?

    // MARK: - Computed Properties
    var hasSchedules: Bool {
        !schedules.isEmpty
    }

    var activeScheduleCount: Int {
        schedules.filter { $0.isActiveNow }.count
    }

    var enabledScheduleCount: Int {
        schedules.filter { $0.isEnabled }.count
    }

    var todayActiveSchedules: [RestrictionSchedule] {
        schedules.filter { $0.isActiveToday }
    }

    var nextActiveSchedule: RestrictionSchedule? {
        schedules
            .filter { $0.isEnabled && $0.nextStartTime != nil }
            .sorted { $0.nextStartTime! < $1.nextStartTime! }
            .first
    }

    // MARK: - Initialization
    init() {
        loadSchedules()
        checkDeviceMonitoringStatus()
        setupTimerForScheduleUpdates()
    }

    // MARK: - Schedule Management

    /// Add a new schedule
    func addSchedule(_ schedule: RestrictionSchedule) {
        isLoading = true
        errorMessage = nil

        scheduleManager.addSchedule(schedule)
        loadSchedules()

        // Apply schedule if enabled
        if schedule.isEnabled {
            applySchedule(schedule)
        }

        isLoading = false
        print("📅 Added schedule: \(schedule.name)")
    }

    /// Update an existing schedule
    func updateSchedule(_ schedule: RestrictionSchedule) {
        isLoading = true

        scheduleManager.updateSchedule(schedule)
        loadSchedules()

        // Re-apply if schedule is enabled
        if schedule.isEnabled {
            removeDeviceActivityMonitoring()
            applyAllEnabledSchedules()
        }

        isLoading = false
        print("🔄 Updated schedule: \(schedule.name)")
    }

    /// Remove a schedule
    func removeSchedule(withId id: String) {
        let scheduleName = schedules.first(where: { $0.id == id })?.name ?? "Unknown"

        scheduleManager.removeSchedule(withId: id)
        loadSchedules()

        // Re-apply remaining schedules
        removeDeviceActivityMonitoring()
        applyAllEnabledSchedules()

        print("🗑️ Removed schedule: \(scheduleName)")
    }

    /// Toggle schedule enabled status
    func toggleScheduleEnabled(_ schedule: RestrictionSchedule) {
        var updatedSchedule = schedule
        updatedSchedule.toggleEnabled()
        updateSchedule(updatedSchedule)

        if updatedSchedule.isEnabled {
            print("✅ Enabled schedule: \(schedule.name)")
        } else {
            print("⏸️ Disabled schedule: \(schedule.name)")
        }
    }

    // MARK: - Quick Schedule Creation

    /// Create work hours schedule
    func createWorkSchedule() -> RestrictionSchedule {
        return scheduleManager.createWorkSchedule()
    }

    /// Create evening schedule
    func createEveningSchedule() -> RestrictionSchedule {
        return scheduleManager.createEveningSchedule()
    }

    /// Create night schedule
    func createNightSchedule() -> RestrictionSchedule {
        return scheduleManager.createNightSchedule()
    }

    /// Add all common schedules
    func addCommonSchedules() {
        let workSchedule = createWorkSchedule()
        let eveningSchedule = createEveningSchedule()
        let nightSchedule = createNightSchedule()

        addSchedule(workSchedule)
        addSchedule(eveningSchedule)
        addSchedule(nightSchedule)

        print("📋 Added all common schedules")
    }

    // MARK: - Device Activity Management

    /// Start device activity monitoring for all enabled schedules
    func startDeviceActivityMonitoring() {
        guard !schedules.isEmpty else {
            errorMessage = "No schedules available to monitor"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            // Create combined schedule from all enabled schedules
            if let deviceSchedule = createCombinedDeviceSchedule() {
                try screenTimeService.startDeviceActivityMonitoring(schedule: deviceSchedule)
                isDeviceMonitoringActive = true
                print("📱 Started device activity monitoring")
            }
        } catch {
            errorMessage = "Failed to start device activity monitoring: \(error.localizedDescription)"
            print("❌ Device monitoring failed: \(error)")
        }

        isLoading = false
    }

    /// Stop device activity monitoring
    func stopDeviceActivityMonitoring() {
        isLoading = true

        screenTimeService.stopDeviceActivityMonitoring()
        isDeviceMonitoringActive = false

        isLoading = false
        print("⏹️ Stopped device activity monitoring")
    }

    /// Check device monitoring status
    func checkDeviceMonitoringStatus() {
        // This would check the actual device activity center status
        // For now, we'll use a simple flag
        isDeviceMonitoringActive = UserDefaults.standard.bool(forKey: "DeviceMonitoringActive")
    }

    // MARK: - Schedule Analytics

    /// Get schedule analytics
    func getScheduleAnalytics() -> ScheduleAnalytics {
        return scheduleManager.getScheduleAnalytics()
    }

    /// Get schedule compliance rate
    func getScheduleComplianceRate() -> Double {
        guard enabledScheduleCount > 0 else { return 0.0 }
        return Double(activeScheduleCount) / Double(enabledScheduleCount)
    }

    /// Get today's active time
    func getTodayActiveTime() -> TimeInterval {
        return todayActiveSchedules.reduce(0) { total, schedule in
            total + schedule.totalActiveTimeToday
        }
    }

    /// Get formatted today's active time
    func getFormattedTodayActiveTime() -> String {
        let totalSeconds = Int(getTodayActiveTime())
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    // MARK: - Schedule Templates

    /// Get available schedule templates
    func getScheduleTemplates() -> [ScheduleTemplate] {
        return [
            ScheduleTemplate(
                name: "Work Focus",
                description: "Restrict distractions during work hours",
                icon: "briefcase",
                timeRanges: [TimeRange.workHours, TimeRange.lunch],
                daysOfWeek: Set([2,3,4,5,6]), // Monday-Friday
                scheduleType: .timeBased
            ),
            ScheduleTemplate(
                name: "Evening Wind Down",
                description: "Prepare for restful sleep",
                icon: "moon",
                timeRanges: [TimeRange.evening],
                daysOfWeek: Set([1,2,3,4,5,6,7]),
                scheduleType: .timeBased
            ),
            ScheduleTemplate(
                name: "Night Mode",
                description: "Deep sleep protection",
                icon: "bed.double",
                timeRanges: [TimeRange.night],
                daysOfWeek: Set([1,2,3,4,5,6,7]),
                scheduleType: .timeBased
            ),
            ScheduleTemplate(
                name: "Weekend Balance",
                description: "Moderate weekend usage",
                icon: "calendar",
                timeRanges: [TimeRange.morning, TimeRange.evening],
                daysOfWeek: Set([1,7]), // Saturday-Sunday
                scheduleType: .timeBased
            )
        ]
    }

    /// Create schedule from template
    func createScheduleFromTemplate(_ template: ScheduleTemplate) -> RestrictionSchedule {
        return RestrictionSchedule(
            name: template.name,
            scheduleType: template.scheduleType,
            timeRanges: template.timeRanges,
            daysOfWeek: template.daysOfWeek,
            repeatPattern: template.repeatPattern
        )
    }

    // MARK: - Private Methods

    private func loadSchedules() {
        schedules = scheduleManager.schedules
        updateActiveSchedules()
        print("📂 Loaded \(schedules.count) schedules")
    }

    private func updateActiveSchedules() {
        activeSchedules = schedules.filter { $0.isActiveNow }
    }

    private func setupTimerForScheduleUpdates() {
        // PERFORMANCE FIX: Optimized timer from 60s to 300s (5 minutes)
        // Also added timer reference for proper cleanup
        scheduleTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateActiveSchedules()
            }
        }

        // Also update when app becomes active (more efficient than continuous polling)
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.updateActiveSchedules()
                    self?.checkDeviceMonitoringStatus()
                }
            }
            .store(in: &cancellables)
    }

    private func applySchedule(_ schedule: RestrictionSchedule) {
        guard let deviceSchedule = schedule.toDeviceActivitySchedule() else {
            print("⚠️ Failed to create device schedule for \(schedule.name)")
            return
        }

        do {
            try screenTimeService.startDeviceActivityMonitoring(schedule: deviceSchedule)
            print("📅 Applied schedule: \(schedule.name)")
        } catch {
            print("❌ Failed to apply schedule \(schedule.name): \(error)")
        }
    }

    private func applyAllEnabledSchedules() {
        let enabledSchedules = schedules.filter { $0.isEnabled }
        guard !enabledSchedules.isEmpty else { return }

        if let combinedSchedule = createCombinedDeviceSchedule() {
            do {
                try screenTimeService.startDeviceActivityMonitoring(schedule: combinedSchedule)
                print("📅 Applied \(enabledSchedules.count) enabled schedules")
            } catch {
                print("❌ Failed to apply schedules: \(error)")
            }
        }
    }

    private func removeDeviceActivityMonitoring() {
        screenTimeService.stopDeviceActivityMonitoring()
        UserDefaults.standard.set(false, forKey: "DeviceMonitoringActive")
    }

    private func createCombinedDeviceSchedule() -> DeviceActivitySchedule? {
        let enabledSchedules = schedules.filter { $0.isEnabled }
        guard !enabledSchedules.isEmpty else { return nil }

        // Find the earliest start time and latest end time
        let calendar = Calendar.current
        let now = Date()

        let earliestStart = enabledSchedules
            .compactMap { $0.startDate }
            .min() ?? now

        let latestEnd = enabledSchedules
            .compactMap { $0.endDate }
            .max() ?? now.addingTimeInterval(365 * 24 * 60 * 60) // 1 year from now

        let startComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: earliestStart)
        let endComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: latestEnd)

        return DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: true
        )
    }

    // MARK: - Schedule Testing

    /// Test a schedule by temporarily applying it
    func testSchedule(_ schedule: RestrictionSchedule, duration: TimeInterval = 300) { // 5 minutes default
        let testSchedule = RestrictionSchedule(
            name: "Test: \(schedule.name)",
            scheduleType: schedule.scheduleType,
            timeRanges: schedule.timeRanges,
            daysOfWeek: Set([1,2,3,4,5,6,7]), // All days
            startDate: Date(),
            endDate: Date().addingTimeInterval(duration)
        )

        applySchedule(testSchedule)
        print("🧪 Testing schedule: \(schedule.name) for \(Int(duration))s")

        // Auto-remove after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.removeSchedule(withId: testSchedule.id)
        }
    }

    // MARK: - Deinit
    deinit {
        scheduleTimer?.invalidate()
        scheduleTimer = nil
        cancellables.removeAll()
    }
}

// MARK: - Schedule Template Model

struct ScheduleTemplate: Identifiable {
    let id: String = UUID().uuidString
    let name: String
    let description: String
    let icon: String
    let timeRanges: [TimeRange]
    let daysOfWeek: Set<Int>
    let scheduleType: ScheduleType
    let repeatPattern: RepeatPattern

    init(name: String, description: String, icon: String, timeRanges: [TimeRange],
         daysOfWeek: Set<Int>, scheduleType: ScheduleType, repeatPattern: RepeatPattern = .custom) {
        self.name = name
        self.description = description
        self.icon = icon
        self.timeRanges = timeRanges
        self.daysOfWeek = daysOfWeek
        self.scheduleType = scheduleType
        self.repeatPattern = repeatPattern
    }
}

// MARK: - Schedule Status Extensions

extension RestrictionSchedule {
    var statusColor: Color {
        if !isEnabled {
            return .gray
        } else if isActiveNow {
            return .green
        } else if isActiveToday {
            return .orange
        } else {
            return .blue
        }
    }

    var statusText: String {
        if !isEnabled {
            return "Disabled"
        } else if isActiveNow {
            return "Active"
        } else if isActiveToday {
            return "Scheduled Today"
        } else {
            return "Scheduled"
        }
    }

    var nextEventText: String? {
        guard isEnabled else { return nil }

        if let nextStart = nextStartTime {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Next: \(formatter.string(from: nextStart))"
        }

        return nil
    }
}

// MARK: - Color Extension

import SwiftUI

extension Color {
    static let scheduleGreen = Color.green
    static let scheduleOrange = Color.orange
    static let scheduleBlue = Color.blue
    static let scheduleGray = Color.gray
}