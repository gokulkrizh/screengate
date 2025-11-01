import Foundation
import Combine
import ManagedSettings

// MARK: - Website Restriction Model

struct WebsiteRestriction: Codable, Identifiable {
    let id: String
    var name: String
    var domain: String
    var urlPattern: String
    var category: WebsiteCategory
    var isEnabled: Bool
    var restrictionType: RestrictionType
    var intentionAssignments: [IntentionActivity]
    var schedules: [RestrictionSchedule]
    var createdAt: Date
    var updatedAt: Date
    var lastTriggered: Date?
    var triggerCount: Int
    var isWhitelist: Bool // true = allowed site, false = blocked site

    // MARK: - Initialization
    init(
        id: String = UUID().uuidString,
        name: String,
        domain: String,
        urlPattern: String = "",
        category: WebsiteCategory = .other,
        isEnabled: Bool = true,
        restrictionType: RestrictionType = .intention,
        intentionAssignments: [IntentionActivity] = [],
        schedules: [RestrictionSchedule] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        lastTriggered: Date? = nil,
        triggerCount: Int = 0,
        isWhitelist: Bool = false
    ) {
        self.id = id
        self.name = name
        self.domain = domain.lowercased()
        self.urlPattern = urlPattern.isEmpty ? "*://\(domain.lowercased())/*" : urlPattern
        self.category = category
        self.isEnabled = isEnabled
        self.restrictionType = restrictionType
        self.intentionAssignments = intentionAssignments
        self.schedules = schedules
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastTriggered = lastTriggered
        self.triggerCount = triggerCount
        self.isWhitelist = isWhitelist
    }

    // MARK: - Computed Properties
    var isActive: Bool {
        guard isEnabled else { return false }
        return schedules.contains { $0.isActiveNow }
    }

    var primaryIntention: IntentionActivity? {
        return intentionAssignments.first
    }

    var effectivePattern: String {
        return urlPattern.isEmpty ? "*://\(domain)/*" : urlPattern
    }

    var isSubdomainRestriction: Bool {
        return urlPattern.contains("*.")
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

    // MARK: - URL Matching
    func matchesURL(_ url: String) -> Bool {
        let normalizedURL = url.lowercased()

        // Direct domain match
        if normalizedURL.contains(domain) {
            return true
        }

        // Pattern matching
        if !urlPattern.isEmpty {
            return matchesPattern(normalizedURL)
        }

        return false
    }

    private func matchesPattern(_ url: String) -> Bool {
        let pattern = urlPattern.lowercased()

        // Simple wildcard matching
        if pattern.hasPrefix("*://") {
            let domainPattern = pattern.dropFirst(4)
            if url.hasSuffix(String(domainPattern)) {
                return true
            }
        }

        if pattern.hasSuffix("/*") {
            let prefix = pattern.dropLast(2)
            if url.hasPrefix(String(prefix)) {
                return true
            }
        }

        // Exact match
        return url == pattern
    }
}

// MARK: - Website Category

enum WebsiteCategory: String, Codable, CaseIterable, Identifiable {
    case socialMedia = "socialMedia"
    case news = "news"
    case entertainment = "entertainment"
    case shopping = "shopping"
    case gaming = "gaming"
    case adult = "adult"
    case gambling = "gambling"
    case streaming = "streaming"
    case productivity = "productivity"
    case education = "education"
    case finance = "finance"
    case health = "health"
    case forums = "forums"
    case other = "other"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .socialMedia: return "Social Media"
        case .news: return "News & Information"
        case .entertainment: return "Entertainment"
        case .shopping: return "Shopping"
        case .gaming: return "Gaming"
        case .adult: return "Adult Content"
        case .gambling: return "Gambling"
        case .streaming: return "Streaming"
        case .productivity: return "Productivity"
        case .education: return "Education"
        case .finance: return "Finance"
        case .health: return "Health"
        case .forums: return "Forums"
        case .other: return "Other"
        }
    }

    var iconName: String {
        switch self {
        case .socialMedia: return "person.2.fill"
        case .news: return "newspaper.fill"
        case .entertainment: return "tv.fill"
        case .shopping: return "cart.fill"
        case .gaming: return "gamecontroller.fill"
        case .adult: return "exclamationmark.triangle.fill"
        case .gambling: return "dice.fill"
        case .streaming: return "play.rectangle.fill"
        case .productivity: return "briefcase.fill"
        case .education: return "book.fill"
        case .finance: return "dollarsign.circle.fill"
        case .health: return "heart.fill"
        case .forums: return "bubble.left.and.bubble.right.fill"
        case .other: return "globe"
        }
    }

    var color: String {
        switch self {
        case .socialMedia: return "blue"
        case .news: return "orange"
        case .entertainment: return "purple"
        case .shopping: return "pink"
        case .gaming: return "red"
        case .adult: return "red"
        case .gambling: return "yellow"
        case .streaming: return "indigo"
        case .productivity: return "green"
        case .education: return "mint"
        case .finance: return "yellow"
        case .health: return "mint"
        case .forums: return "gray"
        case .other: return "secondary"
        }
    }

    var defaultRestrictionType: RestrictionType {
        switch self {
        case .socialMedia, .entertainment, .gaming, .streaming:
            return .intention
        case .shopping, .news:
            return .timeLimited
        case .adult, .gambling:
            return .blocked
        case .productivity, .education, .finance, .health:
            return .intention
        case .forums:
            return .timeLimited
        case .other:
            return .intention
        }
    }

    var recommendedIntentionCategories: [IntentionCategory] {
        switch self {
        case .socialMedia, .entertainment:
            return [.mindfulness, .reflection, .breathing]
        case .gaming, .streaming:
            return [.movement, .quickBreak, .breathing]
        case .shopping:
            return [.mindfulness, .reflection]
        case .news:
            return [.breathing, .mindfulness]
        case .adult, .gambling:
            return [.reflection, .mindfulness, .breathing]
        case .productivity:
            return [.quickBreak, .breathing]
        case .education, .finance, .health:
            return [.mindfulness, .reflection]
        case .forums:
            return [.mindfulness, .breathing]
        case .other:
            return [.breathing, .quickBreak]
        }
    }

    var isSensitiveContent: Bool {
        switch self {
        case .adult, .gambling:
            return true
        default:
            return false
        }
    }
}

// MARK: - Website Restriction Manager

class WebsiteRestrictionManager: ObservableObject {
    @Published var restrictions: [WebsiteRestriction] = []
    @Published var categoryRestrictions: [WebsiteCategoryRestriction] = []
    @Published var globalWhitelistEnabled = false
    @Published var globalBlacklistEnabled = false

    private let userDefaults = UserDefaults.standard
    private let restrictionsKey = "WebsiteRestrictions"
    private let categoryRestrictionsKey = "WebsiteCategoryRestrictions"
    private let globalSettingsKey = "WebsiteGlobalSettings"

    init() {
        loadRestrictions()
        loadCategoryRestrictions()
        loadGlobalSettings()
    }

    // MARK: - Individual Website Restrictions
    func addRestriction(_ restriction: WebsiteRestriction) {
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

    func updateRestriction(_ restriction: WebsiteRestriction) {
        addRestriction(restriction)
    }

    func getRestriction(for url: String) -> WebsiteRestriction? {
        return restrictions.first { $0.matchesURL(url) && $0.isEnabled }
    }

    func getActiveRestrictions() -> [WebsiteRestriction] {
        return restrictions.filter { $0.isActive }
    }

    func getRestrictionsByCategory(_ category: WebsiteCategory) -> [WebsiteRestriction] {
        return restrictions.filter { $0.category == category }
    }

    // MARK: - Category Restrictions
    func addCategoryRestriction(_ restriction: WebsiteCategoryRestriction) {
        if let index = categoryRestrictions.firstIndex(where: { $0.category == restriction.category }) {
            categoryRestrictions[index] = restriction
        } else {
            categoryRestrictions.append(restriction)
        }
        saveCategoryRestrictions()
    }

    func removeCategoryRestriction(category: WebsiteCategory) {
        categoryRestrictions.removeAll { $0.category == category }
        saveCategoryRestrictions()
    }

    func getCategoryRestriction(for url: String) -> WebsiteCategoryRestriction? {
        let category = WebsiteCategoryProvider.getCategoryForURL(url)
        return categoryRestrictions.first { $0.category == category && $0.isEnabled }
    }

    // MARK: - URL Checking Logic
    func shouldRestrictURL(_ url: String) -> (shouldRestrict: Bool, restriction: WebsiteRestriction?) {
        // Check global whitelist first
        if globalWhitelistEnabled {
            if let whitelistRestriction = restrictions.first(where: { $0.isWhitelist && $0.matchesURL(url) && $0.isEnabled }) {
                return (false, nil) // Allowed by whitelist
            }
        }

        // Check specific restrictions
        if let restriction = getRestriction(for: url) {
            return (true, restriction)
        }

        // Check category restrictions
        if let categoryRestriction = getCategoryRestriction(for: url) {
            // Create a temporary restriction for this category
            let tempRestriction = WebsiteRestriction(
                name: categoryRestriction.category.displayName,
                domain: URL(string: url)?.host ?? "",
                category: categoryRestriction.category,
                restrictionType: categoryRestriction.restrictionType,
                intentionAssignments: categoryRestriction.intentionAssignments,
                schedules: categoryRestriction.schedules
            )
            return (true, tempRestriction)
        }

        // Check global blacklist
        if globalBlacklistEnabled {
            if let blacklistRestriction = restrictions.first(where: { !$0.isWhitelist && $0.matchesURL(url) && $0.isEnabled }) {
                return (true, blacklistRestriction)
            }
        }

        return (false, nil)
    }

    // MARK: - Bulk Operations
    func addCommonSocialMediaSites() {
        let socialMediaSites = [
            ("Facebook", "facebook.com", WebsiteCategory.socialMedia),
            ("Instagram", "instagram.com", WebsiteCategory.socialMedia),
            ("Twitter/X", "twitter.com", WebsiteCategory.socialMedia),
            ("Twitter/X", "x.com", WebsiteCategory.socialMedia),
            ("TikTok", "tiktok.com", WebsiteCategory.socialMedia),
            ("LinkedIn", "linkedin.com", WebsiteCategory.socialMedia),
            ("Reddit", "reddit.com", WebsiteCategory.socialMedia)
        ]

        for (name, domain, category) in socialMediaSites {
            let restriction = WebsiteRestriction(
                name: name,
                domain: domain,
                category: category,
                restrictionType: category.defaultRestrictionType
            )
            addRestriction(restriction)
        }
    }

    func addCommonEntertainmentSites() {
        let entertainmentSites = [
            ("YouTube", "youtube.com", WebsiteCategory.streaming),
            ("Netflix", "netflix.com", WebsiteCategory.streaming),
            ("Twitch", "twitch.tv", WebsiteCategory.streaming),
            ("Hulu", "hulu.com", WebsiteCategory.streaming),
            ("Disney+", "disneyplus.com", WebsiteCategory.streaming)
        ]

        for (name, domain, category) in entertainmentSites {
            let restriction = WebsiteRestriction(
                name: name,
                domain: domain,
                category: category,
                restrictionType: category.defaultRestrictionType
            )
            addRestriction(restriction)
        }
    }

    func addCommonShoppingSites() {
        let shoppingSites = [
            ("Amazon", "amazon.com", WebsiteCategory.shopping),
            ("eBay", "ebay.com", WebsiteCategory.shopping),
            ("Etsy", "etsy.com", WebsiteCategory.shopping)
        ]

        for (name, domain, category) in shoppingSites {
            let restriction = WebsiteRestriction(
                name: name,
                domain: domain,
                category: category,
                restrictionType: category.defaultRestrictionType
            )
            addRestriction(restriction)
        }
    }

    // MARK: - Analytics
    func getRestrictionAnalytics() -> WebsiteRestrictionAnalytics {
        let totalRestrictions = restrictions.count + categoryRestrictions.count
        let activeRestrictions = restrictions.filter { $0.isActive }.count + categoryRestrictions.filter { $0.isActive }.count
        let totalTriggers = restrictions.reduce(0) { $0 + $1.triggerCount }
        let mostTriggered = restrictions.max { $0.triggerCount < $1.triggerCount }
        let categoryBreakdown = Dictionary(grouping: restrictions) { $0.category }

        return WebsiteRestrictionAnalytics(
            totalRestrictions: totalRestrictions,
            activeRestrictions: activeRestrictions,
            totalTriggers: totalTriggers,
            mostTriggeredSite: mostTriggered?.name,
            categoryBreakdown: categoryBreakdown.mapValues { $0.count }
        )
    }

    // MARK: - Data Persistence
    private func loadRestrictions() {
        if let data = userDefaults.data(forKey: restrictionsKey),
           let loadedRestrictions = try? JSONDecoder().decode([WebsiteRestriction].self, from: data) {
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
           let loadedRestrictions = try? JSONDecoder().decode([WebsiteCategoryRestriction].self, from: data) {
            categoryRestrictions = loadedRestrictions
        }
    }

    private func saveCategoryRestrictions() {
        if let data = try? JSONEncoder().encode(categoryRestrictions) {
            userDefaults.set(data, forKey: categoryRestrictionsKey)
        }
    }

    private func loadGlobalSettings() {
        if let data = userDefaults.data(forKey: globalSettingsKey),
           let settings = try? JSONDecoder().decode(WebsiteGlobalSettings.self, from: data) {
            globalWhitelistEnabled = settings.whitelistEnabled
            globalBlacklistEnabled = settings.blacklistEnabled
        }
    }

    func saveGlobalSettings() {
        let settings = WebsiteGlobalSettings(
            whitelistEnabled: globalWhitelistEnabled,
            blacklistEnabled: globalBlacklistEnabled
        )
        if let data = try? JSONEncoder().encode(settings) {
            userDefaults.set(data, forKey: globalSettingsKey)
        }
    }
}

// MARK: - Website Category Restriction

struct WebsiteCategoryRestriction: Codable, Identifiable {
    let id = UUID().uuidString
    let category: WebsiteCategory
    var isEnabled: Bool
    var restrictionType: RestrictionType
    var intentionAssignments: [IntentionActivity]
    var schedules: [RestrictionSchedule]
    var createdAt: Date
    var updatedAt: Date

    init(
        category: WebsiteCategory,
        isEnabled: Bool = true,
        restrictionType: RestrictionType,
        intentionAssignments: [IntentionActivity] = [],
        schedules: [RestrictionSchedule] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.category = category
        self.isEnabled = isEnabled
        self.restrictionType = restrictionType
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

// MARK: - Supporting Types

struct WebsiteGlobalSettings: Codable {
    let whitelistEnabled: Bool
    let blacklistEnabled: Bool
}

struct WebsiteRestrictionAnalytics: Codable {
    let totalRestrictions: Int
    let activeRestrictions: Int
    let totalTriggers: Int
    let mostTriggeredSite: String?
    let categoryBreakdown: [WebsiteCategory: Int]

    var mostRestrictedCategory: WebsiteCategory? {
        return categoryBreakdown.max { $0.value < $1.value }?.key
    }
}

// MARK: - Website Category Provider

class WebsiteCategoryProvider {
    static func getCategoryForURL(_ url: String) -> WebsiteCategory {
        let domain = URL(string: url)?.host?.lowercased() ?? ""

        // Social Media
        if domain.contains("facebook") || domain.contains("instagram") ||
           domain.contains("twitter") || domain.contains("tiktok") ||
           domain.contains("linkedin") || domain.contains("reddit") {
            return .socialMedia
        }

        // Streaming
        if domain.contains("youtube") || domain.contains("netflix") ||
           domain.contains("twitch") || domain.contains("hulu") ||
           domain.contains("disneyplus") {
            return .streaming
        }

        // Shopping
        if domain.contains("amazon") || domain.contains("ebay") ||
           domain.contains("etsy") || domain.contains("shopify") {
            return .shopping
        }

        // News
        if domain.contains("cnn") || domain.contains("bbc") ||
           domain.contains("reuters") || domain.contains("nytimes") {
            return .news
        }

        // Gaming
        if domain.contains("steam") || domain.contains("epicgames") ||
           domain.contains("roblox") {
            return .gaming
        }

        return .other
    }

    static func getSuggestedIntentions(for category: WebsiteCategory) -> [IntentionActivity] {
        return [
            IntentionActivity.breathingExercise,
            IntentionActivity.mindfulnessBodyScan,
            IntentionActivity.waterBreak
        ]
    }
}