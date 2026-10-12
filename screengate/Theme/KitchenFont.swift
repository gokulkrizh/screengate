import SwiftUI

/// Type styles from spec §3. Sizes are base sizes; `relativeTo` makes them follow Dynamic Type.
///
/// Bricolage Grotesque ships as one variable font (opsz 12–96, wght 200–800); `display` names its ExtraBold (800) instance.
enum KitchenFont {
    /// The only named instance that resolves to ExtraBold (800) on iOS ("BricolageGrotesque-ExtraBold" resolves to a thin face).
    static let display = "BricolageGrotesque-96ptExtraBold"
    static let manrope = "Manrope"

    /// Headline (h1) 34–40 pt, tracking −1.2.
    static func headline(_ size: CGFloat = 36) -> Font { .custom(display, size: size, relativeTo: .largeTitle) }
    /// Big numbers: portion, hours, grade. 40–72 pt, tabular figures.
    static func bigNumber(_ size: CGFloat = 56) -> Font { .custom(display, size: size, relativeTo: .largeTitle).monospacedDigit() }
    static let wordmark = Font.custom(display, size: 20, relativeTo: .title3)
    /// Eyebrow: Manrope 700, 11 pt, uppercase, +0.14 em.
    static let eyebrow = Font.custom(manrope, size: 11, relativeTo: .caption2).weight(.bold)
    static func body(_ size: CGFloat = 15) -> Font { .custom(manrope, size: size, relativeTo: .body).weight(.medium) }
    static let button = Font.custom(manrope, size: 16, relativeTo: .body).weight(.bold)
    static func label(_ size: CGFloat = 13) -> Font { .custom(manrope, size: size, relativeTo: .footnote).weight(.semibold) }
}

extension View {
    /// Headline with spec tracking and line height ≈ 1.02.
    func kitchenHeadline(_ size: CGFloat = 36) -> some View {
        font(KitchenFont.headline(size)).tracking(-1.2).lineSpacing(-size * 0.1)
    }

    func kitchenEyebrow() -> some View {
        textCase(.uppercase).font(KitchenFont.eyebrow).tracking(11 * 0.14)
    }

    func kitchenBody(_ size: CGFloat = 15) -> some View {
        font(KitchenFont.body(size)).lineSpacing(size * 0.45)
    }
}
