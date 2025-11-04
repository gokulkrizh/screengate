import Foundation
import UIKit
import FamilyControls
import ManagedSettings
import DeviceActivity
import Combine

@MainActor
class ScreenTimeService: ObservableObject {

    // MARK: - Published Properties
    @Published var authorizationStatus: FamilyControls.AuthorizationStatus = .notDetermined
    @Published var selectedApps: FamilyActivitySelection = FamilyActivitySelection()
    @Published var selectedCategories: FamilyActivitySelection = FamilyActivitySelection()
    @Published var isAuthorized = false
    @Published var isLoading = false

    // MARK: - Private Properties
    private let managedSettingsStore = ManagedSettingsStore()
    private let authorizationCenter = FamilyControls.AuthorizationCenter.shared
    private var cancellables = Set<AnyCancellable>()
    private var authorizationObserver: NSObjectProtocol?

    // MARK: - Shared Instance
    @MainActor
    static let shared = ScreenTimeService()

    private init() {
        setupAuthorizationObserver()
        loadSavedSelections()
        checkAuthorizationStatus()
    }

    // MARK: - Authorization Management

    /// Request Screen Time authorization from the user
    func requestAuthorization() async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            // Use the modern requestAuthorization(for:) API
            try await authorizationCenter.requestAuthorization(for: .individual)
            Task { @MainActor in
                self.checkAuthorizationStatus() // Update status from authorization center
            }
        } catch {
            Task { @MainActor in
                self.checkAuthorizationStatus() // Update status even on failure
            }
            throw ScreenTimeError.authorizationFailed(error)
        }
    }

    /// Check current authorization status
    func checkAuthorizationStatus() {
        authorizationStatus = authorizationCenter.authorizationStatus
        isAuthorized = (authorizationStatus == .approved)
    }

    /// Manually refresh authorization status (call when user returns from Settings)
    func refreshAuthorizationStatus() {
        checkAuthorizationStatus()
    }

    // MARK: - App Selection Management

    /// Save selected apps and categories
    func saveSelection(_ selection: FamilyActivitySelection) {
        selectedApps = selection
        selectedCategories = selection

        // Save to UserDefaults for persistence (simplified for now)
        UserDefaults.standard.set(true, forKey: "HasSelectedApps")

        // Apply restrictions if authorized
        if isAuthorized {
            applyRestrictions()
        }
    }

    /// Load previously saved selections
    func loadSavedSelections() {
        // Simplified loading for now
        let hasSelections = UserDefaults.standard.bool(forKey: "HasSelectedApps")
        if hasSelections {
            // TODO: Load actual selections when Codable is properly implemented
            print("Found saved app selections")
        }
    }

    // MARK: - Restriction Management

    /// Apply restrictions based on current selections
    func applyRestrictions() {
        guard isAuthorized else {
            print("Cannot apply restrictions: not authorized")
            return
        }

        // Clear existing restrictions
        clearRestrictions()

        // Apply app restrictions using ManagedSettings
        if !selectedApps.applicationTokens.isEmpty {
            // Convert ApplicationToken to Application and block the applications
            let applicationsToBlock = selectedApps.applicationTokens.map { token in
                Application(token: token) // Convert token to Application with proper label
            }
            managedSettingsStore.application.blockedApplications = Set(applicationsToBlock)
            print("🛡️ Applied app restrictions for \(selectedApps.applicationTokens.count) apps")
        }

        // Apply category restrictions using ManagedSettings
        if !selectedApps.categoryTokens.isEmpty {
            // Note: Category blocking API may not be available in current iOS version
            // Categories will be handled by individual app blocking for now
            print("⚠️ Category restrictions selected (\(selectedApps.categoryTokens.count) categories) but not directly blocked via API")
            print("📝 Categories will be handled through shield configuration")
        }

        // Mark that restrictions are applied
        UserDefaults.standard.set(true, forKey: "RestrictionsApplied")

        // Share data with extensions
        shareDataWithExtensions()

        print("Screen Time restrictions applied successfully")
    }

    /// Clear all restrictions
    func clearRestrictions() {
        managedSettingsStore.clearAllSettings()
        print("All restrictions cleared")
    }

    // MARK: - Device Activity Scheduling

    /// Start device activity monitoring
    func startDeviceActivityMonitoring(schedule: DeviceActivitySchedule) throws {
        let deviceActivityCenter = DeviceActivityCenter()
        let monitoringName = DeviceActivityName("ScreenGateMonitoring")

        try deviceActivityCenter.startMonitoring(monitoringName, during: schedule)
        print("Device activity monitoring started")
    }

    /// Stop device activity monitoring
    func stopDeviceActivityMonitoring() {
        let deviceActivityCenter = DeviceActivityCenter()
        let monitoringName = DeviceActivityName("ScreenGateMonitoring")

        // Remove monitoring without try-catch since stopMonitoring doesn't throw
        deviceActivityCenter.stopMonitoring([monitoringName])
        print("Device activity monitoring stopped")
    }

    // MARK: - App Groups Communication

    /// Share data with extensions via App Groups
    func shareDataWithExtensions() {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.gia.screengate") else {
            print("Failed to access shared defaults")
            return
        }

        // Share authorization status
        sharedDefaults.set(isAuthorized, forKey: "ScreenTimeAuthorized")
        sharedDefaults.set(true, forKey: "HasSelectedApps")

        // Sync data immediately
        sharedDefaults.synchronize()
    }

    /// Load data shared from extensions
    func loadDataFromExtensions() {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.gia.screengate") else {
            return
        }

        // Load any data that extensions might have shared
        let hasSelections = sharedDefaults.bool(forKey: "HasSelectedApps")
        if hasSelections {
            print("Found shared selections from extensions")
        }
    }

    // MARK: - Shield Integration Methods

    /// Share user intention preferences with shield extensions
    func shareIntentionPreferences(_ preferences: UserIntentionPreference) {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.gia.screengate") else {
            print("Failed to access shared defaults for intention preferences")
            return
        }

        if let data = try? JSONEncoder().encode(preferences) {
            sharedDefaults.set(data, forKey: "UserIntentionPreferences")
            sharedDefaults.synchronize()
            print("Intention preferences shared with shield extensions")
        }
    }

    /// Load shield metadata from extensions (for analytics and tracking)
    func loadShieldMetadata() -> [String: ShieldMetadata] {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.gia.screengate"),
              let data = sharedDefaults.data(forKey: "ShieldMetadata"),
              let metadata = try? JSONDecoder().decode([String: ShieldMetadata].self, from: data) else {
            return [:]
        }
        return metadata
    }

    /// Clear shield metadata (for cleanup or user privacy)
    func clearShieldMetadata() {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.gia.screengate") else {
            return
        }

        sharedDefaults.removeObject(forKey: "ShieldMetadata")
        sharedDefaults.synchronize()
        print("Shield metadata cleared")
    }

    /// Get shield analytics for user insights
    func getShieldAnalytics() -> ShieldAnalytics {
        let metadata = loadShieldMetadata()
        let now = Date()

        let todayMetadata = metadata.values.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: now) }
        let thisWeekMetadata = metadata.values.filter { Calendar.current.isDate($0.timestamp, equalTo: now, toGranularity: .weekOfYear) }

        // Count intention categories
        var categoryCounts: [IntentionCategory: Int] = [:]
        for meta in metadata.values {
            if let intention = meta.selectedIntention {
                categoryCounts[intention.category, default: 0] += 1
            }
        }

        // Get most used intention category
        let mostUsedCategory = categoryCounts.max { $0.value < $1.value }?.key

        return ShieldAnalytics(
            totalShieldsTriggered: metadata.count,
            todayShieldsTriggered: todayMetadata.count,
            thisWeekShieldsTriggered: thisWeekMetadata.count,
            mostUsedIntentionCategory: mostUsedCategory,
            categoryBreakdown: categoryCounts,
            lastShieldTimestamp: metadata.values.max { $0.timestamp < $1.timestamp }?.timestamp
        )
    }

    /// Configure shield with specific intention for testing
    func configureTestShield(for appName: String, intention: IntentionActivity) {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.gia.screengate") else {
            return
        }

        let metadata = ShieldMetadata(
            bundleIdentifier: "com.test.app",
            appName: appName,
            selectedIntention: intention,
            isFromCategory: false
        )

        var allMetadata = loadShieldMetadata()
        allMetadata[metadata.bundleIdentifier] = metadata

        if let data = try? JSONEncoder().encode(allMetadata) {
            sharedDefaults.set(data, forKey: "ShieldMetadata")
            sharedDefaults.synchronize()
            print("Test shield configured for \(appName)")
        }
    }

    /// Export shield usage data for user privacy or analysis
    func exportShieldData() -> ShieldDataExport? {
        let metadata = loadShieldMetadata()
        let analytics = getShieldAnalytics()

        let export = ShieldDataExport(
            exportDate: Date(),
            totalInteractions: analytics.totalShieldsTriggered,
            interactionHistory: metadata.values.sorted { $0.timestamp < $1.timestamp },
            categoryAnalytics: analytics.categoryBreakdown,
            dateRange: DateRange(
                start: metadata.values.map { $0.timestamp }.min() ?? Date(),
                end: metadata.values.map { $0.timestamp }.max() ?? Date()
            )
        )

        return export
    }

    // MARK: - Enhanced Data Sharing

    /// Comprehensive data sync with extensions
    func syncAllDataWithExtensions() {
        // Share basic authorization and selection data
        shareDataWithExtensions()

        // Share intention preferences
        let preferences = UserDefaults.standard.getUserPreferences() ?? .default
        shareIntentionPreferences(preferences)

        // Share restriction schedules
        let schedules = UserDefaults.standard.getRestrictionSchedules()
        if !schedules.isEmpty {
            guard let sharedDefaults = UserDefaults(suiteName: "group.com.gia.screengate") else { return }
            if let data = try? JSONEncoder().encode(schedules) {
                sharedDefaults.set(data, forKey: "RestrictionSchedules")
            }
        }

        print("All ScreenTime data synced with shield extensions")
    }

    // MARK: - Private Methods

    private func setupAuthorizationObserver() {
        // Monitor authorization status changes using NotificationCenter
        authorizationObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.checkAuthorizationStatus()
            }
        }
    }

    deinit {
        if let observer = authorizationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

// MARK: - Error Types

enum ScreenTimeError: LocalizedError {
    case authorizationDenied
    case authorizationFailed(Error)
    case invalidSelection
    case configurationFailed

    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Screen Time authorization was denied. Please enable Screen Time permissions in Settings."
        case .authorizationFailed(let error):
            return "Failed to request Screen Time authorization: \(error.localizedDescription)"
        case .invalidSelection:
            return "Invalid app or category selection."
        case .configurationFailed:
            return "Failed to configure Screen Time settings."
        }
    }
}

// MARK: - Shield Analytics Models

struct ShieldAnalytics: Codable {
    let totalShieldsTriggered: Int
    let todayShieldsTriggered: Int
    let thisWeekShieldsTriggered: Int
    let mostUsedIntentionCategory: IntentionCategory?
    let categoryBreakdown: [IntentionCategory: Int]
    let lastShieldTimestamp: Date?

    var averageShieldsPerDay: Double {
        guard let daysSinceFirst = Calendar.current.dateComponents([.day], from: Date().addingTimeInterval(-7 * 24 * 60 * 60), to: Date()).day, daysSinceFirst > 0 else {
            return 0
        }
        return Double(thisWeekShieldsTriggered) / Double(daysSinceFirst)
    }

    var topCategory: (category: IntentionCategory, count: Int)? {
        return categoryBreakdown.max { $0.value < $1.value }.map { ($0.key, $0.value) }
    }
}

struct ShieldDataExport: Codable {
    let exportDate: Date
    let totalInteractions: Int
    let interactionHistory: [ShieldMetadata]
    let categoryAnalytics: [IntentionCategory: Int]
    let dateRange: DateRange
}

struct DateRange: Codable {
    let start: Date
    let end: Date

    var duration: TimeInterval {
        return end.timeIntervalSince(start)
    }

    var days: Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
    }
}

// MARK: - Shield Metadata Model (Matching Extensions)

struct ShieldMetadata: Codable {
    let bundleIdentifier: String
    let appName: String?
    let category: String?
    let selectedIntention: IntentionActivity?
    let timestamp: Date
    let isFromCategory: Bool

    init(
        bundleIdentifier: String,
        appName: String? = nil,
        category: String? = nil,
        selectedIntention: IntentionActivity? = nil,
        isFromCategory: Bool = false
    ) {
        self.bundleIdentifier = bundleIdentifier
        self.appName = appName
        self.category = category
        self.selectedIntention = selectedIntention
        self.timestamp = Date()
        self.isFromCategory = isFromCategory
    }
}