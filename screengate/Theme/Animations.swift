import SwiftUI

/// Focus Club Animation Timings & Easing Functions
struct FocusClubAnimations {
    // MARK: - Timing Durations (in seconds)
    /// Quick interactions (button press, toggle)
    static let quick = 0.1
    
    /// Standard transitions (page changes, card reveals)
    static let standard = 0.3
    
    /// Moderate animations (modal appearance)
    static let moderate = 0.4
    
    /// Slow animations (breathing effects, elaborate transitions)
    static let slow = 0.5
    
    /// Very slow animations (breathing cycle, meditation)
    static let verySlow = 4.0
    
    // MARK: - Animation Curves
    /// Page transition animation
    static let pageTransition = Animation.easeOut(duration: standard)
    
    /// Button press animation (immediate feedback)
    static let buttonPress = Animation.easeInOut(duration: quick)
    
    /// Card reveal animation (smooth appearance)
    static let cardReveal = Animation.easeOut(duration: moderate)
    
    /// Modal/sheet appearance (bouncy)
    static let modalAppearance: Animation = {
        Animation.interpolatingSpring(stiffness: 0.6, damping: 0.8)
            .delay(0.05)
    }()
    
    /// Breathing animation loop (meditative)
    static let breathing = Animation.easeInOut(duration: verySlow)
        .repeatForever(autoreverses: true)
    
    /// Progress animation (linear)
    static let progress = Animation.linear(duration: standard)
}

// MARK: - Animation Extensions
extension View {
    /// Page transition animation: slide from right + fade
    func pageTransitionAnimation(_ isVisible: Bool) -> some View {
        self
            .opacity(isVisible ? 1 : 0)
            .offset(x: isVisible ? 0 : 50)
            .animation(.easeOut(duration: 0.3), value: isVisible)
    }
    
    /// Button press animation: scale down slightly
    func buttonPressAnimation(_ isPressed: Bool) -> some View {
        self
            .scaleEffect(isPressed ? 0.95 : 1.0, anchor: .center)
            .opacity(isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
    
    /// Card reveal animation: fade in + slide up
    func cardRevealAnimation(_ isVisible: Bool) -> some View {
        self
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .animation(.easeOut(duration: 0.4), value: isVisible)
    }
    
    /// Modal appearance: spring-based animation
    func modalAppearanceAnimation(_ isPresented: Bool) -> some View {
        self
            .opacity(isPresented ? 1 : 0)
            .scaleEffect(isPresented ? 1 : 0.9, anchor: .center)
            .animation(
                Animation.interpolatingSpring(stiffness: 0.6, damping: 0.8)
                    .delay(isPresented ? 0.05 : 0),
                value: isPresented
            )
    }
    
    /// Breathing circle animation (expand/contract)
    func breathingAnimation(_ isAnimating: Bool) -> some View {
        self
            .scaleEffect(isAnimating ? 1.2 : 0.8, anchor: .center)
            .animation(
                Animation.easeInOut(duration: 4.0)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
    }
    
    /// Progress ring stroke animation
    func progressRingAnimation(_ progress: Double) -> some View {
        self
            .animation(.linear(duration: 0.3), value: progress)
    }
    
    /// Success celebration: scale pulse
    func celebrationAnimation(_ isActive: Bool) -> some View {
        self
            .scaleEffect(isActive ? 1.1 : 1.0, anchor: .center)
            .animation(
                Animation.easeInOut(duration: 0.4)
                    .repeatCount(2, autoreverses: true),
                value: isActive
            )
    }
}

// MARK: - Transition Extensions
extension AnyTransition {
    /// Slide + fade transition for pages
    static var slideAndFade: AnyTransition {
        AnyTransition.asymmetric(
            insertion: AnyTransition.opacity
                .combined(with: .offset(x: 50)),
            removal: AnyTransition.opacity
                .combined(with: .offset(x: -50))
        )
    }
    
    /// Slide up + fade for modals
    static var slideUpAndFade: AnyTransition {
        AnyTransition.asymmetric(
            insertion: AnyTransition.opacity
                .combined(with: .offset(y: 20)),
            removal: AnyTransition.opacity
                .combined(with: .offset(y: 20))
        )
    }
    
    /// Scale + fade for card reveals
    static var scaleAndFade: AnyTransition {
        AnyTransition.asymmetric(
            insertion: AnyTransition.opacity
                .combined(with: .scale(scale: 0.9)),
            removal: AnyTransition.opacity
                .combined(with: .scale(scale: 0.9))
        )
    }
}
