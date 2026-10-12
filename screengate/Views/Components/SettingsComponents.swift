import SwiftUI

// Shared building blocks for the Pantry / Journal / Settings screens (canvas V2A-*).
// Every view reads colours from `\.kitchenTheme`; none draws its own background.

/// Eyebrow + 30 pt headline, matching the Kitchen tab header.
struct KitchenTitleBlock<Trailing: View>: View {
    @Environment(\.kitchenTheme) private var theme
    let eyebrow: String
    let title: String
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 6) {
                Text(eyebrow).kitchenEyebrow().foregroundStyle(theme.faint)
                Text(title).font(KitchenFont.headline(30)).tracking(-1).foregroundStyle(theme.text)
                    .accessibilityAddTraits(.isHeader)
            }
            Spacer(minLength: 8)
            trailing()
        }
    }
}

extension KitchenTitleBlock where Trailing == EmptyView {
    init(eyebrow: String, title: String) {
        self.init(eyebrow: eyebrow, title: title) { EmptyView() }
    }
}

/// Uppercase section label above a grouped card (12 % tracking, faint).
struct SettingsSectionLabel: View {
    @Environment(\.kitchenTheme) private var theme
    let text: String
    var body: some View {
        Text(text).font(KitchenFont.eyebrow).tracking(11 * 0.12).foregroundStyle(theme.faint)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, KitchenMetrics.textMargin - KitchenMetrics.cardMargin)
            .accessibilityAddTraits(.isHeader)
    }
}

/// Rounded surface that clips its rows and draws a 1 pt line ring.
struct SettingsGroupCard<Content: View>: View {
    @Environment(\.kitchenTheme) private var theme
    @ViewBuilder var content: () -> Content
    var body: some View {
        VStack(spacing: 0, content: content)
            .frame(maxWidth: .infinity)
            .background(theme.surface, in: RoundedRectangle(cornerRadius: KitchenMetrics.listRadius))
            .overlay(RoundedRectangle(cornerRadius: KitchenMetrics.listRadius).stroke(theme.line, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: KitchenMetrics.listRadius))
    }
}

/// Soft-tinted 32 pt icon tile (group colour at 10–14 %).
struct SettingsIconTile: View {
    @Environment(\.kitchenTheme) private var theme
    let symbol: String
    let group: KitchenFoodGroup
    var body: some View {
        Image(systemName: symbol).font(.system(size: 14, weight: .bold))
            .foregroundStyle(theme.color(for: group))
            .frame(width: 32, height: 32)
            .background(theme.soft(group, opacity: 0.11), in: RoundedRectangle(cornerRadius: 10))
            .accessibilityHidden(true)
    }
}

/// 56 pt list row: icon tile, title (+ optional subtitle), value, chevron. Tappable when `action` is set.
struct SettingsRow: View {
    @Environment(\.kitchenTheme) private var theme
    let symbol: String
    var group: KitchenFoodGroup = .protein
    let title: String
    var subtitle: String? = nil
    var value: String = ""
    var showsDivider = true
    var destructive = false
    var action: (() -> Void)? = nil

    var body: some View {
        Group {
            if let action { Button(action: action) { rowBody }.buttonStyle(TactileButtonStyle()) }
            else { rowBody }
        }
        .overlay(alignment: .top) { if showsDivider { Rectangle().fill(theme.line).frame(height: 1) } }
    }

    private var rowBody: some View {
        HStack(spacing: 12) {
            SettingsIconTile(symbol: symbol, group: group)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(KitchenFont.body(15).weight(.semibold)).foregroundStyle(destructive ? theme.color(for: .carbs) : theme.text)
                if let subtitle { Text(subtitle).font(KitchenFont.body(12)).foregroundStyle(theme.muted).fixedSize(horizontal: false, vertical: true) }
            }
            Spacer(minLength: 8)
            if !value.isEmpty { Text(value).font(KitchenFont.body(14)).foregroundStyle(theme.muted).multilineTextAlignment(.trailing) }
            if action != nil { Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).foregroundStyle(theme.faint) }
        }
        .padding(.horizontal, 16).padding(.vertical, 8)
        .frame(maxWidth: .infinity, minHeight: subtitle == nil ? 56 : 64, alignment: .leading)
        .contentShape(Rectangle())
    }
}

/// Row with the canvas switch (52 × 32 track, 26 pt knob, Fats-green when on).
struct SettingsToggleRow: View {
    @Environment(\.kitchenTheme) private var theme
    let symbol: String
    var group: KitchenFoodGroup = .protein
    let title: String
    var subtitle: String? = nil
    var showsDivider = true
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            SettingsIconTile(symbol: symbol, group: group)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(KitchenFont.body(15).weight(.semibold)).foregroundStyle(theme.text)
                if let subtitle { Text(subtitle).font(KitchenFont.body(12)).foregroundStyle(theme.muted).fixedSize(horizontal: false, vertical: true) }
            }
            Spacer(minLength: 8)
            KitchenSwitch(isOn: $isOn, label: title)
        }
        .padding(.horizontal, 16).padding(.vertical, 8)
        .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
        .overlay(alignment: .top) { if showsDivider { Rectangle().fill(theme.line).frame(height: 1) } }
    }
}

struct KitchenSwitch: View {
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var isOn: Bool
    let label: String

    var body: some View {
        Button { isOn.toggle() } label: {
            Capsule().fill(isOn ? theme.color(for: .fats) : theme.surface2)
                .frame(width: 52, height: 32)
                .overlay(alignment: isOn ? .trailing : .leading) {
                    Circle().fill(.white).frame(width: 26, height: 26)
                        .shadow(color: .black.opacity(0.2), radius: 3, y: 2).padding(3)
                }
                .frame(width: 52, height: 44).contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.3, dampingFraction: 0.65), value: isOn)
        .sensoryFeedback(.selection, trigger: isOn)
        .accessibilityLabel(label)
        .accessibilityValue(isOn ? "On" : "Off")
        .accessibilityAddTraits(.isToggle)
    }
}

/// Staggered "rise" entrance used across the three screens (18 pt, fade, 0.1 s steps).
struct RiseIn: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = false
    let index: Int
    func body(content: Content) -> some View {
        content.opacity(shown ? 1 : 0).offset(y: shown || reduceMotion ? 0 : 18)
            .onAppear {
                withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .easeOut(duration: 0.6).delay(0.05 + Double(index) * 0.1)) { shown = true }
            }
    }
}

extension View {
    func riseIn(_ index: Int = 0) -> some View { modifier(RiseIn(index: index)) }

    /// Presents a sheet in the Daylight look (the sheet has no HomeScreen background behind it).
    func daylightSheet() -> some View {
        environment(\.kitchenTheme, .daylight)
            .kitchenBackground(.daylight)
            .preferredColorScheme(.light)
            .tint(KitchenTheme.daylight.lamp)
    }
}

/// Sheet header: eyebrow + title on the left, 44 pt close button on the right.
struct KitchenSheetHeader: View {
    @Environment(\.kitchenTheme) private var theme
    let eyebrow: String
    let title: String
    let onClose: () -> Void
    var body: some View {
        KitchenTitleBlock(eyebrow: eyebrow, title: title) {
            Button(action: onClose) {
                Image(systemName: "xmark").font(.system(size: 14, weight: .bold)).foregroundStyle(theme.text)
                    .frame(width: 44, height: 44).background(theme.surface, in: Circle())
                    .overlay(Circle().stroke(theme.line, lineWidth: 1))
            }.buttonStyle(TactileButtonStyle()).accessibilityLabel("Close")
        }
    }
}
