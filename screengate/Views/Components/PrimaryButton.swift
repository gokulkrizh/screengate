import SwiftUI

/// Primary action button with gradient background
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    let isLoading: Bool
    let isDisabled: Bool
    
    init(title: String, action: @escaping () -> Void, isLoading: Bool = false, isDisabled: Bool = false) {
        self.title = title
        self.action = action
        self.isLoading = isLoading
        self.isDisabled = isDisabled
    }
    
    var body: some View {
        Button(action: {
            if !isLoading && !isDisabled {
                action()
            }
        }) {
            if isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                        .tint(.white)
                    Text(title)
                        .font(FocusClubTypography.button)
                        .foregroundColor(.white)
                }
            } else {
                Text(title)
                    .font(FocusClubTypography.button)
                    .foregroundColor(.white)
            }
        }
        .disabled(isDisabled || isLoading)
        .if(isDisabled || isLoading) { view in
            view.disabledButtonStyle()
        }
        .if(!isDisabled && !isLoading) { view in
            view.primaryButton()
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Continue", action: {})
        PrimaryButton(title: "Loading...", action: {}, isLoading: true)
        PrimaryButton(title: "Disabled", action: {}, isDisabled: true)
    }
    .screenBackground()
    .screenHorizontalPadding()
}

// MARK: - View Extension Helper
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
