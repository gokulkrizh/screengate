import SwiftUI

/// Onboarding step 06 (canvas V2-06): daily screen time + hardest moment. Saves the quiz answers on Continue.
struct RhythmStep: View {
    @ObservedObject var data: OnboardingData
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(DietManager.self) private var dietManager

    /// `hours` is the value stored in `quizDailyHours` (drives `suggestedPlan`: ≥ 6 suggests Maker).
    private let hours: [(hours: Int, big: String, small: String, fill: CGFloat)] = [
        (1, "<2h", "A light snacker", 0.25), (3, "2–4h", "A typical day", 0.5),
        (5, "4–6h", "A full plate", 0.75), (7, "6h+", "Always within reach", 1),
    ]
    private let struggles: [(id: String, title: String, icon: String)] = [
        ("morning", "First thing in the morning", "sun.max"), ("afternoon", "Between tasks", "checklist"),
        ("latelight", "Late at night", "moon"), ("evening", "Honestly, all day", "clock"),
    ]

    var body: some View {
        OnboardingPage {
            VStack(alignment: .leading, spacing: 12) {
                OnboardingEyebrow(text: "No judgment. Just a starting point.").rise(0)
                OnboardingTitle(first: "What does your", second: "usual day look like?", emphasis: false, size: 38).rise(1)
            }
            .padding(.top, 12)
            VStack(alignment: .leading, spacing: 12) {
                Text("Daily screen time, roughly").font(KitchenFont.label(13).weight(.bold)).foregroundStyle(theme.text).padding(.horizontal, 4)
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                    ForEach(hours, id: \.hours) { hourCard($0) }
                }
            }
            .padding(.horizontal, -4).padding(.top, 6).rise(2)
            VStack(alignment: .leading, spacing: 12) {
                Text("When is it hardest to stop?").font(KitchenFont.label(13).weight(.bold)).foregroundStyle(theme.text).padding(.horizontal, 4)
                RhythmFlowLayout(spacing: 8) {
                    ForEach(Array(struggles.enumerated()), id: \.element.id) { i, s in
                        chip(s).editorialEntrance(delay: 0.5 + Double(i) * 0.07)
                    }
                }
            }
            .padding(.horizontal, -4).padding(.top, 8).rise(3)
        } footer: {
            KitchenPrimaryButton(title: "Continue", systemImage: "arrow.right") {
                dietManager.saveOnboardingAnswers(data.quizAnswers)
                data.nextScreen()
            }
        }
        .onAppear {
            if !hours.contains(where: { $0.hours == data.quizDailyHours }) { data.quizDailyHours = hours.first(where: { $0.hours == 5 })?.hours }
            if !struggles.contains(where: { $0.id == data.quizWorstTime }) { data.quizWorstTime = "latelight" }
        }
    }

    private func hourCard(_ h: (hours: Int, big: String, small: String, fill: CGFloat)) -> some View {
        let on = data.quizDailyHours == h.hours
        return Button { data.quizDailyHours = h.hours } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(h.big).font(KitchenFont.bigNumber(28)).tracking(-1).foregroundStyle(theme.text)
                Text(h.small).font(KitchenFont.label(12)).foregroundStyle(theme.muted)
            }
            .padding(.horizontal, 16).padding(.bottom, 10)
            .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
            .overlay(alignment: .bottom) {
                GeometryReader { geo in
                    Capsule().fill(theme.surface2)
                        .overlay(alignment: .leading) {
                            Capsule().fill(theme.color(for: .carbs)).frame(width: geo.size.width * (on ? h.fill : 0))
                        }
                }
                .frame(height: 5).padding(.horizontal, 16).padding(.bottom, 12)
            }
            .background(on ? theme.surface : theme.surface.opacity(0.55), in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(on ? theme.text : theme.line, lineWidth: on ? 2 : 1))
            .shadow(color: .black.opacity(on ? 0.10 : 0), radius: 12, y: 8)
        }
        .buttonStyle(TactileButtonStyle())
        .animation(reduceMotion ? .easeOut(duration: 0.2) : .easeOut(duration: 0.5), value: on)
        .sensoryFeedback(.selection, trigger: on)
        .accessibilityLabel("\(h.big), \(h.small)")
        .accessibilityAddTraits(on ? .isSelected : [])
    }

    private func chip(_ s: (id: String, title: String, icon: String)) -> some View {
        let on = data.quizWorstTime == s.id
        return Button { data.quizWorstTime = s.id } label: {
            HStack(spacing: 8) {
                Image(systemName: s.icon).font(.system(size: 13, weight: .semibold))
                Text(s.title).font(KitchenFont.body(14).weight(.semibold))
            }
            .foregroundStyle(on ? theme.buttonText : theme.text)
            .padding(.horizontal, 16).frame(height: 44)
            .background(on ? theme.buttonBg : theme.surface, in: Capsule())
            .overlay(Capsule().stroke(on ? .clear : theme.line, lineWidth: 1))
        }
        .buttonStyle(TactileButtonStyle())
        .animation(reduceMotion ? .easeOut(duration: 0.2) : .easeOut(duration: 0.25), value: on)
        .sensoryFeedback(.selection, trigger: on)
        .accessibilityAddTraits(on ? .isSelected : [])
    }
}

/// Left-aligned wrapping layout for chips.
struct RhythmFlowLayout: Layout {
    var spacing: CGFloat = 8
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(proposal.width ?? .infinity, subviews).size
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for (i, f) in arrange(bounds.width, subviews).frames.enumerated() {
            subviews[i].place(at: CGPoint(x: bounds.minX + f.minX, y: bounds.minY + f.minY), proposal: .init(f.size))
        }
    }
    private func arrange(_ width: CGFloat, _ subviews: Subviews) -> (frames: [CGRect], size: CGSize) {
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0, maxW: CGFloat = 0
        var frames: [CGRect] = []
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x > 0, x + s.width > width { x = 0; y += rowH + spacing; rowH = 0 }
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: s))
            x += s.width + spacing; rowH = max(rowH, s.height); maxW = max(maxW, x - spacing)
        }
        return (frames, CGSize(width: maxW, height: y + rowH))
    }
}
