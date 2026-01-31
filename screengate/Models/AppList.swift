import Foundation
import FamilyControls

// MARK: - AppList Model

struct AppList: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var icon: String  // SF Symbol name
    var selection: FamilyActivitySelection
    var isDefault: Bool
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        icon: String = "flame.fill",
        selection: FamilyActivitySelection = FamilyActivitySelection(),
        isDefault: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.selection = selection
        self.isDefault = isDefault
        self.createdAt = createdAt
    }
    
    // Equatable conformance
    static func == (lhs: AppList, rhs: AppList) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.icon == rhs.icon &&
               lhs.isDefault == rhs.isDefault
    }
    
    /// Number of apps in this list
    var appCount: Int {
        return selection.applicationTokens.count
    }
    
    /// Number of categories in this list
    var categoryCount: Int {
        return selection.categoryTokens.count
    }
    
    /// Total number of items (apps + categories)
    var totalItemCount: Int {
        return appCount + categoryCount
    }
    
    /// Whether this list has any apps selected
    var hasApps: Bool {
        return !selection.applicationTokens.isEmpty
    }
    
    /// Whether this list has any categories selected
    var hasCategories: Bool {
        return !selection.categoryTokens.isEmpty
    }
}

// MARK: - AppListManager

@Observable
final class AppListManager {
    // MARK: - Published State
    
    var lists: [AppList] = []
    
    // MARK: - Private Dependencies
    
    private let userDefaults: UserDefaults
    
    // MARK: - Constants (per-list storage like BlockManager)
    
    private let listIdsKey = "appListIds"  // [String] array of list UUIDs
    
    // Helper function for per-list keys
    private func listKey(_ id: UUID) -> String { "appList_\(id.uuidString)" }
    
    // MARK: - Initialization
    
    init() {
        // Use app group for cross-target access
        self.userDefaults = UserDefaults(suiteName: "group.com.gia.screendiet") ?? .standard
        loadFromUserDefaults()
    }
    
    // MARK: - CRUD Operations
    
    /// Create a new app list
    func createList(_ list: AppList) throws {
        lists.append(list)
        saveToUserDefaults()
    }
    
    /// Update an existing app list
    func updateList(_ list: AppList) throws {
        guard let index = lists.firstIndex(where: { $0.id == list.id }) else {
            throw AppListError.listNotFound
        }
        lists[index] = list
        
        // Save individual list (O(1) update)
        if let encoded = try? JSONEncoder().encode(list) {
            userDefaults.set(encoded, forKey: listKey(list.id))
        }
    }
    
    /// Delete an app list
    func deleteList(_ list: AppList) throws {
        lists.removeAll { $0.id == list.id }
        
        // Remove from UserDefaults
        userDefaults.removeObject(forKey: listKey(list.id))
        saveToUserDefaults()
    }
    
    /// Get a list by ID
    func getList(id: UUID) -> AppList? {
        return lists.first { $0.id == id }
    }
    
    /// Set a list as default (only one default allowed)
    func setAsDefault(_ list: AppList) throws {
        // Remove default from all other lists
        for i in lists.indices {
            lists[i].isDefault = false
        }
        
        // Set this list as default
        if let index = lists.firstIndex(where: { $0.id == list.id }) {
            lists[index].isDefault = true
            saveToUserDefaults()
        }
    }
    
    // MARK: - Persistence
    
    /// Save all lists to UserDefaults (optimized per-list storage)
    private func saveToUserDefaults() {
        // 1. Save each list individually
        for list in lists {
            if let encoded = try? JSONEncoder().encode(list) {
                userDefaults.set(encoded, forKey: listKey(list.id))
            }
        }
        
        // 2. Save list of IDs (triggers observers)
        let ids = lists.map { $0.id.uuidString }
        userDefaults.set(ids, forKey: listIdsKey)
        
        // 3. Post Darwin notification for cross-process sync (matching BlockManager pattern)
        let notificationName = "com.gia.screendiet.appListsChanged" as CFString
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterPostNotification(center, CFNotificationName(notificationName), nil, nil, true)
    }
    
    /// Load all lists from UserDefaults
    private func loadFromUserDefaults() {
        guard let idsArray = userDefaults.array(forKey: listIdsKey) as? [String] else {
            lists = []
            return
        }
        
        var loadedLists: [AppList] = []
        
        for idString in idsArray {
            guard let uuid = UUID(uuidString: idString),
                  let data = userDefaults.data(forKey: listKey(uuid)),
                  let list = try? JSONDecoder().decode(AppList.self, from: data) else {
                continue
            }
            loadedLists.append(list)
        }
        
        lists = loadedLists
    }
}

// MARK: - Errors

enum AppListError: LocalizedError {
    case listNotFound
    case invalidSelection
    
    var errorDescription: String? {
        switch self {
        case .listNotFound:
            return "App list not found"
        case .invalidSelection:
            return "Invalid app selection"
        }
    }
}
