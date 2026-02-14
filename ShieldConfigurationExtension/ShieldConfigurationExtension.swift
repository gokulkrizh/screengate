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

class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    private let userDefaults = UserDefaults(suiteName: "group.com.gia.screendiet")
    private let jsonDecoder = JSONDecoder()

    // MARK: - Theme Colors

    private let backgroundColor = UIColor(red: 0.06, green: 0.06, blue: 0.08, alpha: 1.0) // #0F1014
    private let primaryGreen = UIColor(red: 0.0, green: 1.0, blue: 0.39, alpha: 1.0)       // #00FF63
    private let warningYellow = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
    private let errorRed = UIColor.systemRed
    private let textWhite = UIColor.white
    private let textSecondary = UIColor.white.withAlphaComponent(0.6)

    // MARK: - Helpers

    private func getCurrentShieldType() -> String {
        return userDefaults?.string(forKey: "currentShieldType") ?? "kitchenClosed"
    }

    private func getCarbsUsedToday() -> Int {
        return userDefaults?.integer(forKey: "carbsUsedToday") ?? 0
    }

    private func getDailyCarbLimit() -> Int {
        guard let userDefaults = userDefaults,
              let data = userDefaults.data(forKey: "dietProfile"),
              let profile = try? jsonDecoder.decode(DietProfileLight.self, from: data) else {
            return 60
        }
        return profile.eatingWindow.dailyCarbLimitMinutes
    }

    private func getWindowEndHour() -> Int {
        guard let userDefaults = userDefaults,
              let data = userDefaults.data(forKey: "dietProfile"),
              let profile = try? jsonDecoder.decode(DietProfileLight.self, from: data) else {
            return 18
        }
        return profile.eatingWindow.endHour
    }

    private func isCheatMealActive() -> Bool {
        guard let userDefaults = userDefaults else { return false }
        let active = userDefaults.bool(forKey: "cheatMealActive")
        if active, let expires = userDefaults.object(forKey: "cheatMealExpires") as? Date {
            return expires > Date()
        }
        return false
    }

    private func getCheatsRemaining() -> Int {
        guard let userDefaults = userDefaults,
              let data = userDefaults.data(forKey: "dietProfile"),
              let profile = try? jsonDecoder.decode(DietProfileLight.self, from: data) else {
            return 0
        }
        // Use the max of the dedicated key and the profile value
        let cheatsUsedKey = userDefaults.integer(forKey: "cheatsUsedThisWeek")
        let actualUsed = max(cheatsUsedKey, profile.cheatsUsedThisWeek)
        return max(0, profile.weeklyCheatMeals - actualUsed)
    }

    private func formatHour(_ hour: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return "\(displayHour):00 \(period)"
    }

    // MARK: - Shield Configuration

    private func createShieldConfiguration(for shieldType: String) -> ShieldConfiguration {
        switch shieldType {
        case "kitchenClosed":
            return kitchenClosedShield()
        case "portionTimer":
            return portionTimerShield()
        case "dailyLimitReached":
            return dailyLimitReachedShield()
        case "proteinApp":
            return proteinAppShield()
        case "carbCurfew":
            return carbCurfewShield()
        case "nightLock":
            return nightLockShield()
        default:
            return kitchenClosedShield()
        }
    }

    private func kitchenClosedShield() -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterialDark,
            backgroundColor: backgroundColor,
            icon: UIImage(systemName: "moon.fill")?.withTintColor(warningYellow, renderingMode: .alwaysOriginal),
            title: .init(text: "KITCHEN CLOSED", color: warningYellow),
            subtitle: .init(text: "You're fasting. Protein apps are always available.", color: textSecondary),
            primaryButtonLabel: .init(text: "Close", color: backgroundColor),
            primaryButtonBackgroundColor: primaryGreen,
            secondaryButtonLabel: getCheatsRemaining() > 0
                ? .init(text: "Cheat Meal (\(getCheatsRemaining()) left)", color: warningYellow)
                : .init(text: "No Cheats Left", color: textSecondary)
        )
    }

    private func portionTimerShield() -> ShieldConfiguration {
        let used = getCarbsUsedToday()
        let limit = getDailyCarbLimit()
        let remaining = max(0, limit - used)

        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterialDark,
            backgroundColor: backgroundColor,
            icon: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(primaryGreen, renderingMode: .alwaysOriginal),
            title: .init(text: "KITCHEN OPEN", color: primaryGreen),
            subtitle: .init(text: "\(remaining) min remaining today (\(used)/\(limit) used)", color: textSecondary),
            primaryButtonLabel: .init(text: "Open App", color: backgroundColor),
            primaryButtonBackgroundColor: primaryGreen,
            secondaryButtonLabel: .init(text: "Close", color: primaryGreen)
        )
    }

    private func dailyLimitReachedShield() -> ShieldConfiguration {
        let limit = getDailyCarbLimit()
        let windowEnd = formatHour(getWindowEndHour())

        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterialDark,
            backgroundColor: backgroundColor,
            icon: UIImage(systemName: "exclamationmark.octagon.fill")?.withTintColor(errorRed, renderingMode: .alwaysOriginal),
            title: .init(text: "DAILY LIMIT REACHED", color: errorRed),
            subtitle: .init(text: "\(limit)/\(limit) min consumed. Try protein or fiber apps instead.", color: textSecondary),
            primaryButtonLabel: .init(text: "Close", color: backgroundColor),
            primaryButtonBackgroundColor: errorRed,
            secondaryButtonLabel: getCheatsRemaining() > 0
                ? .init(text: "Cheat Meal (\(getCheatsRemaining()) left)", color: warningYellow)
                : .init(text: "No Cheats Left", color: textSecondary)
        )
    }

    private func proteinAppShield() -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterialDark,
            backgroundColor: backgroundColor,
            icon: UIImage(systemName: "star.fill")?.withTintColor(primaryGreen, renderingMode: .alwaysOriginal),
            title: .init(text: "ALWAYS AVAILABLE", color: primaryGreen),
            subtitle: .init(text: "Protein apps are unlimited. Create something!", color: textSecondary),
            primaryButtonLabel: .init(text: "Open App", color: backgroundColor),
            primaryButtonBackgroundColor: primaryGreen,
            secondaryButtonLabel: .init(text: "Close", color: primaryGreen)
        )
    }

    private func carbCurfewShield() -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterialDark,
            backgroundColor: backgroundColor,
            icon: UIImage(systemName: "clock.badge.exclamationmark.fill")?.withTintColor(errorRed, renderingMode: .alwaysOriginal),
            title: .init(text: "CARB CURFEW", color: errorRed),
            subtitle: .init(text: "The eating window has closed. Save this for tomorrow.", color: textSecondary),
            primaryButtonLabel: .init(text: "Close", color: backgroundColor),
            primaryButtonBackgroundColor: errorRed,
            secondaryButtonLabel: getCheatsRemaining() > 0
                ? .init(text: "Cheat Meal (\(getCheatsRemaining()) left)", color: warningYellow)
                : .init(text: "No Cheats Left", color: textSecondary)
        )
    }

    private func nightLockShield() -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterialDark,
            backgroundColor: backgroundColor,
            icon: UIImage(systemName: "moon.zzz.fill")?.withTintColor(UIColor.systemPurple, renderingMode: .alwaysOriginal),
            title: .init(text: "NIGHT LOCK ACTIVE", color: UIColor.systemPurple),
            subtitle: .init(text: "Only protein apps are available during night lock. Rest well.", color: textSecondary),
            primaryButtonLabel: .init(text: "Close", color: textWhite),
            primaryButtonBackgroundColor: UIColor.systemPurple,
            secondaryButtonLabel: .init(text: "Emergency Access", color: UIColor.systemPurple)
        )
    }

    // MARK: - ShieldConfigurationDataSource

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        let shieldType = getCurrentShieldType()
        return createShieldConfiguration(for: shieldType)
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        let shieldType = getCurrentShieldType()
        return createShieldConfiguration(for: shieldType)
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        let shieldType = getCurrentShieldType()
        return createShieldConfiguration(for: shieldType)
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        let shieldType = getCurrentShieldType()
        return createShieldConfiguration(for: shieldType)
    }
}

// MARK: - Lightweight Codable for Extension

/// Lightweight struct to decode diet profile in extensions (avoids importing full model)
private struct DietProfileLight: Codable {
    var dietType: String
    var eatingWindow: EatingWindowLight
    var nightLockHour: Int
    var nightLockMinute: Int
    var weeklyCheatMeals: Int
    var cheatsUsedThisWeek: Int
    var isActive: Bool

    enum CodingKeys: String, CodingKey {
        case dietType, eatingWindow, nightLockHour, nightLockMinute
        case weeklyCheatMeals, cheatsUsedThisWeek, isActive
    }
}

private struct EatingWindowLight: Codable {
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    var dailyCarbLimitMinutes: Int
}
