//
//  ShieldConfigurationExtension.swift
//  ShieldConfigurationExtension
//
//  Created by gokul on 01/11/25.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit
import FamilyControls

// MARK: - Shield Configuration Data Manager
class ShieldDataManager {
    static let shared = ShieldDataManager()

    private let sharedDefaults = UserDefaults(suiteName: "group.com.gia.screengate")
    private let metadataKey = "ShieldMetadata"

    private init() {}

    // MARK: - Metadata Storage
    func saveShieldMetadata(bundleIdentifier: String, metadata: ShieldMetadata) {
        var allMetadata = getAllShieldMetadata()
        allMetadata[bundleIdentifier] = metadata

        if let data = try? JSONEncoder().encode(allMetadata) {
            sharedDefaults?.set(data, forKey: metadataKey)
        }
    }

    func getShieldMetadata(for bundleIdentifier: String) -> ShieldMetadata? {
        let allMetadata = getAllShieldMetadata()
        return allMetadata[bundleIdentifier]
    }

    private func getAllShieldMetadata() -> [String: ShieldMetadata] {
        guard let data = sharedDefaults?.data(forKey: metadataKey),
              let metadata = try? JSONDecoder().decode([String: ShieldMetadata].self, from: data) else {
            return [:]
        }
        return metadata
    }

    // MARK: - Intention Selection
    func getIntentionForApp(bundleIdentifier: String) -> IntentionInfo? {
        // Try to get the configured intention for this specific app
        if let restriction = getRestriction(for: bundleIdentifier) {
            // Convert the configured intention to IntentionInfo
            return IntentionInfo(
                id: restriction.intentionId,
                name: restriction.intentionName,
                category: restriction.intentionCategory,
                duration: restriction.intentionDuration
            )
        }

        // Fallback to default intention if no specific configuration found
        return getDefaultIntention()
    }

    private func getRestriction(for bundleIdentifier: String) -> SimpleRestriction? {
        guard let data = sharedDefaults?.data(forKey: "SavedRestrictions"),
              let restrictions = try? JSONDecoder().decode([SimpleRestriction].self, from: data) else {
            return nil
        }

        return restrictions.first { $0.bundleIdentifier == bundleIdentifier }
    }

    private func getDefaultIntention() -> IntentionInfo {
        return IntentionInfo(
            id: "mindful-pause",
            name: "Mindful Pause",
            category: "Mindfulness",
            duration: 60
        )
    }
}

// MARK: - Shield Metadata Models
struct ShieldMetadata: Codable {
    let bundleIdentifier: String
    let appName: String?
    let category: String?
    let selectedIntention: IntentionInfo?
    let timestamp: Date
    let isFromCategory: Bool

    init(
        bundleIdentifier: String,
        appName: String? = nil,
        category: String? = nil,
        selectedIntention: IntentionInfo? = nil,
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

// MARK: - Simplified Intention Model
struct IntentionInfo: Codable {
    let id: String
    let name: String
    let category: String
    let duration: TimeInterval
}

// MARK: - Simplified Restriction Model for Shield Extension
struct SimpleRestriction: Codable {
    let bundleIdentifier: String
    let appName: String
    let intentionId: String
    let intentionName: String
    let intentionCategory: String
    let intentionDuration: TimeInterval
}

// MARK: - Enhanced Shield Configuration Extension
class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    private let dataManager = ShieldDataManager.shared

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        let bundleIdentifier = String(describing: application)
        return createCustomShield(
            bundleIdentifier: bundleIdentifier,
            appName: getAppName(from: bundleIdentifier),
            isFromCategory: false
        )
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        let bundleIdentifier = String(describing: application)
        return createCustomShield(
            bundleIdentifier: bundleIdentifier,
            appName: getAppName(from: bundleIdentifier),
            isFromCategory: true,
            categoryName: getCategoryName(from: category)
        )
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        let domainString = String(describing: webDomain)
        return createCustomShield(
            bundleIdentifier: domainString,
            appName: domainString,
            isFromCategory: false,
            isWebDomain: true
        )
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        let domainString = String(describing: webDomain)
        return createCustomShield(
            bundleIdentifier: domainString,
            appName: domainString,
            isFromCategory: true,
            categoryName: getCategoryName(from: category),
            isWebDomain: true
        )
    }

    // MARK: - Custom Shield Creation
    private func createCustomShield(
        bundleIdentifier: String,
        appName: String? = nil,
        isFromCategory: Bool,
        categoryName: String? = nil,
        isWebDomain: Bool = false
    ) -> ShieldConfiguration {

        // Get the configured intention for this specific app
        let selectedIntention = dataManager.getIntentionForApp(bundleIdentifier: bundleIdentifier)

        // Create metadata for the shield action extension
        let metadata = ShieldMetadata(
            bundleIdentifier: bundleIdentifier,
            appName: appName,
            category: categoryName,
            selectedIntention: selectedIntention,
            isFromCategory: isFromCategory
        )

        // Save metadata for the shield action extension to use
        dataManager.saveShieldMetadata(bundleIdentifier: bundleIdentifier, metadata: metadata)

        // Create dynamic title and subtitle
        let title = getShieldTitle(appName: appName, isWebDomain: isWebDomain)
        let subtitle = getShieldSubtitle(
            intention: selectedIntention,
            appName: appName,
            isFromCategory: isFromCategory,
            categoryName: categoryName
        )

        // Create a proper shield configuration with ShieldConfiguration.Label
        let config = ShieldConfiguration(
            title: ShieldConfiguration.Label(text: title, color: .label),
            subtitle: ShieldConfiguration.Label(text: subtitle, color: .secondaryLabel),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Continue to App", color: .systemBlue),
            secondaryButtonLabel: ShieldConfiguration.Label(text: "Start Intention", color: .systemGreen)
        )

        // Log shield configuration details for debugging
        print("🛡️ Shield configuration created for \(bundleIdentifier)")
        print("🛡️ Title: \(title)")
        print("🛡️ Subtitle: \(subtitle)")
        print("🛡️ Selected intention: \(selectedIntention?.name ?? "None")")

        return config
    }

    // MARK: - Dynamic Content Generation
    private func getShieldTitle(appName: String?, isWebDomain: Bool) -> String {
        if isWebDomain, let domain = appName {
            return "Pause before accessing \(domain)"
        } else if let app = appName {
            return "Pause before opening \(app)"
        } else {
            return "ScreenGate"
        }
    }

    private func getShieldSubtitle(
        intention: IntentionInfo?,
        appName: String?,
        isFromCategory: Bool,
        categoryName: String?
    ) -> String {
        guard let intention = intention else {
            return "Take a mindful moment before continuing"
        }

        let appText = appName != nil ? "before opening \(appName!)" : ""
        let categoryText = categoryName != nil ? "in the \(categoryName!) category" : ""
        let contextText = appText.isEmpty ? categoryText : appText

        return "Try '\(intention.name)' (\(Int(intention.duration / 60)) min) \(contextText)"
    }

    // MARK: - Helper Methods
    private func getAppName(from bundleIdentifier: String) -> String {
        // Extract app name from bundle identifier
        let components = bundleIdentifier.components(separatedBy: ".")
        return components.last ?? bundleIdentifier
    }

    private func getCategoryName(from category: ActivityCategory) -> String {
        // Convert ActivityCategory to readable name
        // Note: ActivityCategory enum may have different cases in current iOS
        return String(describing: category).replacingOccurrences(of: "ActivityCategory.", with: "")
    }
}

// Note: All intention models are imported from the main app through the module
// The ShieldConfigurationExtension has access to the same models as the main app
