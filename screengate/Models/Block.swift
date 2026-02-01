import Foundation
import FamilyControls
import DeviceActivity

// MARK: - Block Model

struct Block: Codable, Identifiable {
    let id: UUID
    var name: String
    var icon: String
    var iconColor: String  // Hex color for Codable support
    var type: BlockType
    var appSelection: FamilyActivitySelection
    var schedule: BlockSchedule
    var strictMode: StrictMode
    var isActive: Bool
    var isPaused: Bool
    var pausedUntil: Date?
    var createdAt: Date
    var activityName: DeviceActivityName?  // Link to system monitor
    var appCount: Int?
    var isOverlapped: Bool = false  // True if other blocks overlap with this one
    var isActiveAmongOverlaps: Bool = false  // True if this is the active one among overlapping blocks
    var appListId: UUID?
    var appListName: String?
    
    /// Block type determines how the block is executed
    enum BlockType: String, Codable, CaseIterable {
        case scheduled      // Time-based recurring or one-time
        case blockNow       // Immediate timer-based block
        case appTimeLimit   // Threshold-based daily usage limit
        case openLimit      // Count-based limit (parked for v2)
    }
    
    /// Schedule configuration for the block
    struct BlockSchedule: Codable {
        var startTime: Date?           // For scheduled blocks: start time of interval
        var endTime: Date?             // For scheduled blocks: end time of interval
        var duration: TimeInterval?    // For blockNow: total duration in seconds
        var threshold: TimeInterval?   // For appTimeLimit: daily usage limit in seconds
        var repeatDays: Set<Int>?      // 1=Mon, 2=Tue, ... 7=Sun; nil = one-time
        var isRepeating: Bool = false  // Daily repeat flag for scheduled blocks
        
        // ✅ Custom Codable: Set<Int> needs Array intermediary
        enum CodingKeys: String, CodingKey {
            case startTime, endTime, duration, threshold, repeatDaysArray, isRepeating
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(startTime, forKey: .startTime)
            try container.encode(endTime, forKey: .endTime)
            try container.encode(duration, forKey: .duration)
            try container.encode(threshold, forKey: .threshold)
            try container.encode(isRepeating, forKey: .isRepeating)
            
            // Convert Set<Int> to Array for encoding
            if let repeatDays = repeatDays {
                try container.encode(Array(repeatDays).sorted(), forKey: .repeatDaysArray)
            } else {
                try container.encodeNil(forKey: .repeatDaysArray)
            }
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            startTime = try container.decodeIfPresent(Date.self, forKey: .startTime)
            endTime = try container.decodeIfPresent(Date.self, forKey: .endTime)
            duration = try container.decodeIfPresent(TimeInterval.self, forKey: .duration)
            threshold = try container.decodeIfPresent(TimeInterval.self, forKey: .threshold)
            isRepeating = try container.decodeIfPresent(Bool.self, forKey: .isRepeating) ?? false
            
            // Convert Array back to Set<Int>
            if let repeatDaysArray = try container.decodeIfPresent([Int].self, forKey: .repeatDaysArray) {
                repeatDays = Set(repeatDaysArray)
            } else {
                repeatDays = nil
            }
        }
        
        init(startTime: Date? = nil, endTime: Date? = nil, duration: TimeInterval? = nil, threshold: TimeInterval? = nil, repeatDays: Set<Int>? = nil, isRepeating: Bool = false) {
            self.startTime = startTime
            self.endTime = endTime
            self.duration = duration
            self.threshold = threshold
            self.repeatDays = repeatDays
            self.isRepeating = isRepeating
        }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        icon: String = "app.fill",
        iconColor: String = "#66C5A8",
        type: BlockType,
        appSelection: FamilyActivitySelection,
        schedule: BlockSchedule,
        strictMode: StrictMode,
        isActive: Bool = false,
        isPaused: Bool = false,
        pausedUntil: Date? = nil,
        createdAt: Date = Date(),
        activityName: DeviceActivityName? = nil,
        appCount: Int? = nil,
        isOverlapped: Bool = false,
        isActiveAmongOverlaps: Bool = false,
        appListId: UUID? = nil,
        appListName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.iconColor = iconColor
        self.type = type
        self.appSelection = appSelection
        self.schedule = schedule
        self.strictMode = strictMode
        self.isActive = isActive
        self.isPaused = isPaused
        self.pausedUntil = pausedUntil
        self.createdAt = createdAt
        self.activityName = activityName
        self.appCount = appCount
        self.isOverlapped = isOverlapped
        self.isActiveAmongOverlaps = isActiveAmongOverlaps
        self.appListId = appListId
        self.appListName = appListName
        
        // Debug: Log app list metadata initialization
        if appListId != nil || appListName != nil {
            print("📦 [Block.init] Creating block '\(name)' with app list metadata: appListId=\(appListId?.uuidString ?? "nil"), appListName=\(appListName ?? "nil")")
        }
    }
    
    // MARK: - Computed Properties
    
    /// Check if block is currently paused
    var isCurrentlyPaused: Bool {
        guard let pausedUntil = pausedUntil else { return false }
        return pausedUntil > Date()
    }
    
    /// Get time remaining for pause
    var pauseTimeRemaining: TimeInterval? {
        guard let pausedUntil = pausedUntil else { return nil }
        let remaining = pausedUntil.timeIntervalSince(Date())
        return remaining > 0 ? remaining : nil
    }
    
    /// Check if block should be active today based on schedule
    var shouldBeActiveTodayBasedOnSchedule: Bool {
        guard schedule.repeatDays != nil else { return false }
        let today = Calendar.current.component(.weekday, from: Date())
        return schedule.repeatDays?.contains(today) ?? false
    }
    
    /// Get monitor name for this block
    func getMonitorName(for day: Int? = nil) -> DeviceActivityName {
        if let activityName = activityName {
            return activityName
        }
        if let day = day {
            return DeviceActivityName("com.gia.screendiet.\(id.uuidString).day\(day)")
        } else {
            return DeviceActivityName("com.gia.screendiet.\(id.uuidString)")
        }
    }
}

// MARK: - Strict Mode Enum

enum StrictMode: String, Codable, CaseIterable {
    case easy    // Can dismiss shield by tapping anywhere
    case medium  // Requires confirmation button
    case hard    // Cannot dismiss shield, must wait or type forfeit phrase
    
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
    
    var description: String {
        switch self {
        case .easy: return "Can dismiss shield easily"
        case .medium: return "Requires confirmation to continue"
        case .hard: return "Cannot dismiss until time expires"
        }
    }
}
