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
    
    // Helper functions for per-block keys
    private func blockKey(_ id: UUID) -> String { "block_\(id.uuidString)" }
    private func metadataKey(_ id: UUID) -> String { "activeBlockMetadata_\(id.uuidString)" }
    
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
    
    /// Create a new block and save it
    func createBlock(_ block: Block) throws {
        var newBlock = block
        newBlock.createdAt = Date()
        blocks.append(newBlock)
        saveToUserDefaults()
        
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
        
        self.activeBlock = activeBlock
        
        // Update in blocks array
        if let index = blocks.firstIndex(where: { $0.id == block.id }) {
            blocks[index] = activeBlock
        }
        
        saveToUserDefaults()
        
        // Determine action based on block type
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
                
                let scheduleEnd = now.addingTimeInterval(15 * 60)  // 15 min schedule
                let warningOffset = (15 * 60) - duration           // Time BEFORE end
                let warningMinutes = Int(warningOffset / 60)
                
                try deviceActivityManager.startMonitor(
                    activitySelection: block.appSelection,
                    shieldThreshold: .hms(0, 0, 0),              // Threshold = 0 (not used)
                    start: now,
                    end: scheduleEnd,                             // 15 min
                    repeatDaily: false,
                    activityName: monitorName.rawValue,
                    warningTimeMinutes: warningMinutes            // e.g., 10 for 5-min block
                )
                
            } else {
                // For blocks ≥ 15 minutes:
                // - Schedule: Actual duration
                // - Warning: 10 min before end (standard)
                // - Threshold: 0 (not used)
                // - Cleanup: Handle in intervalDidEnd callback
                
                let scheduleEnd = now.addingTimeInterval(duration)
                
                try deviceActivityManager.startMonitor(
                    activitySelection: block.appSelection,
                    shieldThreshold: .hms(0, 0, 0),              // Threshold = 0 (not used)
                    start: now,
                    end: scheduleEnd,                             // Actual duration
                    repeatDaily: false,
                    activityName: monitorName.rawValue,
                    warningTimeMinutes: 10                        // Standard 10 min warning
                )
            }
            
        case .scheduled:
            // Start monitor for scheduled time range
            if let startTime = block.schedule.startTime,
               let endTime = block.schedule.endTime {
                let isRepeating = block.schedule.isRepeating
                let dayMonitors = block.schedule.repeatDays ?? Set([Calendar.current.component(.weekday, from: Date())])
                
                // Create monitors for each day
                for day in dayMonitors {
                    let monitorName = block.getMonitorName(for: day)
                    try deviceActivityManager.startMonitor(
                        activitySelection: block.appSelection,
                        shieldThreshold: .hms(0, 0, 0),
                        start: startTime,
                        end: endTime,
                        repeatDaily: isRepeating,
                        activityName: monitorName.rawValue
                    )
                }
            }
            
        case .appTimeLimit:
            // Start monitor with threshold
            if let startTime = block.schedule.startTime,
               let endTime = block.schedule.endTime,
               let threshold = block.schedule.threshold {
                let monitorName = block.getMonitorName()
                let (h, m, _) = threshold.hms
                try deviceActivityManager.startMonitor(
                    activitySelection: block.appSelection,
                    shieldThreshold: .hms(h, m, 0),
                    start: startTime,
                    end: endTime,
                    repeatDaily: block.schedule.isRepeating,
                    activityName: monitorName.rawValue
                )
            }
            
        case .openLimit:
            // Parked for v2 - no action yet
            break
        }
        
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
        guard let activeBlock = activeBlock else { return }
        
        // Remove restrictions immediately
        try deviceActivityManager.removeRestrictions()
        
        // Stop all monitors for this block
        await stopAllMonitorsForBlock(activeBlock)
        
        // Clear active state
        self.activeBlock = nil
        self.pausedUntil = nil
        pauseTimer?.invalidate()
        pauseTimer = nil
        
        // Update block state in blocks array
        var updatedBlock = activeBlock
        updatedBlock.isActive = false
        updatedBlock.isPaused = false
        updatedBlock.pausedUntil = nil
        
        if let index = blocks.firstIndex(where: { $0.id == activeBlock.id }) {
            blocks[index] = updatedBlock
        }
        
        saveToUserDefaults()
        
        let reason = pausedUntil == nil ? "cancelled" : "expired"
        postNotification(title: "Session \(reason)", body: "Focus session has \(reason)")
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
            
            // Save block-specific metadata for ALL active blocks (supports multiple concurrent blocks)
            let activeBlocks = blocks.filter { $0.isActive && !$0.isPaused }
            var activeBlockIds: [String] = []
            
            for block in activeBlocks {
                var metadata: [String: Any] = [:]
                metadata["id"] = block.id.uuidString
                metadata["type"] = block.type.rawValue
                metadata["createdAt"] = block.createdAt
                if let duration = block.schedule.duration {
                    metadata["duration"] = duration
                    // Pre-calculate isShortBlock to avoid calculation in extension (limited 5MB memory)
                    metadata["isShortBlock"] = (block.type == .blockNow && duration < 15 * 60)
                }
                
                userDefaults.set(metadata, forKey: metadataKey(block.id))
                activeBlockIds.append(block.id.uuidString)
            }
            
            // Save array of active block IDs for extension
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
        if block.schedule.repeatDays == nil {
            // Single monitor
            let monitorName = block.getMonitorName()
            deviceActivityManager.stopMonitor(activityName: monitorName.rawValue)
        } else {
            // Multiple day-based monitors
            let dayMonitors = block.schedule.repeatDays ?? Set()
            for day in dayMonitors {
                let monitorName = block.getMonitorName(for: day)
                deviceActivityManager.stopMonitor(activityName: monitorName.rawValue)
            }
        }
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
