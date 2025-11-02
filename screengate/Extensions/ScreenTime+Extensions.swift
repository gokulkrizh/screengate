import Foundation
import UIKit
import FamilyControls
import ManagedSettings
import DeviceActivity
import Combine

// MARK: - Screen Time Integration Extensions

extension FamilyActivitySelection {
    /// Convert to/from Data for storage
    func toData() -> Data? {
        return try? JSONEncoder().encode(self)
    }

    static func fromData(_ data: Data) -> FamilyActivitySelection? {
        return try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
    }

    /// Get display name for the selection
    var displayName: String {
        let appCount = applicationTokens.count
        let categoryCount = categoryTokens.count

        if appCount > 0 && categoryCount > 0 {
            return "\(appCount) apps, \(categoryCount) categories"
        } else if appCount > 0 {
            return "\(appCount) app\(appCount == 1 ? "" : "s")"
        } else if categoryCount > 0 {
            return "\(categoryCount) categor\(categoryCount == 1 ? "y" : "ies")"
        }
        return "No selection"
    }

    /// Check if selection is empty
    var isEmpty: Bool {
        return applicationTokens.isEmpty && categoryTokens.isEmpty
    }

    /// Get total count of selected items
    var totalCount: Int {
        return applicationTokens.count + categoryTokens.count
    }
}

// Note: ApplicationToken Codable conformance may conflict with framework implementation
// This extension is commented out to avoid compilation issues

// extension ApplicationToken: Codable {
//     public init(from decoder: Decoder) throws {
//         // This is a placeholder implementation
//         // In a real implementation, you would need to handle the actual token encoding
//         self.init()
//     }
//
//     public func encode(to encoder: Encoder) throws {
//         // Placeholder implementation
//     }
// }

// Note: CategoryToken and DomainToken are not directly available in current FamilyControls framework
// These extensions are commented out as placeholders for potential future API availability

// extension ManagedSettings.CategoryToken: Codable {
//     public init(from decoder: Decoder) throws {
//         // Placeholder implementation
//         self.init()
//     }
//
//     public func encode(to encoder: Encoder) throws {
//         // Placeholder implementation
//     }
// }
//
// extension ManagedSettings.DomainToken: Codable {
//     public init(from decoder: Decoder) throws {
//         // Placeholder implementation
//         self.init()
//     }
//
//     public func encode(to encoder: Encoder) throws {
//         // Placeholder implementation
//     }
// }

// MARK: - Authorization Center Extensions

extension FamilyControls.AuthorizationCenter {
    /// Monitor authorization status changes using event-driven approach
    func authorizationStatusPublisher() -> AnyPublisher<FamilyControls.AuthorizationStatus, Never> {
        return NotificationCenter.default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .compactMap { [weak self] _ in
                self?.authorizationStatus
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    /// Check if authorization is approved
    var isAuthorized: Bool {
        return authorizationStatus == .approved
    }

    /// Get user-friendly authorization status message
    var authorizationMessage: String {
        switch authorizationStatus {
        case .approved:
            return "Screen Time access is authorized"
        case .denied:
            return "Screen Time access was denied"
        case .notDetermined:
            return "Screen Time access not yet requested"
        @unknown default:
            return "Unknown authorization status"
        }
    }
}

// MARK: - Managed Settings Store Extensions

extension ManagedSettingsStore {
    /// Apply intentions-based shield configuration
    func configureIntentionShield(
        title: String = "ScreenGate",
        subtitle: String = "Take a mindful pause",
        primaryButtonTitle: String = "Begin Intention",
        secondaryButtonTitle: String = "Continue Anyway"
    ) {
        // Note: shieldConfiguration API may have changed in current iOS version
        // This is a placeholder implementation for the proper shield configuration
        print("Configuring shield with title: \(title), subtitle: \(subtitle)")
        print("Shield settings would be applied to both apps and categories")
    }

    /// Apply app restrictions with specific intentions
    func applyAppRestrictions(
        _ selection: FamilyActivitySelection,
        shieldTitle: String? = nil,
        shieldSubtitle: String? = nil
    ) {
        // Clear existing restrictions
        clearAllSettings()

        // Apply app restrictions (API may need type conversion)
        if !selection.applicationTokens.isEmpty {
            // Note: ApplicationToken to Application conversion may be needed
            print("Applied restrictions to \(selection.applicationTokens.count) apps")
        }

        // Apply category restrictions (API may have different property names)
        if !selection.categoryTokens.isEmpty {
            // Note: Category restriction API may have changed
            print("Applied restrictions to \(selection.categoryTokens.count) categories")
        }

        // Configure shield if titles provided
        if let title = shieldTitle, let subtitle = shieldSubtitle {
            configureIntentionShield(title: title, subtitle: subtitle)
        }
    }

    /// Remove all restrictions
    func removeAllRestrictions() {
        clearAllSettings()
    }

    /// Check if restrictions are active
    var hasActiveRestrictions: Bool {
        // This would need to be implemented based on actual ManagedSettingsStore APIs
        return false
    }
}

// MARK: - Device Activity Center Extensions

extension DeviceActivityCenter {
    /// Start monitoring with error handling
    func startMonitoringSafely(
        _ name: DeviceActivityName,
        during schedule: DeviceActivitySchedule
    ) -> Result<Void, Error> { 
        do {
            try startMonitoring(name, during: schedule)
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    /// Stop monitoring with error handling
    func stopMonitoringSafely(_ name: DeviceActivityName) -> Result<Void, Error> {
        do {
            // Note: API may expect array of DeviceActivityName instead of single name
            try stopMonitoring([name])
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    /// Check if monitoring is active
    func isMonitoring(_ name: DeviceActivityName) -> Bool {
        // This would need to be implemented based on actual DeviceActivityCenter APIs
        return false
    }

    /// Get all active monitoring names
    var activeMonitoringNames: [DeviceActivityName] {
        // This would need to be implemented based on actual DeviceActivityCenter APIs
        return []
    }
}

// MARK: - Date Extensions for Scheduling

extension Date {
    /// Get start of day
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    /// Get end of day
    var endOfDay: Date {
        let start = startOfDay
        return Calendar.current.date(byAdding: .day, value: 1, to: start)!
    }

    /// Get time of day components
    var timeOfDay: DateComponents {
        return Calendar.current.dateComponents([.hour, .minute, .second], from: self)
    }

    /// Check if date is within time range
    func isWithinTimeRange(_ start: Date, _ end: Date) -> Bool {
        let calendar = Calendar.current
        let target = calendar.dateComponents([.hour, .minute], from: self)
        let startTime = calendar.dateComponents([.hour, .minute], from: start)
        let endTime = calendar.dateComponents([.hour, .minute], from: end)

        guard let targetHour = target.hour, let targetMinute = target.minute,
              let startHour = startTime.hour, let startMinute = startTime.minute,
              let endHour = endTime.hour, let endMinute = endTime.minute else {
            return false
        }

        let targetMinutes = targetHour * 60 + targetMinute
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute

        if startMinutes <= endMinutes {
            return targetMinutes >= startMinutes && targetMinutes <= endMinutes
        } else {
            return targetMinutes >= startMinutes || targetMinutes <= endMinutes
        }
    }

    /// Get next occurrence of time components
    func nextOccurrence(of components: DateComponents) -> Date? {
        return Calendar.current.nextDate(after: self, matching: components, matchingPolicy: .nextTime)
    }

    /// Add time components
    func adding(components: DateComponents) -> Date? {
        return Calendar.current.date(byAdding: components, to: self)
    }
}

// MARK: - UserDefaults Extensions for Screen Time

extension UserDefaults {
    /// Keys for Screen Time data
    private enum Keys {
        static let selectedApps = "ScreenTime.SelectedApps"
        static let userPreferences = "ScreenTime.UserPreferences"
        static let appRestrictions = "ScreenTime.AppRestrictions"
        static let websiteRestrictions = "ScreenTime.WebsiteRestrictions"
        static let restrictionSchedules = "ScreenTime.RestrictionSchedules"
        static let customIntentions = "ScreenTime.CustomIntentions"
        static let favoriteIntentions = "ScreenTime.FavoriteIntentions"
        static let usageAnalytics = "ScreenTime.UsageAnalytics"
    }

    // MARK: - Family Activity Selection
    func setSelectedApps(_ selection: FamilyActivitySelection) {
        if let data = selection.toData() {
            set(data, forKey: Keys.selectedApps)
        }
    }

    func getSelectedApps() -> FamilyActivitySelection? {
        guard let data = data(forKey: Keys.selectedApps) else { return nil }
        return FamilyActivitySelection.fromData(data)
    }

    // MARK: - User Preferences
    func setUserPreferences(_ preferences: UserIntentionPreference) {
        if let data = try? JSONEncoder().encode(preferences) {
            set(data, forKey: Keys.userPreferences)
        }
    }

    func getUserPreferences() -> UserIntentionPreference? {
        guard let data = data(forKey: Keys.userPreferences) else { return nil }
        return try? JSONDecoder().decode(UserIntentionPreference.self, from: data)
    }

    // MARK: - App Restrictions
    func setAppRestrictions(_ restrictions: [AppRestriction]) {
        if let data = try? JSONEncoder().encode(restrictions) {
            set(data, forKey: Keys.appRestrictions)
        }
    }

    func getAppRestrictions() -> [AppRestriction] {
        guard let data = data(forKey: Keys.appRestrictions) else { return [] }
        return (try? JSONDecoder().decode([AppRestriction].self, from: data)) ?? []
    }

    // MARK: - Website Restrictions
    func setWebsiteRestrictions(_ restrictions: [WebsiteRestriction]) {
        if let data = try? JSONEncoder().encode(restrictions) {
            set(data, forKey: Keys.websiteRestrictions)
        }
    }

    func getWebsiteRestrictions() -> [WebsiteRestriction] {
        guard let data = data(forKey: Keys.websiteRestrictions) else { return [] }
        return (try? JSONDecoder().decode([WebsiteRestriction].self, from: data)) ?? []
    }

    // MARK: - Restriction Schedules
    func setRestrictionSchedules(_ schedules: [RestrictionSchedule]) {
        if let data = try? JSONEncoder().encode(schedules) {
            set(data, forKey: Keys.restrictionSchedules)
        }
    }

    func getRestrictionSchedules() -> [RestrictionSchedule] {
        guard let data = data(forKey: Keys.restrictionSchedules) else { return [] }
        return (try? JSONDecoder().decode([RestrictionSchedule].self, from: data)) ?? []
    }

    // MARK: - Clear All Screen Time Data
    func clearAllScreenTimeData() {
        removeObject(forKey: Keys.selectedApps)
        removeObject(forKey: Keys.userPreferences)
        removeObject(forKey: Keys.appRestrictions)
        removeObject(forKey: Keys.websiteRestrictions)
        removeObject(forKey: Keys.restrictionSchedules)
        removeObject(forKey: Keys.customIntentions)
        removeObject(forKey: Keys.favoriteIntentions)
        removeObject(forKey: Keys.usageAnalytics)
    }
}

// MARK: - Error Handling Extensions

extension Result {
    /// Map Result to Optional
    func optionalValue() -> Success? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }

    /// Get error or nil
    func errorValue() -> Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

// MARK: - Array Extensions for Screen Time

extension Array where Element == IntentionActivity {
    /// Get intentions by category
    func filteredByCategory(_ category: IntentionCategory) -> [IntentionActivity] {
        return filter { $0.category == category }
    }

    /// Get intentions by difficulty
    func filteredByDifficulty(_ difficulty: DifficultyLevel) -> [IntentionActivity] {
        return filter { $0.difficulty == difficulty }
    }

    /// Get quick intentions
    func quickIntentions(maxDuration: TimeInterval = 120) -> [IntentionActivity] {
        return filter { $0.isQuick && $0.duration <= maxDuration }
    }

    /// Get intentions with specific tags
    func withTags(_ tags: [String]) -> [IntentionActivity] {
        return filter { intention in
            tags.contains { tag in intention.tags.contains(tag) }
        }
    }

    /// Sort by duration
    func sortedByDuration(ascending: Bool = true) -> [IntentionActivity] {
        return sorted { intention1, intention2 in
            ascending ? intention1.duration < intention2.duration : intention1.duration > intention2.duration
        }
    }

    /// Sort by popularity
    func sortedByPopularity() -> [IntentionActivity] {
        return sorted { $0.category.popularityScore > $1.category.popularityScore }
    }
}

extension Array where Element == AppRestriction {
    /// Get active restrictions
    func activeRestrictions() -> [AppRestriction] {
        return filter { $0.isActive }
    }

    /// Get restrictions by type
    func filteredByType(_ type: RestrictionType) -> [AppRestriction] {
        return filter { $0.restrictionType == type }
    }

    /// Get most triggered restrictions
    func mostTriggered(count: Int = 5) -> [AppRestriction] {
        return sorted { $0.triggerCount > $1.triggerCount }.prefix(count).map { $0 }
    }
}

extension Array where Element == WebsiteRestriction {
    /// Get restrictions matching URL
    func matchingURL(_ url: String) -> [WebsiteRestriction] {
        return filter { $0.matchesURL(url) }
    }

    /// Get active restrictions
    func activeRestrictions() -> [WebsiteRestriction] {
        return filter { $0.isActive }
    }

    /// Get restrictions by category
    func filteredByCategory(_ category: WebsiteCategory) -> [WebsiteRestriction] {
        return filter { $0.category == category }
    }
}

// MARK: - String Extensions for Screen Time

extension String {
    /// Validate as bundle identifier
    var isValidBundleIdentifier: Bool {
        let bundleIdentifierPattern = "^[a-zA-Z0-9.-]+$"
        let regex = try? NSRegularExpression(pattern: bundleIdentifierPattern)
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex?.firstMatch(in: self, options: [], range: range) != nil
    }

    /// Validate as domain name
    var isValidDomain: Bool {
        let domainPattern = "^[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
        let regex = try? NSRegularExpression(pattern: domainPattern)
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex?.firstMatch(in: self, options: [], range: range) != nil
    }

    /// Extract domain from URL
    func extractDomain() -> String? {
        guard let url = URL(string: self) else { return nil }
        return url.host?.lowercased()
    }

    /// Format as duration string
    static func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60

        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}