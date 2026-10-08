import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Bundle

@main
struct ScreenDietWidgetsBundle: WidgetBundle {
    var body: some Widget {
        KitchenStatusWidget()
        PlateWidget()
        StreakWidget()
        FastNowWidget()
        FastActivityWidget()
        StartFastControl()
    }
}

// MARK: - Kitchen Status

struct KitchenStatusWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "KitchenStatusWidget", provider: DietTimelineProvider()) { entry in
            KitchenStatusView(entry: entry)
                .containerBackground(for: .widget) { WidgetTheme.background }
        }
        .configurationDisplayName("Kitchen Status")
        .description("Open, closed or fasting — with a live countdown.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

// MARK: - Plate

struct PlateWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "PlateWidget", provider: DietTimelineProvider()) { entry in
            PlateView(entry: entry)
                .containerBackground(for: .widget) { WidgetTheme.background }
        }
        .configurationDisplayName("Plate")
        .description("Approximate carbs left in today's portion.")
        .supportedFamilies([.systemSmall, .accessoryCircular])
    }
}

// MARK: - Streak

struct StreakWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "StreakWidget", provider: DietTimelineProvider()) { entry in
            StreakView(entry: entry)
                .containerBackground(for: .widget) { WidgetTheme.background }
        }
        .configurationDisplayName("Streak")
        .description("Your streak and remaining cheat meals.")
        .supportedFamilies([.systemSmall, .accessoryInline])
    }
}

// MARK: - Fast Now (interactive)

struct FastNowWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "FastNowWidget", provider: DietTimelineProvider()) { entry in
            FastNowView(entry: entry)
                .containerBackground(for: .widget) { WidgetTheme.background }
        }
        .configurationDisplayName("Fast Now")
        .description("Start a focus fast without opening the app.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
