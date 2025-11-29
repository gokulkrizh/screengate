import SwiftUI

/// Focus Club Spacing System
/// Consistent spacing throughout the app based on 4pt grid
struct FocusClubSpacing {
    // MARK: - Base Spacing Units
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let base: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    
    // MARK: - Component Specific
    /// Screen edge margins (left/right padding)
    static let screenMarginHorizontal: CGFloat = 20
    
    /// Safe area top padding
    static let screenMarginTop: CGFloat = 16
    
    /// Safe area bottom padding
    static let screenMarginBottom: CGFloat = 24
    
    /// Card padding (internal content padding)
    static let cardPadding: CGFloat = 16
    
    /// Card margin between cards
    static let cardMargin: CGFloat = 20
    
    /// Button height
    static let buttonHeight: CGFloat = 56
    
    /// Button corner radius (pill shape)
    static let buttonCornerRadius: CGFloat = 28
    
    /// Card corner radius
    static let cardCornerRadius: CGFloat = 16
    
    /// Small component corner radius
    static let componentCornerRadius: CGFloat = 12
    
    /// Tab bar height (excluding safe area)
    static let tabBarHeight: CGFloat = 49
    
    // MARK: - Line Heights
    static let lineHeightTight: CGFloat = 1.2
    static let lineHeightNormal: CGFloat = 1.4
    static let lineHeightRelaxed: CGFloat = 1.6
}

// MARK: - Padding Extensions
extension View {
    /// Screen horizontal margins (sides only)
    func screenHorizontalPadding() -> some View {
        self.padding(.horizontal, FocusClubSpacing.screenMarginHorizontal)
    }
    
    /// Screen full padding (top, bottom, sides)
    func screenPadding() -> some View {
        self.padding(.horizontal, FocusClubSpacing.screenMarginHorizontal)
            .padding(.top, FocusClubSpacing.screenMarginTop)
            .padding(.bottom, FocusClubSpacing.screenMarginBottom)
    }
    
    /// Card internal padding
    func cardPadding() -> some View {
        self.padding(FocusClubSpacing.cardPadding)
    }
}
