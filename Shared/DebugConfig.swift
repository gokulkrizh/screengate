//
//  DebugConfig.swift
//  Shared
//
//  Development-only overrides for durations that would otherwise make on-device
//  testing slow (a full diet cycle takes a day) or leak test values into release.
//
//  Rule: release builds must never contain the short test durations.
//

import Foundation

enum DebugConfig {
    /// Default carb portion for a new profile (production: 45 min).
    static let defaultPortionMinutes = minutes(production: 45, debug: 6)

    /// Relaxed portion used by lighter plans (production: 90 min).
    static let relaxedPortionMinutes = minutes(production: 90, debug: 6)

    /// How long a cheat meal lifts restrictions (production: 30 min).
    static let cheatMealMinutes = minutes(production: 30, debug: 6)

    private static func minutes(production: Int, debug: Int) -> Int {
        #if DEBUG
        return debug
        #else
        return production
        #endif
    }
}
