import Foundation
import FamilyControls
import Combine

// MARK: - App Restriction Model

struct AppRestriction: Codable, Identifiable {
    let id: String
    var name: String
    var bundleIdentifier: String
    var appToken: Data? // Encoded ApplicationToken
    var categoryToken: Data? // Encoded CategoryToken
    var isEnabled: Bool
    var restrictionType: RestrictionType
    var intentionAssignments: [IntentionActivity]
    var schedules: [RestrictionSchedule]
    var createdAt: Date
    var updatedAt: Date
    var lastTriggered: Date?
    var triggerCount: Int

    // MARK: - Initialization
    init(
        id: String = UUID().uuidString,
        name: String,
        bundleIdentifier: String,
        appToken: Data? = nil,
        categoryToken: Data? = nil,
        isEnabled: Bool = true,
        restrictionType: RestrictionType = .intention,
        intentionAssignments: [IntentionActivity] = [],
        schedules: [RestrictionSchedule] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        lastTriggered: Date? = nil,
        triggerCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.bundleIdentifier = bundleIdentifier
        self.appToken = appToken
        self.categoryToken = categoryToken
        self.isEnabled = isEnabled
        self.restrictionType = restrictionType
        self.intentionAssignments = intentionAssignments
        self.schedules = schedules
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastTriggered = lastTriggered
        self.triggerCount = triggerCount
    }

    // MARK: - Computed Properties
    var isActive: Bool {
        guard isEnabled else { return false }
        return schedules.contains { $0.isActiveNow }
    }

    var nextScheduledRestriction: Date? {
        return schedules
            .compactMap { $0.nextStartTime }
            .sorted()
            .first
    }

    var primaryIntention: IntentionActivity? {
        return intentionAssignments.first
    }

    var restrictionLevel: RestrictionLevel {
        switch restrictionType {
        case .intention: return .soft
        case .timeLimited: return .moderate
        case .blocked: return .hard
        }
    }

    var averageDailyTriggers: Double {
        guard let daysSinceCreation = Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day, daysSinceCreation > 0 else {
            return Double(triggerCount)
        }
        return Double(triggerCount) / Double(daysSinceCreation)
    }

    // MARK: - Methods
    mutating func recordTrigger() {
        lastTriggered = Date()
        triggerCount += 1
        updatedAt = Date()
    }

    mutating func updateIntentionAssignments(_ intentions: [IntentionActivity]) {
        intentionAssignments = intentions
        updatedAt = Date()
    }

    mutating func addSchedule(_ schedule: RestrictionSchedule) {
        schedules.append(schedule)
        updatedAt = Date()
    }

    mutating func removeSchedule(scheduleId: String) {
        schedules.removeAll { $0.id == scheduleId }
        updatedAt = Date()
    }

    mutating func toggleEnabled() {
        isEnabled.toggle()
        updatedAt = Date()
    }
}

// MARK: - Restriction Type

enum RestrictionType: String, Codable, CaseIterable {
    case intention = "intention"
    case timeLimited = "timeLimited"
    case blocked = "blocked"

    var displayName: String {
        switch self {
        case .intention: return "Intention Required"
        case .timeLimited: return "Time Limited"
        case .blocked: return "Blocked"
        }
    }

    var description: String {
        switch self {
        case .intention: return "User must complete an intention activity before accessing the app"
        case .timeLimited: return "App is accessible for limited time periods"
        case .blocked: return "App is completely blocked during specified times"
        }
    }

    var iconName: String {
        switch self {
        case .intention: return "brain.head.profile"
        case .timeLimited: return "clock"
        case .blocked: return "xmark.circle.fill"
        }
    }

    var color: String {
        switch self {
        case .intention: return "blue"
        case .timeLimited: return "orange"
        case .blocked: return "red"
        }
    }
}

// MARK: - Restriction Level

enum RestrictionLevel: String, Codable, CaseIterable {
    case soft = "soft"
    case moderate = "moderate"
    case hard = "hard"

    var displayName: String {
        switch self {
        case .soft: return "Soft"
        case .moderate: return "Moderate"
        case .hard: return "Hard"
        }
    }

    var description: String {
        switch self {
        case .soft: return "Gentle reminders and optional intentions"
        case .moderate: return "Required intentions with flexibility"
        case .hard: return "Strict blocking with minimal exceptions"
        }
    }

    var priority: Int {
        switch self {
        case .soft: return 1
        case .moderate: return 2
        case .hard: return 3
        }
    }
}

// MARK: - App Category

enum AppCategory: String, Codable, CaseIterable, Identifiable {
    case social = "social"
    case entertainment = "entertainment"
    case productivity = "productivity"
    case games = "games"
    case news = "news"
    case shopping = "shopping"
    case health = "health"
    case education = "education"
    case finance = "finance"
    case utilities = "utilities"
    case other = "other"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .social: return "Social Media"
        case .entertainment: return "Entertainment"
        case .productivity: return "Productivity"
        case .games: return "Games"
        case .news: return "News"
        case .shopping: return "Shopping"
        case .health: return "Health & Fitness"
        case .education: return "Education"
        case .finance: return "Finance"
        case .utilities: return "Utilities"
        case .other: return "Other"
        }
    }

    var iconName: String {
        switch self {
        case .social: return "person.2.fill"
        case .entertainment: return "tv.fill"
        case .productivity: return "briefcase.fill"
        case .games: return "gamecontroller.fill"
        case .news: return "newspaper.fill"
        case .shopping: return "cart.fill"
        case .health: return "heart.fill"
        case .education: return "book.fill"
        case .finance: return "dollarsign.circle.fill"
        case .utilities: return "wrench.and.screwdriver.fill"
        case .other: return "app.fill"
        }
    }

    var color: String {
        switch self {
        case .social: return "blue"
        case .entertainment: return "purple"
        case .productivity: return "green"
        case .games: return "orange"
        case .news: return "red"
        case .shopping: return "pink"
        case .health: return "mint"
        case .education: return "indigo"
        case .finance: return "yellow"
        case .utilities: return "gray"
        case .other: return "secondary"
        }
    }

    var defaultRestrictionType: RestrictionType {
        switch self {
        case .social, .entertainment, .games:
            return .intention
        case .shopping:
            return .timeLimited
        case .news:
            return .timeLimited
        case .productivity, .health, .education, .finance, .utilities:
            return .intention
        case .other:
            return .intention
        }
    }

    var recommendedIntentionCategories: [IntentionCategory] {
        switch self {
        case .social, .entertainment:
            return [.mindfulness, .reflection, .breathing]
        case .games:
            return [.movement, .quickBreak, .breathing]
        case .news, .shopping:
            return [.mindfulness, .reflection, .breathing]
        case .productivity:
            return [.quickBreak, .breathing, .movement]
        case .health, .education:
            return [.mindfulness, .reflection]
        case .finance:
            return [.breathing, .mindfulness]
        case .utilities:
            return [.quickBreak]
        case .other:
            return [.breathing, .quickBreak]
        }
    }
}

// MARK: - App Restriction Manager

class AppRestrictionManager: ObservableObject {
    @Published var restrictions: [AppRestriction] = []
    @Published var categoryRestrictions: [CategoryRestriction] = []

    private let userDefaults = UserDefaults.standard
    private let restrictionsKey = "AppRestrictions"
    private let categoryRestrictionsKey = "CategoryRestrictions"

    init() {
        loadRestrictions()
        loadCategoryRestrictions()
    }

    // MARK: - App Restriction Management
    func addRestriction(_ restriction: AppRestriction) {
        if let index = restrictions.firstIndex(where: { $0.id == restriction.id }) {
            restrictions[index] = restriction
        } else {
            restrictions.append(restriction)
        }
        saveRestrictions()
    }

    func removeRestriction(withId id: String) {
        restrictions.removeAll { $0.id == id }
        saveRestrictions()
    }

    func updateRestriction(_ restriction: AppRestriction) {
        addRestriction(restriction) // Handles both add and update
    }

    func getRestriction(for bundleIdentifier: String) -> AppRestriction? {
        return restrictions.first { $0.bundleIdentifier == bundleIdentifier && $0.isEnabled }
    }

    func getActiveRestrictions() -> [AppRestriction] {
        return restrictions.filter { $0.isActive }
    }

    func getRestrictionsByCategory(_ category: AppCategory) -> [AppRestriction] {
        return restrictions.filter { restriction in
            AppInfoProvider.getCategory(for: restriction.bundleIdentifier) == category
        }
    }

    // MARK: - Category Restriction Management
    func addCategoryRestriction(_ restriction: CategoryRestriction) {
        if let index = categoryRestrictions.firstIndex(where: { $0.category == restriction.category }) {
            categoryRestrictions[index] = restriction
        } else {
            categoryRestrictions.append(restriction)
        }
        saveCategoryRestrictions()
    }

    func removeCategoryRestriction(category: AppCategory) {
        categoryRestrictions.removeAll { $0.category == category }
        saveCategoryRestrictions()
    }

    func getCategoryRestriction(for category: AppCategory) -> CategoryRestriction? {
        return categoryRestrictions.first { $0.category == category && $0.isEnabled }
    }

    // MARK: - Batch Operations
    func enableAllRestrictions() {
        for index in restrictions.indices {
            restrictions[index].isEnabled = true
        }
        saveRestrictions()
    }

    func disableAllRestrictions() {
        for index in restrictions.indices {
            restrictions[index].isEnabled = false
        }
        saveRestrictions()
    }

    func createRestrictionFromSelection(
        selection: FamilyActivitySelection,
        intentionAssignments: [IntentionActivity] = [],
        schedules: [RestrictionSchedule] = []
    ) {
        // Note: The following code is commented out due to API compatibility issues
        // Process individual apps would need proper API implementation
        // for appToken in selection.applicationTokens {
        //     let appInfo = AppInfoProvider.getAppInfo(for: appToken)
        //     let restriction = AppRestriction(
        //         name: appInfo.name,
        //         bundleIdentifier: appInfo.bundleIdentifier,
        //         appToken: try? JSONEncoder().encode(appToken),
        //         intentionAssignments: intentionAssignments,
        //         schedules: schedules
        //     )
        //     addRestriction(restriction)
        // }

        // Process categories would need proper API implementation
        // for categoryToken in selection.categoryTokens {
        //     let categoryInfo = AppInfoProvider.getCategoryInfo(for: categoryToken)
        //     let categoryRestriction = CategoryRestriction(
        //         category: AppInfoProvider.getAppCategory(from: categoryInfo.name),
        //         categoryToken: try? JSONEncoder().encode(categoryToken),
        //         intentionAssignments: intentionAssignments,
        //         schedules: schedules
        //     )
        //     addCategoryRestriction(categoryRestriction)
        // }

        // Placeholder implementation
        print("Creating restrictions from selection: \(selection.displayName)")
    }

    // MARK: - Analytics
    func getRestrictionAnalytics() -> RestrictionAnalytics {
        let totalRestrictions = restrictions.count + categoryRestrictions.count
        let activeRestrictions = restrictions.filter { $0.isActive }.count + categoryRestrictions.filter { $0.isActive }.count
        let totalTriggers = restrictions.reduce(0) { $0 + $1.triggerCount }
        let mostTriggered = restrictions.max { $0.triggerCount < $1.triggerCount }

        return RestrictionAnalytics(
            totalRestrictions: totalRestrictions,
            activeRestrictions: activeRestrictions,
            totalTriggers: totalTriggers,
            mostTriggeredApp: mostTriggered?.name,
            averageDailyTriggers: restrictions.reduce(0.0) { $0 + $1.averageDailyTriggers }
        )
    }

    // MARK: - Data Persistence
    private func loadRestrictions() {
        if let data = userDefaults.data(forKey: restrictionsKey),
           let loadedRestrictions = try? JSONDecoder().decode([AppRestriction].self, from: data) {
            restrictions = loadedRestrictions
        }
    }

    private func saveRestrictions() {
        if let data = try? JSONEncoder().encode(restrictions) {
            userDefaults.set(data, forKey: restrictionsKey)
        }
    }

    private func loadCategoryRestrictions() {
        if let data = userDefaults.data(forKey: categoryRestrictionsKey),
           let loadedRestrictions = try? JSONDecoder().decode([CategoryRestriction].self, from: data) {
            categoryRestrictions = loadedRestrictions
        }
    }

    private func saveCategoryRestrictions() {
        if let data = try? JSONEncoder().encode(categoryRestrictions) {
            userDefaults.set(data, forKey: categoryRestrictionsKey)
        }
    }
}

// MARK: - Category Restriction

struct CategoryRestriction: Codable, Identifiable {
    let id = UUID().uuidString
    let category: AppCategory
    var categoryToken: Data?
    var isEnabled: Bool
    var intentionAssignments: [IntentionActivity]
    var schedules: [RestrictionSchedule]
    var createdAt: Date
    var updatedAt: Date

    init(
        category: AppCategory,
        categoryToken: Data? = nil,
        isEnabled: Bool = true,
        intentionAssignments: [IntentionActivity] = [],
        schedules: [RestrictionSchedule] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.category = category
        self.categoryToken = categoryToken
        self.isEnabled = isEnabled
        self.intentionAssignments = intentionAssignments
        self.schedules = schedules
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var isActive: Bool {
        guard isEnabled else { return false }
        return schedules.contains { $0.isActiveNow }
    }
}

// MARK: - Analytics

struct RestrictionAnalytics: Codable {
    let totalRestrictions: Int
    let activeRestrictions: Int
    let totalTriggers: Int
    let mostTriggeredApp: String?
    let averageDailyTriggers: Double

    var effectiveness: Double {
        guard totalRestrictions > 0 else { return 0 }
        return Double(activeRestrictions) / Double(totalRestrictions)
    }
}

// MARK: - App Info Provider (Placeholder)

class AppInfoProvider {
    // Note: ApplicationToken and CategoryToken may not be directly available in current FamilyControls framework
    // These methods are placeholders for potential future API availability

    // static func getAppInfo(for token: ApplicationToken) -> (name: String, bundleIdentifier: String) {
    //     // This would integrate with actual app info APIs
    //     // For now, return placeholder data
    //     return ("Sample App", "com.example.app")
    // }

    // static func getCategoryInfo(for token: CategoryToken) -> (name: String) {
    //     // This would integrate with actual category info APIs
    //     return ("Social")
    // }

    static func getCategory(for bundleIdentifier: String) -> AppCategory {
        // This would determine the category based on bundle identifier
        // For now, return basic categorization
        if bundleIdentifier.contains("facebook") || bundleIdentifier.contains("instagram") {
            return .social
        } else if bundleIdentifier.contains("netflix") || bundleIdentifier.contains("youtube") {
            return .entertainment
        } else if bundleIdentifier.contains("game") {
            return .games
        } else {
            return .other
        }
    }

    static func getAppCategory(from categoryName: String) -> AppCategory {
        switch categoryName.lowercased() {
        case "social": return .social
        case "entertainment": return .entertainment
        case "games": return .games
        case "productivity": return .productivity
        default: return .other
        }
    }
}