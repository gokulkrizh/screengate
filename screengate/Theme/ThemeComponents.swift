//
//  ThemeComponents.swift
//  screengate
//
//  Created by Gokul on 2025/12/30.
//

import SwiftUI

// MARK: - Themed Button Style
struct ThemedButtonStyle: ButtonStyle {
    @Environment(\.theme) var theme
    var variant: ButtonVariant = .primary
    var isEnabled: Bool = true
    
    enum ButtonVariant {
        case primary
        case secondary
        case tertiary
        case destructive
        case success
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(theme.fonts.labelLarge)
            .padding(.horizontal, theme.spacing.large)
            .padding(.vertical, theme.spacing.medium)
            .background(backgroundColor(for: variant, isPressed: configuration.isPressed, isEnabled: isEnabled))
            .foregroundColor(foregroundColor(for: variant))
            .cornerRadius(theme.spacing.cornerRadiusMedium)
            .opacity((configuration.isPressed || !isEnabled) ? 0.8 : 1.0)
            .disabled(!isEnabled)
    }
    
    private func backgroundColor(for variant: ButtonVariant, isPressed: Bool, isEnabled: Bool) -> Color {
        guard isEnabled else {
            return theme.colors.border
        }
        
        switch variant {
        case .primary:
            return isPressed ? theme.colors.primaryDark : theme.colors.primary
        case .secondary:
            return isPressed ? theme.colors.secondaryDark : theme.colors.secondary
        case .tertiary:
            return theme.colors.surfaceVariant
        case .destructive:
            return isPressed ? theme.colors.accentDark : theme.colors.error
        case .success:
            return isPressed ? theme.colors.success.opacity(0.7) : theme.colors.success
        }
    }
    
    private func foregroundColor(for variant: ButtonVariant) -> Color {
        guard isEnabled else {
            return theme.colors.textSecondary
        }
        
        switch variant {
        case .primary, .secondary, .destructive, .success:
            return .white
        case .tertiary:
            return theme.colors.text
        }
    }
}

// MARK: - Themed Card Style
struct ThemedCardStyle: ViewModifier {
    @Environment(\.theme) var theme
    
    func body(content: Content) -> some View {
        content
            .padding(theme.spacing.medium)
            .background(theme.colors.surface)
            .cornerRadius(theme.spacing.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: theme.spacing.cornerRadiusMedium)
                    .stroke(theme.colors.border, lineWidth: 0.5)
            )
    }
}

// MARK: - Themed Text Field Modifier
struct ThemedTextFieldModifier: ViewModifier {
    @Environment(\.theme) var theme
    
    func body(content: Content) -> some View {
        content
            .font(theme.fonts.bodyMedium)
            .foregroundColor(theme.colors.text)
            .padding(theme.spacing.medium)
            .background(theme.colors.surface)
            .cornerRadius(theme.spacing.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: theme.spacing.cornerRadiusMedium)
                    .stroke(theme.colors.border, lineWidth: 1)
            )
    }
}

// MARK: - View Modifiers
extension View {
    /// Apply themed card styling
    func themedCard() -> some View {
        modifier(ThemedCardStyle())
    }
    
    /// Apply themed text field styling
    func themedTextField() -> some View {
        modifier(ThemedTextFieldModifier())
    }
    
    /// Apply primary button style
    func primaryButton(isEnabled: Bool = true) -> some View {
        buttonStyle(ThemedButtonStyle(variant: .primary, isEnabled: isEnabled))
    }
    
    /// Apply secondary button style
    func secondaryButton(isEnabled: Bool = true) -> some View {
        buttonStyle(ThemedButtonStyle(variant: .secondary, isEnabled: isEnabled))
    }
    
    /// Apply tertiary button style
    func tertiaryButton(isEnabled: Bool = true) -> some View {
        buttonStyle(ThemedButtonStyle(variant: .tertiary, isEnabled: isEnabled))
    }
    
    /// Apply destructive button style
    func destructiveButton(isEnabled: Bool = true) -> some View {
        buttonStyle(ThemedButtonStyle(variant: .destructive, isEnabled: isEnabled))
    }
    
    /// Apply success button style
    func successButton(isEnabled: Bool = true) -> some View {
        buttonStyle(ThemedButtonStyle(variant: .success, isEnabled: isEnabled))
    }
    
    /// Apply themed background
    func themedBackground() -> some View {
        @Environment(\.theme) var theme
        return self.background(theme.colors.background)
    }
    
    /// Apply themed text color
    func themedText() -> some View {
        @Environment(\.theme) var theme
        return self.foregroundColor(theme.colors.text)
    }
    
    /// Apply themed secondary text color
    func themedSecondaryText() -> some View {
        @Environment(\.theme) var theme
        return self.foregroundColor(theme.colors.textSecondary)
    }
}
