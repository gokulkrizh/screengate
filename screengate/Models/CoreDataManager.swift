import Foundation
import CoreData

/// Central Core Data manager for all database operations
class CoreDataManager {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    private init() {
        container = NSPersistentContainer(name: "ScreenGate")
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Core Data error: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Save Operations
    
    /// Save changes to Core Data
    func save() throws {
        let context = container.viewContext
        if context.hasChanges {
            try context.save()
        }
    }
    
    /// Save in background context
    func saveBackground(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask { context in
            block(context)
            
            do {
                try context.save()
            } catch {
                print("Background save error: \(error)")
            }
        }
    }
    
    // MARK: - User Operations
    
    /// Create or get current user
    func getCurrentOrCreateUser(email: String = "") -> User {
        let request = NSFetchRequest<User>(entityName: "User")
        
        do {
            if let user = try context.fetch(request).first {
                return user
            }
        } catch {
            print("Error fetching user: \(error)")
        }
        
        let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as! User
        user.id = UUID()
        user.email = email.isEmpty ? nil : email
        user.createdAt = Date()
        user.lastActiveAt = Date()
        user.subscriptionStatus = "trial"
        user.trialStartDate = Date()
        user.trialEndDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        user.notificationsEnabled = true
        user.analyticsEnabled = true
        user.dailyGoalMinutes = 120
        user.preferredBreakDurationMinutes = 15
        user.allowBreaksDuringSession = true
        user.allowEmergencyBypass = false
        
        try? save()
        return user
    }
    
    /// Update user last active time
    func updateLastActiveTime(user: User) {
        user.lastActiveAt = Date()
        try? save()
    }
    
    // MARK: - Protected App Operations
    
    /// Add protected app
    func addProtectedApp(user: User, bundleID: String, displayName: String, category: String) -> ProtectedApp {
        let app = NSEntityDescription.insertNewObject(forEntityName: "ProtectedApp", into: context) as! ProtectedApp
        app.id = UUID()
        app.bundleIdentifier = bundleID
        app.displayName = displayName
        app.category = category
        app.addedAt = Date()
        app.isEnabled = true
        app.blockingMode = "delay" // Default to delay mode
        app.delayDurationSeconds = 10
        app.allowBreakDuring = true
        app.user = user
        
        user.addToProtectedApps(app)
        try? save()
        return app
    }
    
    /// Remove protected app
    func removeProtectedApp(_ app: ProtectedApp) {
        context.delete(app)
        try? save()
    }
    
    // MARK: - Focus Session Operations
    
    /// Create new focus session
    func createFocusSession(user: User, name: String, durationMinutes: Int, protectedApps: [ProtectedApp]) -> FocusSession {
        let session = NSEntityDescription.insertNewObject(forEntityName: "FocusSession", into: context) as! FocusSession
        session.id = UUID()
        session.name = name
        session.startTime = Date()
        session.scheduledDurationMinutes = Int32(durationMinutes)
        session.status = "active"
        session.isRecurring = false
        session.allowManualBreaks = true
        session.completionPercentage = 0
        session.wasSuccessful = false
        session.user = user
        
        for app in protectedApps {
            session.addToProtectedApps(app)
        }
        
        user.addToFocusSessions(session)
        try? save()
        return session
    }
    
    /// Complete focus session
    func completeFocusSession(_ session: FocusSession, successful: Bool) {
        session.endTime = Date()
        session.status = "completed"
        session.wasSuccessful = successful
        if let startTime = session.startTime {
            session.actualDurationSeconds = Int64(Date().timeIntervalSince(startTime))
        }
        
        if session.scheduledDurationMinutes > 0 {
            let completionPercent = (Double(session.actualDurationSeconds) / Double(session.scheduledDurationMinutes * 60)) * 100
            session.completionPercentage = min(100, completionPercent)
        }
        
        try? save()
    }
    
    // MARK: - Intervention Log Operations
    
    /// Log intervention event
    func logIntervention(user: User, type: String, appBundleID: String, appName: String, sessionID: UUID? = nil) -> InterventionLog {
        let log = NSEntityDescription.insertNewObject(forEntityName: "InterventionLog", into: context) as! InterventionLog
        log.id = UUID()
        log.type = type
        log.appBundleID = appBundleID
        log.appName = appName
        log.timestamp = Date()
        log.sessionID = sessionID
        log.user = user
        
        user.addToInterventionLogs(log)
        try? save()
        return log
    }
    
    // MARK: - Daily Stats Operations
    
    /// Get or create daily stats for today
    func getOrCreateDailyStat(for user: User) -> DailyStat {
        let request = NSFetchRequest<DailyStat>(entityName: "DailyStat")
        let today = Calendar.current.startOfDay(for: Date())
        request.predicate = NSPredicate(format: "date == %@ AND user == %@", today as NSDate, user)
        
        if let existing = try? context.fetch(request).first {
            return existing
        }
        
        let stat = NSEntityDescription.insertNewObject(forEntityName: "DailyStat", into: context) as! DailyStat
        stat.id = UUID()
        stat.date = today
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        stat.dayOfWeek = dateFormatter.string(from: Date()).lowercased()
        
        stat.totalSessionsScheduled = 0
        stat.totalSessionsCompleted = 0
        stat.totalFocusTimeSeconds = 0
        stat.sessionCompletionRate = 0
        stat.interventionSuccessRate = 0
        stat.focusGoalAchieved = false
        stat.user = user
        
        user.addToDailyStats(stat)
        try? save()
        return stat
    }
    
    // MARK: - Milestone Operations
    
    /// Initialize all milestones for new user
    func initializeMilestones(for user: User) {
        let milestoneDefinitions: [(type: String, title: String, descText: String, icon: String, target: Int32)] = [
            ("first_session", "First Session", "Complete your first focus session", "🎯", 1),
            ("seven_day_streak", "Week Warrior", "Maintain a 7-day focus streak", "🔥", 7),
            ("thirty_day_streak", "Monthly Master", "Maintain a 30-day focus streak", "👑", 30),
            ("total_hours", "Hour Challenger", "Accumulate 10 hours of focus time", "⏱️", 36000),
            ("session_completion", "Perfect Focus", "Complete 10 consecutive sessions", "✨", 10),
            ("intervention_resistance", "Resistant", "Successfully resist 50 interventions", "💪", 50)
        ]
        
        for def in milestoneDefinitions {
            let milestone = NSEntityDescription.insertNewObject(forEntityName: "Milestone", into: context) as! Milestone
            milestone.id = UUID()
            milestone.type = def.type
            milestone.title = def.title
            milestone.desc = def.descText
            milestone.icon = def.icon
            milestone.targetValue = def.target
            milestone.currentValue = 0
            milestone.progress = 0
            milestone.streakCount = 0
            milestone.maxStreakCount = 0
            milestone.notificationSent = false
            milestone.celebratedByUser = false
            milestone.user = user
            
            user.addToMilestones(milestone)
        }
        
        try? save()
    }
    
    // MARK: - Cleanup
    
    /// Delete all user data (for account deletion)
    func deleteAllUserData(for user: User) throws {
        context.delete(user)
        try save()
    }
    
    /// Reset Core Data (for testing)
    func resetCoreData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        try? container.persistentStoreCoordinator.execute(deleteRequest, with: context)
    }
}
