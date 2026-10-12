//
//  AppTheme.swift
//  screengate
//
//  Created by Gokul on 2025/12/30.
//

import SwiftUI

/// Global theme for the app
struct AppTheme {
    static let shared = AppTheme()
    
    // MARK: - Colors
    let colors: ColorTheme
    
    // MARK: - Fonts
    let fonts: FontTheme
    
    // MARK: - Spacing
    let spacing: SpacingTheme
    
    private init() {
        self.colors = ColorTheme()
        self.fonts = FontTheme()
        self.spacing = SpacingTheme()
    }
}

// MARK: - Color Theme
struct ColorTheme {
    // Primary = Lamp accent (v2)
    let primary = Color(hex: "F3D9A4")
    let primaryLight = Color(hex: "F8E8C6")
    let primaryDark = Color(hex: "B8862C")
    
    // Secondary Colors (Gray tones)
    let secondary = Color(red: 0.65, green: 0.72, blue: 0.67)
    let secondaryLight = Color(red: 0.6, green: 0.6, blue: 0.62)
    let secondaryDark = Color(red: 0.35, green: 0.35, blue: 0.37)
    
    // Accent Colors (Neon Green variant)
    let accent = Color(hex: "F3D9A4")
    let accentLight = Color(hex: "F8E8C6")
    let accentDark = Color(hex: "B8862C")
    
    // Success / Warning / Error
    let success = Color(hex: "B6D07E")
    let warning = Color(red: 1, green: 0.84, blue: 0)
    let error = Color(red: 1, green: 0.24, blue: 0.24)
    
    // Interactive Components Colors
    let checkboxUnchecked: Color
    let checkboxChecked: Color
    let radioButtonUnchecked: Color
    let radioButtonSelected: Color
    let sliderThumb: Color
    let sliderTrack: Color
    let toggleEnabled: Color
    let toggleDisabled: Color
    
    // Neutral Colors
    let background: Color
    let surface: Color
    let surfaceVariant: Color
    let text: Color
    let textSecondary: Color
    let border: Color
    let divider: Color
    
    init() {
        let isDark = true // Force dark mode by default
        
        if isDark {
            // v2 Lamp palette (see KitchenTheme). Legacy screens pick this up until they are restyled.
            self.background = Color(hex: "15120F")
            self.surface = Color(hex: "221E1A")
            self.surfaceVariant = Color(hex: "2D2823")
            self.text = Color(hex: "F7F2E9")
            self.textSecondary = Color(hex: "B5AC9F")
            self.border = Color(hex: "F3D9A4")
            self.divider = Color(hex: "2D2823")
            self.checkboxUnchecked = Color(hex: "2D2823")
            self.checkboxChecked = Color(hex: "F3D9A4")
            self.radioButtonUnchecked = Color(hex: "2D2823")
            self.radioButtonSelected = Color(hex: "F3D9A4")
            self.sliderThumb = Color(hex: "F3D9A4")
            self.sliderTrack = Color(hex: "2D2823")
            self.toggleEnabled = Color(hex: "F3D9A4")
            self.toggleDisabled = Color(hex: "2D2823")
        } else {
            // Light Mode
            self.background = Color(red: 0.98, green: 0.98, blue: 0.98)
            self.surface = Color(red: 1, green: 1, blue: 1)
            self.surfaceVariant = Color(red: 0.92, green: 0.92, blue: 0.92)
            self.text = Color(red: 0.11, green: 0.11, blue: 0.12)
            self.textSecondary = Color(red: 0.6, green: 0.6, blue: 0.62)
            self.border = Color(red: 0.45, green: 0.65, blue: 0.35)
            self.divider = Color(red: 0.92, green: 0.92, blue: 0.92)
            self.checkboxUnchecked = Color(red: 0.92, green: 0.92, blue: 0.92)
            self.checkboxChecked = Color(red: 0.70, green: 0.86, blue: 0.55)
            self.radioButtonUnchecked = Color(red: 0.92, green: 0.92, blue: 0.92)
            self.radioButtonSelected = Color(red: 0.70, green: 0.86, blue: 0.55)
            self.sliderThumb = Color(red: 0.70, green: 0.86, blue: 0.55)
            self.sliderTrack = Color(red: 0.92, green: 0.92, blue: 0.92)
            self.toggleEnabled = Color(red: 0.70, green: 0.86, blue: 0.55)
            self.toggleDisabled = Color(red: 0.92, green: 0.92, blue: 0.92)
        }
    }
}

// MARK: - Font Theme
struct FontTheme {
    // Display Fonts (Large headings)
    let displayLarge = Font.custom("Manrope", size: 57, relativeTo: .body).weight(.bold)
    let displayMedium = Font.custom("Manrope", size: 45, relativeTo: .body).weight(.bold)
    let displaySmall = Font.custom("Manrope", size: 36, relativeTo: .body).weight(.bold)
    
    // Headline Fonts
    let headlineLarge = Font.custom("Manrope", size: 32, relativeTo: .body).weight(.bold)
    let headlineMedium = Font.custom("Manrope", size: 28, relativeTo: .body).weight(.bold)
    let headlineSmall = Font.custom("Manrope", size: 24, relativeTo: .body).weight(.bold)
    
    // Title Fonts
    let titleLarge = Font.custom("Manrope", size: 22, relativeTo: .body).weight(.semibold)
    let titleMedium = Font.custom("Manrope", size: 16, relativeTo: .body).weight(.semibold)
    let titleSmall = Font.custom("Manrope", size: 14, relativeTo: .body).weight(.semibold)
    
    // Body Fonts
    let bodyLarge = Font.custom("Manrope", size: 16, relativeTo: .body).weight(.regular)
    let bodyMedium = Font.custom("Manrope", size: 14, relativeTo: .body).weight(.regular)
    let bodySmall = Font.custom("Manrope", size: 12, relativeTo: .body).weight(.regular)
    
    // Label Fonts
    let labelLarge = Font.custom("Manrope", size: 14, relativeTo: .body).weight(.medium)
    let labelMedium = Font.custom("Manrope", size: 12, relativeTo: .body).weight(.medium)
    let labelSmall = Font.custom("Manrope", size: 11, relativeTo: .body).weight(.medium)
}

// MARK: - Spacing Theme
struct SpacingTheme {
    let none: CGFloat = 0
    let extraSmall: CGFloat = 4
    let small: CGFloat = 8
    let medium: CGFloat = 16
    let large: CGFloat = 24
    let extraLarge: CGFloat = 32
    let huge: CGFloat = 48
    
    let cornerRadiusSmall: CGFloat = 8
    let cornerRadiusMedium: CGFloat = 12
    let cornerRadiusLarge: CGFloat = 16
    let cornerRadiusExtraLarge: CGFloat = 20
}
