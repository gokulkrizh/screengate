import SwiftUI

/// Min 76 pt. Selected = surface + 2 pt text ring + soft shadow; icon tile turns lamp; check fills.
struct KitchenChoiceCard: View {
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let title: String
    var detail: String? = nil
    var systemImage: String = "circle"
    var badge: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: systemImage).font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isSelected ? theme.buttonText : theme.muted)
                    .frame(width: 44, height: 44)
                    .background(isSelected ? theme.lamp : theme.surface2, in: RoundedRectangle(cornerRadius: 14))
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(title).font(KitchenFont.body(16).weight(.bold)).foregroundStyle(theme.text)
                        if let badge { StatusPill(text: badge, color: theme.lamp, compact: true) }
                    }
                    if let detail { Text(detail).font(KitchenFont.body(13)).foregroundStyle(theme.muted).fixedSize(horizontal: false, vertical: true) }
                }
                Spacer(minLength: 8)
                Circle().strokeBorder(isSelected ? theme.text : theme.line2, lineWidth: 2)
                    .background(Circle().fill(isSelected ? theme.text : .clear))
                    .overlay { Image(systemName: "checkmark").font(.system(size: 11, weight: .heavy)).foregroundStyle(theme.bg).opacity(isSelected ? 1 : 0) }
                    .frame(width: 24, height: 24)
                    .scaleEffect(isSelected || reduceMotion ? 1 : 0.9)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 76, alignment: .leading)
            .background(isSelected ? theme.surface : theme.surface.opacity(0.55), in: RoundedRectangle(cornerRadius: KitchenMetrics.listRadius))
            .overlay(RoundedRectangle(cornerRadius: KitchenMetrics.listRadius).stroke(isSelected ? theme.text : theme.line, lineWidth: isSelected ? 2 : 1))
            .shadow(color: .black.opacity(isSelected ? 0.10 : 0), radius: 14, y: 8)
        }
        .buttonStyle(TactileButtonStyle())
        .animation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        .sensoryFeedback(.selection, trigger: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

extension View {
    /// Surface card with a 1 pt line ring.
    func kitchenCard(_ theme: KitchenTheme, radius: CGFloat = KitchenMetrics.listRadius) -> some View {
        background(theme.surface, in: RoundedRectangle(cornerRadius: radius))
            .overlay(RoundedRectangle(cornerRadius: radius).stroke(theme.line, lineWidth: 1))
    }
}
