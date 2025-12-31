//
//  ThemeUsageGuide.swift
//  screengate
//
//  Created by Gokul on 2025/12/30.
//

import SwiftUI

/// THEME USAGE GUIDE
/// 
/// This file demonstrates how to use the centralized theme system throughout your app.
/// The theme supports light/dark modes automatically and provides colors, fonts, and spacing.
///
/// QUICK START EXAMPLES:

// MARK: - Example 1: Using Colors
struct ColorExample: View {
    @Environment(\.theme) var theme
    
    var body: some View {
        VStack(spacing: theme.spacing.large) {
            // Primary color
            Text("Primary Color")
                .font(theme.fonts.headlineSmall)
                .foregroundColor(theme.colors.primary)
            
            // Secondary color
            Text("Secondary Color")
                .font(theme.fonts.bodyLarge)
                .foregroundColor(theme.colors.secondary)
            
            // Background and surface
            VStack {
                Text("Surface")
                    .foregroundColor(theme.colors.text)
            }
            .padding(theme.spacing.medium)
            .background(theme.colors.surface)
            .cornerRadius(theme.spacing.cornerRadiusMedium)
        }
        .padding(theme.spacing.large)
        .background(theme.colors.background)
    }
}

// MARK: - Example 2: Using Fonts
struct FontExample: View {
    @Environment(\.theme) var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.medium) {
            Text("Display Large")
                .font(theme.fonts.displayLarge)
            
            Text("Headline Medium")
                .font(theme.fonts.headlineMedium)
            
            Text("Title Large")
                .font(theme.fonts.titleLarge)
            
            Text("Body Medium")
                .font(theme.fonts.bodyMedium)
            
            Text("Label Small")
                .font(theme.fonts.labelSmall)
        }
        .padding(theme.spacing.large)
    }
}

// MARK: - Example 3: Using Buttons
struct ButtonExample: View {
    var body: some View {
        VStack(spacing: 12) {
            Button("Primary Button") {}
                .primaryButton()
            
            Button("Secondary Button") {}
                .secondaryButton()
            
            Button("Tertiary Button") {}
                .tertiaryButton()
            
            Button("Delete") {}
                .destructiveButton()
        }
        .padding()
    }
}

// MARK: - Example 4: Using Cards
struct CardExample: View {
    @Environment(\.theme) var theme
    
    var body: some View {
        VStack(spacing: theme.spacing.large) {
            VStack(alignment: .leading, spacing: theme.spacing.small) {
                Text("Card Title")
                    .font(theme.fonts.titleLarge)
                
                Text("This is a themed card component with automatic light/dark mode support.")
                    .font(theme.fonts.bodyMedium)
                    .foregroundColor(theme.colors.textSecondary)
            }
            .themedCard()
            
            VStack {
                Text("Another Card")
                    .font(theme.fonts.bodyLarge)
            }
            .themedCard()
        }
        .padding(theme.spacing.large)
        .background(theme.colors.background)
    }
}

// MARK: - Example 5: Using Interactive Components
struct InteractiveComponentsExample: View {
    @Environment(\.theme) var theme
    @State private var isChecked = false
    @State private var selectedOption = "option1"
    @State private var sliderValue = 50.0
    @State private var toggleState = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.large) {
            // Checkbox
            ThemedCheckbox("Accept terms", isChecked: $isChecked)
            
            // Radio buttons
            VStack(alignment: .leading, spacing: theme.spacing.small) {
                Text("Select an option:")
                    .font(theme.fonts.labelLarge)
                
                ThemedRadioButton("Option 1", selection: $selectedOption, option: "option1")
                ThemedRadioButton("Option 2", selection: $selectedOption, option: "option2")
                ThemedRadioButton("Option 3", selection: $selectedOption, option: "option3")
            }
            .padding(theme.spacing.medium)
            .themedCard()
            
            // Slider
            VStack(spacing: theme.spacing.small) {
                ThemedSlider("Volume", value: $sliderValue, in: 0...100, step: 1)
                Text("Current: \(Int(sliderValue))")
                    .font(theme.fonts.bodySmall)
                    .foregroundColor(theme.colors.textSecondary)
            }
            .padding(theme.spacing.medium)
            .themedCard()
            
            // Toggle
            ThemedToggle("Enable notifications", isOn: $toggleState)
                .padding(theme.spacing.medium)
                .themedCard()
        }
        .padding(theme.spacing.large)
    }
}

// MARK: - Example 6: Complete Screen Example
struct CompleteScreenExample: View {
    @Environment(\.theme) var theme
    @State private var textInput = ""
    
    var body: some View {
        ZStack {
            theme.colors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.large) {
                    // Header
                    VStack(alignment: .leading, spacing: theme.spacing.small) {
                        Text("Welcome")
                            .font(theme.fonts.displaySmall)
                            .foregroundColor(theme.colors.primary)
                        
                        Text("This is a complete example")
                            .font(theme.fonts.bodyLarge)
                            .foregroundColor(theme.colors.textSecondary)
                    }
                    
                    Divider()
                        .background(theme.colors.divider)
                    
                    // Text input field
                    TextField("Enter text", text: $textInput)
                        .themedTextField()
                    
                    // Content card
                    VStack(alignment: .leading, spacing: theme.spacing.medium) {
                        HStack {
                            Circle()
                                .fill(theme.colors.success)
                                .frame(width: 8, height: 8)
                            
                            Text("Success status")
                                .font(theme.fonts.bodyMedium)
                                .foregroundColor(theme.colors.text)
                        }
                        
                        HStack {
                            Circle()
                                .fill(theme.colors.warning)
                                .frame(width: 8, height: 8)
                            
                            Text("Warning status")
                                .font(theme.fonts.bodyMedium)
                                .foregroundColor(theme.colors.text)
                        }
                        
                        HStack {
                            Circle()
                                .fill(theme.colors.error)
                                .frame(width: 8, height: 8)
                            
                            Text("Error status")
                                .font(theme.fonts.bodyMedium)
                                .foregroundColor(theme.colors.text)
                        }
                    }
                    .themedCard()
                    
                    // Buttons
                    VStack(spacing: theme.spacing.medium) {
                        Button("Save") {}
                            .successButton()
                        
                        Button("Cancel") {}
                            .tertiaryButton()
                        
                        Button("Delete") {}
                            .destructiveButton()
                    }
                }
                .padding(theme.spacing.large)
            }
        }
    }
}

// MARK: - How to Use in Your App:
// 
// 1. Import the theme in any view:
//    @Environment(\.theme) var theme
//
// 2. Access colors:
//    Text("Hello")
//        .foregroundColor(theme.colors.primary)
//
// 3. Access fonts:
//    Text("Title")
//        .font(theme.fonts.headlineLarge)
//
// 4. Access spacing:
//    VStack(spacing: theme.spacing.large) { ... }
//
// 5. Use modifier shortcuts:
//    Button("Save") {}
//        .primaryButton()
//
// 6. The theme automatically supports light/dark mode!

#Preview {
    CompleteScreenExample()
}
