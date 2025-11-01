import Foundation
import FamilyControls
import Combine

// MARK: - Restriction Configuration View Model

@MainActor
class RestrictionConfigurationViewModel: ObservableObject {
    @Published var restrictedApps: [String] = []
    @Published var appConfigurations: [String: AppRestrictionConfiguration] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let userDefaults = UserDefaults.standard
    private let configurationKey = "RestrictionConfigurations"
    private let screenTimeService = ScreenTimeService.shared

    init() {
        loadConfiguration()
    }

    // MARK: - Configuration Management

    func loadConfiguration() {
        isLoading = true
        defer { isLoading = false }

        // Load restricted apps - get from FamilyActivitySelection
        // This is a simplified approach - in a real implementation, you'd extract tokens from the selection
        restrictedApps = [] // For now, empty until we have actual tokens

        // Load configurations
        if let data = userDefaults.data(forKey: configurationKey),
           let configurations = try? JSONDecoder().decode([String: AppRestrictionConfiguration].self, from: data) {
            appConfigurations = configurations
        }
    }

    func saveConfiguration() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Save configurations to UserDefaults
            let data = try JSONEncoder().encode(appConfigurations)
            userDefaults.set(data, forKey: configurationKey)

            // Apply restrictions to managed settings
            await applyRestrictionsToSystem()
        } catch {
            errorMessage = "Failed to save configuration: \(error.localizedDescription)"
        }
    }

    private func applyRestrictionsToSystem() async {
        // Apply app restrictions
        for (appIdentifier, configuration) in appConfigurations {
            if configuration.isEnabled {
                // Apply the restriction with the associated intention
                await applyRestriction(for: appIdentifier, configuration: configuration)
            }
        }
    }

    private func applyRestriction(for appIdentifier: String, configuration: AppRestrictionConfiguration) async {
        // Implementation would integrate with ManagedSettings
        // For now, this is a placeholder
        print("🔒 Applying restriction for \(appIdentifier) with intention: \(configuration.intention?.title ?? "None")")
    }

    // MARK: - App Configuration Methods

    func setIntention(_ intention: IntentionActivity?, for appIdentifier: String) {
        var configuration = appConfigurations[appIdentifier] ?? AppRestrictionConfiguration(
            appIdentifier: appIdentifier,
            intention: intention
        )
        configuration.intention = intention
        appConfigurations[appIdentifier] = configuration
    }

    func setSchedule(_ scheduleId: String?, for appIdentifier: String) {
        var configuration = appConfigurations[appIdentifier] ?? AppRestrictionConfiguration(
            appIdentifier: appIdentifier
        )
        configuration.scheduleId = scheduleId
        appConfigurations[appIdentifier] = configuration
    }

    func removeRestriction(for appIdentifier: String) {
        appConfigurations.removeValue(forKey: appIdentifier)

        // Remove from restricted apps if no configuration exists
        if !appConfigurations.keys.contains(appIdentifier) {
            restrictedApps.removeAll { $0 == appIdentifier }
        }
    }

    // MARK: - Data Access Methods

    func getIntention(for appIdentifier: String) -> IntentionActivity? {
        return appConfigurations[appIdentifier]?.intention
    }

    func getScheduleId(for appIdentifier: String) -> String? {
        return appConfigurations[appIdentifier]?.scheduleId
    }

    func getConfiguration(for appIdentifier: String) -> AppRestrictionConfiguration? {
        return appConfigurations[appIdentifier]
    }

    // MARK: - Validation

    func validateConfiguration() -> [ConfigurationValidationError] {
        var errors: [ConfigurationValidationError] = []

        for (appIdentifier, configuration) in appConfigurations {
            // Check if intention is required but not set
            if configuration.intention == nil {
                errors.append(.missingIntention(appIdentifier))
            }
        }

        return errors
    }
}

// MARK: - App Restriction Configuration

struct AppRestrictionConfiguration: Codable, Identifiable {
    let id = UUID()
    let appIdentifier: String
    var intention: IntentionActivity?
    var scheduleId: String? // Reference to RestrictionSchedule
    var isEnabled: Bool
    var strictMode: Bool
    var gracePeriod: TimeInterval

    init(
        appIdentifier: String,
        intention: IntentionActivity? = nil,
        scheduleId: String? = nil,
        isEnabled: Bool = true,
        strictMode: Bool = false,
        gracePeriod: TimeInterval = 30.0
    ) {
        self.appIdentifier = appIdentifier
        self.intention = intention
        self.scheduleId = scheduleId
        self.isEnabled = isEnabled
        self.strictMode = strictMode
        self.gracePeriod = gracePeriod
    }

    var isFullyConfigured: Bool {
        return intention != nil
    }

    var isActiveNow: Bool {
        guard isEnabled else { return false }
        // For simplicity, assume active if enabled and has intention
        return intention != nil
    }
}

// MARK: - Simple Validation Error

enum ConfigurationValidationError: LocalizedError, Identifiable {
    case missingIntention(String)
    case invalidConfiguration(String)

    var id: String {
        switch self {
        case .missingIntention(let app):
            return "missingIntention-\(app)"
        case .invalidConfiguration(let app):
            return "invalidConfig-\(app)"
        }
    }

    var errorDescription: String? {
        switch self {
        case .missingIntention(let app):
            return "App \(app) requires an intention assignment"
        case .invalidConfiguration(let app):
            return "App \(app) has invalid configuration"
        }
    }
}