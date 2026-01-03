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
    // Primary Colors (Neon Green)
    let primary = Color(red: 0, green: 1, blue: 0.39)
    let primaryLight = Color(red: 0.2, green: 1, blue: 0.5)
    let primaryDark = Color(red: 0, green: 0.8, blue: 0.31)
    
    // Secondary Colors (Gray tones)
    let secondary = Color(red: 0.47, green: 0.47, blue: 0.49)
    let secondaryLight = Color(red: 0.6, green: 0.6, blue: 0.62)
    let secondaryDark = Color(red: 0.35, green: 0.35, blue: 0.37)
    
    // Accent Colors (Neon Green variant)
    let accent = Color(red: 0, green: 1, blue: 0.39)
    let accentLight = Color(red: 0.2, green: 1, blue: 0.5)
    let accentDark = Color(red: 0, green: 0.8, blue: 0.31)
    
    // Success / Warning / Error
    let success = Color(red: 0, green: 1, blue: 0.39)
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
            // Dark Mode
            self.background = Color(red: 0.06, green: 0.06, blue: 0.07)
            self.surface = Color(red: 0.09, green: 0.09, blue: 0.10)
            self.surfaceVariant = Color(red: 0.16, green: 0.16, blue: 0.18)
            self.text = Color(red: 0.95, green: 0.95, blue: 0.95)
            self.textSecondary = Color(red: 0.47, green: 0.47, blue: 0.49)
            self.border = Color(red: 0, green: 1, blue: 0.39)
            self.divider = Color(red: 0.16, green: 0.16, blue: 0.18)
            self.checkboxUnchecked = Color(red: 0.16, green: 0.16, blue: 0.18)
            self.checkboxChecked = Color(red: 0, green: 1, blue: 0.39)
            self.radioButtonUnchecked = Color(red: 0.16, green: 0.16, blue: 0.18)
            self.radioButtonSelected = Color(red: 0, green: 1, blue: 0.39)
            self.sliderThumb = Color(red: 0, green: 1, blue: 0.39)
            self.sliderTrack = Color(red: 0.16, green: 0.16, blue: 0.18)
            self.toggleEnabled = Color(red: 0, green: 1, blue: 0.39)
            self.toggleDisabled = Color(red: 0.16, green: 0.16, blue: 0.18)
        } else {
            // Light Mode
            self.background = Color(red: 0.98, green: 0.98, blue: 0.98)
            self.surface = Color(red: 1, green: 1, blue: 1)
            self.surfaceVariant = Color(red: 0.92, green: 0.92, blue: 0.92)
            self.text = Color(red: 0.11, green: 0.11, blue: 0.12)
            self.textSecondary = Color(red: 0.6, green: 0.6, blue: 0.62)
            self.border = Color(red: 0, green: 0.8, blue: 0.31)
            self.divider = Color(red: 0.92, green: 0.92, blue: 0.92)
            self.checkboxUnchecked = Color(red: 0.92, green: 0.92, blue: 0.92)
            self.checkboxChecked = Color(red: 0, green: 1, blue: 0.39)
            self.radioButtonUnchecked = Color(red: 0.92, green: 0.92, blue: 0.92)
            self.radioButtonSelected = Color(red: 0, green: 1, blue: 0.39)
            self.sliderThumb = Color(red: 0, green: 1, blue: 0.39)
            self.sliderTrack = Color(red: 0.92, green: 0.92, blue: 0.92)
            self.toggleEnabled = Color(red: 0, green: 1, blue: 0.39)
            self.toggleDisabled = Color(red: 0.92, green: 0.92, blue: 0.92)
        }
    }
}

// MARK: - Font Theme
struct FontTheme {
    // Display Fonts (Large headings)
    let displayLarge = Font.custom("Manrope", size: 57).weight(.bold)
    let displayMedium = Font.custom("Manrope", size: 45).weight(.bold)
    let displaySmall = Font.custom("Manrope", size: 36).weight(.bold)
    
    // Headline Fonts
    let headlineLarge = Font.custom("Manrope", size: 32).weight(.bold)
    let headlineMedium = Font.custom("Manrope", size: 28).weight(.bold)
    let headlineSmall = Font.custom("Manrope", size: 24).weight(.bold)
    
    // Title Fonts
    let titleLarge = Font.custom("Manrope", size: 22).weight(.semibold)
    let titleMedium = Font.custom("Manrope", size: 16).weight(.semibold)
    let titleSmall = Font.custom("Manrope", size: 14).weight(.semibold)
    
    // Body Fonts
    let bodyLarge = Font.custom("Manrope", size: 16).weight(.regular)
    let bodyMedium = Font.custom("Manrope", size: 14).weight(.regular)
    let bodySmall = Font.custom("Manrope", size: 12).weight(.regular)
    
    // Label Fonts
    let labelLarge = Font.custom("Manrope", size: 14).weight(.medium)
    let labelMedium = Font.custom("Manrope", size: 12).weight(.medium)
    let labelSmall = Font.custom("Manrope", size: 11).weight(.medium)
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
