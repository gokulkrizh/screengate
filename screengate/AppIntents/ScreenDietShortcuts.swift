import AppIntents

/// App Shortcuts: "Start a fast in ScreenDiet", "How much carbs do I have left?"
struct ScreenDietShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartFastIntent(),
            phrases: [
                "Start a fast in \(.applicationName)",
                "Start a focus fast in \(.applicationName)",
                "\(.applicationName) fast now",
            ],
            shortTitle: "Start Fast",
            systemImageName: "bolt.fill"
        )
        AppShortcut(
            intent: CarbsRemainingIntent(),
            phrases: [
                "How much carbs do I have left in \(.applicationName)",
                "\(.applicationName) carbs left",
            ],
            shortTitle: "Carbs Left",
            systemImageName: "takeoutbag.and.cup.and.straw"
        )
    }
}
