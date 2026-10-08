import AppIntents
import Foundation

/// Focus filter (premium): "When Work Focus is on, start Fast Now."
struct ScreenDietFocusFilter: SetFocusFilterIntent {
    static var title: LocalizedStringResource = "ScreenDiet Focus"
    static var description = IntentDescription("Start a Fast Now when this Focus turns on.")

    @Parameter(title: "Fast duration (minutes)")
    var minutes: Int?

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "ScreenDiet",
            subtitle: "Start a \(minutes ?? 60)-minute fast"
        )
    }

    func perform() async throws -> some IntentResult {
        let value = max(DietRules.minimumScheduleMinutes, minutes ?? 60)
        _ = try await StartFastIntent(minutes: value).perform()
        return .result()
    }
}
