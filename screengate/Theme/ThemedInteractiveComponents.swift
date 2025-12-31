//
//  ThemedInteractiveComponents.swift
//  screengate
//
//  Created by Gokul on 2025/12/30.
//

import SwiftUI

// MARK: - Themed Checkbox
struct ThemedCheckbox: View {
    @Environment(\.theme) var theme
    @Binding var isChecked: Bool
    let label: String?
    
    init(_ label: String? = nil, isChecked: Binding<Bool>) {
        self.label = label
        self._isChecked = isChecked
    }
    
    var body: some View {
        Button(action: { isChecked.toggle() }) {
            HStack(spacing: theme.spacing.small) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isChecked ? theme.colors.checkboxChecked : theme.colors.checkboxUnchecked)
                
                if let label = label {
                    Text(label)
                        .font(theme.fonts.bodyMedium)
                        .foregroundColor(theme.colors.text)
                }
            }
        }
    }
}

// MARK: - Themed Radio Button
struct ThemedRadioButton<T: Equatable>: View {
    @Environment(\.theme) var theme
    @Binding var selection: T
    let option: T
    let label: String?
    
    init(_ label: String? = nil, selection: Binding<T>, option: T) {
        self.label = label
        self._selection = selection
        self.option = option
    }
    
    var body: some View {
        Button(action: { selection = option }) {
            HStack(spacing: theme.spacing.small) {
                Circle()
                    .strokeBorder(
                        selection == option ? theme.colors.radioButtonSelected : theme.colors.radioButtonUnchecked,
                        lineWidth: 2
                    )
                    .background(
                        Circle()
                            .fill(
                                selection == option ?
                                theme.colors.radioButtonSelected.opacity(0.2) :
                                Color.clear
                            )
                    )
                    .frame(width: 20, height: 20)
                
                if selection == option {
                    Circle()
                        .fill(theme.colors.radioButtonSelected)
                        .frame(width: 8, height: 8)
                }
                
                if let label = label {
                    Text(label)
                        .font(theme.fonts.bodyMedium)
                        .foregroundColor(theme.colors.text)
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Themed Slider
struct ThemedSlider: View {
    @Environment(\.theme) var theme
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double?
    let label: String?
    
    init(_ label: String? = nil, value: Binding<Double>, in range: ClosedRange<Double>, step: Double? = nil) {
        self.label = label
        self._value = value
        self.range = range
        self.step = step
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.small) {
            if let label = label {
                Text(label)
                    .font(theme.fonts.labelLarge)
                    .foregroundColor(theme.colors.text)
            }
            
            Slider(value: $value, in: range, step: step ?? 1.0)
                .tint(theme.colors.sliderThumb)
        }
    }
}

// MARK: - Themed Toggle
struct ThemedToggle: View {
    @Environment(\.theme) var theme
    @Binding var isOn: Bool
    let label: String?
    
    init(_ label: String? = nil, isOn: Binding<Bool>) {
        self.label = label
        self._isOn = isOn
    }
    
    var body: some View {
        HStack(spacing: theme.spacing.medium) {
            if let label = label {
                Text(label)
                    .font(theme.fonts.bodyMedium)
                    .foregroundColor(theme.colors.text)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(isOn ? theme.colors.toggleEnabled : theme.colors.toggleDisabled)
        }
    }
}

// MARK: - View Extensions for Easy Access
extension View {
    /// Create a themed checkbox
    func themedCheckbox(_ label: String? = nil, isChecked: Binding<Bool>) -> some View {
        ThemedCheckbox(label, isChecked: isChecked)
    }
    
    /// Create a themed radio button
    func themedRadioButton<T: Equatable>(_ label: String? = nil, selection: Binding<T>, option: T) -> some View {
        ThemedRadioButton(label, selection: selection, option: option)
    }
    
    /// Create a themed slider
    func themedSlider(_ label: String? = nil, value: Binding<Double>, in range: ClosedRange<Double>, step: Double? = nil) -> some View {
        ThemedSlider(label, value: value, in: range, step: step)
    }
    
    /// Create a themed toggle
    func themedToggle(_ label: String? = nil, isOn: Binding<Bool>) -> some View {
        ThemedToggle(label, isOn: isOn)
    }
}
