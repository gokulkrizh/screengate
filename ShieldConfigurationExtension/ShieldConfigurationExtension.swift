//
//  ShieldConfigurationExtension.swift
//  ShieldConfigurationExtension
//
//  Created by Gokul on 2025/11/05.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

/// Configures the appearance of Shield screens shown when protected apps are blocked
/// Returns custom messages based on intervention type and user settings
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    private let sharedManager = SharedContainerManager.shared
    
    // MARK: - App Blocking Shield
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        let appName = application.localizedDisplayName ?? "App"
        return createBlockShield(for: appName)
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        let appName = application.localizedDisplayName ?? "App"
        return createBlockShield(for: appName)
    }
    
    // MARK: - Web Domain Blocking Shield
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        let domain = webDomain.domain ?? "Website"
        return createBlockShield(for: domain)
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        let domain = webDomain.domain ?? "Website"
        return createBlockShield(for: domain)
    }
    
    // MARK: - Private Methods
    
    /// Create a block shield with app-specific messaging
    private func createBlockShield(for appName: String) -> ShieldConfiguration {
        // Check if user is in active session
        let isInSession = sharedManager.isSessionValid()
        
        let title: String
        let subtitle: String
        let primaryButtonText = "I Got It"
        
        if isInSession {
            title = "🎯 Focus Session Active"
            subtitle = "\(appName) is blocked until your session ends"
        } else {
            title = "🛑 \(appName) is Blocked"
            subtitle = "You're protecting your focus. Stay strong!"
        }
        
        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterial,
            backgroundColor: UIColor(red: 0.06, green: 0.08, blue: 0.16, alpha: 0.95), // Dark #0A0E27
            icon: UIImage(systemName: "shield.fill")?.withTintColor(UIColor(red: 0.42, green: 0.39, blue: 1.0, alpha: 1.0)), // Purple
            title: .init(text: title, color: UIColor.white),
            subtitle: .init(text: subtitle, color: UIColor(red: 0.73, green: 0.72, blue: 0.82, alpha: 1.0)), // Secondary text
            primaryButtonLabel: .init(text: primaryButtonText, color: UIColor.white),
            primaryButtonBackgroundColor: UIColor(red: 0.42, green: 0.39, blue: 1.0, alpha: 1.0), // Purple #6C63FF
            secondaryButtonLabel: .init(text: "Need a break?", color: UIColor(red: 0.42, green: 0.39, blue: 1.0, alpha: 1.0))
        )
    }
}
