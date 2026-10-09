import SwiftUI

struct StoryChapterView: View {
    @ObservedObject var data: OnboardingData
    let chapter: Int
    private var asset: String { ["DigitalGarden", "LifeReclaimed", "BalancedPantry"][chapter] }
    private var title: String { ["One more scroll.\nOne less moment.", "What would you\nmake room for?", "A balanced diet.\nFor your attention."][chapter] }
    private var detail: String { ["The feed never ends. Your day does. Let’s put a little intention between you and the next refresh.", "A book you actually finish. A conversation without checking. A quiet evening that feels like yours.", "Portion the tempting apps. Keep the nourishing ones. Give your digital life a rhythm you can live with."][chapter] }
    var body: some View {
        DietPage {
            DietArtwork(asset: asset, height: 260).editorialEntrance()
            DietHeading(eyebrow: ["Notice the habit", "Imagine the space", "Meet ScreenDiet"][chapter], title: title, detail: detail, centered: true).editorialEntrance(delay: 0.1)
            if chapter == 2 {
                VStack(spacing: 18) {
                    DietFeatureRow(icon: "birthday.cake.fill", title: "Carbs · Enjoy in portions", detail: "Your most tempting apps get a daily allowance.", tint: .orange)
                    DietFeatureRow(icon: "leaf.fill", title: "Fats · Keep the connection", detail: "Social apps stay open except during fasts.", tint: .purple)
                    DietFeatureRow(icon: "pencil.and.outline", title: "Protein · Create freely", detail: "Learning and productive apps stay available.")
                }.dietCard().editorialEntrance(delay: 0.2)
            } else {
                Text(chapter == 0 ? "No guilt. Just a little more choice." : "Less autopilot. More of what matters.").font(.subheadline).foregroundStyle(AppTheme.shared.colors.primary).multilineTextAlignment(.center)
            }
        } footer: {
            PrimaryButton(title: chapter == 2 ? "Make it mine" : "Turn the page", icon: "arrow.right") { data.nextScreen() }
        }
    }
}

struct IntentionView: View {
    @ObservedObject var data: OnboardingData
    private let intentions = [("book.fill", "Reading", "A few pages, without interruption"), ("person.2.fill", "Connection", "Be here for the people around you"), ("paintbrush.pointed.fill", "Creating", "Make something instead of consuming"), ("moon.stars.fill", "Rest", "A calmer end to your day")]
    var body: some View {
        DietPage {
            DietHeading(eyebrow: "Your why", title: "More time for…", detail: "Choose the part of life you want to give your attention back to.")
            ForEach(Array(intentions.enumerated()), id: \.offset) { index, item in
                DietChoice(icon: item.0, title: item.1, detail: item.2, selected: data.intention == item.1) { data.intention = item.1 }.editorialEntrance(delay: Double(index) * 0.06)
            }
            Text("Keep this intention close when the next refresh calls.").font(.caption).foregroundStyle(AppTheme.shared.colors.textSecondary)
        } footer: {
            PrimaryButton(title: "That’s my why", icon: "arrow.right", isDisabled: data.intention == nil) { data.nextScreen() }
        }
    }
}

struct PersonalPlanPreview: View {
    @ObservedObject var data: OnboardingData
    var body: some View {
        DietPage {
            DietArtwork(asset: data.quizGoal == "focus" ? "FocusGarden" : "FreshStart", height: 220)
            DietHeading(eyebrow: "Your starting point", title: "Gentle structure.\nA meaningful change.", detail: "You chose \(data.intention?.lowercased() ?? "more life") over autopilot. Here’s how your routine can help.", centered: true)
            VStack(spacing: 20) {
                DietFeatureRow(icon: "clock.fill", title: "Give scrolling a place", detail: "Set kitchen hours around your day, so tempting apps have an opening and closing time.")
                DietFeatureRow(icon: "circle.lefthalf.filled", title: "Choose a satisfying portion", detail: "A daily allowance turns endless scrolling into a conscious choice.")
                DietFeatureRow(icon: "leaf.fill", title: "Keep the nourishing things", detail: "Productive apps remain available. Your phone can still be useful.")
            }.dietCard()
        } footer: {
            PrimaryButton(title: "Build this routine", icon: "arrow.right") { data.nextScreen() }
        }
    }
}

struct PlanReviewView: View {
    @ObservedObject var data: OnboardingData
    var body: some View {
        DietPage {
            DietArtwork(asset: "FreshStart", height: 190)
            DietHeading(eyebrow: "Ready when you are", title: "Your day,\nwith a little rhythm.", detail: "A routine designed to make room for \(data.intention?.lowercased() ?? "what matters").", centered: true)
            VStack(spacing: 20) {
                DietFeatureRow(icon: "sun.max.fill", title: "Kitchen opens", detail: EatingWindow.formatTime(hour: data.windowStartHour, minute: data.windowStartMinute))
                DietFeatureRow(icon: "fork.knife", title: "Your daily portion", detail: data.dailyCarbLimitMinutes == 0 ? "Carbs stay off the menu" : "\(data.dailyCarbLimitMinutes) minutes for your selected Carbs")
                DietFeatureRow(icon: "moon.fill", title: "Kitchen closes", detail: EatingWindow.formatTime(hour: data.windowEndHour, minute: data.windowEndMinute))
            }.dietCard()
            Text("You can fine-tune your routine in Settings. More relaxed rules have a 24-hour cooldown.").font(.caption).foregroundStyle(AppTheme.shared.colors.textSecondary).multilineTextAlignment(.center)
        } footer: {
            PrimaryButton(title: "See my next step", icon: "arrow.right") { data.nextScreen() }
        }
    }
}

struct FirstDayView: View {
    @ObservedObject var data: OnboardingData
    var body: some View {
        DietPage {
            DietHeading(eyebrow: "Your first day", title: "Start small.\nLet the routine work.", detail: "There’s no perfect score to chase today. Just notice what changes.")
            DietArtwork(asset: "LifeReclaimed", height: 220)
            VStack(spacing: 20) {
                DietFeatureRow(icon: "house.fill", title: "Visit your Kitchen", detail: "See your current state and approximate portion remaining.")
                DietFeatureRow(icon: "cabinet.fill", title: "Keep your Pantry honest", detail: "Move apps into the groups that match how you use them.")
                DietFeatureRow(icon: "chart.bar.xaxis", title: "Check in after a little time", detail: "Your report fills as Screen Time records activity. Exact numbers live there.")
            }.dietCard()
        } footer: {
            PrimaryButton(title: "Open my Kitchen", icon: "arrow.right") { data.completeOnboarding() }
        }
    }
}
