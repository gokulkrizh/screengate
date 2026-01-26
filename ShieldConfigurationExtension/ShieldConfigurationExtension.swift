//
//  ShieldConfigurationExtension.swift
//  ShieldConfigurationExtension
//
//  Created by Gokul on 2025/11/05.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit
import Foundation

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    private let userDefaults = UserDefaults(suiteName: "group.com.gia.screendiet")
    private let jsonDecoder = JSONDecoder()
    
    // MARK: - Helpers
    
    /// Get active block name from UserDefaults
    private func getActiveBlockName() -> String {
        guard let userDefaults = userDefaults,
              let activeBlockData = userDefaults.data(forKey: "activeBlock") else {
            return "Focus Session"
        }
        
        do {
            let decoded = try jsonDecoder.decode([String: AnyCodable].self, from: activeBlockData)
            let name = (decoded["name"] as? String) ?? "Focus Session"
            return name
        } catch {
            print("Error decoding block name: \(error)")
            return "Focus Session"
        }
    }
    
    /// Get strict mode from active block
    private func getStrictMode() -> String {
        guard let userDefaults = userDefaults,
              let activeBlockData = userDefaults.data(forKey: "activeBlock") else {
            return "medium"
        }
        
        do {
            let decoded = try jsonDecoder.decode([String: AnyCodable].self, from: activeBlockData)
            let strictMode = (decoded["strictMode"] as? String) ?? "medium"
            return strictMode
        } catch {
            print("Error decoding strict mode: \(error)")
            return "medium"
        }
    }
    
    /// Create appropriate shield configuration based on strict mode
    private func createShieldConfiguration(for strictMode: String, blockName: String) -> ShieldConfiguration {
        let blockTitle = "Focus: \(blockName)"
        
        switch strictMode {
        case "easy":
            // Easy mode: user-friendly, can dismiss easily
            return ShieldConfiguration(
                backgroundBlurStyle: .systemMaterialDark,
                backgroundColor: UIColor(red: 0.1, green: 0.12, blue: 0.15, alpha: 0.95),
                icon: UIImage(systemName: "focus")?.withTintColor(UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0), renderingMode: .alwaysTemplate),
                title: .init(text: blockTitle, color: UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0)),
                subtitle: .init(text: "You're in focus mode. Tap to dismiss.", color: UIColor.white.withAlphaComponent(0.7)),
                primaryButtonLabel: .init(text: "Got it", color: .white),
                primaryButtonBackgroundColor: UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0),
                secondaryButtonLabel: .init(text: "End Session", color: UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0))
            )
            
        case "medium":
            // Medium mode: requires confirmation
            return ShieldConfiguration(
                backgroundBlurStyle: .systemMaterialDark,
                backgroundColor: UIColor(red: 0.15, green: 0.12, blue: 0.1, alpha: 0.95),
                icon: UIImage(systemName: "exclamationmark.circle.fill")?.withTintColor(UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0), renderingMode: .alwaysTemplate),
                title: .init(text: blockTitle, color: UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)),
                subtitle: .init(text: "Confirm before dismissing this shield.", color: UIColor.white.withAlphaComponent(0.7)),
                primaryButtonLabel: .init(text: "Confirm Dismiss", color: .white),
                primaryButtonBackgroundColor: UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0),
                secondaryButtonLabel: .init(text: "Ask to Remove", color: UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0))
            )
            
        case "hard":
            // Hard mode: cannot dismiss easily
            return ShieldConfiguration(
                backgroundBlurStyle: .systemMaterialDark,
                backgroundColor: UIColor(red: 0.2, green: 0.08, blue: 0.08, alpha: 0.95),
                icon: UIImage(systemName: "lock.fill")?.withTintColor(UIColor.systemRed, renderingMode: .alwaysTemplate),
                title: .init(text: blockTitle, color: UIColor.systemRed),
                subtitle: .init(text: "Hard mode: You cannot dismiss this shield. Stay focused!", color: UIColor.white.withAlphaComponent(0.7)),
                primaryButtonLabel: .init(text: "Acknowledge", color: .white),
                primaryButtonBackgroundColor: UIColor.systemRed,
                secondaryButtonLabel: .init(text: "Contact Support", color: UIColor.systemRed)
            )
            
        default:
            // Default to medium
            return ShieldConfiguration(
                backgroundBlurStyle: .systemMaterialDark,
                backgroundColor: UIColor(red: 0.15, green: 0.12, blue: 0.1, alpha: 0.95),
                icon: UIImage(systemName: "focus")?.withTintColor(UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0), renderingMode: .alwaysTemplate),
                title: .init(text: blockTitle, color: UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0)),
                subtitle: .init(text: "You're in focus mode.", color: UIColor.white.withAlphaComponent(0.7)),
                primaryButtonLabel: .init(text: "Dismiss", color: .white),
                primaryButtonBackgroundColor: UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0),
                secondaryButtonLabel: .init(text: "More Options", color: UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0))
            )
        }
    }
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Customize the shield as needed for applications.
        let blockName = getActiveBlockName()
        let strictMode = getStrictMode()
        return createShieldConfiguration(for: strictMode, blockName: blockName)
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for applications shielded because of their category.
        let blockName = getActiveBlockName()
        let strictMode = getStrictMode()
        return createShieldConfiguration(for: strictMode, blockName: blockName)
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        // Customize the shield as needed for web domains.
        let blockName = getActiveBlockName()
        let strictMode = getStrictMode()
        return createShieldConfiguration(for: strictMode, blockName: blockName)
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for web domains shielded because of their category.
        let blockName = getActiveBlockName()
        let strictMode = getStrictMode()
        return createShieldConfiguration(for: strictMode, blockName: blockName)
    }
}

// Helper to decode AnyCodable values
struct AnyCodable: Codable {
    let value: Any
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intVal = try? container.decode(Int.self) {
            value = intVal
        } else if let boolVal = try? container.decode(Bool.self) {
            value = boolVal
        } else if let stringVal = try? container.decode(String.self) {
            value = stringVal
        } else if let doubleVal = try? container.decode(Double.self) {
            value = doubleVal
        } else if let dateVal = try? container.decode(Date.self) {
            value = dateVal
        } else if let dictVal = try? container.decode([String: AnyCodable].self) {
            value = dictVal
        } else if let arrayVal = try? container.decode([AnyCodable].self) {
            value = arrayVal
        } else {
            value = NSNull()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let intVal as Int:
            try container.encode(intVal)
        case let boolVal as Bool:
            try container.encode(boolVal)
        case let stringVal as String:
            try container.encode(stringVal)
        case let doubleVal as Double:
            try container.encode(doubleVal)
        case let dateVal as Date:
            try container.encode(dateVal)
        case let dictVal as [String: AnyCodable]:
            try container.encode(dictVal)
        case let arrayVal as [AnyCodable]:
            try container.encode(arrayVal)
        default:
            try container.encodeNil()
        }
    }
    

}

