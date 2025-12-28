import Foundation

/// Manages shared container communication between main app and Device Activity extensions
/// Uses App Groups and shared UserDefaults for real-time data sync
class SharedContainerManager {
    static let shared = SharedContainerManager()
    
    // App Group identifier must match entitlements
    private let appGroupID = "group.com.gia.screengate"
    
    private lazy var sharedUserDefaults: UserDefaults? = {
        // UserDefaults with suiteName automatically uses the app group container
        let defaults = UserDefaults(suiteName: appGroupID)
        // Ensure it's initialized by setting and synchronizing
        defaults?.synchronize()
        return defaults
    }()
    
    // MARK: - Intervention Logging
    
    /// Log an intervention event from extension (app launch attempt)
    func logIntervention(
        bundleID: String,
        appName: String,
        type: String, // "delay", "block", "ask"
        timestamp: Date
    ) {
        let interventionData: [String: Any] = [
            "bundleID": bundleID,
            "appName": appName,
            "type": type,
            "timestamp": timestamp.timeIntervalSince1970,
            "dateLogged": ISO8601DateFormatter().string(from: timestamp)
        ]
        
        // Add to intervention queue
        var interventions = sharedUserDefaults?.array(forKey: "pendingInterventions") as? [[String: Any]] ?? []
        interventions.append(interventionData)
        sharedUserDefaults?.set(interventions, forKey: "pendingInterventions")
        sharedUserDefaults?.synchronize() // Force sync
        
        print("✓ Intervention logged: \(appName) (\(type))")
    }
    
    /// Get pending interventions from extension
    func getPendingInterventions() -> [[String: Any]] {
        let interventions = sharedUserDefaults?.array(forKey: "pendingInterventions") as? [[String: Any]] ?? []
        return interventions
    }
    
    /// Clear pending interventions after syncing to Core Data
    func clearPendingInterventions() {
        sharedUserDefaults?.removeObject(forKey: "pendingInterventions")
        sharedUserDefaults?.synchronize()
    }
    
    // MARK: - Session State
    
    /// Save active session to shared container
    func saveActiveSession(
        id: UUID,
        startTime: Date,
        durationSeconds: Int,
        protectedAppBundles: [String]
    ) {
        let sessionData: [String: Any] = [
            "sessionId": id.uuidString,
            "startTime": startTime.timeIntervalSince1970,
            "durationSeconds": durationSeconds,
            "protectedAppBundles": protectedAppBundles,
            "isActive": true
        ]
        
        sharedUserDefaults?.set(sessionData, forKey: "activeSession")
        sharedUserDefaults?.synchronize()
        print("✓ Session saved to shared container: \(id.uuidString)")
    }
    
    /// Get active session from shared container
    func getActiveSession() -> (id: UUID, startTime: Date, durationSeconds: Int, protectedApps: [String])? {
        guard let sessionData = sharedUserDefaults?.dictionary(forKey: "activeSession") as? [String: Any],
              let idString = sessionData["sessionId"] as? String,
              let id = UUID(uuidString: idString),
              let startTime = sessionData["startTime"] as? TimeInterval,
              let durationSeconds = sessionData["durationSeconds"] as? Int else {
            return nil
        }
        
        // Get protected app count if available
        let protectedAppCount = sessionData["protectedAppCount"] as? Int ?? 0
        let protectedApps = sessionData["protectedAppBundles"] as? [String] ?? []
        
        return (
            id: id,
            startTime: Date(timeIntervalSince1970: startTime),
            durationSeconds: durationSeconds,
            protectedApps: protectedApps.isEmpty ? Array(0..<protectedAppCount).map { "app\($0)" } : protectedApps
        )
    }
    
    /// Clear active session (called when session ends)
    func clearActiveSession() {
        sharedUserDefaults?.removeObject(forKey: "activeSession")
        sharedUserDefaults?.synchronize()
        print("✓ Active session cleared from shared container")
    }
    
    /// Check if session is still valid (not expired)
    func isSessionValid() -> Bool {
        guard let session = getActiveSession() else { return false }
        
        let elapsed = Date().timeIntervalSince(session.startTime)
        return elapsed < TimeInterval(session.durationSeconds)
    }
    
    // MARK: - Break Management
    
    /// Save active break to shared container
    func saveActiveBreak(
        durationSeconds: Int,
        startTime: Date
    ) {
        let breakData: [String: Any] = [
            "durationSeconds": durationSeconds,
            "startTime": startTime.timeIntervalSince1970,
            "isActive": true
        ]
        
        sharedUserDefaults?.set(breakData, forKey: "activeBreak")
        sharedUserDefaults?.synchronize()
        print("✓ Break saved: \(durationSeconds)s")
    }
    
    /// Get active break
    func getActiveBreak() -> (durationSeconds: Int, startTime: Date)? {
        guard let breakData = sharedUserDefaults?.dictionary(forKey: "activeBreak") as? [String: Any],
              let durationSeconds = breakData["durationSeconds"] as? Int,
              let startTime = breakData["startTime"] as? TimeInterval else {
            return nil
        }
        
        return (durationSeconds: durationSeconds, startTime: Date(timeIntervalSince1970: startTime))
    }
    
    /// Clear active break
    func clearActiveBreak() {
        sharedUserDefaults?.removeObject(forKey: "activeBreak")
        sharedUserDefaults?.synchronize()
    }
    
    // MARK: - User Preferences
    
    /// Save user's protection settings to shared container
    func saveProtectionSettings(
        defaultBehavior: String, // "delay", "block", "ask"
        delayDurationSeconds: Int
    ) {
        let settings: [String: Any] = [
            "defaultBehavior": defaultBehavior,
            "delayDurationSeconds": delayDurationSeconds,
            "lastUpdated": Date().timeIntervalSince1970
        ]
        
        sharedUserDefaults?.set(settings, forKey: "protectionSettings")
        sharedUserDefaults?.synchronize()
        print("✓ Protection settings saved to shared container")
    }
    
    /// Get user's protection settings from shared container
    func getProtectionSettings() -> (behavior: String, delaySeconds: Int)? {
        guard let settings = sharedUserDefaults?.dictionary(forKey: "protectionSettings") as? [String: Any],
              let behavior = settings["defaultBehavior"] as? String,
              let delaySeconds = settings["delayDurationSeconds"] as? Int else {
            return nil
        }
        
        return (behavior: behavior, delaySeconds: delaySeconds)
    }
    
    // MARK: - Protected Apps List
    
    /// Save list of protected apps to shared container
    func saveProtectedApps(_ apps: [String]) { // bundle IDs
        sharedUserDefaults?.set(apps, forKey: "protectedApps")
        sharedUserDefaults?.synchronize()
        print("✓ Protected apps list saved: \(apps.count) apps")
    }
    
    /// Get protected apps from shared container
    func getProtectedApps() -> [String] {
        return sharedUserDefaults?.array(forKey: "protectedApps") as? [String] ?? []
    }
    
    // MARK: - Emergency Bypass
    
    /// Record emergency bypass usage
    func recordEmergencyBypass() {
        let today = Calendar.current.startOfDay(for: Date())
        let key = "bypasses_\(today.timeIntervalSince1970)"
        
        var count = sharedUserDefaults?.integer(forKey: key) ?? 0
        count += 1
        sharedUserDefaults?.set(count, forKey: key)
        
        print("✓ Emergency bypass recorded for today")
    }
    
    /// Get emergency bypass count for today
    func getBypassCountToday() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let key = "bypasses_\(today.timeIntervalSince1970)"
        return sharedUserDefaults?.integer(forKey: key) ?? 0
    }
    
    // MARK: - Debugging
    
    /// Clear all shared data (testing only)
    func clearAllData() {
        sharedUserDefaults?.removePersistentDomain(forName: appGroupID)
        print("⚠️ All shared container data cleared")
    }
    
    /// Print all shared data for debugging
    func debugPrintAllData() {
        guard let defaults = sharedUserDefaults else { return }
        
        print("\n📊 Shared Container Data:")
        print("Active Session: \(getActiveSession() != nil ? "✓" : "✗")")
        print("Active Break: \(getActiveBreak() != nil ? "✓" : "✗")")
        print("Pending Interventions: \(getPendingInterventions().count)")
        print("Protected Apps: \(getProtectedApps().count)")
        print("Bypass Count Today: \(getBypassCountToday())")
        print()
    }
}
