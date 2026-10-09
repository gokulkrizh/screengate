import SwiftUI

struct SplashView: View {
    @State private var proceed = false
    var onCompletion: () -> Void = {}
    private let theme = AppTheme.shared
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            DietArtwork(height: 320)
            VStack(spacing: 12) {
                Text("ScreenDiet").font(.system(.largeTitle, design: .serif).weight(.semibold)).foregroundStyle(theme.colors.text)
                Text("Nourish your attention.").font(.body).foregroundStyle(theme.colors.textSecondary)
            }.editorialEntrance(delay: 0.15)
            Spacer()
            ProgressView().tint(theme.colors.primary)
            Text("A little space for a fuller life.").font(.caption).foregroundStyle(theme.colors.textSecondary)
        }.padding(32).frame(maxWidth: .infinity).background(theme.colors.background.ignoresSafeArea())
        .fullScreenCover(isPresented: $proceed) {
            OnboardingView(onCompletion: onCompletion).paywallPresenter()
        }
        .task {
            do { try await Task.sleep(for: .seconds(1.5)); proceed = true } catch { }
        }
    }
}
