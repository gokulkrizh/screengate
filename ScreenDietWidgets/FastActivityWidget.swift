import WidgetKit
import SwiftUI
import ActivityKit

// MARK: - Live Activity (Fast Now / Night Fast / Cheat Meal)

struct FastActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FastActivityAttributes.self) { context in
            FastLockScreenView(context: context)
                .activityBackgroundTint(WidgetTheme.background)
                .activitySystemActionForegroundColor(WidgetTheme.primary)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 4) {
                        Text(context.state.kind.emoji)
                        Text(context.state.kind.title)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(WidgetTheme.text)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: context.state.startDate...context.state.endDate, countsDown: true)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(WidgetTheme.primary)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        if context.state.streak > 0 {
                            Text("🔥 \(context.state.streak)")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        Spacer()
                        Text("Ends \(context.state.endDate, style: .time)")
                            .font(.system(size: 12))
                            .foregroundStyle(WidgetTheme.secondary)
                    }
                }
            } compactLeading: {
                Text(context.state.kind.emoji)
            } compactTrailing: {
                Text(timerInterval: context.state.startDate...context.state.endDate, countsDown: true)
                    .monospacedDigit()
                    .frame(maxWidth: 54)
            } minimal: {
                Text(context.state.kind.emoji)
            }
        }
    }
}

struct FastLockScreenView: View {
    let context: ActivityViewContext<FastActivityAttributes>

    private var progress: Double {
        let total = context.state.endDate.timeIntervalSince(context.state.startDate)
        guard total > 0 else { return 0 }
        let elapsed = Date().timeIntervalSince(context.state.startDate)
        return min(1, max(0, elapsed / total))
    }

    var body: some View {
        HStack(spacing: 16) {
            Text(context.state.kind.emoji)
                .font(.system(size: 40))

            VStack(alignment: .leading, spacing: 6) {
                Text(context.state.kind.title)
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(WidgetTheme.text)

                Text(timerInterval: context.state.startDate...context.state.endDate, countsDown: true)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(WidgetTheme.primary)

                HStack {
                    Text("Ends \(context.state.endDate, style: .time)")
                        .font(.system(size: 12))
                        .foregroundStyle(WidgetTheme.secondary)
                    if context.state.streak > 0 {
                        Text("· 🔥 \(context.state.streak)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(WidgetTheme.text)
                    }
                }
            }

            Spacer()

            ZStack {
                Circle()
                    .stroke(WidgetTheme.surface, lineWidth: 6)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(WidgetTheme.primary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 44, height: 44)
        }
        .padding(16)
    }
}
