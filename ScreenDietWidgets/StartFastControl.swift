import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Control Center / Action Button

struct StartFastControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "StartFastControl") {
            ControlWidgetButton(action: StartFastIntent(minutes: 60)) {
                Label("Fast Now", systemImage: "bolt.fill")
            }
        }
        .displayName("Fast Now")
        .description("Start a 60-minute focus fast in ScreenDiet.")
    }
}
