import SwiftUI

/// Custom tab bar with 3 tabs: Shield, Stats, Settings
struct TabBar: View {
    @Binding var selectedTab: TabBarItem
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .foregroundColor(.focusCard)
            
            HStack(spacing: 0) {
                ForEach(TabBarItem.allCases, id: \.self) { tab in
                    TabBarButton(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        action: {
                            withAnimation(FocusClubAnimations.pageTransition) {
                                selectedTab = tab
                            }
                        }
                    )
                }
            }
            .frame(height: 60)
            .background(Color.focusDarkBase)
            .safeAreaInset(edge: .bottom) { }
        }
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let tab: TabBarItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.iconName)
                    .font(.system(size: 20, weight: .semibold))
                
                Text(tab.label)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(isSelected ? .focusAccent : .focusTextSecondary)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
    }
}

// MARK: - Tab Bar Item
enum TabBarItem: CaseIterable, Hashable {
    case shield
    case stats
    case settings
    
    var label: String {
        switch self {
        case .shield:
            return "Shield"
        case .stats:
            return "Stats"
        case .settings:
            return "Settings"
        }
    }
    
    var iconName: String {
        switch self {
        case .shield:
            return "shield.fill"
        case .stats:
            return "chart.bar.fill"
        case .settings:
            return "gearshape.fill"
        }
    }
}

// MARK: - Preview
#Preview {
    @State var selectedTab = TabBarItem.shield
    
    return ZStack(alignment: .bottom) {
        Color.focusDarkBase.ignoresSafeArea()
        
        VStack {
            switch selectedTab {
            case .shield:
                Text("Shield Tab Content")
                    .headlineStyle()
            case .stats:
                Text("Stats Tab Content")
                    .headlineStyle()
            case .settings:
                Text("Settings Tab Content")
                    .headlineStyle()
            }
            
            Spacer()
        }
        .screenHorizontalPadding()
        
        TabBar(selectedTab: $selectedTab)
    }
}
