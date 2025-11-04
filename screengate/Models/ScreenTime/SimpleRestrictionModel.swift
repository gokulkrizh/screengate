//
//  SimpleRestrictionModel.swift
//  screengate
//
//  Created by Claude on 11/03/25.
//

import Foundation

// MARK: - Simplified Restriction Model for Shield Extension Communication
struct SimpleRestriction: Codable {
    let bundleIdentifier: String
    let appName: String
    let intentionId: String
    let intentionName: String
    let intentionCategory: String
    let intentionDuration: TimeInterval

    init(
        bundleIdentifier: String,
        appName: String,
        intentionId: String,
        intentionName: String,
        intentionCategory: String,
        intentionDuration: TimeInterval
    ) {
        self.bundleIdentifier = bundleIdentifier
        self.appName = appName
        self.intentionId = intentionId
        self.intentionName = intentionName
        self.intentionCategory = intentionCategory
        self.intentionDuration = intentionDuration
    }

    // Convert from full AppRestriction to SimpleRestriction
    init(from restriction: AppRestriction) {
        self.bundleIdentifier = restriction.bundleIdentifier
        self.appName = restriction.name

        if let intention = restriction.intentionAssignments.first {
            self.intentionId = intention.id
            self.intentionName = intention.title
            self.intentionCategory = intention.category.rawValue
            self.intentionDuration = intention.duration
        } else {
            self.intentionId = "mindful-pause"
            self.intentionName = "Mindful Pause"
            self.intentionCategory = "mindfulness"
            self.intentionDuration = 60
        }
    }
}