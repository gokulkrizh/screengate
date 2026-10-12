import SwiftUI

/// Onboarding step 05 (canvas V2-05): "Make room for life". Stored as `intention` (display text, used on the paywall).
struct IntentionStep: View {
    @ObservedObject var data: OnboardingData
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let options: [(value: String, title: String, detail: String, icon: String)] = [
        ("Reading", "Read more", "A few pages instead of another feed.", "book"),
        ("Time with people", "Time with people", "Full attention for the people around you.", "person.2"),
        ("Making things", "Make something", "Space to create, build and explore.", "sparkles"),
        ("Moving my body", "Move my body", "A walk, a stretch, a little fresh air.", "figure.walk"),
    ]

    var body: some View {
        OnboardingPage {
            OnboardingArtwork(asset: "LifeReclaimed", height: 168,
                              alt: "A clay reading nook with an open book, a cup and a face-down phone")
                .padding(.horizontal, -4).rise(0)
            VStack(alignment: .leading, spacing: 8) {
                OnboardingEyebrow(text: "Make room for something").rise(1)
                OnboardingTitle(first: "What belongs on the", second: "other side of less?", emphasis: false, size: 32).rise(2)
            }
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(Array(options.enumerated()), id: \.element.value) { i, o in
                    tile(o).editorialEntrance(delay: 0.45 + Double(i) * 0.08)
                }
            }
            .padding(.horizontal, -4)
        } footer: {
            KitchenPrimaryButton(title: "Continue", systemImage: "arrow.right") { data.nextScreen() }
        }
        .onAppear { if !options.contains(where: { $0.value == data.intention }) { data.intention = options[0].value } }
    }

    private func tile(_ o: (value: String, title: String, detail: String, icon: String)) -> some View {
        let on = data.intention == o.value
        return Button { data.intention = o.value } label: {
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .top) {
                    Image(systemName: o.icon).font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(on ? theme.buttonText : theme.muted)
                        .frame(width: 40, height: 40)
                        .background(on ? theme.lamp : theme.surface2, in: RoundedRectangle(cornerRadius: 13))
                    Spacer(minLength: 0)
                    Circle().strokeBorder(on ? theme.text : theme.line2, lineWidth: 1.5)
                        .background(Circle().fill(on ? theme.text : .clear))
                        .overlay { Image(systemName: "checkmark").font(.system(size: 10, weight: .heavy)).foregroundStyle(theme.surface).opacity(on ? 1 : 0) }
                        .frame(width: 22, height: 22)
                }
                .padding(.bottom, 6)
                Text(o.title).font(KitchenFont.body(15).weight(.bold)).foregroundStyle(theme.text)
                Text(o.detail).font(KitchenFont.body(12)).foregroundStyle(theme.muted).fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
            .background(on ? theme.surface : theme.surface.opacity(0.55), in: RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(on ? theme.text : theme.line, lineWidth: on ? 2 : 1))
            .shadow(color: .black.opacity(on ? 0.10 : 0), radius: 12, y: 8)
        }
        .buttonStyle(TactileButtonStyle())
        .animation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.3, dampingFraction: 0.7), value: on)
        .sensoryFeedback(.selection, trigger: on)
        .accessibilityLabel("\(o.title). \(o.detail)")
        .accessibilityAddTraits(on ? .isSelected : [])
    }
}
