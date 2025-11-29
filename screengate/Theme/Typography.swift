import SwiftUI

/// Focus Club Typography System
/// Uses SF Pro font family for consistency with Apple's design language
struct FocusClubTypography {
    // MARK: - Font Families
    static let displayFont = "SF Pro Display"
    static let bodyFont = "SF Pro Text"
    
    // MARK: - Display Styles (Headlines)
    static let display: Font = {
        return Font.system(size: 34, weight: .bold)
    }()
    
    static let headline: Font = {
        return Font.system(size: 28, weight: .bold)
    }()
    
    // MARK: - Title Styles
    static let title: Font = Font.system(size: 20, weight: .semibold)
    
    // MARK: - Body Styles
    static let body: Font = Font.system(size: 16, weight: .regular)
    static let bodyMedium: Font = Font.system(size: 16, weight: .medium)
    static let bodySemibold: Font = Font.system(size: 16, weight: .semibold)
    
    // MARK: - Caption Styles
    static let caption: Font = Font.system(size: 14, weight: .medium)
    static let captionSmall: Font = Font.system(size: 12, weight: .regular)
    
    // MARK: - Button Style
    static let button: Font = Font.system(size: 18, weight: .semibold)
    
    // MARK: - Special Styles
    static let largeNumber: Font = Font.system(size: 48, weight: .bold, design: .default)
    static let mediumNumber: Font = Font.system(size: 32, weight: .bold, design: .default)
}

// MARK: - Text Style Extensions
extension View {
    /// Display style for major headlines
    func displayStyle() -> some View {
        self.font(FocusClubTypography.display)
            .lineSpacing(1.2)
    }
    
    /// Headline style for section titles
    func headlineStyle() -> some View {
        self.font(FocusClubTypography.headline)
            .lineSpacing(1.3)
    }
    
    /// Title style for card headers
    func titleStyle() -> some View {
        self.font(FocusClubTypography.title)
    }
    
    /// Body style for main content
    func bodyStyle() -> some View {
        self.font(FocusClubTypography.body)
            .lineSpacing(1.4)
    }
    
    /// Caption style for metadata/labels
    func captionStyle() -> some View {
        self.font(FocusClubTypography.caption)
            .foregroundColor(.focusTextSecondary)
    }
    
    /// Button text style
    func buttonStyle() -> some View {
        self.font(FocusClubTypography.button)
            .fontWeight(.semibold)
    }
    
    /// Large number display (48pt)
    func largeNumberStyle() -> some View {
        self.font(FocusClubTypography.largeNumber)
    }
    
    /// Medium number display (32pt)
    func mediumNumberStyle() -> some View {
        self.font(FocusClubTypography.mediumNumber)
    }
}
