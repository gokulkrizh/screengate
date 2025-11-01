import Foundation
import SwiftUI
import UserNotifications
import Combine

// MARK: - Notification ViewModel

@MainActor
class NotificationViewModel: NSObject, ObservableObject, UNUserNotificationCenterDelegate {

    // MARK: - Published Properties
    @Published var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var isNotificationEnabled: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var notificationHistory: [NotificationRecord] = []
    @Published var scheduledNotifications: [ScheduledNotification] = []
    @Published var intentionRemindersEnabled: Bool = true
    @Published var dailyDigestEnabled: Bool = false
    @Published var progressNotificationsEnabled: Bool = true

    // MARK: - Private Properties
    private let notificationCenter = UNUserNotificationCenter.current()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    var canRequestAuthorization: Bool {
        notificationAuthorizationStatus == .notDetermined
    }

    var authorizationStatusText: String {
        switch notificationAuthorizationStatus {
        case .notDetermined:
            return "Not Requested"
        case .denied:
            return "Denied"
        case .authorized:
            return "Authorized"
        case .provisional:
            return "Provisional"
        case .ephemeral:
            return "Ephemeral"
        @unknown default:
            return "Unknown"
        }
    }

    var pendingNotificationCount: Int {
        get async {
            return await notificationCenter.pendingNotificationRequests().count
        }
    }

    // MARK: - Initialization
    override init() {
        super.init()
        setupNotificationCenter()
        checkNotificationAuthorization()
        loadNotificationSettings()
        loadNotificationHistory()
    }

    // MARK: - Authorization Management

    /// Request notification authorization
    func requestNotificationAuthorization() async {
        isLoading = true
        errorMessage = nil

        let options: UNAuthorizationOptions = [.alert, .sound, .badge, .criticalAlert]

        do {
            let granted = try await notificationCenter.requestAuthorization(options: options)
            isNotificationEnabled = granted
            checkNotificationAuthorization()

            if granted {
                print("✅ Notification authorization granted")
                // Schedule default notifications
                scheduleDefaultNotifications()
            } else {
                print("❌ Notification authorization denied")
            }
        } catch {
            errorMessage = "Failed to request notification authorization: \(error.localizedDescription)"
            print("❌ Authorization request failed: \(error)")
        }

        isLoading = false
    }

    /// Check current notification authorization status
    func checkNotificationAuthorization() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.notificationAuthorizationStatus = settings.authorizationStatus
                self?.isNotificationEnabled = settings.authorizationStatus == .authorized
            }
        }
    }

    /// Open app settings for notification permissions
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
            print("📱 Opened app settings")
        }
    }

    // MARK: - Intention Notifications

    /// Schedule intention reminder notification
    func scheduleIntentionReminder(
        for intention: IntentionActivity,
        at date: Date,
        title: String? = nil,
        body: String? = nil
    ) {
        guard isNotificationEnabled else {
            print("⚠️ Notifications not authorized")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = title ?? "Time for \(intention.title)"
        content.body = body ?? "Take a moment to complete your \(intention.category.rawValue.lowercased()) exercise"
        content.sound = .default
        content.categoryIdentifier = "INTENTION_REMINDER"
        content.userInfo = [
            "intentionId": intention.id,
            "intentionName": intention.title,
            "intentionCategory": intention.category.rawValue,
            "type": "intention_reminder"
        ]

        // Create trigger
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        // Create request
        let request = UNNotificationRequest(
            identifier: "intention-reminder-\(intention.id)-\(date.timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )

        // Schedule notification
        notificationCenter.add(request) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to schedule intention reminder: \(error.localizedDescription)"
                    print("❌ Failed to schedule intention reminder: \(error)")
                } else {
                    print("📅 Scheduled intention reminder for \(intention.title)")
                }
            }
        }
    }

    /// Schedule recurring intention notifications
    func scheduleRecurringIntentionNotifications(
        for intention: IntentionActivity,
        interval: TimeInterval = 3600, // 1 hour
        count: Int = 5
    ) {
        guard isNotificationEnabled else { return }

        for i in 1...count {
            let nextTime = Date().addingTimeInterval(TimeInterval(i) * interval)
            scheduleIntentionReminder(for: intention, at: nextTime)
        }

        print("📅 Scheduled \(count) recurring notifications for \(intention.title)")
    }

    // MARK: - Progress and Achievement Notifications

    /// Send completion celebration notification
    func sendCompletionCelebration(for intention: IntentionActivity) {
        guard isNotificationEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Great job! 🎉"
        content.body = "You completed \(intention.title)! Keep up the mindful practice."
        content.sound = .default
        content.categoryIdentifier = "ACHIEVEMENT"
        content.userInfo = [
            "type": "completion_celebration",
            "intentionId": intention.id,
            "intentionName": intention.title,
            "category": intention.category.rawValue
        ]

        // Schedule immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "celebration-\(intention.id)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Failed to send celebration: \(error)")
            } else {
                print("🎉 Sent completion celebration")
            }
        }
    }

    /// Send milestone notification
    func sendMilestoneNotification(
        title: String,
        message: String,
        milestoneType: MilestoneType
    ) {
        guard isNotificationEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Milestone Achieved! 🏆"
        content.body = message
        content.sound = .default
        content.categoryIdentifier = "MILESTONE"
        content.userInfo = [
            "type": "milestone",
            "milestoneType": milestoneType.rawValue
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "milestone-\(milestoneType.rawValue)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Failed to send milestone: \(error)")
            } else {
                print("🏆 Sent milestone notification")
            }
        }
    }

    // MARK: - Daily Digest and Insights

    /// Schedule daily digest notification
    func scheduleDailyDigest(at time: Date) {
        guard dailyDigestEnabled && isNotificationEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Your Daily Mindfulness Report 📊"
        content.body = "See your progress and get personalized recommendations for today."
        content.sound = .default
        content.categoryIdentifier = "DAILY_DIGEST"
        content.userInfo = ["type": "daily_digest"]

        // Create recurring trigger for same time every day
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: "daily-digest",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { [weak self] error in
            if let error = error {
                self?.errorMessage = "Failed to schedule daily digest: \(error.localizedDescription)"
                print("❌ Failed to schedule daily digest: \(error)")
            } else {
                print("📅 Scheduled daily digest for \(components.hour!):\(components.minute!)")
            }
        }
    }

    /// Toggle daily digest
    func toggleDailyDigest() {
        dailyDigestEnabled.toggle()
        saveNotificationSettings()

        if dailyDigestEnabled {
            // Schedule for default time (8 PM)
            let calendar = Calendar.current
            let tonight = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
            scheduleDailyDigest(at: tonight)
            print("✅ Enabled daily digest")
        } else {
            // Cancel daily digest
            notificationCenter.removePendingNotificationRequests(withIdentifiers: ["daily-digest"])
            print("⏹️ Disabled daily digest")
        }
    }

    // MARK: - Notification Management

    /// Get pending notifications
    func getPendingNotifications() {
        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            DispatchQueue.main.async {
                self?.scheduledNotifications = requests.compactMap { request in
                    guard let trigger = request.trigger as? UNCalendarNotificationTrigger else { return nil }

                    return ScheduledNotification(
                        id: request.identifier,
                        title: request.content.title,
                        body: request.content.body,
                        scheduledDate: trigger.nextTriggerDate() ?? Date(),
                        isRepeating: trigger.repeats
                    )
                }.sorted { $0.scheduledDate < $1.scheduledDate }
            }
        }
    }

    /// Cancel specific notification
    func cancelNotification(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        print("🗑️ Cancelled notification: \(identifier)")
    }

    /// Cancel all intention notifications
    func cancelAllIntentionNotifications() {
        let identifiers = scheduledNotifications
            .filter { $0.title.contains("Intention") || $0.title.contains("Reminder") }
            .map { $0.id }

        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        getPendingNotifications()
        print("🗑️ Cancelled all intention notifications")
    }

    /// Clear notification history
    func clearNotificationHistory() {
        notificationHistory.removeAll()
        saveNotificationHistory()
        print("🗑️ Cleared notification history")
    }

    // MARK: - Settings Management

    /// Toggle intention reminders
    func toggleIntentionReminders() {
        intentionRemindersEnabled.toggle()
        saveNotificationSettings()
        print(intentionRemindersEnabled ? "✅ Enabled intention reminders" : "⏹️ Disabled intention reminders")
    }

    /// Toggle progress notifications
    func toggleProgressNotifications() {
        progressNotificationsEnabled.toggle()
        saveNotificationSettings()
        print(progressNotificationsEnabled ? "✅ Enabled progress notifications" : "⏹️ Disabled progress notifications")
    }

    // MARK: - Private Methods

    private func setupNotificationCenter() {
        notificationCenter.delegate = self

        // Listen for app becoming active to check permissions
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.checkNotificationAuthorization()
                }
            }
            .store(in: &cancellables)
    }

    private func scheduleDefaultNotifications() {
        if intentionRemindersEnabled {
            // Schedule some default intention reminders
            let calendar = Calendar.current

            // Morning reminder
            let morningTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
            if let breathing = getDefaultBreathingIntention() {
                scheduleIntentionReminder(for: breathing, at: morningTime)
            }

            // Evening reminder
            let eveningTime = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()
            if let mindfulness = getDefaultMindfulnessIntention() {
                scheduleIntentionReminder(for: mindfulness, at: eveningTime)
            }
        }

        if dailyDigestEnabled {
            let tonight = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
            scheduleDailyDigest(at: tonight)
        }
    }

    private func getDefaultBreathingIntention() -> IntentionActivity? {
        return IntentionActivity.breathingExercise
    }

    private func getDefaultMindfulnessIntention() -> IntentionActivity? {
        return IntentionActivity.mindfulnessBodyScan
    }

    // MARK: - Data Persistence

    private func loadNotificationSettings() {
        intentionRemindersEnabled = UserDefaults.standard.bool(forKey: "IntentionRemindersEnabled")
        dailyDigestEnabled = UserDefaults.standard.bool(forKey: "DailyDigestEnabled")
        progressNotificationsEnabled = UserDefaults.standard.bool(forKey: "ProgressNotificationsEnabled")
    }

    private func saveNotificationSettings() {
        UserDefaults.standard.set(intentionRemindersEnabled, forKey: "IntentionRemindersEnabled")
        UserDefaults.standard.set(dailyDigestEnabled, forKey: "DailyDigestEnabled")
        UserDefaults.standard.set(progressNotificationsEnabled, forKey: "ProgressNotificationsEnabled")
    }

    private func loadNotificationHistory() {
        if let data = UserDefaults.standard.data(forKey: "NotificationHistory"),
           let history = try? JSONDecoder().decode([NotificationRecord].self, from: data) {
            notificationHistory = history.sorted { $0.timestamp > $1.timestamp }
        }
    }

    private func saveNotificationHistory() {
        if let data = try? JSONEncoder().encode(notificationHistory) {
            UserDefaults.standard.set(data, forKey: "NotificationHistory")
        }
    }

    private func addNotificationToHistory(_ record: NotificationRecord) {
        notificationHistory.insert(record, at: 0)
        // Keep only last 100 records
        if notificationHistory.count > 100 {
            notificationHistory = Array(notificationHistory.prefix(100))
        }
        saveNotificationHistory()
    }

    // MARK: - Deinit
    deinit {
        cancellables.removeAll()
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationViewModel {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        handleNotificationResponse(response)
        completionHandler()
    }

    private func handleNotificationResponse(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        let record = NotificationRecord(
            id: response.notification.request.identifier,
            title: response.notification.request.content.title,
            body: response.notification.request.content.body,
            timestamp: Date(),
            action: response.actionIdentifier,
            userInfo: userInfo
        )

        addNotificationToHistory(record)

        // Handle specific notification types
        if let type = userInfo["type"] as? String {
            switch type {
            case "daily_digest":
                // Navigate to analytics screen
                NotificationCenter.default.post(name: .showAnalyticsRequested, object: nil)
            case "milestone":
                // Handle milestone achievement
                handleMilestoneAchievement(userInfo)
            default:
                break
            }
        }
    }

    private func handleMilestoneAchievement(_ userInfo: [AnyHashable: Any]) {
        // Could trigger celebration animation, award points, etc.
        print("🏆 Milestone achieved: \(userInfo)")
    }
}

// MARK: - Supporting Models

struct ScheduledNotification: Identifiable, Codable {
    let id: String
    let title: String
    let body: String
    let scheduledDate: Date
    let isRepeating: Bool

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: scheduledDate)
    }
}

struct NotificationRecord: Codable, Identifiable {
    let id: String
    let title: String
    let body: String
    let timestamp: Date
    let action: String
    let intentionData: String? // Store as JSON string instead of AnyHashable: Any

    init(id: String, title: String, body: String, timestamp: Date, action: String, userInfo: [AnyHashable: Any]) {
        self.id = id
        self.title = title
        self.body = body
        self.timestamp = timestamp
        self.action = action
        // Store intention data if available
        if let intentionInfo = userInfo["intentionData"] {
            self.intentionData = String(describing: intentionInfo)
        } else {
            self.intentionData = nil
        }
    }
}

enum MilestoneType: String, Codable, CaseIterable {
    case firstIntention = "first_intention"
    case weekStreak = "week_streak"
    case monthStreak = "month_streak"
    case categoryMaster = "category_master"
    case customCreator = "custom_creator"

    var displayName: String {
        switch self {
        case .firstIntention: return "First Intention"
        case .weekStreak: return "Week Streak"
        case .monthStreak: return "Month Streak"
        case .categoryMaster: return "Category Master"
        case .customCreator: return "Custom Creator"
        }
    }
}

// MARK: - Notification Extensions

extension Notification.Name {
    static let showAnalyticsRequested = Notification.Name("showAnalyticsRequested")
    static let notificationMilestoneAchieved = Notification.Name("milestoneAchieved")
}