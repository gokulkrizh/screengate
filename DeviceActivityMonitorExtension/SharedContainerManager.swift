import Foundation

/// Manages shared container communication between main app and Device Activity extensions
class SharedContainerManager {
    static let shared = SharedContainerManager()
    
    private let appGroupID = "group.com.gia.screengate"
    private lazy var sharedUserDefaults = UserDefaults(suiteName: appGroupID)
    
    // MARK: - Intervention Logging
    
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
        
        print("✓ Intervention logged: \(appName) (\(type))")
    }
    
    // MARK: - Session State
    
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
    
    func clearActiveSession() {
        sharedUserDefaults?.removeObject(forKey: "activeSession")
        print("✓ Active session cleared")
    }
    
    func clearActiveBreak() {
        sharedUserDefaults?.removeObject(forKey: "activeBreak")
        print("✓ Active break cleared")
    }
    
    func isSessionValid() -> Bool {
        guard let session = getActiveSession() else { return false }
        
        let elapsed = Date().timeIntervalSince(session.startTime)
        return elapsed < TimeInterval(session.durationSeconds)
    }
}
