import SwiftUI

// MARK: - Screen Background Modifier
extension View {
    /// Dark gradient background for entire screens
    func screenBackground() -> some View {
        self
            .background(LinearGradient.focusBackground)
            .ignoresSafeArea()
    }
}

// MARK: - Card Style Modifier
extension View {
    /// Standard card styling (background, border, shadow)
    func cardStyle() -> some View {
        self
            .background(Color.focusCard)
            .cornerRadius(FocusClubSpacing.cardCornerRadius)
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 4)
    }
}

// MARK: - Primary Button Modifier
extension View {
    /// Full-width primary button styling
    func primaryButton() -> some View {
        self
            .font(FocusClubTypography.button)
            .foregroundColor(.white)
            .frame(height: FocusClubSpacing.buttonHeight)
            .frame(maxWidth: .infinity)
            .background(LinearGradient.focusPrimary)
            .cornerRadius(FocusClubSpacing.buttonCornerRadius)
            .shadow(
                color: Color(red: 0.424, green: 0.388, blue: 1.0).opacity(0.3),
                radius: 8,
                x: 0,
                y: 8
            )
    }
}

// MARK: - Secondary Button Modifier
extension View {
    /// Secondary button styling (outline style)
    func secondaryButton() -> some View {
        self
            .font(FocusClubTypography.button)
            .foregroundColor(.focusAccent)
            .frame(height: FocusClubSpacing.buttonHeight)
            .frame(maxWidth: .infinity)
            .background(Color.clear)
            .border(Color.focusAccent, width: 2)
            .cornerRadius(FocusClubSpacing.buttonCornerRadius)
    }
}

// MARK: - Disabled State Modifier
extension View {
    /// Disabled button state styling
    func disabledButtonStyle() -> some View {
        self
            .font(FocusClubTypography.button)
            .foregroundColor(.focusTextMuted)
            .frame(height: FocusClubSpacing.buttonHeight)
            .frame(maxWidth: .infinity)
            .background(Color.focusDisabled)
            .cornerRadius(FocusClubSpacing.buttonCornerRadius)
            .opacity(0.6)
    }
}

// MARK: - Card Content Modifier
extension View {
    /// Padding + text color for card content
    func cardContent() -> some View {
        self
            .padding(FocusClubSpacing.cardPadding)
            .foregroundColor(.focusText)
    }
}

// MARK: - Safe Area Padding
extension View {
    /// Respects safe area with standard screen padding
    func safeAreaPadding() -> some View {
        self
            .padding(.horizontal, FocusClubSpacing.screenMarginHorizontal)
            .padding(.top, FocusClubSpacing.screenMarginTop)
            .padding(.bottom, FocusClubSpacing.screenMarginBottom)
    }
}

// MARK: - Text Secondary Color Modifier
extension View {
    /// Apply secondary text color and style
    func secondaryText() -> some View {
        self
            .foregroundColor(.focusTextSecondary)
            .font(FocusClubTypography.body)
    }
}

// MARK: - Blur Effect Modifier
extension View {
    /// Conditional blur effect
    func blurEffect(radius: CGFloat = 10, isActive: Bool = true) -> some View {
        self
            .blur(radius: isActive ? radius : 0)
    }
}

// MARK: - Haptic Feedback
extension View {
    /// Trigger light haptic feedback on interaction
    func lightHaptic() -> some View {
        onTapGesture {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }
    }
    
    /// Trigger medium haptic feedback
    func mediumHaptic() -> some View {
        onTapGesture {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }
    }
    
    /// Trigger heavy haptic feedback (for important actions)
    func heavyHaptic() -> some View {
        onTapGesture {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
        }
    }
}
