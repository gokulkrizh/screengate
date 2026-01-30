import SwiftUI
import DeviceActivity
import FamilyControls
import ManagedSettings

// MARK: - Monitor Configuration Models

struct MonitorConfiguration: Identifiable {
    let id = UUID()
    let name: String
    let activityName: DeviceActivityName
    let scheduleType: ScheduleType
    let events: [EventConfiguration]
    let selectedApps: FamilyActivitySelection
}

struct EventConfiguration: Identifiable {
    let id = UUID()
    let name: String
    let eventName: DeviceActivityEvent.Name
    let thresholdMinutes: Int
    let action: EventAction
}

enum ScheduleType {
    case daily(startHour: Int, startMinute: Int, endHour: Int, endMinute: Int)
    case custom(start: DateComponents, end: DateComponents, repeats: Bool)
    case duration(minutes: Int) // For 30-min sessions
}

enum EventAction {
    case shield
    case notification
    case both
}

// MARK: - Monitor Manager

class MonitorManager: ObservableObject {
    @Published var configurations: [MonitorConfiguration] = []
    @Published var isCreating = false
    @Published var errorMessage: String?
    
    private let center = DeviceActivityCenter()
    private let authCenter = AuthorizationCenter.shared
    
    // MARK: - Authorization
    
    func requestAuthorization() async throws {
        try await authCenter.requestAuthorization(for: .individual)
    }
    
    // MARK: - Create Monitors
    
    func createDailyLimitMonitor(
        startHour: Int = 0,
        startMinute: Int = 0,
        endHour: Int = 23,
        endMinute: Int = 59,
        thresholdMinutes: Int = 120,
        selectedApps: FamilyActivitySelection
    ) throws {
        
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: startHour, minute: startMinute),
            intervalEnd: DateComponents(hour: endHour, minute: endMinute),
            repeats: true
        )
        
        let event = DeviceActivityEvent(
            applications: selectedApps.applicationTokens,
            threshold: DateComponents(minute: thresholdMinutes)
        )
        
        let events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [
            .dailyLimitReached: event
        ]
        
        try center.startMonitoring(
            .dailyLimit,
            during: schedule,
            events: events
        )
        
        // Save configuration for timeline
        let config = MonitorConfiguration(
            name: "Daily Limit",
            activityName: .dailyLimit,
            scheduleType: .daily(
                startHour: startHour,
                startMinute: startMinute,
                endHour: endHour,
                endMinute: endMinute
            ),
            events: [
                EventConfiguration(
                    name: "Daily Limit Reached",
                    eventName: .dailyLimitReached,
                    thresholdMinutes: thresholdMinutes,
                    action: .shield
                )
            ],
            selectedApps: selectedApps
        )
        
        configurations.append(config)
        saveToUserDefaults(selectedApps, forKey: "dailyLimit_apps")
    }
    
    func createThirtyMinuteSession(
        selectedApps: FamilyActivitySelection
    ) throws {
        
        let now = Date()
        let calendar = Calendar.current
        
        let startComponents = calendar.dateComponents(
            [.hour, .minute, .second],
            from: now
        )
        
        let endDate = now.addingTimeInterval(30 * 60)
        let endComponents = calendar.dateComponents(
            [.hour, .minute, .second],
            from: endDate
        )
        
        let schedule = DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: false
        )
        
        // Multiple checkpoints
        let events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [
            .thirtyMinWarning10: DeviceActivityEvent(
                applications: selectedApps.applicationTokens,
                threshold: DateComponents(minute: 10)
            ),
            .thirtyMinWarning20: DeviceActivityEvent(
                applications: selectedApps.applicationTokens,
                threshold: DateComponents(minute: 20)
            ),
            .thirtyMinLimitReached: DeviceActivityEvent(
                applications: selectedApps.applicationTokens,
                threshold: DateComponents(minute: 30)
            )
        ]
        
        try center.startMonitoring(
            .thirtyMinuteLimit,
            during: schedule,
            events: events
        )
        
        let config = MonitorConfiguration(
            name: "30-Minute Session",
            activityName: .thirtyMinuteLimit,
            scheduleType: .duration(minutes: 30),
            events: [
                EventConfiguration(
                    name: "10 Minutes Used",
                    eventName: .thirtyMinWarning10,
                    thresholdMinutes: 10,
                    action: .notification
                ),
                EventConfiguration(
                    name: "20 Minutes Used",
                    eventName: .thirtyMinWarning20,
                    thresholdMinutes: 20,
                    action: .notification
                ),
                EventConfiguration(
                    name: "30 Minutes - Limit Reached",
                    eventName: .thirtyMinLimitReached,
                    thresholdMinutes: 30,
                    action: .shield
                )
            ],
            selectedApps: selectedApps
        )
        
        configurations.append(config)
        saveToUserDefaults(selectedApps, forKey: "thirtyMin_apps")
    }
    
    func createEveningRestriction(
        startHour: Int = 22,
        startMinute: Int = 0,
        endHour: Int = 6,
        endMinute: Int = 0,
        selectedApps: FamilyActivitySelection
    ) throws {
        
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: startHour, minute: startMinute),
            intervalEnd: DateComponents(hour: endHour, minute: endMinute),
            repeats: true
        )
        
        // Immediate block when interval starts
        let event = DeviceActivityEvent(
            applications: selectedApps.applicationTokens,
            threshold: DateComponents(second: 1)
        )
        
        let events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [
            .eveningBlockStart: event
        ]
        
        try center.startMonitoring(
            .eveningRestriction,
            during: schedule,
            events: events
        )
        
        let config = MonitorConfiguration(
            name: "Evening Restriction",
            activityName: .eveningRestriction,
            scheduleType: .daily(
                startHour: startHour,
                startMinute: startMinute,
                endHour: endHour,
                endMinute: endMinute
            ),
            events: [
                EventConfiguration(
                    name: "Evening Block Active",
                    eventName: .eveningBlockStart,
                    thresholdMinutes: 0,
                    action: .shield
                )
            ],
            selectedApps: selectedApps
        )
        
        configurations.append(config)
        saveToUserDefaults(selectedApps, forKey: "evening_apps")
    }
    
    func createWeeklyReview(
        dayOfWeek: Int = 1, // Sunday
        hour: Int = 18,
        selectedApps: FamilyActivitySelection
    ) throws {
        
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(
                hour: 0,
                minute: 0,
                weekday: dayOfWeek
            ),
            intervalEnd: DateComponents(
                hour: 23,
                minute: 59,
                weekday: dayOfWeek
            ),
            repeats: true
        )
        
        // Track entire week's usage
        let event = DeviceActivityEvent(
            applications: selectedApps.applicationTokens,
            threshold: DateComponents(hour: 1) // Any usage triggers
        )
        
        let events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [
            .weeklyReviewTrigger: event
        ]
        
        try center.startMonitoring(
            .weeklyReview,
            during: schedule,
            events: events
        )
        
        let config = MonitorConfiguration(
            name: "Weekly Review",
            activityName: .weeklyReview,
            scheduleType: .custom(
                start: DateComponents(hour: 0, minute: 0, weekday: dayOfWeek),
                end: DateComponents(hour: 23, minute: 59, weekday: dayOfWeek),
                repeats: true
            ),
            events: [
                EventConfiguration(
                    name: "Weekly Review",
                    eventName: .weeklyReviewTrigger,
                    thresholdMinutes: 60,
                    action: .notification
                )
            ],
            selectedApps: selectedApps
        )
        
        configurations.append(config)
        saveToUserDefaults(selectedApps, forKey: "weekly_apps")
    }
    
    func createCustomMonitor(
        name: String,
        activityName: DeviceActivityName,
        schedule: DeviceActivitySchedule,
        events: [DeviceActivityEvent.Name: DeviceActivityEvent],
        selectedApps: FamilyActivitySelection
    ) throws {
        
        try center.startMonitoring(
            activityName,
            during: schedule,
            events: events
        )
        
        let eventConfigs = events.map { (eventName, event) in
            EventConfiguration(
                name: String(describing: eventName),
                eventName: eventName,
                thresholdMinutes: event.threshold.minute ?? 0,
                action: .both
            )
        }
        
        let config = MonitorConfiguration(
            name: name,
            activityName: activityName,
            scheduleType: .custom(
                start: schedule.intervalStart,
                end: schedule.intervalEnd,
                repeats: schedule.repeats
            ),
            events: eventConfigs,
            selectedApps: selectedApps
        )
        
        configurations.append(config)
        saveToUserDefaults(selectedApps, forKey: "\(activityName)_apps")
    }
    
    // MARK: - Stop Monitors
    
    func stopMonitor(_ activityName: DeviceActivityName) {
        center.stopMonitoring([activityName])
        configurations.removeAll { $0.activityName == activityName }
    }
    
    func stopAllMonitors() {
        let allActivities = configurations.map { $0.activityName }
        center.stopMonitoring(allActivities)
        configurations.removeAll()
    }
    
    // MARK: - Verify Monitors
    
    func verifyMonitor(_ activityName: DeviceActivityName) -> Bool {
        do {
            _ = try center.schedule(for: activityName)
            return true
        } catch {
            return false
        }
    }
    
    func refreshConfigurations() {
        configurations = configurations.filter { config in
            verifyMonitor(config.activityName)
        }
    }
    
    // MARK: - Persistence
    
    private func saveToUserDefaults(_ selection: FamilyActivitySelection, forKey key: String) {
        let sharedDefaults = UserDefaults(suiteName: "group.com.yourapp.screentime")
        
        // Save application tokens
        if let encoded = try? JSONEncoder().encode(
            selection.applicationTokens.map { $0.rawValue }
        ) {
            sharedDefaults?.set(encoded, forKey: "\(key)_tokens")
        }
    }
}

// MARK: - Event Name Extensions

extension DeviceActivityEvent.Name {
    static let dailyLimitReached = Self("dailyLimitReached")
    static let thirtyMinWarning10 = Self("thirtyMinWarning10")
    static let thirtyMinWarning20 = Self("thirtyMinWarning20")
    static let thirtyMinLimitReached = Self("thirtyMinLimitReached")
    static let eveningBlockStart = Self("eveningBlockStart")
    static let weeklyReviewTrigger = Self("weeklyReviewTrigger")
}

// MARK: - SwiftUI Create Monitor View

struct CreateMonitorView: View {
    @StateObject private var monitorManager = MonitorManager()
    @StateObject private var timelineBuilder = MonitoringTimelineBuilder()
    
    @State private var selectedApps = FamilyActivitySelection()
    @State private var showAppPicker = false
    @State private var selectedMonitorType = MonitorType.dailyLimit
    
    // Daily Limit Settings
    @State private var dailyStartHour = 0
    @State private var dailyStartMinute = 0
    @State private var dailyEndHour = 23
    @State private var dailyEndMinute = 59
    @State private var dailyThresholdMinutes = 120
    
    // Evening Settings
    @State private var eveningStartHour = 22
    @State private var eveningStartMinute = 0
    @State private var eveningEndHour = 6
    @State private var eveningEndMinute = 0
    
    enum MonitorType: String, CaseIterable {
        case dailyLimit = "Daily Limit"
        case thirtyMinute = "30-Minute Session"
        case eveningBlock = "Evening Block"
        case weeklyReview = "Weekly Review"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Monitor Type") {
                    Picker("Type", selection: $selectedMonitorType) {
                        ForEach(MonitorType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Select Apps to Monitor") {
                    Button(action: { showAppPicker = true }) {
                        HStack {
                            Image(systemName: "app.badge")
                            Text(selectedApps.applicationTokens.isEmpty 
                                 ? "Choose Apps" 
                                 : "\(selectedApps.applicationTokens.count) apps selected")
                        }
                    }
                    .familyActivityPicker(
                        isPresented: $showAppPicker,
                        selection: $selectedApps
                    )
                }
                
                // Configuration based on type
                switch selectedMonitorType {
                case .dailyLimit:
                    dailyLimitConfiguration
                case .thirtyMinute:
                    thirtyMinuteConfiguration
                case .eveningBlock:
                    eveningBlockConfiguration
                case .weeklyReview:
                    weeklyReviewConfiguration
                }
                
                Section {
                    Button("Create Monitor") {
                        createMonitor()
                    }
                    .disabled(selectedApps.applicationTokens.isEmpty)
                }
                
                // Active Monitors
                Section("Active Monitors") {
                    ForEach(monitorManager.configurations) { config in
                        VStack(alignment: .leading) {
                            Text(config.name)
                                .font(.headline)
                            Text("\(config.events.count) events")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                monitorManager.stopMonitor(config.activityName)
                                timelineBuilder.buildTimeline()
                            } label: {
                                Label("Stop", systemImage: "stop.circle")
                            }
                        }
                    }
                }
                
                // Timeline Preview
                Section("Timeline Preview") {
                    NavigationLink("View Full Timeline") {
                        MonitoringTimelineView()
                    }
                    
                    if let current = timelineBuilder.currentWindow {
                        VStack(alignment: .leading) {
                            Text("Currently Active")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(activityName(current.activityName))
                                .font(.headline)
                        }
                    }
                    
                    if let next = timelineBuilder.upcomingWindows.first {
                        VStack(alignment: .leading) {
                            Text("Next Up")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(activityName(next.activityName))
                                .font(.subheadline)
                            Text("Starts \(next.startTime, style: .relative)")
                                .font(.caption2)
                        }
                    }
                }
            }
            .navigationTitle("Create Monitor")
            .onAppear {
                Task {
                    try? await monitorManager.requestAuthorization()
                    timelineBuilder.buildTimeline()
                }
            }
        }
    }
    
    var dailyLimitConfiguration: some View {
        Section("Daily Limit Settings") {
            HStack {
                Text("Start Time")
                Spacer()
                Picker("Hour", selection: $dailyStartHour) {
                    ForEach(0..<24) { Text("\($0)").tag($0) }
                }
                .frame(width: 70)
                Text(":")
                Picker("Minute", selection: $dailyStartMinute) {
                    ForEach(0..<60) { Text(String(format: "%02d", $0)).tag($0) }
                }
                .frame(width: 70)
            }
            
            HStack {
                Text("End Time")
                Spacer()
                Picker("Hour", selection: $dailyEndHour) {
                    ForEach(0..<24) { Text("\($0)").tag($0) }
                }
                .frame(width: 70)
                Text(":")
                Picker("Minute", selection: $dailyEndMinute) {
                    ForEach(0..<60) { Text(String(format: "%02d", $0)).tag($0) }
                }
                .frame(width: 70)
            }
            
            Stepper("Limit: \(dailyThresholdMinutes) minutes", 
                    value: $dailyThresholdMinutes, 
                    in: 15...480, 
                    step: 15)
        }
    }
    
    var thirtyMinuteConfiguration: some View {
        Section("30-Minute Session") {
            Text("Creates a 30-minute monitoring window starting now")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Checkpoints:")
                .font(.caption)
            Text("• 10 minutes - Warning")
                .font(.caption2)
            Text("• 20 minutes - Warning")
                .font(.caption2)
            Text("• 30 minutes - Block apps")
                .font(.caption2)
        }
    }
    
    var eveningBlockConfiguration: some View {
        Section("Evening Block Settings") {
            HStack {
                Text("Block Start")
                Spacer()
                Picker("Hour", selection: $eveningStartHour) {
                    ForEach(0..<24) { Text("\($0)").tag($0) }
                }
                .frame(width: 70)
                Text(":")
                Picker("Minute", selection: $eveningStartMinute) {
                    ForEach(0..<60) { Text(String(format: "%02d", $0)).tag($0) }
                }
                .frame(width: 70)
            }
            
            HStack {
                Text("Block End")
                Spacer()
                Picker("Hour", selection: $eveningEndHour) {
                    ForEach(0..<24) { Text("\($0)").tag($0) }
                }
                .frame(width: 70)
                Text(":")
                Picker("Minute", selection: $eveningEndMinute) {
                    ForEach(0..<60) { Text(String(format: "%02d", $0)).tag($0) }
                }
                .frame(width: 70)
            }
            
            Text("Apps will be blocked during this time every day")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    var weeklyReviewConfiguration: some View {
        Section("Weekly Review") {
            Text("Monitors weekly usage patterns")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("Review happens every Sunday at 6 PM")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    func createMonitor() {
        do {
            switch selectedMonitorType {
            case .dailyLimit:
                try monitorManager.createDailyLimitMonitor(
                    startHour: dailyStartHour,
                    startMinute: dailyStartMinute,
                    endHour: dailyEndHour,
                    endMinute: dailyEndMinute,
                    thresholdMinutes: dailyThresholdMinutes,
                    selectedApps: selectedApps
                )
                
            case .thirtyMinute:
                try monitorManager.createThirtyMinuteSession(
                    selectedApps: selectedApps
                )
                
            case .eveningBlock:
                try monitorManager.createEveningRestriction(
                    startHour: eveningStartHour,
                    startMinute: eveningStartMinute,
                    endHour: eveningEndHour,
                    endMinute: eveningEndMinute,
                    selectedApps: selectedApps
                )
                
            case .weeklyReview:
                try monitorManager.createWeeklyReview(
                    selectedApps: selectedApps
                )
            }
            
            // Refresh timeline
            timelineBuilder.buildTimeline()
            
            // Reset selection
            selectedApps = FamilyActivitySelection()
            
        } catch {
            print("Failed to create monitor: \(error)")
        }
    }
    
    func activityName(_ name: DeviceActivityName) -> String {
        switch name {
        case .dailyLimit: return "Daily Limit"
        case .thirtyMinuteLimit: return "30-Min Session"
        case .eveningRestriction: return "Evening Block"
        case .weeklyReview: return "Weekly Review"
        default: return "Monitor"
        }
    }
}

import DeviceActivity
import ManagedSettings
import UserNotifications

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    let store = ManagedSettingsStore()
    let sharedDefaults = UserDefaults(suiteName: "group.com.yourapp.screentime")
    
    // MARK: - Interval Callbacks
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        switch activity {
        case .dailyLimit:
            handleDailyLimitStart()
        case .eveningRestriction:
            handleEveningBlockStart()
        case .weeklyReview:
            handleWeeklyReviewStart()
        default:
            break
        }
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        // Remove shields when interval ends
        store.shield.applications = nil
        
        logEvent("Interval ended for \(activity)")
    }
    
    // MARK: - Event Callbacks
    
    override func eventDidReachThreshold(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        super.eventDidReachThreshold(event, activity: activity)
        
        switch event {
        case .dailyLimitReached:
            handleDailyLimitReached()
            
        case .thirtyMinWarning10:
            sendNotification(
                title: "10 Minutes Used",
                body: "20 minutes remaining in your session"
            )
            
        case .thirtyMinWarning20:
            sendNotification(
                title: "20 Minutes Used",
                body: "10 minutes remaining in your session"
            )
            
        case .thirtyMinLimitReached:
            handleThirtyMinuteLimitReached()
            
        case .eveningBlockStart:
            handleEveningBlockActivated()
            
        case .weeklyReviewTrigger:
            handleWeeklyReviewTrigger()
            
        default:
            break
        }
    }
    
    // MARK: - Event Handlers
    
    private func handleDailyLimitStart() {
        // Reset daily counters
        sharedDefaults?.set(0, forKey: "dailyUsageSeconds")
        sharedDefaults?.set(Date(), forKey: "dailyLimitStartTime")
        
        // Clear any existing shields
        store.shield.applications = nil
        
        logEvent("Daily limit monitoring started")
    }
    
    private func handleDailyLimitReached() {
        // Load selected apps
        guard let apps = loadApplicationTokens(forKey: "dailyLimit_apps") else {
            return
        }
        
        // Apply shield
        store.shield.applications = apps
        
        // Send notification
        sendNotification(
            title: "Daily Limit Reached",
            body: "You've reached your daily usage limit"
        )
        
        // Log
        sharedDefaults?.set(Date(), forKey: "dailyLimitReachedTime")
        logEvent("Daily limit reached - apps shielded")
    }
    
    private func handleThirtyMinuteLimitReached() {
        guard let apps = loadApplicationTokens(forKey: "thirtyMin_apps") else {
            return
        }
        
        store.shield.applications = apps
        
        sendNotification(
            title: "Session Complete",
            body: "30-minute session has ended. Apps are now blocked."
        )
        
        logEvent("30-minute session completed")
    }
    
    private func handleEveningBlockStart() {
        // Immediately block apps when evening period starts
        handleEveningBlockActivated()
    }
    
    private func handleEveningBlockActivated() {
        guard let apps = loadApplicationTokens(forKey: "evening_apps") else {
            return
        }
        
        store.shield.applications = apps
        
        sendNotification(
            title: "Evening Block Active",
            body: "Selected apps are blocked for the evening"
        )
        
        logEvent("Evening block activated")
    }
    
    private func handleWeeklyReviewStart() {
        // Reset weekly stats
        sharedDefaults?.set(0, forKey: "weeklyTotalSeconds")
        sharedDefaults?.set(Date(), forKey: "weeklyReviewStartTime")
        
        logEvent("Weekly review period started")
    }
    
    private func handleWeeklyReviewTrigger() {
        // Calculate stats
        let totalSeconds = sharedDefaults?.integer(forKey: "weeklyTotalSeconds") ?? 0
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        
        sendNotification(
            title: "Weekly Review",
            body: "This week: \(hours)h \(minutes)m of screen time"
        )
        
        logEvent("Weekly review triggered: \(totalSeconds) seconds")
    }
    
    // MARK: - Helper Methods
    
    private func loadApplicationTokens(forKey key: String) -> Set<ApplicationToken>? {
        guard let data = sharedDefaults?.data(forKey: "\(key)_tokens"),
              let rawValues = try? JSONDecoder().decode([Data].self, from: data) else {
            return nil
        }
        
        return Set(rawValues.map { ApplicationToken($0) })
    }
    
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func logEvent(_ message: String) {
        let timestamp = Date()
        var logs = sharedDefaults?.array(forKey: "monitorLogs") as? [[String: Any]] ?? []
        
        logs.append([
            "timestamp": timestamp,
            "message": message
        ])
        
        // Keep last 100 logs
        if logs.count > 100 {
            logs = Array(logs.suffix(100))
        }
        
        sharedDefaults?.set(logs, forKey: "monitorLogs")
    }
}

import SwiftUI
import DeviceActivity
import FamilyControls

// MARK: - Timeline Models

struct MonitoringWindow: Identifiable {
    let id = UUID()
    let activityName: DeviceActivityName
    let startTime: Date
    let endTime: Date
    let isActive: Bool
    let events: [MonitoringEvent]
    let repeats: Bool
}

struct MonitoringEvent: Identifiable {
    let id = UUID()
    let name: DeviceActivityEvent.Name
    let threshold: String
    let appCount: Int
    let categoryCount: Int
}

enum TimelineStatus {
    case upcoming
    case active
    case completed
}

// MARK: - Timeline Builder

class MonitoringTimelineBuilder: ObservableObject {
    @Published var windows: [MonitoringWindow] = []
    @Published var currentWindow: MonitoringWindow?
    @Published var upcomingWindows: [MonitoringWindow] = []
    @Published var completedWindows: [MonitoringWindow] = []
    
    let center = DeviceActivityCenter()
    let calendar = Calendar.current
    
    // Your activity names
    let activityNames: [DeviceActivityName] = [
        .dailyLimit,
        .thirtyMinuteLimit,
        .weeklyReview,
        .eveningRestriction
    ]
    
    func buildTimeline() {
        var allWindows: [MonitoringWindow] = []
        let now = Date()
        
        for activityName in activityNames {
            do {
                // Get schedule configuration
                let schedule = try center.schedule(for: activityName)
                
                // Get events configuration
                let events = try center.events(for: activityName)
                
                // Convert to monitoring events
                let monitoringEvents = events.map { (name, event) in
                    MonitoringEvent(
                        name: name,
                        threshold: formatThreshold(event.threshold),
                        appCount: event.applications.count,
                        categoryCount: event.categories.count
                    )
                }
                
                // Calculate actual time windows
                let windows = calculateWindows(
                    for: activityName,
                    schedule: schedule,
                    events: monitoringEvents,
                    referenceDate: now
                )
                
                allWindows.append(contentsOf: windows)
                
            } catch {
                print("No monitoring found for \(activityName)")
            }
        }
        
        // Sort and categorize windows
        allWindows.sort { $0.startTime < $1.startTime }
        
        self.windows = allWindows
        categorizeWindows(allWindows, referenceDate: now)
    }
    
    private func calculateWindows(
        for activityName: DeviceActivityName,
        schedule: DeviceActivitySchedule,
        events: [MonitoringEvent],
        referenceDate: Date
    ) -> [MonitoringWindow] {
        
        var windows: [MonitoringWindow] = []
        let now = referenceDate
        
        // Get today's window
        if let (start, end) = getWindowDates(
            from: schedule,
            for: now
        ) {
            let isActive = now >= start && now <= end
            
            windows.append(MonitoringWindow(
                activityName: activityName,
                startTime: start,
                endTime: end,
                isActive: isActive,
                events: events,
                repeats: schedule.repeats
            ))
        }
        
        // If repeats, add upcoming windows
        if schedule.repeats {
            for dayOffset in 1...7 {
                if let futureDate = calendar.date(
                    byAdding: .day,
                    value: dayOffset,
                    to: now
                ),
                   let (start, end) = getWindowDates(
                    from: schedule,
                    for: futureDate
                   ) {
                    windows.append(MonitoringWindow(
                        activityName: activityName,
                        startTime: start,
                        endTime: end,
                        isActive: false,
                        events: events,
                        repeats: schedule.repeats
                    ))
                }
            }
        }
        
        return windows
    }
    
    private func getWindowDates(
        from schedule: DeviceActivitySchedule,
        for referenceDate: Date
    ) -> (start: Date, end: Date)? {
        
        let startComponents = schedule.intervalStart
        let endComponents = schedule.intervalEnd
        
        // Create start date
        var startDate = calendar.date(
            bySettingHour: startComponents.hour ?? 0,
            minute: startComponents.minute ?? 0,
            second: startComponents.second ?? 0,
            of: referenceDate
        )
        
        // Create end date
        var endDate = calendar.date(
            bySettingHour: endComponents.hour ?? 0,
            minute: endComponents.minute ?? 0,
            second: endComponents.second ?? 0,
            of: referenceDate
        )
        
        // Handle overnight schedules (e.g., 22:00 to 06:00)
        if let start = startDate, let end = endDate, end < start {
            endDate = calendar.date(byAdding: .day, value: 1, to: end)
        }
        
        guard let start = startDate, let end = endDate else {
            return nil
        }
        
        return (start, end)
    }
    
    private func categorizeWindows(
        _ windows: [MonitoringWindow],
        referenceDate: Date
    ) {
        let now = referenceDate
        
        currentWindow = windows.first { $0.isActive }
        
        upcomingWindows = windows.filter { 
            $0.startTime > now 
        }.prefix(5).map { $0 }
        
        completedWindows = windows.filter { 
            $0.endTime < now 
        }.suffix(5).reversed()
    }
    
    private func formatThreshold(_ threshold: DateComponents) -> String {
        var parts: [String] = []
        
        if let hours = threshold.hour, hours > 0 {
            parts.append("\(hours)h")
        }
        if let minutes = threshold.minute, minutes > 0 {
            parts.append("\(minutes)m")
        }
        if let seconds = threshold.second, seconds > 0 {
            parts.append("\(seconds)s")
        }
        
        return parts.isEmpty ? "No threshold" : parts.joined(separator: " ")
    }
}

// MARK: - Activity Name Extension
extension DeviceActivityName {
    static let dailyLimit = Self("dailyLimit")
    static let thirtyMinuteLimit = Self("thirtyMinuteLimit")
    static let weeklyReview = Self("weeklyReview")
    static let eveningRestriction = Self("eveningRestriction")
}

// MARK: - SwiftUI Timeline View

struct MonitoringTimelineView: View {
    @StateObject private var timeline = MonitoringTimelineBuilder()
    
    var body: some View {
        NavigationView {
            List {
                // Current Monitoring
                if let current = timeline.currentWindow {
                    Section("🔴 Active Now") {
                        MonitoringWindowRow(window: current, status: .active)
                    }
                }
                
                // Upcoming Monitoring
                if !timeline.upcomingWindows.isEmpty {
                    Section("📅 Upcoming") {
                        ForEach(timeline.upcomingWindows) { window in
                            MonitoringWindowRow(window: window, status: .upcoming)
                        }
                    }
                }
                
                // Completed Monitoring
                if !timeline.completedWindows.isEmpty {
                    Section("✅ Completed") {
                        ForEach(timeline.completedWindows) { window in
                            MonitoringWindowRow(window: window, status: .completed)
                        }
                    }
                }
                
                // All Windows (Debug)
                Section("📊 All Monitoring Windows") {
                    ForEach(timeline.windows) { window in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(activityDisplayName(window.activityName))
                                .font(.headline)
                            
                            Text("\(window.startTime, style: .time) - \(window.endTime, style: .time)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if window.isActive {
                                Text("ACTIVE")
                                    .font(.caption2)
                                    .padding(4)
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Monitoring Timeline")
            .toolbar {
                Button("Refresh") {
                    timeline.buildTimeline()
                }
            }
            .onAppear {
                timeline.buildTimeline()
            }
        }
    }
    
    func activityDisplayName(_ name: DeviceActivityName) -> String {
        switch name {
        case .dailyLimit: return "Daily Limit"
        case .thirtyMinuteLimit: return "30-Min Session"
        case .weeklyReview: return "Weekly Review"
        case .eveningRestriction: return "Evening Block"
        default: return "Unknown"
        }
    }
}

struct MonitoringWindowRow: View {
    let window: MonitoringWindow
    let status: TimelineStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(activityName)
                    .font(.headline)
                
                Spacer()
                
                if window.repeats {
                    Image(systemName: "repeat")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Image(systemName: "clock")
                    .font(.caption)
                Text("\(window.startTime, style: .time) - \(window.endTime, style: .time)")
                    .font(.subheadline)
            }
            .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                Text(window.startTime, style: .date)
                    .font(.subheadline)
            }
            .foregroundColor(.secondary)
            
            // Show events
            if !window.events.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Events:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(window.events) { event in
                        HStack {
                            Image(systemName: "bell.fill")
                                .font(.caption2)
                            Text("Alert at \(event.threshold)")
                                .font(.caption)
                            Text("(\(event.appCount) apps)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Time remaining or elapsed
            if window.isActive {
                TimeRemainingView(endTime: window.endTime)
            } else if status == .upcoming {
                TimeUntilView(startTime: window.startTime)
            }
        }
        .padding(.vertical, 4)
    }
    
    var activityName: String {
        switch window.activityName {
        case .dailyLimit: return "Daily Limit"
        case .thirtyMinuteLimit: return "30-Min Session"
        case .weeklyReview: return "Weekly Review"
        case .eveningRestriction: return "Evening Block"
        default: return "Monitoring"
        }
    }
}

struct TimeRemainingView: View {
    let endTime: Date
    @State private var timeRemaining: TimeInterval = 0
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            Image(systemName: "hourglass")
                .font(.caption)
            Text("Ends in \(formatTime(timeRemaining))")
                .font(.caption)
                .foregroundColor(.orange)
        }
        .onAppear {
            updateTimeRemaining()
        }
        .onReceive(timer) { _ in
            updateTimeRemaining()
        }
    }
    
    func updateTimeRemaining() {
        timeRemaining = max(0, endTime.timeIntervalSinceNow)
    }
    
    func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct TimeUntilView: View {
    let startTime: Date
    
    var body: some View {
        HStack {
            Image(systemName: "clock.arrow.circlepath")
                .font(.caption)
            Text("Starts \(startTime, style: .relative)")
                .font(.caption)
                .foregroundColor(.blue)
        }
    }
}

// MARK: - Compact Timeline Widget

struct CompactTimelineView: View {
    @StateObject private var timeline = MonitoringTimelineBuilder()
    
    var body: some View {
        VStack(spacing: 16) {
            if let current = timeline.currentWindow {
                VStack {
                    Text("Currently Active")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(activityName(current.activityName))
                        .font(.title2)
                        .bold()
                    
                    Text("Until \(current.endTime, style: .time)")
                        .font(.subheadline)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            }
            
            if let next = timeline.upcomingWindows.first {
                VStack {
                    Text("Next Up")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(activityName(next.activityName))
                        .font(.headline)
                    
                    Text("Starts \(next.startTime, style: .relative)")
                        .font(.caption)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .onAppear {
            timeline.buildTimeline()
        }
    }
    
    func activityName(_ name: DeviceActivityName) -> String {
        switch name {
        case .dailyLimit: return "Daily Limit"
        case .thirtyMinuteLimit: return "30-Min Session"
        default: return "Monitoring"
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            MonitoringTimelineView()
                .tabItem {
                    Label("Timeline", systemImage: "calendar")
                }
            
            CompactTimelineView()
                .tabItem {
                    Label("Current", systemImage: "clock")
                }
        }
    }
}