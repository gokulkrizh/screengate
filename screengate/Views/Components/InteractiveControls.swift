import SwiftUI

/// Press-and-hold confirmation with a filling ring and rising haptics.
/// Reduce Motion: the ring cross-fades instead of animating.
struct HoldToConfirmButton: View {
    let title: String
    var holdDuration: TimeInterval = 2.0
    var tint: Color = .orange
    var onConfirm: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var progress: Double = 0
    @State private var isPressing = false
    @State private var tick = 0
    private let appTheme = AppTheme.shared

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: appTheme.spacing.cornerRadiusLarge)
                .fill(tint.opacity(0.15))

            GeometryReader { geo in
                RoundedRectangle(cornerRadius: appTheme.spacing.cornerRadiusLarge)
                    .fill(tint)
                    .frame(width: geo.size.width * progress)
            }
            .clipShape(RoundedRectangle(cornerRadius: appTheme.spacing.cornerRadiusLarge))

            HStack(spacing: 8) {
                Image(systemName: isPressing ? "circle.dotted" : "hand.tap.fill")
                Text(isPressing ? "Keep holding…" : title)
            }
            .font(appTheme.fonts.titleMedium)
            .foregroundColor(appTheme.colors.text)
        }
        .frame(height: 56)
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: holdDuration, perform: {
            tick += 1
            onConfirm()
            reset()
        }, onPressingChanged: { pressing in
            isPressing = pressing
            if pressing {
                if reduceMotion {
                    progress = 1
                } else {
                    withAnimation(.linear(duration: holdDuration)) { progress = 1 }
                }
            } else {
                reset()
            }
        })
        .sensoryFeedback(.increase, trigger: tick)
    }

    private func reset() {
        isPressing = false
        withAnimation(reduceMotion ? .easeOut(duration: 0.15) : .easeOut(duration: 0.3)) {
            progress = 0
        }
    }
}

/// Slide-to-start control for Fast Now.
struct SlideToFastControl: View {
    let title: String
    var tint: Color = .green
    var onSlide: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var offset: CGFloat = 0
    @State private var done = false
    private let appTheme = AppTheme.shared
    private let knobSize: CGFloat = 48

    var body: some View {
        GeometryReader { geo in
            let travel = max(geo.size.width - knobSize - 8, 1)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(appTheme.colors.surfaceVariant)

                Capsule()
                    .fill(tint.opacity(0.25))
                    .frame(width: offset + knobSize + 8)

                Text(title)
                    .font(appTheme.fonts.titleSmall)
                    .foregroundColor(appTheme.colors.textSecondary)
                    .frame(maxWidth: .infinity)

                Circle()
                    .fill(tint)
                    .frame(width: knobSize, height: knobSize)
                    .overlay(
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(appTheme.colors.background)
                    )
                    .offset(x: offset + 4)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                guard !done else { return }
                                offset = min(max(0, value.translation.width), travel)
                            }
                            .onEnded { value in
                                if offset > travel * 0.75 {
                                    done = true
                                    if !reduceMotion {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            offset = travel
                                        }
                                    } else {
                                        offset = travel
                                    }
                                    onSlide()
                                } else {
                                    withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.7)) {
                                        offset = 0
                                    }
                                }
                            }
                    )
            }
        }
        .frame(height: knobSize + 8)
    }
}
