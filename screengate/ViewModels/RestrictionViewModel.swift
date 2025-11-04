import Foundation
import SwiftUI
import FamilyControls
import Combine

// MARK: - Restriction ViewModel

@MainActor
class RestrictionViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var selectedApps: FamilyActivitySelection = FamilyActivitySelection()
    @Published var isAuthorized: Bool = false
    @Published var isLoading: Bool = false
    @Published var restrictions: [AppRestriction] = []
    @Published var websiteRestrictions: [WebsiteRestriction] = []
    @Published var isRestrictionsActive: Bool = false
    @Published var errorMessage: String?
    @Published var showFamilyActivityPicker: Bool = false

    // MARK: - Private Properties
    private let screenTimeService = ScreenTimeService.shared
    // NOTE: AppRestrictionManager was not implemented, so functionality is moved to this ViewModel
    // private let appRestrictionManager = AppRestrictionManager()
    private let websiteRestrictionManager = WebsiteRestrictionManager()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    var hasSelections: Bool {
        !selectedApps.isEmpty
    }

    var totalRestrictedItems: Int {
        restrictions.count + websiteRestrictions.count
    }

    var activeRestrictions: Int {
        restrictions.filter { $0.isActive }.count + websiteRestrictions.filter { $0.isActive }.count
    }

    var displayName: String {
        selectedApps.displayName
    }

    // MARK: - Initialization
    init() {
        // PERFORMANCE FIX: Add debouncing to prevent cascading updates
        // These continuous Combine publishers were causing high CPU usage

        screenTimeService.$authorizationStatus
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: \.authorizationStatus, on: self)
            .store(in: &cancellables)

        screenTimeService.$isAuthorized
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: \.isAuthorized, on: self)
            .store(in: &cancellables)

        screenTimeService.$isLoading
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)

        // Load existing data
        loadExistingData()
        checkAuthorizationStatus()
    }

    // MARK: - Authorization Management

    /// Request Screen Time authorization
    func requestAuthorization() async {
        isLoading = true
        errorMessage = nil

        do {
            try await screenTimeService.requestAuthorization()
            print("✅ Screen Time authorization granted")
        } catch {
            errorMessage = "Failed to get Screen Time authorization: \(error.localizedDescription)"
            print("❌ Authorization failed: \(error)")
        }

        isLoading = false
    }

    /// Check current authorization status
    func checkAuthorizationStatus() {
        screenTimeService.checkAuthorizationStatus()
        isAuthorized = screenTimeService.isAuthorized
    }

    // MARK: - App Selection Management

    /// Show Family Activity Picker for app selection
    func showAppSelection() async {
        guard isAuthorized else {
            await requestAuthorization()
            return
        }
        showFamilyActivityPicker = true
    }

    /// Save selected apps and categories
    func saveSelection(_ selection: FamilyActivitySelection) {
        print("🔍 [DEBUG] RestrictionViewModel.saveSelection called")
        print("🔍 [DEBUG] Selection - Apps: \(selection.applicationTokens.count), Categories: \(selection.categoryTokens.count)")

        selectedApps = selection
        screenTimeService.saveSelection(selection)

        print("🔍 [DEBUG] About to create restrictions from selection...")
        // Convert selection to restrictions
        createRestrictionsFromSelection(selection)

        showFamilyActivityPicker = false
        print("💾 Saved app selection with \(selection.totalCount) items")
        print("🔍 [DEBUG] Total restrictions in ViewModel: \(restrictions.count)")
    }

    /// Clear current selection
    func clearSelection() {
        selectedApps = FamilyActivitySelection()
        restrictions.removeAll()
        websiteRestrictions.removeAll()
        isRestrictionsActive = false

        // Clear screen time service selection
        screenTimeService.saveSelection(FamilyActivitySelection())

        // Clear shared defaults for shield extension
        let sharedDefaults = UserDefaults(suiteName: "group.com.gia.screengate")
        sharedDefaults?.removeObject(forKey: "SavedRestrictions")

        print("🗑️ Cleared all selections and restrictions (including shared defaults)")
    }

    // MARK: - Restriction Management

    /// Apply restrictions to selected apps
    func applyRestrictions() {
        guard isAuthorized else {
            errorMessage = "Screen Time authorization required"
            return
        }

        guard hasSelections else {
            errorMessage = "No apps selected for restriction"
            return
        }

        isLoading = true
        errorMessage = nil

        // Update restriction states
        for index in restrictions.indices {
            restrictions[index].isEnabled = true
        }

        for index in websiteRestrictions.indices {
            websiteRestrictions[index].isEnabled = true
        }

        // Apply through screen time service
        screenTimeService.applyRestrictions()
        isRestrictionsActive = true

        isLoading = false
        print("🔒 Applied restrictions to \(totalRestrictedItems) items")
    }

    /// Remove all restrictions
    func removeRestrictions() {
        isLoading = true

        // Update restriction states
        for index in restrictions.indices {
            restrictions[index].isEnabled = false
        }

        for index in websiteRestrictions.indices {
            websiteRestrictionManager.removeRestriction(withId: websiteRestrictions[index].id)
        }

        // Clear through screen time service
        screenTimeService.clearRestrictions()
        isRestrictionsActive = false

        isLoading = false
        print("🔓 Removed all restrictions")
    }

    /// Toggle restriction for specific app
    func toggleRestriction(for restriction: AppRestriction) {
        guard let index = restrictions.firstIndex(where: { $0.id == restriction.id }) else { return }

        restrictions[index].isEnabled.toggle()
        saveRestrictions()

        if restrictions[index].isActive {
            screenTimeService.applyRestrictions()
        } else {
            screenTimeService.clearRestrictions()
            // Re-apply other active restrictions
            applyActiveRestrictions()
        }

        print("🔄 Toggled restriction for \(restriction.name)")
    }

    /// Toggle restriction for specific website
    func toggleWebsiteRestriction(for restriction: WebsiteRestriction) {
        if restriction.isActive {
            websiteRestrictionManager.removeRestriction(withId: restriction.id)
        } else {
            websiteRestrictionManager.addRestriction(restriction)
        }

        // Update local copy
        if let index = websiteRestrictions.firstIndex(where: { $0.id == restriction.id }) {
            websiteRestrictions[index] = websiteRestrictionManager.getRestriction(for: restriction.id) ?? restriction
        }

        print("🔄 Toggled website restriction for \(restriction.domain)")
    }

    // MARK: - Website Restriction Management

    /// Add website restriction
    func addWebsiteRestriction(_ restriction: WebsiteRestriction) {
        websiteRestrictionManager.addRestriction(restriction)
        websiteRestrictions.append(restriction)
        print("➕ Added website restriction for \(restriction.domain)")
    }

    /// Remove website restriction
    func removeWebsiteRestriction(_ restriction: WebsiteRestriction) {
        websiteRestrictionManager.removeRestriction(withId: restriction.id)
        websiteRestrictions.removeAll { $0.id == restriction.id }
        print("➖ Removed website restriction for \(restriction.domain)")
    }

    /// Add common social media sites
    func addCommonSocialMediaSites() {
        websiteRestrictionManager.addCommonSocialMediaSites()
        loadWebsiteRestrictions()
        print("📱 Added common social media sites")
    }

    /// Add common entertainment sites
    func addCommonEntertainmentSites() {
        websiteRestrictionManager.addCommonEntertainmentSites()
        loadWebsiteRestrictions()
        print("🎬 Added common entertainment sites")
    }

    /// Add common shopping sites
    func addCommonShoppingSites() {
        websiteRestrictionManager.addCommonShoppingSites()
        loadWebsiteRestrictions()
        print("🛒 Added common shopping sites")
    }

    // MARK: - Analytics and Insights

    /// Get restriction analytics
    func getRestrictionAnalytics() -> RestrictionAnalytics {
        // Since AppRestrictionManager doesn't exist, create analytics from our local data
        return RestrictionAnalytics(
            totalRestrictions: restrictions.count,
            activeRestrictions: restrictions.filter { $0.isEnabled }.count,
            totalTriggers: 0, // Placeholder - would need tracking
            mostTriggeredApp: nil, // Placeholder - would need tracking
            averageDailyTriggers: 0.0 // Placeholder - would need tracking
        )
    }

    /// Get shield analytics from screen time service
    func getShieldAnalytics() -> ShieldAnalytics {
        return screenTimeService.getShieldAnalytics()
    }

    /// Get completion rate for intentions
    func getIntentionCompletionRate() -> Double {
        let completions = getIntentionCompletions()
        guard !completions.isEmpty else { return 0.0 }

        let completedCount = completions.filter { !$0.wasSkipped }.count
        return Double(completedCount) / Double(completions.count)
    }

    /// Get most restricted categories
    func getMostRestrictedCategories() -> [(category: String, count: Int)] {
        let categoryCounts = Dictionary(grouping: restrictions) { $0.restrictionType }
        return categoryCounts.map { ($0.key.displayName, $0.value.count) }
            .sorted { $0.1 > $1.1 }
            .prefix(3)
            .map { ($0.0, $0.1) }
    }

    // MARK: - Private Methods

    private func loadExistingData() {
        loadRestrictions()
        loadWebsiteRestrictions()
        loadSavedSelection()
    }

    func loadRestrictions() {
        // Since AppRestrictionManager doesn't exist, restrictions are managed locally
        // The restrictions array is already populated by createRestrictionsFromSelection
        print("📂 Loaded \(restrictions.count) app restrictions (local data)")
    }

    private func loadWebsiteRestrictions() {
        websiteRestrictions = websiteRestrictionManager.getActiveRestrictions()
        print("🌐 Loaded \(websiteRestrictions.count) website restrictions")
    }

    private func loadSavedSelection() {
        // Load from UserDefaults (simplified implementation)
        if UserDefaults.standard.bool(forKey: "HasSelectedApps") {
            print("📋 Found saved app selections")
        }
    }

    private func saveRestrictions() {
        // Data is automatically saved when restrictions are added/updated
    }

    private func createRestrictionsFromSelection(_ selection: FamilyActivitySelection) {
        print("🔍 [DEBUG] Creating restrictions from selection...")
        print("🔍 [DEBUG] Apps in selection: \(selection.applicationTokens.count)")
        print("🔍 [DEBUG] Categories in selection: \(selection.categoryTokens.count)")

        // Clear existing restrictions
        restrictions.removeAll()

        // Create restrictions from selection directly in this ViewModel
        // since AppRestrictionManager doesn't exist
        let defaultIntentions = getDefaultIntentions()

        // Create app restrictions from application tokens
        for (index, appToken) in selection.applicationTokens.enumerated() {
            let restriction = AppRestriction(
                name: "App \(index + 1)", // Placeholder name
                bundleIdentifier: "app.\(index)", // Simplified identifier
                appToken: try? JSONEncoder().encode(appToken), // Store token as data
                intentionAssignments: [defaultIntentions[index % defaultIntentions.count]]
            )
            restrictions.append(restriction)
            print("�� [DEBUG] Created app restriction: \(restriction.bundleIdentifier)")
        }

        // Create restrictions from category tokens
        for (index, categoryToken) in selection.categoryTokens.enumerated() {
            let restriction = AppRestriction(
                name: "Category \(index + 1)", // Placeholder name
                bundleIdentifier: "category.\(index)", // Simplified identifier
                categoryToken: try? JSONEncoder().encode(categoryToken), // Store token as data
                intentionAssignments: [defaultIntentions[index % defaultIntentions.count]]
            )
            restrictions.append(restriction)
            print("🔍 [DEBUG] Created category restriction: \(restriction.bundleIdentifier)")
        }

        // Save restrictions to shared UserDefaults for shield extension
        saveRestrictionsToSharedDefaults()

        print("🔍 [DEBUG] Total restrictions created: \(restrictions.count)")
    }

    private func saveRestrictionsToSharedDefaults() {
        // Convert AppRestriction objects to SimpleRestriction objects for shield extension
        let simpleRestrictions = restrictions.map { SimpleRestriction(from: $0) }

        guard let data = try? JSONEncoder().encode(simpleRestrictions) else {
            print("❌ Failed to encode restrictions for sharing")
            return
        }

        let sharedDefaults = UserDefaults(suiteName: "group.com.gia.screengate")
        sharedDefaults?.set(data, forKey: "SavedRestrictions")
        print("💾 Saved \(simpleRestrictions.count) restrictions to shared defaults for shield extension")
    }

    private func getDefaultIntentions() -> [IntentionActivity] {
        return [
            IntentionActivity.breathingExercise,
            IntentionActivity.mindfulnessBodyScan,
            IntentionActivity.waterBreak
        ]
    }

    private func applyActiveRestrictions() {
        let activeRestrictions = restrictions.filter { $0.isActive }
        if !activeRestrictions.isEmpty {
            screenTimeService.applyRestrictions()
        }
    }

    private func getIntentionCompletions() -> [IntentionCompletion] {
        if let data = UserDefaults.standard.data(forKey: "IntentionCompletions"),
           let completions = try? JSONDecoder().decode([IntentionCompletion].self, from: data) {
            return completions
        }
        return []
    }

    // MARK: - Test and Debug Methods

    /// Configure test shield for debugging
    func configureTestShield() {
        guard let intention = currentDefaultIntention else { return }

        screenTimeService.configureTestShield(
            for: "Test App",
            intention: intention
        )
        print("🧪 Configured test shield")
    }

    private var currentDefaultIntention: IntentionActivity? {
        return IntentionActivity.breathingExercise
    }

    // MARK: - Deinit
    deinit {
        cancellables.removeAll()
    }
}

// MARK: - Authorization Status Extension

extension RestrictionViewModel {
    var authorizationStatus: FamilyControls.AuthorizationStatus {
        get { screenTimeService.authorizationStatus }
        set {
            screenTimeService.authorizationStatus = newValue
            isAuthorized = (newValue == .approved)
        }
    }

    var authorizationStatusText: String {
        switch authorizationStatus {
        case .notDetermined:
            return "Not Requested"
        case .denied:
            return "Denied"
        case .approved:
            return "Authorized"
        @unknown default:
            return "Unknown"
        }
    }

    var canRequestAuthorization: Bool {
        authorizationStatus == .notDetermined
    }

    var isAuthorizationNeeded: Bool {
        authorizationStatus != .approved
    }
}