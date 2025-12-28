import SwiftUI
import CoreData

/// Debug view to inspect Core Data contents and extension communication
struct DebugView: View {
    @State private var interventions: [InterventionLog] = []
    @State private var sessionInfo: String = "No active session"
    @State private var sharedData: String = ""
    
    var body: some View {
        List {
            // Session Status
            Section("Active Session") {
                Text(sessionInfo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Shared Container Data
            Section("Shared Container") {
                Text(sharedData)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button("Refresh") {
                    loadSharedData()
                }
            }
            
            // Intervention Logs
            Section("Intervention Logs (\(interventions.count))") {
                if interventions.isEmpty {
                    Text("No interventions logged yet")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(interventions, id: \.id) { log in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(log.appName ?? "Unknown")
                                .font(.headline)
                            Text("Type: \(log.type ?? "unknown")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if let timestamp = log.timestamp {
                                Text(timestamp.formatted())
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            // Daily Stats
            Section("Today's Stats") {
                dailyStatsView()
            }
            
            // Actions
            Section("Debug Actions") {
                Button("Refresh Data") {
                    loadInterventions()
                    loadSharedData()
                }
                
                Button("Test: Add Fake Intervention") {
                    testAddIntervention()
                }
                
                Button("Clear All Interventions", role: .destructive) {
                    clearInterventions()
                }
                
                Button("Clear Shared Container", role: .destructive) {
                    SharedContainerManager.shared.clearAllData()
                    loadSharedData()
                }
                
                Button("Print Debug Info") {
                    printDebugInfo()
                }
            }
        }
        .navigationTitle("Debug Center")
        .onAppear {
            loadInterventions()
            loadSharedData()
            loadSessionInfo()
        }
    }
    
    private func loadInterventions() {
        // First, sync pending interventions from shared container
        syncPendingInterventions()
        
        let request = NSFetchRequest<InterventionLog>(entityName: "InterventionLog")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \InterventionLog.timestamp, ascending: false)]
        
        do {
            interventions = try CoreDataManager.shared.context.fetch(request)
        } catch {
            print("Failed to fetch interventions: \(error)")
        }
    }
    
    private func syncPendingInterventions() {
        print("🔄 syncPendingInterventions() called")
        
        let sharedManager = SharedContainerManager.shared
        let pendingInterventions = sharedManager.getPendingInterventions()
        
        print("📊 Retrieved \(pendingInterventions.count) pending interventions from shared container")
        
        guard !pendingInterventions.isEmpty else {
            print("⚠️ No pending interventions to sync, returning early")
            return
        }
        
        print("📥 Syncing \(pendingInterventions.count) pending interventions to Core Data...")
        
        let context = CoreDataManager.shared.context
        
        for interventionData in pendingInterventions {
            guard let bundleID = interventionData["bundleID"] as? String,
                  let appName = interventionData["appName"] as? String,
                  let type = interventionData["type"] as? String,
                  let timestamp = interventionData["timestamp"] as? TimeInterval else {
                print("⚠️ Invalid intervention data: \(interventionData)")
                continue
            }
            
            // Create InterventionLog entity
            let log = NSEntityDescription.insertNewObject(forEntityName: "InterventionLog", into: context) as! InterventionLog
            log.id = UUID()
            log.appBundleID = bundleID
            log.appName = appName
            log.type = type
            log.timestamp = Date(timeIntervalSince1970: timestamp)
            
            print("✓ Created intervention log: \(appName)")
        }
        
        // Save to Core Data
        do {
            try CoreDataManager.shared.save()
            print("✓ Synced \(pendingInterventions.count) interventions to Core Data")
            
            // Clear pending interventions after syncing
            sharedManager.clearPendingInterventions()
        } catch {
            print("❌ Failed to save interventions to Core Data: \(error)")
        }
    }
    
    private func loadSessionInfo() {
        let sharedManager = SharedContainerManager.shared
        if let session = sharedManager.getActiveSession() {
            let elapsed = Date().timeIntervalSince(session.startTime)
            let remaining = Double(session.durationSeconds) - elapsed
            sessionInfo = """
            ID: \(session.id.uuidString.prefix(8))...
            Duration: \(session.durationSeconds)s
            Elapsed: \(Int(elapsed))s
            Remaining: \(Int(remaining))s
            Apps: \(session.protectedApps.count)
            Valid: \(sharedManager.isSessionValid() ? "✓" : "✗")
            """
        } else {
            sessionInfo = "No active session"
        }
    }
    
    private func loadSharedData() {
        let sharedManager = SharedContainerManager.shared
        
        var info = ""
        
        // Pending interventions
        let pending = sharedManager.getPendingInterventions()
        info += "Pending Interventions: \(pending.count)\n"
        
        // DEBUG: Print actual pending data
        if pending.count > 0 {
            print("🔍 DEBUG: Found \(pending.count) pending interventions:")
            for (index, item) in pending.enumerated() {
                print("  [\(index)]: \(item)")
            }
        } else {
            print("⚠️ DEBUG: No pending interventions found in shared container")
        }
        
        // Protected apps
        let protectedApps = sharedManager.getProtectedApps()
        info += "Protected Apps: \(protectedApps.count)\n"
        
        // Bypass count
        let bypasses = sharedManager.getBypassCountToday()
        info += "Bypasses Today: \(bypasses)\n"
        
        // Active break
        if let breakInfo = sharedManager.getActiveBreak() {
            let elapsed = Date().timeIntervalSince(breakInfo.startTime)
            let remaining = Double(breakInfo.durationSeconds) - elapsed
            info += "Active Break: \(Int(remaining))s remaining"
        } else {
            info += "No active break"
        }
        
        sharedData = info
    }
    
    @ViewBuilder
    private func dailyStatsView() -> some View {
        if let todayStat = getTodayStats() {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sessions: \(todayStat.totalSessionsCompleted)")
                Text("Focus Time: \(todayStat.totalFocusTimeSeconds)s")
                Text("Completion Rate: \(String(format: "%.0f%%", todayStat.sessionCompletionRate))")
            }
        } else {
            Text("No stats for today")
                .foregroundColor(.secondary)
        }
    }
    
    private func getTodayStats() -> DailyStat? {
        let request = NSFetchRequest<DailyStat>(entityName: "DailyStat")
        let today = Calendar.current.startOfDay(for: Date())
        request.predicate = NSPredicate(format: "date == %@", today as NSDate)
        
        do {
            let stats = try CoreDataManager.shared.context.fetch(request)
            return stats.first
        } catch {
            print("Error loading daily stats: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func clearInterventions() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "InterventionLog")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try CoreDataManager.shared.context.execute(deleteRequest)
            try CoreDataManager.shared.save()
            loadInterventions()
        } catch {
            print("Failed to clear interventions: \(error)")
        }
    }
    
    private func printDebugInfo() {
        print("\n📊 === DEBUG INFO ===")
        print("Interventions: \(interventions.count)")
        
        let sharedManager = SharedContainerManager.shared
        sharedManager.debugPrintAllData()
        
        print("Active Session: \(sharedManager.getActiveSession() != nil ? "✓" : "✗")")
        print("Active Break: \(sharedManager.getActiveBreak() != nil ? "✓" : "✗")")
        print("===================\n")
    }
    
    private func testAddIntervention() {
        print("🧪 TEST: Adding fake intervention to shared container...")
        
        let sharedManager = SharedContainerManager.shared
        sharedManager.logIntervention(
            bundleID: "com.test.app",
            appName: "Test App",
            type: "block",
            timestamp: Date()
        )
        
        print("✓ TEST: Fake intervention added")
        
        // Refresh to see if it appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            loadSharedData()
            loadInterventions()
        }
    }
}

#Preview {
    DebugView()
}
