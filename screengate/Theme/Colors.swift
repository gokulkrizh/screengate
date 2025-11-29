import SwiftUI

/// Focus Club Color Palette
/// Design spec: Dark mode focused with muted, calming colors
struct FocusClubColors {
    // MARK: - Primary Colors
    static let darkBase = Color(red: 0.039, green: 0.055, blue: 0.153) // #0A0E27
    static let cardBackground = Color(red: 0.102, green: 0.122, blue: 0.227) // #1A1F3A
    static let accentPrimary = Color(red: 0.424, green: 0.388, blue: 1.0) // #6C63FF (Focus Purple)
    
    // MARK: - Semantic Colors
    static let success = Color(red: 0.306, green: 0.843, blue: 0.769) // #4ECDC4 (Muted Teal)
    static let warning = Color(red: 1.0, green: 0.702, blue: 0.282) // #FFB347 (Soft Orange)
    static let destructive = Color(red: 1.0, green: 0.420, blue: 0.612) // #FF6B9D (Soft Pink-Red)
    
    // MARK: - Text Colors
    static let textPrimary = Color.white // #FFFFFF
    static let textSecondary = Color(red: 0.722, green: 0.722, blue: 0.816) // #B8B8D0 (Light Gray)
    static let textMuted = Color(red: 0.420, green: 0.439, blue: 0.537) // #6B7089 (Muted Gray)
    
    // MARK: - Functional Colors
    static let disabled = Color(red: 0.165, green: 0.184, blue: 0.290) // #2A2F4A (Dark Gray)
}

// MARK: - Color Extensions for SwiftUI
extension Color {
    // Dark Base Background
    static let focusDarkBase = FocusClubColors.darkBase
    
    // Cards & Components
    static let focusCard = FocusClubColors.cardBackground
    
    // Accent (Primary brand color)
    static let focusAccent = FocusClubColors.accentPrimary
    
    // States
    static let focusSuccess = FocusClubColors.success
    static let focusWarning = FocusClubColors.warning
    static let focusDestructive = FocusClubColors.destructive
    
    // Text
    static let focusText = FocusClubColors.textPrimary
    static let focusTextSecondary = FocusClubColors.textSecondary
    static let focusTextMuted = FocusClubColors.textMuted
    
    // Disabled
    static let focusDisabled = FocusClubColors.disabled
}

// MARK: - Gradient Extensions
extension LinearGradient {
    /// Primary gradient for buttons (purple)
    static let focusPrimary = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.424, green: 0.388, blue: 1.0), // #6C63FF
            Color(red: 0.616, green: 0.549, blue: 1.0)  // #9D8CFF
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Success gradient for positive actions
    static let focusSuccess = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.306, green: 0.843, blue: 0.769), // #4ECDC4
            Color(red: 0.427, green: 0.835, blue: 0.765)  // #6DD5C3
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Background gradient for screens
    static let focusBackground = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.039, green: 0.055, blue: 0.153), // #0A0E27
            Color(red: 0.102, green: 0.122, blue: 0.227)  // #1A1F3A
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
