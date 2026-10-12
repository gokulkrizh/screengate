import SwiftUI

/// Onboarding chapters (spec §4): Story · You · Plates · Recipe · Ready.
enum OnboardingChapter: Int, CaseIterable {
    case story, you, plates, recipe, ready
    var label: String { ["Story", "You", "Plates", "Recipe", "Ready"][rawValue] }
}

/// 5 equal segments, 4 pt tall, 4 pt gaps. Earlier chapters are full; the current one fills to `fraction`.
struct ChapterProgressBar: View {
    @Environment(\.kitchenTheme) private var theme
    let chapter: OnboardingChapter
    /// `step / stepsInChapter`, 0…1.
    let fraction: Double

    var body: some View {
        HStack(spacing: 4) {
            ForEach(OnboardingChapter.allCases, id: \.rawValue) { c in
                Capsule().fill(theme.line2).frame(height: 4)
                    .overlay(alignment: .leading) {
                        GeometryReader { geo in
                            Capsule().fill(theme.lamp)
                                .frame(width: geo.size.width * fill(for: c))
                        }
                    }
            }
        }
        .animation(.easeOut(duration: 1), value: fraction)
        .animation(.easeOut(duration: 1), value: chapter)
        .accessibilityElement()
        .accessibilityLabel("Step progress")
        .accessibilityValue("\(chapter.label), chapter \(chapter.rawValue + 1) of 5")
    }

    private func fill(for c: OnboardingChapter) -> Double {
        c.rawValue < chapter.rawValue ? 1 : c == chapter ? min(1, max(0, fraction)) : 0
    }
}

struct Wordmark: View {
    @Environment(\.kitchenTheme) private var theme
    var body: some View {
        (Text("screendiet").foregroundStyle(theme.text) + Text(".").foregroundStyle(theme.lamp))
            .font(KitchenFont.wordmark).tracking(-0.6)
            .accessibilityLabel("screendiet")
    }
}

/// Back button · centred wordmark · chapter label, with the progress bar beneath.
struct KitchenOnboardingHeader: View {
    @Environment(\.kitchenTheme) private var theme
    let chapter: OnboardingChapter
    let fraction: Double
    var showsBack = true
    /// Membership step: replaces the plain wordmark with a "screendiet. PLUS" pill.
    var isPlus = false
    var onBack: () -> Void = {}

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                if isPlus { PlusWordmark() } else { Wordmark() }
                HStack {
                    if showsBack { KitchenBackButton(action: onBack) } else { Color.clear.frame(width: 44, height: 44) }
                    Spacer()
                    Text(chapter.label).kitchenEyebrow().foregroundStyle(theme.faint)
                }
            }
            ChapterProgressBar(chapter: chapter, fraction: fraction)
        }
        .padding(.horizontal, KitchenMetrics.textMargin)
    }
}

/// "screendiet. PLUS" pill (Membership header).
struct PlusWordmark: View {
    @Environment(\.kitchenTheme) private var theme
    var body: some View {
        HStack(spacing: 6) {
            (Text("screendiet").foregroundStyle(theme.text) + Text(".").foregroundStyle(theme.lamp))
                .font(.custom(KitchenFont.display, size: 14, relativeTo: .footnote))
            Text("PLUS").font(.custom(KitchenFont.manrope, size: 10, relativeTo: .caption2).weight(.heavy)).tracking(0.6)
                .foregroundStyle(theme.buttonText).padding(.horizontal, 6).frame(height: 18).background(theme.lamp, in: Capsule())
        }
        .padding(.horizontal, 12).frame(height: 30)
        .background(theme.surface, in: Capsule()).overlay(Capsule().stroke(theme.line, lineWidth: 1))
        .accessibilityLabel("screendiet Plus")
    }
}
