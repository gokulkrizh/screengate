import Foundation

/// Manages shared container communication between main app and Device Activity extensions
/// Uses App Groups and shared UserDefaults for real-time data sync
class SharedContainerManager {
    static let shared = SharedContainerManager()
    
    // App Group identifier must match entitlements
    private let appGroupID = "group.com.gia.screengate"
    
    private lazy var sharedUserDefaults: UserDefaults? = {
        UserDefaults(suiteName: appGroupID)
    }()
    
    // MARK: - Intervention Logging
    
    /// Log an intervention event from extension (app launch attempt)
    func logIntervention(
        bundleID: String,
        appName: String,
        type: String,
        timestamp: Date
    ) {
        let interventionData: [String: Any] = [
            "bundleID": bundleID,
            "appName": appName,
            "type": type,
            "timestamp": timestamp.timeIntervalSince1970,
            "dateLogged": ISO8601DateFormatter().string(from: timestamp)
        ]
        
        var interventions = sharedUserDefaults?.array(forKey: "pendingInterventions") as? [[String: Any]] ?? []
        interventions.append(interventionData)
        sharedUserDefaults?.set(interventions, forKey: "pendingInterventions")
        sharedUserDefaults?.synchronize()
        
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
    }
    
    // MARK: - Session State
    
    /// Get active session from shared container
    func getActiveSession() -> (id: UUID, startTime: Date, durationSeconds: Int, protectedApps: [String])? {
        guard let sessionData = sharedUserDefaults?.dictionary(forKey: "activeSession") as? [String: Any],
              let idString = sessionData["sessionId"] as? String,
              let id = UUID(uuidString: idString),
              let startTime = sessionData["startTime"] as? TimeInterval,
              let durationSeconds = sessionData["durationSeconds"] as? Int,
              let protectedApps = sessionData["protectedAppBundles"] as? [String] else {
            return nil
        }
        
        return (
            id: id,
            startTime: Date(timeIntervalSince1970: startTime),
            durationSeconds: durationSeconds,
            protectedApps: protectedApps
        )
    }
    
    /// Clear active session (called when session ends)
    func clearActiveSession() {
        sharedUserDefaults?.removeObject(forKey: "activeSession")
        print("✓ Active session cleared from shared container")
    }
    
    /// Check if session is still valid (not expired)
    func isSessionValid() -> Bool {
        guard let session = getActiveSession() else { return false }
        
        let elapsed = Date().timeIntervalSince(session.startTime)
        return elapsed < TimeInterval(session.durationSeconds)
    }
}
