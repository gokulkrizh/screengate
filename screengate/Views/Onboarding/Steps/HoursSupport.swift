import SwiftUI

// MARK: - Shared helpers for the Recipe-chapter steps (Hours, Night Fast, Reminders, Recipe, Ready)

enum OnboardingFormat {
    /// "12 PM" / "12:30 PM" — compact clock label used on cards and the recipe.
    static func compactTime(hour: Int, minute: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let h = hour % 12 == 0 ? 12 : hour % 12
        return minute == 0 ? "\(h) \(period)" : "\(h):\(String(format: "%02d", minute)) \(period)"
    }

    /// Display name for the v2 plan labels (spec §9).
    static func planName(_ plan: DietPlan?) -> String {
        switch plan ?? .lean {
        case .lean: "Balanced"
        case .keto: "Maker"
        case .detox: "Reset"
        case .custom: "Custom"
        }
    }
}

extension OnboardingData {
    var eatingWindowValue: EatingWindow {
        EatingWindow(startHour: windowStartHour, startMinute: windowStartMinute, endHour: windowEndHour, endMinute: windowEndMinute)
    }

    /// Night Fast from the user's choice: starts at `nightLock…` (10 PM) and ends 7 AM. If that would overlap
    /// the kitchen hours, it falls back to the complementary arc (kitchen closes → kitchen opens).
    func resolvedNightFast(enabled: Bool? = nil) -> NightFast {
        var night = NightFast(isEnabled: enabled ?? nightFastEnabled, startHour: nightLockHour, startMinute: nightLockMinute, endHour: 7, endMinute: 0)
        let window = eatingWindowValue
        if night.durationMinutes < 15 || DietRules.windowsOverlap(window, night) {
            night.startHour = window.endHour; night.startMinute = window.endMinute
            night.endHour = window.startHour; night.endMinute = window.startMinute
        }
        return night
    }
}
