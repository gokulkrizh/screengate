import SwiftUI

/// 56 pt pill (spec §4). On Lamp/Night it carries a soft lamp glow.
struct KitchenPrimaryButton: View {
    @Environment(\.kitchenTheme) private var theme
    let title: String
    var systemImage: String? = nil
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                if let systemImage { Image(systemName: systemImage).font(.system(size: 15, weight: .bold)) }
            }
            .font(KitchenFont.button)
            .foregroundStyle(theme.buttonText)
            .frame(maxWidth: .infinity, minHeight: KitchenMetrics.buttonHeight)
            .background(theme.buttonBg, in: Capsule())
            .shadow(color: theme == .daylight ? .clear : theme.lamp.opacity(0.22), radius: 16, y: 12)
            .opacity(isEnabled ? 1 : 0.4)
        }
        .buttonStyle(TactileButtonStyle())
        .disabled(!isEnabled)
        .sensoryFeedback(.impact(weight: .light), trigger: isEnabled)
    }
}

/// Quiet text action for skippable steps ("Not now", "Skip for now").
struct KitchenSecondaryButton: View {
    @Environment(\.kitchenTheme) private var theme
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title).font(KitchenFont.label(14)).foregroundStyle(theme.muted)
                .frame(maxWidth: .infinity, minHeight: 44)
        }.buttonStyle(TactileButtonStyle())
    }
}

/// 44 pt round back button: surface + 1 pt line ring.
struct KitchenBackButton: View {
    @Environment(\.kitchenTheme) private var theme
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left").font(.system(size: 16, weight: .bold)).foregroundStyle(theme.text)
                .frame(width: KitchenMetrics.backButton, height: KitchenMetrics.backButton)
                .background(theme.surface, in: Circle())
                .overlay(Circle().stroke(theme.line, lineWidth: 1))
        }
        .buttonStyle(TactileButtonStyle())
        .accessibilityLabel("Back")
    }
}
