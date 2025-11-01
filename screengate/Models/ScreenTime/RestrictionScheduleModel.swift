import Foundation
import Combine
import DeviceActivity

// MARK: - Restriction Schedule Model

struct RestrictionSchedule: Codable, Identifiable {
    let id: String
    var name: String
    var scheduleType: ScheduleType
    var isEnabled: Bool
    var timeRanges: [TimeRange]
    var daysOfWeek: Set<Int> // 1 = Sunday, 7 = Saturday
    var startDate: Date?
    var endDate: Date?
    var exceptions: [ScheduleException]
    var repeatPattern: RepeatPattern
    var timezone: String
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization
    init(
        id: String = UUID().uuidString,
        name: String,
        scheduleType: ScheduleType,
        isEnabled: Bool = true,
        timeRanges: [TimeRange] = [],
        daysOfWeek: Set<Int> = Set([1,2,3,4,5,6,7]), // All days by default
        startDate: Date? = nil,
        endDate: Date? = nil,
        exceptions: [ScheduleException] = [],
        repeatPattern: RepeatPattern = .daily,
        timezone: String = TimeZone.current.identifier,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.scheduleType = scheduleType
        self.isEnabled = isEnabled
        self.timeRanges = timeRanges
        self.daysOfWeek = daysOfWeek
        self.startDate = startDate
        self.endDate = endDate
        self.exceptions = exceptions
        self.repeatPattern = repeatPattern
        self.timezone = timezone
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Computed Properties
    var isActiveNow: Bool {
        guard isEnabled else { return false }
        return isActiveAt(Date())
    }

    var isActiveToday: Bool {
        let today = Calendar.current.component(.weekday, from: Date())
        return daysOfWeek.contains(today) && isInDateRange(Date())
    }

    var nextStartTime: Date? {
        let now = Date()
        let calendar = Calendar.current

        // Check if there's an active time range today
        if isActiveToday {
            for timeRange in timeRanges.sorted(by: { $0.startTime < $1.startTime }) {
                let startComponents = calendar.dateComponents([.hour, .minute], from: timeRange.startTime)
                if let todayStart = calendar.nextDate(after: now, matching: startComponents, matchingPolicy: .nextTime) {
                    if todayStart > now {
                        return todayStart
                    }
                }
            }
        }

        // Find next active day
        return findNextActiveDay(from: now)
    }

    var nextEndTime: Date? {
        guard isActiveNow else { return nil }

        let now = Date()
        let calendar = Calendar.current

        for timeRange in timeRanges.sorted(by: { $0.endTime < $1.endTime }) {
            let endComponents = calendar.dateComponents([.hour, .minute], from: timeRange.endTime)
            if let todayEnd = calendar.nextDate(after: now, matching: endComponents, matchingPolicy: .nextTime) {
                if todayEnd > now {
                    return todayEnd
                }
            }
        }

        return nil
    }

    var totalActiveTimeToday: TimeInterval {
        let calendar = Calendar.current
        var totalDuration: TimeInterval = 0

        for timeRange in timeRanges {
            let startComponents = calendar.dateComponents([.hour, .minute], from: timeRange.startTime)
            let endComponents = calendar.dateComponents([.hour, .minute], from: timeRange.endTime)

            if let startDate = calendar.date(bySettingHour: startComponents.hour ?? 0, minute: startComponents.minute ?? 0, second: 0, of: Date()),
               let endDate = calendar.date(bySettingHour: endComponents.hour ?? 0, minute: endComponents.minute ?? 0, second: 0, of: Date()) {
                totalDuration += endDate.timeIntervalSince(startDate)
            }
        }

        return totalDuration
    }

    // MARK: - Date Checking Methods
    func isActiveAt(_ date: Date) -> Bool {
        guard isInDateRange(date) && isScheduledDay(date) else { return false }

        // Check for exceptions
        if hasException(for: date) {
            return false
        }

        // Check time ranges
        return isInTimeRange(date)
    }

    private func isInDateRange(_ date: Date) -> Bool {
        if let startDate = startDate, date < startDate {
            return false
        }
        if let endDate = endDate, date > endDate {
            return false
        }
        return true
    }

    private func isScheduledDay(_ date: Date) -> Bool {
        let dayOfWeek = Calendar.current.component(.weekday, from: date)
        return daysOfWeek.contains(dayOfWeek)
    }

    private func hasException(for date: Date) -> Bool {
        let calendar = Calendar.current
        return exceptions.contains { exception in
            calendar.isDate(date, inSameDayAs: exception.date)
        }
    }

    private func isInTimeRange(_ date: Date) -> Bool {
        let time = Calendar.current.dateComponents([.hour, .minute], from: date)
        let currentMinutes = (time.hour ?? 0) * 60 + (time.minute ?? 0)

        for timeRange in timeRanges {
            let startMinutes = timeRange.startMinutes
            let endMinutes = timeRange.endMinutes

            if startMinutes <= endMinutes {
                // Normal range (e.g., 9:00 AM - 5:00 PM)
                if currentMinutes >= startMinutes && currentMinutes <= endMinutes {
                    return true
                }
            } else {
                // Overnight range (e.g., 10:00 PM - 6:00 AM)
                if currentMinutes >= startMinutes || currentMinutes <= endMinutes {
                    return true
                }
            }
        }

        return false
    }

    private func findNextActiveDay(from date: Date) -> Date? {
        let calendar = Calendar.current
        var searchDate = calendar.date(byAdding: .day, value: 1, to: date) ?? date

        for _ in 1..<8 { // Search up to 7 days ahead
            let dayOfWeek = calendar.component(.weekday, from: searchDate)
            if daysOfWeek.contains(dayOfWeek) && isInDateRange(searchDate) {
                // Find the first time range for this day
                if let firstTimeRange = timeRanges.sorted(by: { $0.startTime < $1.startTime }).first {
                    let components = calendar.dateComponents([.hour, .minute], from: firstTimeRange.startTime)
                    return calendar.nextDate(after: searchDate, matching: components, matchingPolicy: .nextTime)
                }
            }
            searchDate = calendar.date(byAdding: .day, value: 1, to: searchDate) ?? searchDate
        }

        return nil
    }

    // MARK: - Device Activity Conversion
    func toDeviceActivitySchedule() -> DeviceActivitySchedule? {
        let calendar = Calendar.current

        // Note: DeviceActivitySchedule API may have changed in current iOS version
        // This is a placeholder implementation based on available APIs

        // Convert schedule dates to DateComponents as required by current API
        let startComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: startDate ?? Date())

        let scheduleEnd = endDate ?? Date().addingTimeInterval(60 * 60 * 24 * 365) // Default to 1 year from now
        let endComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: scheduleEnd)

        // Create basic schedule with current API
        // Note: Weekday and interval support may have changed
        let schedule = DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: repeatPattern != .custom
        )

        print("Created DeviceActivitySchedule for \(name) - API may need adjustment for full functionality")
        return schedule
    }

    // MARK: - Schedule Management
    mutating func addTimeRange(_ timeRange: TimeRange) {
        timeRanges.append(timeRange)
        updatedTimeRanges()
    }

    mutating func removeTimeRange(withId id: String) {
        timeRanges.removeAll { $0.id == id }
        updatedTimeRanges()
    }

    mutating func updateTimeRange(_ timeRange: TimeRange) {
        if let index = timeRanges.firstIndex(where: { $0.id == timeRange.id }) {
            timeRanges[index] = timeRange
        }
        updatedTimeRanges()
    }

    mutating func addException(_ exception: ScheduleException) {
        exceptions.append(exception)
        updatedAt = Date()
    }

    mutating func removeException(withId id: String) {
        exceptions.removeAll { $0.id == id }
        updatedAt = Date()
    }

    mutating func updatedTimeRanges() {
        timeRanges.sort { $0.startMinutes < $1.startMinutes }
        updatedAt = Date()
    }

    mutating func toggleEnabled() {
        isEnabled.toggle()
        updatedAt = Date()
    }
}

// MARK: - Schedule Type

enum ScheduleType: String, Codable, CaseIterable {
    case always = "always"
    case timeBased = "timeBased"
    case conditional = "conditional"
    case adaptive = "adaptive"

    var displayName: String {
        switch self {
        case .always: return "Always Active"
        case .timeBased: return "Time Based"
        case .conditional: return "Conditional"
        case .adaptive: return "Adaptive"
        }
    }

    var description: String {
        switch self {
        case .always: return "Restriction is always active when enabled"
        case .timeBased: return "Active during specific time ranges"
        case .conditional: return "Active based on conditions"
        case .adaptive: return "Adapts based on usage patterns"
        }
    }

    var iconName: String {
        switch self {
        case .always: return "infinity"
        case .timeBased: return "clock"
        case .conditional: return "gearshape.2"
        case .adaptive: return "brain.head.profile"
        }
    }
}

// MARK: - Time Range

struct TimeRange: Codable, Identifiable {
    let id: String
    var startTime: Date
    var endTime: Date
    var name: String

    // MARK: - Initialization
    init(
        id: String = UUID().uuidString,
        startTime: Date,
        endTime: Date,
        name: String = ""
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.name = name
    }

    // MARK: - Computed Properties
    var startMinutes: Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: startTime)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }

    var endMinutes: Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: endTime)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }

    var duration: TimeInterval {
        return endTime.timeIntervalSince(startTime)
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        return "\(minutes) minutes"
    }

    var isOvernight: Bool {
        return startMinutes > endMinutes
    }

    // MARK: - Helper Methods
    private func formatTimeRange(_ start: Date, _ end: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }

    // MARK: - Convenience Initializers
    static func from(_ startHour: Int, _ startMinute: Int, to endHour: Int, _ endMinute: Int) -> TimeRange {
        let calendar = Calendar.current
        let now = Date()

        let startTime = calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: now) ?? now
        let endTime = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: now) ?? now

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let name = "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"

        return TimeRange(
            startTime: startTime,
            endTime: endTime,
            name: name
        )
    }

    // Common time ranges
    static let workHours = TimeRange(
        startTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(),
        endTime: Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date()) ?? Date(),
        name: "Work Hours"
    )
    static let evening = TimeRange(
        startTime: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date(),
        endTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date(),
        name: "Evening"
    )
    static let night = TimeRange(
        startTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date(),
        endTime: Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: Date()) ?? Date(),
        name: "Night"
    )
    static let morning = TimeRange(
        startTime: Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: Date()) ?? Date(),
        endTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(),
        name: "Morning"
    )
    static let lunch = TimeRange(
        startTime: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date(),
        endTime: Calendar.current.date(bySettingHour: 13, minute: 0, second: 0, of: Date()) ?? Date(),
        name: "Lunch Time"
    )
}

// MARK: - Schedule Exception

struct ScheduleException: Codable, Identifiable {
    let id: String
    var date: Date
    var reason: String
    var type: ExceptionType
    var isRecurring: Bool
    var recurrencePattern: RecurrencePattern?

    // MARK: - Initialization
    init(
        id: String = UUID().uuidString,
        date: Date,
        reason: String = "",
        type: ExceptionType = .skip,
        isRecurring: Bool = false,
        recurrencePattern: RecurrencePattern? = nil
    ) {
        self.id = id
        self.date = date
        self.reason = reason
        self.type = type
        self.isRecurring = isRecurring
        self.recurrencePattern = recurrencePattern
    }
}

enum ExceptionType: String, Codable, CaseIterable {
    case skip = "skip"
    case modify = "modify"
    case extend = "extend"

    var displayName: String {
        switch self {
        case .skip: return "Skip Restriction"
        case .modify: return "Modify Restriction"
        case .extend: return "Extend Restriction"
        }
    }
}

enum RecurrencePattern: String, Codable, CaseIterable {
    case never = "never"
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"

    var displayName: String {
        switch self {
        case .never: return "Never"
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
}

// MARK: - Repeat Pattern

enum RepeatPattern: String, Codable, CaseIterable {
    case daily = "daily"
    case weekdays = "weekdays"
    case weekends = "weekends"
    case weekly = "weekly"
    case monthly = "monthly"
    case custom = "custom"

    var displayName: String {
        switch self {
        case .daily: return "Daily"
        case .weekdays: return "Weekdays"
        case .weekends: return "Weekends"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .custom: return "Custom"
        }
    }

    var defaultDays: Set<Int> {
        switch self {
        case .daily: return Set([1,2,3,4,5,6,7])
        case .weekdays: return Set([2,3,4,5,6]) // Mon-Fri
        case .weekends: return Set([1,7]) // Sat-Sun
        case .weekly, .monthly, .custom: return Set([])
        }
    }
}

// MARK: - Schedule Manager

class ScheduleManager: ObservableObject {
    @Published var schedules: [RestrictionSchedule] = []

    private let userDefaults = UserDefaults.standard
    private let schedulesKey = "RestrictionSchedules"

    init() {
        loadSchedules()
        createDefaultSchedulesIfNeeded()
    }

    // MARK: - Schedule Management
    func addSchedule(_ schedule: RestrictionSchedule) {
        if let index = schedules.firstIndex(where: { $0.id == schedule.id }) {
            schedules[index] = schedule
        } else {
            schedules.append(schedule)
        }
        saveSchedules()
    }

    func removeSchedule(withId id: String) {
        schedules.removeAll { $0.id == id }
        saveSchedules()
    }

    func updateSchedule(_ schedule: RestrictionSchedule) {
        addSchedule(schedule)
    }

    func getSchedule(withId id: String) -> RestrictionSchedule? {
        return schedules.first { $0.id == id }
    }

    func getActiveSchedules() -> [RestrictionSchedule] {
        return schedules.filter { $0.isActiveNow }
    }

    func getSchedulesActiveAt(_ date: Date) -> [RestrictionSchedule] {
        return schedules.filter { $0.isActiveAt(date) }
    }

    // MARK: - Quick Schedule Creation
    func createWorkSchedule() -> RestrictionSchedule {
        return RestrictionSchedule(
            name: "Work Hours",
            scheduleType: .timeBased,
            timeRanges: [.workHours, .lunch],
            daysOfWeek: Set([2,3,4,5,6]) // Monday-Friday
        )
    }

    func createEveningSchedule() -> RestrictionSchedule {
        return RestrictionSchedule(
            name: "Evening Wind Down",
            scheduleType: .timeBased,
            timeRanges: [.evening],
            daysOfWeek: Set([1,2,3,4,5,6,7])
        )
    }

    func createNightSchedule() -> RestrictionSchedule {
        return RestrictionSchedule(
            name: "Night Time",
            scheduleType: .timeBased,
            timeRanges: [.night],
            daysOfWeek: Set([1,2,3,4,5,6,7])
        )
    }

    // MARK: - Default Schedules
    private func createDefaultSchedulesIfNeeded() {
        if schedules.isEmpty {
            let defaultSchedules = [
                createWorkSchedule(),
                createEveningSchedule(),
                createNightSchedule()
            ]
            schedules = defaultSchedules
            saveSchedules()
        }
    }

    // MARK: - Data Persistence
    private func loadSchedules() {
        if let data = userDefaults.data(forKey: schedulesKey),
           let loadedSchedules = try? JSONDecoder().decode([RestrictionSchedule].self, from: data) {
            schedules = loadedSchedules
        }
    }

    private func saveSchedules() {
        if let data = try? JSONEncoder().encode(schedules) {
            userDefaults.set(data, forKey: schedulesKey)
        }
    }

    // MARK: - Analytics
    func getScheduleAnalytics() -> ScheduleAnalytics {
        let totalSchedules = schedules.count
        let activeSchedules = schedules.filter { $0.isActiveNow }.count
        let enabledSchedules = schedules.filter { $0.isEnabled }.count
        let scheduleTypes = Dictionary(grouping: schedules) { $0.scheduleType }

        return ScheduleAnalytics(
            totalSchedules: totalSchedules,
            activeSchedules: activeSchedules,
            enabledSchedules: enabledSchedules,
            scheduleTypeBreakdown: scheduleTypes.mapValues { $0.count }
        )
    }
}

// MARK: - Analytics

struct ScheduleAnalytics: Codable {
    let totalSchedules: Int
    let activeSchedules: Int
    let enabledSchedules: Int
    let scheduleTypeBreakdown: [ScheduleType: Int]

    var mostCommonType: ScheduleType? {
        return scheduleTypeBreakdown.max { $0.value < $1.value }?.key
    }

    var activationRate: Double {
        guard enabledSchedules > 0 else { return 0 }
        return Double(activeSchedules) / Double(enabledSchedules)
    }
}