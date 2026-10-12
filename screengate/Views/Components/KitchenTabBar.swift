import SwiftUI

enum KitchenTab: Int, CaseIterable {
    case kitchen, pantry, journal, settings
    var title: String { ["Kitchen", "Pantry", "Journal", "Settings"][rawValue] }
    var symbol: String { ["circle.circle", "cabinet", "book.pages", "gearshape"][rawValue] }
}

/// 84 pt, 16 pt blur over a 90 % bg tint, 1 pt line on top.
struct KitchenTabBar: View {
    @Environment(\.kitchenTheme) private var theme
    @Binding var selection: KitchenTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(KitchenTab.allCases, id: \.rawValue) { tab in
                Button { selection = tab } label: {
                    VStack(spacing: 3) {
                        Image(systemName: tab.symbol).font(.system(size: 20, weight: selection == tab ? .bold : .regular))
                        Text(tab.title).font(.custom(KitchenFont.manrope, size: 10, relativeTo: .caption2).weight(selection == tab ? .heavy : .bold))
                    }
                    .foregroundStyle(selection == tab ? theme.text : theme.faint)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection == tab ? [.isSelected, .isButton] : .isButton)
            }
        }
        .padding(.horizontal, 12).padding(.top, 6)
        .frame(height: KitchenMetrics.tabBarHeight, alignment: .top)
        .background { Rectangle().fill(.ultraThinMaterial).overlay(theme.bg.opacity(0.9)) }
        .overlay(alignment: .top) { theme.line.frame(height: 1) }
        .sensoryFeedback(.selection, trigger: selection)
        .animation(KitchenMetrics.crossFade, value: theme)
    }
}
