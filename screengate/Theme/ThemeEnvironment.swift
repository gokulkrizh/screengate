//
//  ThemeEnvironment.swift
//  screengate
//
//  Created by Gokul on 2025/12/30.
//

import SwiftUI

// MARK: - Theme Environment Key
struct ThemeKey: EnvironmentKey {
    static let defaultValue = AppTheme.shared
}

extension EnvironmentValues {
    var theme: AppTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

extension View {
    func applyTheme(_ theme: AppTheme = AppTheme.shared) -> some View {
        self.environment(\.theme, theme)
    }
}

// MARK: - Convenient Color Extensions
extension View {
    var theme: AppTheme {
        AppTheme.shared
    }
}
