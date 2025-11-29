import SwiftUI

/// iOS-style toggle switch with haptic feedback
struct ToggleSwitch: View {
    @Binding var isOn: Bool
    var label: String?
    var hapticFeedback: Bool = true
    
    var body: some View {
        HStack(spacing: FocusClubSpacing.base) {
            if let label = label {
                Text(label)
                    .bodyStyle()
                    .foregroundColor(.focusText)
                
                Spacer()
            }
            
            Toggle("", isOn: $isOn)
                .onChange(of: isOn) { _, newValue in
                    if hapticFeedback {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
                .tint(.focusAccent)
        }
    }
}

/// Alternative custom toggle with animation (without native toggle)
struct CustomToggleSwitch: View {
    @Binding var isOn: Bool
    var label: String?
    var hapticFeedback: Bool = true
    var backgroundColor: Color = .focusCard
    var onColor: Color = .focusAccent
    var size: CGSize = CGSize(width: 50, height: 28)
    
    var body: some View {
        HStack(spacing: FocusClubSpacing.base) {
            if let label = label {
                Text(label)
                    .bodyStyle()
                    .foregroundColor(.focusText)
                
                Spacer()
            }
            
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule()
                    .fill(isOn ? onColor : backgroundColor)
                    .frame(width: size.width, height: size.height)
                
                Circle()
                    .fill(.white)
                    .frame(width: size.height - 2, height: size.height - 2)
                    .padding(1)
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isOn.toggle()
                }
                if hapticFeedback {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            .frame(width: size.width, height: size.height)
        }
    }
}

// MARK: - Preview
#Preview {
    @State var toggle1 = true
    @State var toggle2 = false
    @State var toggle3 = true
    
    return VStack(spacing: 20) {
        CardView {
            VStack(spacing: 16) {
                ToggleSwitch(isOn: $toggle1, label: "Focus Mode Enabled")
                
                Divider()
                    .foregroundColor(.focusCard)
                
                ToggleSwitch(isOn: $toggle2, label: "Notifications")
                
                Divider()
                    .foregroundColor(.focusCard)
                
                ToggleSwitch(isOn: $toggle3, label: "Analytics")
            }
        }
        
        VStack(spacing: 16) {
            Text("Custom Toggle Variant")
                .titleStyle()
            
            CustomToggleSwitch(isOn: $toggle1, label: "Custom Style")
            CustomToggleSwitch(isOn: $toggle2, label: "Another Option")
        }
        .screenHorizontalPadding()
        
        Spacer()
    }
    .screenBackground()
    .screenHorizontalPadding()
}
