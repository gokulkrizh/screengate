import SwiftUI

/// The three kitchen looks from `design/v2-design-spec.md` §1–2. The theme follows the kitchen state,
/// never the system appearance.
enum KitchenTheme: String, CaseIterable, Equatable {
    case lamp       // closed / evening / premium
    case daylight   // open / building your diet
    case night      // night fast

    /// Spec §1: precedence `fastNow > nightFast > portionHit > kitchenClosed > open` is already
    /// resolved by `DietRules`; this only maps the resolved state to a look.
    init(state: DietState) {
        switch state {
        case .fastNow, .fasting: self = .lamp
        case .nightFast: self = .night
        case .windowOpen, .portionHit, .inactive: self = .daylight
        }
    }

    private func pick(_ lamp: String, _ daylight: String, _ night: String) -> Color {
        Color(hex: self == .lamp ? lamp : self == .daylight ? daylight : night)
    }

    // MARK: Surfaces
    var bg: Color { pick("15120F", "F5EFE4", "0F1226") }
    var surface: Color { pick("221E1A", "FFFDF8", "1A1E38") }
    var surface2: Color { pick("2D2823", "EDE5D6", "262B4A") }
    var line: Color { (self == .lamp ? Color(hex: "FFECD2") : self == .daylight ? Color(hex: "3C2814") : Color(hex: "DCE2FF")).opacity(self == .daylight ? 0.09 : 0.08) }
    var line2: Color { (self == .lamp ? Color(hex: "FFECD2") : self == .daylight ? Color(hex: "3C2814") : Color(hex: "DCE2FF")).opacity(self == .daylight ? 0.16 : 0.15) }

    // MARK: Text
    var text: Color { pick("F7F2E9", "1F1A14", "EEF0FA") }
    var muted: Color { pick("B5AC9F", "5F564A", "ABB0CC") }
    var faint: Color { pick("918778", "766B5E", "8A90B0") }

    // MARK: Accent + buttons
    var lamp: Color { pick("F3D9A4", "B8862C", "F3D9A4") }
    var buttonBg: Color { pick("F3D9A4", "1F1A14", "F3D9A4") }
    var buttonText: Color { pick("1D1812", "F7F1E6", "151830") }

    // MARK: Plate (night has none; reuse lamp values)
    var plate: Color { self == .daylight ? Color(hex: "FFFFFF") : Color(hex: "EDE6D8") }
    var plateInner: Color { self == .daylight ? Color(hex: "FAF6EE") : Color(hex: "F6F1E7") }
    var plateEdge: Color { self == .daylight ? Color(hex: "E0D5C2") : Color(hex: "BDB3A1") }

    // MARK: Food groups (meaning, never decoration)
    func color(for group: KitchenFoodGroup) -> Color {
        switch (group, self == .daylight) {
        case (.carbs, false): return Color(hex: "F4929F")
        case (.carbs, true): return Color(hex: "B83E5E")
        case (.fats, false): return Color(hex: "B6D07E")
        case (.fats, true): return Color(hex: "4F7A22")
        case (.protein, false): return Color(hex: "EBA75A")
        case (.protein, true): return Color(hex: "995A12")
        }
    }

    /// Soft fill: group colour at 10–14 %.
    func soft(_ group: KitchenFoodGroup, opacity: Double = 0.12) -> Color { color(for: group).opacity(opacity) }

    var colorScheme: ColorScheme { self == .daylight ? .light : .dark }
}

/// Display grouping for the v2 design. Mirrors `FoodGroup` without depending on it.
enum KitchenFoodGroup: String, CaseIterable {
    case carbs, fats, protein
    var verb: String { switch self { case .carbs: "Consume"; case .fats: "Connect"; case .protein: "Create" } }
    var title: String { rawValue.capitalized }
}

// MARK: - Environment

private struct KitchenThemeKey: EnvironmentKey { static let defaultValue = KitchenTheme.lamp }

extension EnvironmentValues {
    var kitchenTheme: KitchenTheme {
        get { self[KitchenThemeKey.self] }
        set { self[KitchenThemeKey.self] = newValue }
    }
}

extension View {
    /// Applies a kitchen theme to this subtree: environment value, colour scheme and base text colour.
    func kitchenTheme(_ theme: KitchenTheme) -> some View {
        environment(\.kitchenTheme, theme)
            .preferredColorScheme(theme.colorScheme)
            .tint(theme.lamp)
    }
}

// MARK: - Layout tokens (spec §4)

enum KitchenMetrics {
    static let cardMargin: CGFloat = 20
    static let textMargin: CGFloat = 24
    static let cardRadius: CGFloat = 30
    static let listRadius: CGFloat = 22
    static let chipRadius: CGFloat = 18
    static let buttonHeight: CGFloat = 56
    static let backButton: CGFloat = 44
    static let tabBarHeight: CGFloat = 84
    static let crossFade: Animation = .easeInOut(duration: 0.6)
    static let spring: Animation = .spring(response: 0.55, dampingFraction: 0.8)
}
