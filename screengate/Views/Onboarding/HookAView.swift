import SwiftUI

/// Hook A — the animated "junk plate".
/// Icons pile onto a plate as a hour counter climbs to 6.
struct HookAView: View {
    @ObservedObject var data: OnboardingData
    @State private var appearedIcons = 0
    @State private var hours = 0
    private let appTheme = AppTheme.shared

    private let icons = [
        "play.rectangle.fill", "music.note", "camera.fill", "gamecontroller.fill",
        "bubble.left.and.bubble.right.fill", "cart.fill", "tv.fill", "photo.fill",
        "heart.fill", "flame.fill", "sparkles", "globe",
        "play.circle.fill", "message.fill", "video.fill", "newspaper.fill",
        "wand.and.stars", "bolt.fill", "cloud.fill", "sun.max.fill",
        "moon.stars.fill", "paintbrush.fill", "theatermasks.fill", "ticket.fill",
    ]

    var body: some View {
        VStack(spacing: appTheme.spacing.large) {
            Spacer(minLength: appTheme.spacing.large)

            VStack(spacing: appTheme.spacing.small) {
                Text("THE APPETIZER")
                    .font(appTheme.fonts.labelSmall)
                    .foregroundColor(appTheme.colors.primary)
                    .tracking(1.5)

                Text("You'd never eat junk\n6 hours a day.")
                    .font(appTheme.fonts.headlineLarge)
                    .foregroundColor(appTheme.colors.text)
                    .multilineTextAlignment(.center)
            }

            plate

            Text(hours > 0 ? "But you'll scroll it — \(hours)h today." : "But you'll scroll it.")
                .font(appTheme.fonts.bodyLarge)
                .foregroundColor(appTheme.colors.textSecondary)
                .contentTransition(.numericText())

            Spacer()

            Button(action: { data.nextScreen() }) {
                Text("Wait, really?")
                    .font(appTheme.fonts.titleMedium)
                    .foregroundColor(appTheme.colors.background)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(appTheme.colors.primary)
                    .cornerRadius(appTheme.spacing.cornerRadiusLarge)
            }
            .padding(.horizontal, appTheme.spacing.large)
            .padding(.bottom, appTheme.spacing.extraLarge)
        }
        .onAppear(perform: playAnimation)
    }

    private var plate: some View {
        ZStack {
            Circle()
                .fill(appTheme.colors.surface)
                .frame(width: 280, height: 280)
                .overlay(
                    Circle().stroke(appTheme.colors.surfaceVariant, lineWidth: 2)
                )

            LazyVGrid(columns: Array(repeating: GridItem(.fixed(36), spacing: 8), count: 6), spacing: 8) {
                ForEach(Array(icons.enumerated()), id: \.offset) { index, icon in
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(appTheme.colors.primary.opacity(0.9))
                        .frame(width: 36, height: 36)
                        .background(appTheme.colors.background.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                        .rotationEffect(.degrees(Double((index * 37) % 21) - 10))
                        .scaleEffect(appearedIcons > index ? 1 : 0.01)
                        .opacity(appearedIcons > index ? 1 : 0)
                }
            }
            .frame(width: 240)
        }
    }

    private func playAnimation() {
        guard appearedIcons == 0 else { return }
        Task { @MainActor in
            for index in 1...icons.count {
                try? await Task.sleep(nanoseconds: 80_000_000)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                    appearedIcons = index
                }
                hours = max(1, Int((Double(index) / Double(icons.count) * 6).rounded()))
            }
        }
    }
}
