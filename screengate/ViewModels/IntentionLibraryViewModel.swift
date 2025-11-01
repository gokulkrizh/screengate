import Foundation
import SwiftUI
import Combine

// MARK: - Intention Library ViewModel

@MainActor
class IntentionLibraryViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var allIntentions: [IntentionActivity] = []
    @Published var customIntentions: [IntentionActivity] = []
    @Published var favoriteIntentionIds: [String] = []
    @Published var selectedCategory: IntentionCategory?
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showCreateIntention: Bool = false
    @Published var selectedIntention: IntentionActivity?

    // MARK: - Private Properties
    private let intentionLibraryManager = IntentionLibraryManager.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    var filteredIntentions: [IntentionActivity] {
        var intentions = allIntentions

        // Filter by selected category
        if let category = selectedCategory {
            intentions = intentions.filter { $0.category == category }
        }

        // Filter by search text
        if !searchText.isEmpty {
            intentions = intentions.filter { intention in
                intention.title.localizedCaseInsensitiveContains(searchText) ||
                intention.description.localizedCaseInsensitiveContains(searchText) ||
                intention.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }

        return intentions
    }

    var favoriteIntentions: [IntentionActivity] {
        return favoriteIntentionIds.compactMap { id in
            allIntentions.first { $0.id == id }
        }
    }

    // MARK: - Initialization
    init() {
        loadIntentions()
        setupBindings()
    }

    // MARK: - Public Methods

    func loadIntentions() {
        isLoading = true
        errorMessage = nil

        allIntentions = intentionLibraryManager.getAllIntentions()
        customIntentions = allIntentions.filter { $0.isCustom }
        favoriteIntentionIds = intentionLibraryManager.getFavoriteIntentions().map { $0.id }

        isLoading = false
    }

    func refreshIntentions() {
        loadIntentions()
    }

    func addToFavorites(_ intention: IntentionActivity) {
        intentionLibraryManager.addToFavorites(id: intention.id)
        favoriteIntentionIds = intentionLibraryManager.getFavoriteIntentions().map { $0.id }
    }

    func removeFromFavorites(_ intention: IntentionActivity) {
        intentionLibraryManager.removeFromFavorites(id: intention.id)
        favoriteIntentionIds = intentionLibraryManager.getFavoriteIntentions().map { $0.id }
    }

    func toggleFavorite(_ intention: IntentionActivity) {
        if intentionLibraryManager.isFavorite(id: intention.id) {
            removeFromFavorites(intention)
        } else {
            addToFavorites(intention)
        }
    }

    func isFavorite(_ intention: IntentionActivity) -> Bool {
        return intentionLibraryManager.isFavorite(id: intention.id)
    }

    func createCustomIntention(
        title: String,
        description: String,
        category: IntentionCategory,
        duration: TimeInterval,
        content: IntentionContent
    ) {
        isLoading = true

        let customIntention = IntentionActivity(
            title: title,
            description: description,
            category: category,
            duration: duration,
            content: content,
            isCustom: true
        )

        intentionLibraryManager.addCustomIntention(customIntention)
        loadIntentions()
        showCreateIntention = false
    }

    func deleteCustomIntention(_ intention: IntentionActivity) {
        guard intention.isCustom else { return }
        intentionLibraryManager.deleteCustomIntention(withId: intention.id)
        loadIntentions()
    }

    func searchIntentions(_ query: String) -> [IntentionActivity] {
        return intentionLibraryManager.searchIntentions(query: query)
    }

    func getIntentionsByCategory(_ category: IntentionCategory) -> [IntentionActivity] {
        return intentionLibraryManager.getIntentionsByCategory(category)
    }

    func getQuickIntentions() -> [IntentionActivity] {
        return intentionLibraryManager.getQuickIntentions()
    }

    func getRecommendedIntentions() -> [IntentionActivity] {
        return intentionLibraryManager.getRecommendedIntentions()
    }

    // MARK: - Private Methods

    private func setupBindings() {
        // Monitor intention library manager changes
        // This would require the IntentionLibraryManager to be @Published or use Combine publishers
    }
}