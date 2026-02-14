import SwiftUI

struct OnboardingView: View {
    @StateObject private var data = OnboardingData()
    @Environment(\.dismiss) var dismiss
    @Environment(DietManager.self) private var dietManager
    var onCompletion: () -> Void = {}

    var body: some View {
        ZStack {
            AppTheme.shared.colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Group {
                    switch data.currentScreen {
                    case 0:
                        PermissionsView(data: data)
                    case 1:
                        FoodGroupSelectionView(data: data)
                            .environment(dietManager)
                    case 2:
                        DietSelectionView(data: data)
                    case 3:
                        EatingWindowSetupView(data: data)
                    case 4:
                        DietActivatedView(data: data)
                            .environment(dietManager)
                    default:
                        DietActivatedView(data: data)
                            .environment(dietManager)
                    }
                }
                .transition(.opacity)
            }
        }
        .onChange(of: data.isOnboardingComplete) { _, isComplete in
            if isComplete {
                onCompletion()
                dismiss()
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environment(DietManager())
}
