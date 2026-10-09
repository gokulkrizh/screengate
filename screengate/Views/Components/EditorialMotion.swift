import SwiftUI

struct EditorialEntrance: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var visible = false
    var delay: Double = 0
    func body(content: Content) -> some View {
        content.opacity(visible ? 1 : 0).offset(y: visible || reduceMotion ? 0 : 16)
            .onAppear { withAnimation(.easeOut(duration: reduceMotion ? 0.18 : 0.55).delay(delay)) { visible = true } }
    }
}

struct TactileButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.75 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.75), value: configuration.isPressed)
    }
}

extension View {
    func editorialEntrance(delay: Double = 0) -> some View { modifier(EditorialEntrance(delay: delay)) }
    func dietCard(tint: Color = AppTheme.shared.colors.primary) -> some View {
        padding(20).background(AppTheme.shared.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(tint.opacity(0.12)))
    }
}

struct DietArtwork: View {
    var asset: String = "DigitalGarden"
    var height: CGFloat = 240
    var floating: Bool = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var lifted = false
    var body: some View {
        Image(asset).resizable().scaledToFit().frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .frame(maxWidth: .infinity)
            .offset(y: lifted && !reduceMotion && floating ? -5 : 0)
            .onAppear {
                if !reduceMotion && floating {
                    withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) { lifted = true }
                }
            }.accessibilityHidden(true)
    }
}

struct DietHeading: View {
    let eyebrow: String
    let title: String
    var detail: String = ""
    var centered: Bool = false
    var body: some View {
        VStack(alignment: centered ? .center : .leading, spacing: 12) {
            Text(eyebrow.uppercased()).font(.caption2.bold()).tracking(2.2).foregroundStyle(AppTheme.shared.colors.primary)
            Text(title).font(.system(.largeTitle, design: .serif).weight(.semibold)).foregroundStyle(AppTheme.shared.colors.text).fixedSize(horizontal: false, vertical: true)
            if !detail.isEmpty {
                Text(detail).font(.subheadline).foregroundStyle(AppTheme.shared.colors.textSecondary).fixedSize(horizontal: false, vertical: true)
            }
        }.multilineTextAlignment(centered ? .center : .leading).frame(maxWidth: .infinity, alignment: centered ? .center : .leading)
    }
}

struct EditorialBanner: View {
    let eyebrow: String
    let title: String
    let detail: String
    var asset: String = "LifeReclaimed"
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(eyebrow.uppercased()).font(.caption2.bold()).tracking(1.6).foregroundStyle(AppTheme.shared.colors.primary)
                Text(title).font(.system(.title2, design: .serif).weight(.semibold)).foregroundStyle(AppTheme.shared.colors.text).fixedSize(horizontal: false, vertical: true)
                Text(detail).font(.caption).foregroundStyle(AppTheme.shared.colors.textSecondary)
            }
            Spacer(minLength: 0)
            Image(asset).resizable().scaledToFill().frame(width: 92, height: 112).clipped().clipShape(RoundedRectangle(cornerRadius: 20)).accessibilityHidden(true)
        }.dietCard().editorialEntrance()
    }
}

struct DietFeatureRow: View {
    let icon: String
    let title: String
    let detail: String
    var tint: Color = AppTheme.shared.colors.primary
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon).font(.body.weight(.semibold)).foregroundStyle(tint)
                .frame(width: 42, height: 42).background(tint.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(AppTheme.shared.colors.text)
                Text(detail).font(.caption).foregroundStyle(AppTheme.shared.colors.textSecondary)
            }.fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }
}

struct DietChoice: View {
    let icon: String
    let title: String
    let detail: String
    let selected: Bool
    var tint: Color = AppTheme.shared.colors.primary
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        Button {
            withAnimation(reduceMotion ? .easeOut(duration: 0.15) : .spring(response: 0.35, dampingFraction: 0.8)) { action() }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon).font(.title3).foregroundStyle(tint).frame(width: 40, height: 40)
                    .background(tint.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 5) {
                    Text(title).font(.headline).foregroundStyle(AppTheme.shared.colors.text)
                    if !detail.isEmpty { Text(detail).font(.caption).foregroundStyle(AppTheme.shared.colors.textSecondary) }
                }
                Spacer(minLength: 8)
                Image(systemName: selected ? "checkmark.circle.fill" : "circle").font(.title3)
                    .foregroundStyle(selected ? tint : AppTheme.shared.colors.textSecondary.opacity(0.6))
                    .contentTransition(reduceMotion ? .opacity : .symbolEffect(.replace))
            }.padding(16).frame(maxWidth: .infinity, alignment: .leading).frame(minHeight: 72)
                .background(selected ? tint.opacity(0.12) : AppTheme.shared.colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(selected ? tint : tint.opacity(0.12), lineWidth: selected ? 1.5 : 1))
        }.buttonStyle(TactileButtonStyle()).sensoryFeedback(.selection, trigger: selected)
            .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

struct DietMetric: View {
    let icon: String
    let value: String
    let label: String
    var tint: Color = AppTheme.shared.colors.primary
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon).font(.body).foregroundStyle(tint)
            Text(value).font(.system(.title2, design: .rounded).bold()).foregroundStyle(AppTheme.shared.colors.text).contentTransition(.numericText())
            Text(label).font(.caption).foregroundStyle(AppTheme.shared.colors.textSecondary)
        }.frame(maxWidth: .infinity, alignment: .leading).dietCard(tint: tint)
    }
}

struct DietPage<Content: View, Footer: View>: View {
    @ViewBuilder var content: () -> Content
    @ViewBuilder var footer: () -> Footer
    var body: some View {
        ScrollView {
            VStack(spacing: 24, content: content).padding(24).frame(maxWidth: 600).frame(maxWidth: .infinity)
        }.background(AppTheme.shared.colors.background.ignoresSafeArea())
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 8, content: footer).padding(.horizontal, 24).padding(.vertical, 12)
                    .frame(maxWidth: 600).frame(maxWidth: .infinity)
                    .background(AppTheme.shared.colors.background.opacity(0.98))
            }
    }
}

struct DietCloseButton: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Button { dismiss() } label: { Image(systemName: "xmark").font(.body.weight(.semibold)) }
            .accessibilityLabel("Close").buttonStyle(.automatic)
    }
}
