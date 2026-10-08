import WidgetKit
import SwiftUI

// MARK: - Entry

struct DietEntry: TimelineEntry {
    let date: Date
    let state: SharedState
}

/// Reads SharedState (read-only) and lays entries on every known boundary.
/// Countdowns use Text(timerInterval:) so they tick without widget reloads.
struct DietTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> DietEntry {
        DietEntry(date: .now, state: .empty())
    }

    func getSnapshot(in context: Context, completion: @escaping (DietEntry) -> Void) {
        completion(DietEntry(date: .now, state: SharedStore.shared.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DietEntry>) -> Void) {
        let state = SharedStore.shared.load()
        let now = Date()

        var entries = [DietEntry(date: now, state: state)]
        let boundaries = DietRules.nextBoundaries(
            profile: state.profile,
            cheat: state.cheat,
            fast: state.fast,
            after: now
        )
        for boundary in boundaries.prefix(12) {
            entries.append(DietEntry(date: boundary.addingTimeInterval(1), state: state))
        }

        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

// MARK: - Derived status for widget copy

enum WidgetStatus {
    case fastNow(until: Date)
    case nightFast(until: Date)
    case plateEmpty(opensAt: Date)
    case open(closesAt: Date)
    case closed(opensAt: Date)
    case inactive

    static func from(_ state: SharedState, at now: Date = Date()) -> WidgetStatus {
        guard let profile = state.profile, profile.isActive else { return .inactive }

        let dietState = DietRules.state(
            profile: profile,
            counters: state.counters,
            fast: state.fast,
            cheat: state.cheat
        )

        switch dietState {
        case .fastNow:
            return .fastNow(until: state.fast?.endsAt ?? now)
        case .nightFast:
            return .nightFast(until: DietRules.nextOccurrence(
                hour: profile.nightFast.endHour,
                minute: profile.nightFast.endMinute,
                after: now
            ))
        case .portionHit:
            return .plateEmpty(opensAt: DietRules.nextOccurrence(
                hour: profile.eatingWindow.startHour,
                minute: profile.eatingWindow.startMinute,
                after: now
            ))
        case .windowOpen:
            return .open(closesAt: DietRules.nextOccurrence(
                hour: profile.eatingWindow.endHour,
                minute: profile.eatingWindow.endMinute,
                after: now
            ))
        case .fasting:
            return .closed(opensAt: DietRules.nextOccurrence(
                hour: profile.eatingWindow.startHour,
                minute: profile.eatingWindow.startMinute,
                after: now
            ))
        case .inactive:
            return .inactive
        }
    }
}
