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
    // Primary Colors (Yellow)
    let primary = Color(red: 1.0, green: 0.84, blue: 0.0) // Yellow
    let primaryLight = Color(red: 1.0, green: 0.92, blue: 0.3)
    let primaryDark = Color(red: 0.85, green: 0.68, blue: 0.0)
    
    // Yellow Variants
    let yellowAccent = Color(red: 1.0, green: 0.84, blue: 0.0) // Bright yellow for accents
    let yellowHeading = Color(red: 0.85, green: 0.68, blue: 0.0) // Dark yellow for headings
    let yellowSecondary = Color(red: 1.0, green: 0.92, blue: 0.3) // Light yellow for secondary text
    let yellowMuted = Color(red: 0.95, green: 0.85, blue: 0.2) // Muted yellow for secondary stats
    
    // Secondary Colors
    let secondary = Color(red: 1.0, green: 0.6, blue: 0.2) // Orange
    let secondaryLight = Color(red: 1.0, green: 0.75, blue: 0.4)
    let secondaryDark = Color(red: 0.8, green: 0.4, blue: 0.0)
    
    // Accent Colors
    let accent = Color(red: 1.0, green: 0.3, blue: 0.3) // Red
    let accentLight = Color(red: 1.0, green: 0.5, blue: 0.5)
    let accentDark = Color(red: 0.8, green: 0.1, blue: 0.1)
    
    // Success / Warning / Error
    let success = Color(red: 0.2, green: 0.8, blue: 0.4) // Green
    let warning = Color(red: 1.0, green: 0.7, blue: 0.0) // Yellow
    let error = Color(red: 1.0, green: 0.3, blue: 0.3) // Red
    
    // Interactive Components Colors
    let checkboxUnchecked: Color
    let checkboxChecked = Color(red: 1.0, green: 0.84, blue: 0.0)
    let radioButtonUnchecked: Color
    let radioButtonSelected = Color(red: 1.0, green: 0.84, blue: 0.0)
    let sliderThumb = Color(red: 1.0, green: 0.84, blue: 0.0)
    let sliderTrack: Color
    let toggleEnabled = Color(red: 0.2, green: 0.8, blue: 0.4)
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
            self.background = Color(red: 0.1, green: 0.1, blue: 0.12)
            self.surface = Color(red: 0.15, green: 0.15, blue: 0.17)
            self.surfaceVariant = Color(red: 0.2, green: 0.2, blue: 0.22)
            self.text = Color(red: 0.95, green: 0.95, blue: 0.95)
            self.textSecondary = Color(red: 0.7, green: 0.7, blue: 0.7)
            self.border = Color(red: 0.3, green: 0.3, blue: 0.32)
            self.divider = Color(red: 0.25, green: 0.25, blue: 0.27)
            self.checkboxUnchecked = Color(red: 0.4, green: 0.4, blue: 0.42)
            self.radioButtonUnchecked = Color(red: 0.4, green: 0.4, blue: 0.42)
            self.sliderTrack = Color(red: 0.3, green: 0.3, blue: 0.32)
            self.toggleDisabled = Color(red: 0.3, green: 0.3, blue: 0.32)
        } else {
            // Light Mode
            self.background = Color(red: 0.98, green: 0.98, blue: 1.0)
            self.surface = Color(red: 1.0, green: 1.0, blue: 1.0)
            self.surfaceVariant = Color(red: 0.95, green: 0.95, blue: 0.97)
            self.text = Color(red: 0.1, green: 0.1, blue: 0.12)
            self.textSecondary = Color(red: 0.4, green: 0.4, blue: 0.4)
            self.border = Color(red: 0.85, green: 0.85, blue: 0.87)
            self.divider = Color(red: 0.9, green: 0.9, blue: 0.92)
            self.checkboxUnchecked = Color(red: 0.85, green: 0.85, blue: 0.87)
            self.radioButtonUnchecked = Color(red: 0.85, green: 0.85, blue: 0.87)
            self.sliderTrack = Color(red: 0.9, green: 0.9, blue: 0.92)
            self.toggleDisabled = Color(red: 0.9, green: 0.9, blue: 0.92)
        }
    }
}

// MARK: - Font Theme
struct FontTheme {
    // Display Fonts (Large headings)
    let displayLarge = Font.system(size: 57, weight: .bold, design: .default)
    let displayMedium = Font.system(size: 45, weight: .bold, design: .default)
    let displaySmall = Font.system(size: 36, weight: .bold, design: .default)
    
    // Headline Fonts
    let headlineLarge = Font.system(size: 32, weight: .bold, design: .default)
    let headlineMedium = Font.system(size: 28, weight: .bold, design: .default)
    let headlineSmall = Font.system(size: 24, weight: .bold, design: .default)
    
    // Title Fonts
    let titleLarge = Font.system(size: 22, weight: .semibold, design: .default)
    let titleMedium = Font.system(size: 16, weight: .semibold, design: .default)
    let titleSmall = Font.system(size: 14, weight: .semibold, design: .default)
    
    // Body Fonts
    let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)
    let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)
    let bodySmall = Font.system(size: 12, weight: .regular, design: .default)
    
    // Label Fonts
    let labelLarge = Font.system(size: 14, weight: .medium, design: .default)
    let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
    let labelSmall = Font.system(size: 11, weight: .medium, design: .default)
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
