import Foundation
import FamilyControls
import UserNotifications
import DeviceActivity

@Observable
final class BlockManager {
    // MARK: - Published State
    
    var blocks: [Block] = []
    var activeBlock: Block?
    var pausedUntil: Date?
    
    // MARK: - Private Dependencies
    
    private let deviceActivityManager = DeviceActivityManager()
    private let userDefaults: UserDefaults
    private var pauseTimer: Timer?
    
    // MARK: - Constants (Optimized per-block storage)
    
    private let blockIdsKey = "blockIds"  // [String] array of block UUIDs
    private let activeBlockIdKey = "activeBlockId"
    private let pausedUntilKey = "pausedUntil"
    
    // Helper function for per-block keys
    private func blockKey(_ id: UUID) -> String { "block_\(id.uuidString)" }
    
    // MARK: - Computed Properties
    
    /// The block that should be displayed on the Home screen (first prioritized block)
    var displayBlock: Block? {
        return prioritizedBlocks.first
    }
    
    /// Prioritized blocks for display - active blocks first (most recent start), then upcoming (soonest start)
    var prioritizedBlocks: [Block] {
        let now = Date()
        let calendar = Calendar.current
        let todayWeekday = calendar.component(.weekday, from: now)
        
        // Helper: Check if block should run today based on repeat rules
        func shouldRunToday(_ block: Block) -> Bool {
            guard let repeatDays = block.schedule.repeatDays else {
                // No repeat pattern: one-time block
                // Check if scheduled date matches today
                if let startTime = block.schedule.startTime {
                    return calendar.isDate(startTime, inSameDayAs: now)
                }
                return true // For blockNow types without specific date
            }
            
            // Repeating block: check if today is in repeatDays
            return repeatDays.contains(todayWeekday)
        }
        
        // Helper: Convert block schedule to actual Date for comparison
        func toDate(from block: Block, useStart: Bool) -> Date? {
            // Special handling for blockNow type - uses createdAt + duration
            if block.type == .blockNow {
                if useStart {
                    return block.createdAt
                } else {
                    guard let duration = block.schedule.duration else { return nil }
                    return block.createdAt.addingTimeInterval(duration)
                }
            }
            
            // For scheduled blocks, use startTime/endTime
            let timeDate = useStart ? block.schedule.startTime : block.schedule.endTime
            guard let timeDate = timeDate else { return nil }
            
            // For repeating blocks, use today's date + scheduled time
            if block.schedule.repeatDays != nil {
                var todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
                let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: timeDate)
                todayComponents.hour = timeComponents.hour
                todayComponents.minute = timeComponents.minute
                todayComponents.second = timeComponents.second
                return calendar.date(from: todayComponents)
            }
            
            // For one-time blocks, use the stored date
            return timeDate
        }
        
        // Filter blocks that should run today
        let relevantBlocks = blocks.filter { shouldRunToday($0) }
        
        // Separate into active and upcoming
        let activeBlocks = relevantBlocks.filter { block in
            guard let startDate = toDate(from: block, useStart: true),
                  let endDate = toDate(from: block, useStart: false) else {
                return false
            }
            return now >= startDate && now < endDate
        }
        
        let upcomingBlocks = relevantBlocks.filter { block in
            guard let startDate = toDate(from: block, useStart: true) else {
                return false
            }
            return now < startDate
        }
        
        // Sort active blocks by most recent start (newest first)
        let sortedActive = activeBlocks.sorted { block1, block2 in
            guard let start1 = toDate(from: block1, useStart: true),
                  let start2 = toDate(from: block2, useStart: true) else {
                return false
            }
            return start1 > start2 // Most recent (later) start time first
        }
        
        // Sort upcoming blocks by soonest start (earliest first)
        let sortedUpcoming = upcomingBlocks.sorted { block1, block2 in
            guard let start1 = toDate(from: block1, useStart: true),
                  let start2 = toDate(from: block2, useStart: true) else {
                return false
            }
            return start1 < start2 // Soonest (earlier) start time first
        }
        
        return sortedActive + sortedUpcoming
    }
    
    // MARK: - Initialization
    
    init() {
        self.userDefaults = UserDefaults(suiteName: "group.com.gia.screendiet") ?? .standard
        
        // Load from UserDefaults asynchronously to avoid blocking UI
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.loadFromUserDefaults()
        }
        
        // ✅ REACTIVE: Listen for Darwin notifications from extension
        setupDarwinNotificationObserver()
    }
    
    deinit {
        pauseTimer?.invalidate()
        // Remove Darwin notification observer
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let observer = Unmanaged.passUnretained(self).toOpaque()
        CFNotificationCenterRemoveObserver(center, observer, nil, nil)
    }
    
    // MARK: - Darwin Notification Observer (Cross-Process Communication)
    
    private func setupDarwinNotificationObserver() {
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let observer = Unmanaged.passUnretained(self).toOpaque()
        
        CFNotificationCenterAddObserver(
            center,
            observer,
            { (center, observer, name, object, userInfo) in
                guard let observer = observer else { return }
                let manager = Unmanaged<BlockManager>.fromOpaque(observer).takeUnretainedValue()
                
                DispatchQueue.main.async {
                    manager.loadFromUserDefaults()
                    print("✅ [BlockManager] Received Darwin notification, reloaded blocks")
                }
            },
            "com.gia.screendiet.blocksChanged" as CFString,
            nil,
            .deliverImmediately
        )
        
        print("✅ [BlockManager] Darwin notification observer registered")
    }
    
    // MARK: - Computed Properties
    
    var upcomingBlocks: [Block] {
        blocks
            .filter { $0.type == .scheduled }
            .filter { !$0.isActive }
            .sorted { ($0.schedule.startTime ?? Date()) < ($1.schedule.startTime ?? Date()) }
    }
    
    var todayBlocks: [Block] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? Date()
        
        return blocks.filter { block in
            guard let startTime = block.schedule.startTime else { return false }
            return startTime >= today && startTime < tomorrow
        }
    }
    
    var hasActiveSession: Bool {
        activeBlock != nil && !isPaused
    }
    
    var isPaused: Bool {
        guard let pausedUntil = pausedUntil else { return false }
        return pausedUntil > Date()
    }
    
    var pauseTimeRemaining: TimeInterval? {
        guard let pausedUntil = pausedUntil else { return nil }
        let remaining = pausedUntil.timeIntervalSince(Date())
        return remaining > 0 ? remaining : nil
    }
    
    // MARK: - CRUD Operations
    
    /// Create a new block (in-memory only - not persisted until activated)
    func createBlock(_ block: Block) throws {
        var newBlock = block
        newBlock.createdAt = Date()
        blocks.append(newBlock)
        // Don't save to UserDefaults yet - only save after successful activation
        
        // Post notification for successful creation
        notifyBlockCreated(newBlock)
    }
    
    /// Update an existing block (O(1) per-block update)
    func updateBlock(_ block: Block) throws {
        if let index = blocks.firstIndex(where: { $0.id == block.id }) {
            blocks[index] = block
            
            // Update individual block
            let blockData = try JSONEncoder().encode(block)
            userDefaults.set(blockData, forKey: blockKey(block.id))
            userDefaults.synchronize()
            
            notifyBlockUpdated(block)
        }
    }
    
    /// Delete a block
    func deleteBlock(_ block: Block) throws {
        // Stop all monitors associated with this block
        Task {
            await stopAllMonitorsForBlock(block)
        }
        
        blocks.removeAll { $0.id == block.id }
        
        // If deleted block was active, clear active state
        if activeBlock?.id == block.id {
            activeBlock = nil
        }
        
        saveToUserDefaults()
        notifyBlockDeleted(block)
    }
    
    /// Get block by ID
    func getBlock(by id: UUID) -> Block? {
        blocks.first { $0.id == id }
    }
    
    // MARK: - Session Control
    
    /// Activate a block (apply restrictions immediately or start schedule)
    func activateBlock(_ block: Block) async throws {
        var activeBlock = block
        activeBlock.isActive = true
        activeBlock.isPaused = false
        activeBlock.pausedUntil = nil
        
        // Generate and save activityName for linking to DeviceActivityCenter
        let activityName = DeviceActivityName("com.gia.screengate.\(block.id.uuidString)")
        activeBlock.activityName = activityName
        
        // Store original state for rollback on failure
        let originalActiveBlock = self.activeBlock
        let originalBlocksState = blocks
        
        // Update in-memory state (will rollback if monitor fails)
        self.activeBlock = activeBlock
        if let index = blocks.firstIndex(where: { $0.id == block.id }) {
            blocks[index] = activeBlock
        }
        
        // Determine action based on block type
        // NOTE: saveToUserDefaults() is called AFTER successful monitor setup
        do {
            switch block.type {
            case .blockNow:
            // For blockNow: Two strategies based on duration
            guard let duration = block.schedule.duration else {
                throw NSError(domain: "BlockManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Block duration is required"])
            }
            
            // Apply immediate restrictions first
            try deviceActivityManager.applyImmediateRestrictions(
                activitySelection: block.appSelection
            )
            
            let now = Date()
            let monitorName = block.getMonitorName()
            
            if duration < 15 * 60 {
                // For blocks < 15 minutes:
                // - Schedule: Always 15 min (DeviceActivity minimum)
                // - Warning: Fires at ACTUAL duration by calculating offset from end
                //   Formula: warningTime = 15min - duration
                //   Example: 5min block → warning at (15-5) = 10min before end = at 5min mark ✅
                // - Threshold: 0 (not used)
                // - Cleanup: Handle in intervalWillEndWarning callback
                // - Event name: "blocknow-short" for extension routing
                
                let scheduleEnd = now.addingTimeInterval(15 * 60)  // 15 min schedule
                let warningOffset = (15 * 60) - duration           // Time BEFORE end
                let warningMinutes = Int(warningOffset / 60)
                
                try deviceActivityManager.startMonitor(
                    activitySelection: block.appSelection,
                    shieldThreshold: .hms(0, 0, 0),              // Threshold = 0 (not used)
                    start: now,
                    end: scheduleEnd,                             // 15 min
                    repeatDaily: false,
                    activityName: block.id.uuidString,
                    eventName: "blocknow-short",                  // Descriptive event name
                    warningTimeMinutes: warningMinutes            // e.g., 10 for 5-min block
                )
                
            } else {
                // For blocks ≥ 15 minutes:
                // - Schedule: Actual duration
                // - Warning: 10 min before end (standard)
                // - Threshold: 0 (not used)
                // - Cleanup: Handle in intervalDidEnd callback
                // - Event name: "blocknow-long" for extension routing
                
                let scheduleEnd = now.addingTimeInterval(duration)
                
                try deviceActivityManager.startMonitor(
                    activitySelection: block.appSelection,
                    shieldThreshold: .hms(0, 0, 0),              // Threshold = 0 (not used)
                    start: now,
                    end: scheduleEnd,                             // Actual duration
                    repeatDaily: false,
                    activityName: block.id.uuidString,
                    eventName: "blocknow-long",                   // Descriptive event name
                    warningTimeMinutes: 10                        // Standard 10 min warning
                )
            }
            
        case .scheduled:
            // Start monitor for scheduled time range
            if let startTime = block.schedule.startTime,
               let endTime = block.schedule.endTime {
                let isRepeating = block.schedule.isRepeating
                let dayMonitors = block.schedule.repeatDays ?? Set([Calendar.current.component(.weekday, from: Date())])
                
                // Calculate duration to determine if short block strategy needed
                let duration = endTime.timeIntervalSince(startTime)
                let isShortBlock = duration < 15 * 60
                
                // Create monitors for each day
                for day in dayMonitors {
                    let activityName = dayMonitors.count > 1 ? "\(block.id.uuidString).day\(day)" : block.id.uuidString
                    
                    if isShortBlock {
                        // Short scheduled block (< 15 min): Use warningTime strategy
                        // - Schedule: Always 15 min from start (DeviceActivity minimum)
                        // - Warning: Fires at ACTUAL end time
                        //   Formula: warningTime = 15min - duration
                        //   Example: 8:00-8:10 (10 min) → schedule 8:00-8:15, warning at 5 min before = 8:10 ✅
                        // - Cleanup: Handle in intervalWillEndWarning callback
                        // - Event name: "scheduled-short" for extension routing
                        
                        let calendar = Calendar.current
                        let extendedEnd = calendar.date(byAdding: .minute, value: 15, to: startTime) ?? endTime
                        let warningOffset = (15 * 60) - duration
                        let warningMinutes = Int(warningOffset / 60)
                        
                        try deviceActivityManager.startMonitor(
                            activitySelection: block.appSelection,
                            shieldThreshold: .hms(0, 0, 0),
                            start: startTime,
                            end: extendedEnd,                      // Start + 15 min
                            repeatDaily: isRepeating,
                            activityName: activityName,
                            eventName: "scheduled-short",          // Descriptive event name
                            warningTimeMinutes: warningMinutes     // Custom warning offset
                        )
                    } else {
                        // Long scheduled block (≥ 15 min): Use normal strategy
                        // - Schedule: Actual duration
                        // - Warning: 10 min before end (standard)
                        // - Cleanup: Handle in intervalDidEnd callback
                        // - Event name: "scheduled-long" for extension routing
                        
                        try deviceActivityManager.startMonitor(
                            activitySelection: block.appSelection,
                            shieldThreshold: .hms(0, 0, 0),
                            start: startTime,
                            end: endTime,                          // Actual end time
                            repeatDaily: isRepeating,
                            activityName: activityName,
                            eventName: "scheduled-long",           // Descriptive event name
                            warningTimeMinutes: 10                 // Standard 10 min warning
                        )
                    }
                }
            }
            
        case .appTimeLimit:
            // Start monitor with threshold
            if let startTime = block.schedule.startTime,
               let endTime = block.schedule.endTime,
               let threshold = block.schedule.threshold {
                let (h, m, _) = threshold.hms
                
                try deviceActivityManager.startMonitor(
                    activitySelection: block.appSelection,
                    shieldThreshold: .hms(h, m, 0),
                    start: startTime,
                    end: endTime,
                    repeatDaily: block.schedule.isRepeating,
                    activityName: block.id.uuidString,
                    eventName: "apptimelimit"                  // Descriptive event name
                )
            }
            
            case .openLimit:
                // Parked for v2 - no action yet
                break
            }
        } catch {
            // ❌ Monitor creation failed - rollback state
            print("❌ [BlockManager] Monitor creation failed: \(error)")
            self.activeBlock = originalActiveBlock
            self.blocks = originalBlocksState
            // Don't save - UserDefaults never had the failed block since we only save on success
            throw error  // Re-throw to notify caller
        }
        
        // ✅ Save to UserDefaults only after successful monitor setup
        saveToUserDefaults()
        
        postNotification(title: "\(block.name) started", body: "Focus session is now active")
    }
    
    /// Pause the active block (temporarily remove restrictions)
    func pauseBlock(for duration: TimeInterval) async throws {
        guard let activeBlock = activeBlock else { return }
        
        // Set pause expiry time
        let pauseExpiry = Date().addingTimeInterval(duration)
        self.pausedUntil = pauseExpiry
        
        // Remove restrictions temporarily
        try deviceActivityManager.removeRestrictions()
        
        // Update block state
        var updatedBlock = activeBlock
        updatedBlock.isPaused = true
        updatedBlock.pausedUntil = pauseExpiry
        
        self.activeBlock = updatedBlock
        if let index = blocks.firstIndex(where: { $0.id == activeBlock.id }) {
            blocks[index] = updatedBlock
        }
        
        saveToUserDefaults()
        
        // Start timer to resume when pause expires
        startPauseTimer()
        
        let minutes = Int(duration / 60)
        postNotification(
            title: "Session paused",
            body: "Your focus session will resume in \(minutes) minutes"
        )
    }
    
    /// Resume a paused block (re-apply restrictions)
    func resumeBlock() async throws {
        guard let activeBlock = activeBlock else { return }
        
        // Clear pause state
        self.pausedUntil = nil
        pauseTimer?.invalidate()
        pauseTimer = nil
        
        // Re-apply restrictions
        try deviceActivityManager.applyImmediateRestrictions(
            activitySelection: activeBlock.appSelection
        )
        
        // Update block state
        var updatedBlock = activeBlock
        updatedBlock.isPaused = false
        updatedBlock.pausedUntil = nil
        
        self.activeBlock = updatedBlock
        if let index = blocks.firstIndex(where: { $0.id == activeBlock.id }) {
            blocks[index] = updatedBlock
        }
        
        saveToUserDefaults()
        
        postNotification(title: "Session resumed", body: "Focus session is active again")
    }
    
    /// Cancel the active block (stop restrictions and clear active state)
    func cancelBlock() async throws {
        print("🔴 [BlockManager] cancelBlock called")
        guard let activeBlock = activeBlock else {
            print("⚠️ [BlockManager] No active block to cancel")
            return
        }
        
        print("🔴 [BlockManager] Canceling block: \(activeBlock.name)")
        
        // Remove restrictions immediately
        print("🔴 [BlockManager] Removing restrictions...")
        deviceActivityManager.removeRestrictions()
        print("✅ [BlockManager] Restrictions removed")
        
        // Stop all monitors for this block
        print("🔴 [BlockManager] Stopping monitors...")
        await stopAllMonitorsForBlock(activeBlock)
        print("✅ [BlockManager] Monitors stopped")
        
        // Clear active state
        print("🔴 [BlockManager] Clearing active state...")
        self.activeBlock = nil
        self.pausedUntil = nil
        pauseTimer?.invalidate()
        pauseTimer = nil
        print("✅ [BlockManager] Active state cleared")
        
        // Update block state in blocks array
        var updatedBlock = activeBlock
        updatedBlock.isActive = false
        updatedBlock.isPaused = false
        updatedBlock.pausedUntil = nil
        
        if let index = blocks.firstIndex(where: { $0.id == activeBlock.id }) {
            blocks[index] = updatedBlock
            print("✅ [BlockManager] Block updated in array")
        }
        
        saveToUserDefaults()
        print("✅ [BlockManager] State saved to UserDefaults")
        
        let reason = pausedUntil == nil ? "cancelled" : "expired"
        postNotification(title: "Session \(reason)", body: "Focus session has \(reason)")
        print("✅ [BlockManager] cancelBlock completed successfully")
    }
    
    /// Extend active block duration
    func extendBlock(by minutes: Int) async throws {
        guard let activeBlock = activeBlock else { return }
        
        let extensionTime = TimeInterval(minutes * 60)
        
        // Update duration
        var schedule = activeBlock.schedule
        if var duration = schedule.duration {
            duration += extensionTime
            schedule.duration = duration
            
            var updatedBlock = activeBlock
            updatedBlock.schedule = schedule
            self.activeBlock = updatedBlock
            
            if let index = blocks.firstIndex(where: { $0.id == activeBlock.id }) {
                blocks[index] = updatedBlock
            }
        }
        
        saveToUserDefaults()
        
        postNotification(
            title: "Session extended",
            body: "Added \(minutes) more minutes to your focus session"
        )
    }
    
    // MARK: - Persistence
    
    func saveToUserDefaults() {
        do {
            // Save all blocks with per-block keys (O(n) but only on explicit save)
            for block in blocks {
                let blockData = try JSONEncoder().encode(block)
                userDefaults.set(blockData, forKey: blockKey(block.id))
            }
            
            // Save blockIds array (triggers Combine observer)
            let ids = blocks.map { $0.id.uuidString }
            userDefaults.set(ids, forKey: blockIdsKey)
            
            // Save active block ID
            if let activeBlockId = activeBlock?.id {
                userDefaults.set(activeBlockId.uuidString, forKey: activeBlockIdKey)
            } else {
                userDefaults.removeObject(forKey: activeBlockIdKey)
            }
            
            // Save array of active block IDs for extension (block metadata no longer needed - using event names)
            let activeBlocks = blocks.filter { $0.isActive && !$0.isPaused }
            let activeBlockIds = activeBlocks.map { $0.id.uuidString }
            
            if !activeBlockIds.isEmpty {
                userDefaults.set(activeBlockIds, forKey: "activeBlockIds")
            } else {
                userDefaults.removeObject(forKey: "activeBlockIds")
            }
            
            // Save paused until time
            if let pausedUntil = pausedUntil {
                userDefaults.set(pausedUntil, forKey: pausedUntilKey)
            } else {
                userDefaults.removeObject(forKey: pausedUntilKey)
            }
            
            userDefaults.synchronize()
            
            // Post notification to trigger timeline rebuild
            CFNotificationCenterPostNotification(
                CFNotificationCenterGetDarwinNotifyCenter(),
                CFNotificationName("com.gia.screendiet.blocksChanged" as CFString),
                nil,
                nil,
                true
            )
            print("📡 [BlockManager] Posted blocks changed notification")
        } catch {
            print("Error saving blocks to UserDefaults: \(error)")
        }
    }
    
    /// Load blocks from per-block UserDefaults keys (O(n) on startup only)
    func loadFromUserDefaults() {
        guard let ids = userDefaults.stringArray(forKey: blockIdsKey) else {
            blocks = []
            activeBlock = nil
            return
        }
        
        // Load each block individually (O(n) but only on app launch)
        let loadedBlocks: [Block] = ids.compactMap { idString in
            guard let uuid = UUID(uuidString: idString),
                  let data = userDefaults.data(forKey: blockKey(uuid)),
                  let block = try? JSONDecoder().decode(Block.self, from: data) else {
                return nil
            }
            return block
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.blocks = loadedBlocks
            self?.updateActiveBlock()
            
            // Load paused until time
            if let pausedUntil = self?.userDefaults.object(forKey: self?.pausedUntilKey ?? "") as? Date {
                self?.pausedUntil = pausedUntil
                
                // If pause is still active, restart timer
                if pausedUntil > Date() {
                    self?.startPauseTimer()
                }
            }
        }
    }
    
    /// Update active block from activeBlockId (called by Combine observer)
    private func updateActiveBlock() {
        if let activeId = userDefaults.string(forKey: activeBlockIdKey),
           let uuid = UUID(uuidString: activeId) {
            activeBlock = blocks.first { $0.id == uuid }
        } else {
            activeBlock = nil
        }
    }
    
    // MARK: - Private Helpers
    
    private func stopAllMonitorsForBlock(_ block: Block) async {
        print("🔴 [BlockManager] stopAllMonitorsForBlock called for: \(block.name)")
        
        if block.schedule.repeatDays == nil || block.schedule.repeatDays!.count == 1 {
            // Single monitor
            print("🔴 [BlockManager] Stopping single monitor: \(block.id.uuidString)")
            deviceActivityManager.stopMonitor(activityName: block.id.uuidString)
        } else {
            // Multiple day-based monitors
            let dayMonitors = block.schedule.repeatDays ?? Set()
            print("🔴 [BlockManager] Stopping \(dayMonitors.count) day-based monitors")
            for day in dayMonitors {
                let activityName = "\(block.id.uuidString).day\(day)"
                print("🔴 [BlockManager] Stopping monitor for day \(day): \(activityName)")
                deviceActivityManager.stopMonitor(activityName: activityName)
            }
        }
        print("✅ [BlockManager] All monitors stopped")
    }
    
    private func startPauseTimer() {
        pauseTimer?.invalidate()
        pauseTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if let pausedUntil = self.pausedUntil, pausedUntil <= Date() {
                // Pause expired, resume automatically
                Task {
                    try await self.resumeBlock()
                }
            }
        }
    }
    
    // MARK: - Notifications
    
    private func notifyBlockCreated(_ block: Block) {
        postNotification(title: "Block created", body: block.name)
    }
    
    private func notifyBlockUpdated(_ block: Block) {
        postNotification(title: "Block updated", body: block.name)
    }
    
    private func notifyBlockDeleted(_ block: Block) {
        postNotification(title: "Block deleted", body: block.name)
    }
    
    private func postNotification(title: String, body: String) {
        return // Disable for now
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error posting notification: \(error)")
            }
        }
    }
}
