import SwiftUI

struct QuizView: View {
    enum Question { case goal, hours, time }
    @ObservedObject var data: OnboardingData
    var question: Question = .goal
    @Environment(DietManager.self) private var dietManager
    private var title: String {
        switch question { case .goal: return "What feels right\nfor you?"; case .hours: return "How full is your\ndigital plate?"; case .time: return "When does scrolling\npull you in?" }
    }
    private var detail: String {
        switch question { case .goal: return "Start with a direction. Your plan can evolve with you."; case .hours: return "Think about your most tempting apps. A rough estimate is enough."; case .time: return "We’ll suggest a routine around the moments that feel hardest." }
    }
    private var options: [(String, String, String, String)] {
        switch question {
        case .goal: return [("scissors", "A little less scrolling", "Keep the connection, lose the excess", "cutdown"), ("target", "More focused days", "Create more, consume less", "focus"), ("arrow.counterclockwise", "A fresh reset", "Put tempting apps on pause", "reset")]
        case .hours: return [("clock", "1–2 hours", "A few small pockets of scrolling", "2"), ("clock", "3–4 hours", "It adds up through the day", "4"), ("clock", "5–6 hours", "A substantial part of my day", "6"), ("clock", "More than 6 hours", "I’m ready for a different rhythm", "7")]
        case .time: return [("sunrise.fill", "First thing in the morning", "Before the day has really started", "morning"), ("sun.max.fill", "The afternoon slump", "A break becomes a long scroll", "afternoon"), ("sofa.fill", "Evenings on the couch", "My go-to way to unwind", "evening"), ("moon.stars.fill", "Late into the night", "One more video before sleep", "latelight")]
        }
    }
    private var answer: String? {
        switch question { case .goal: return data.quizGoal; case .hours: return data.quizDailyHours.map(String.init); case .time: return data.quizWorstTime }
    }
    var body: some View {
        DietPage {
            DietHeading(eyebrow: "A quick check-in", title: title, detail: detail)
            ForEach(Array(options.enumerated()), id: \.offset) { index, item in
                DietChoice(icon: item.0, title: item.1, detail: item.2, selected: answer == item.3) {
                    switch question { case .goal: data.quizGoal = item.3; case .hours: data.quizDailyHours = Int(item.3); case .time: data.quizWorstTime = item.3 }
                }.editorialEntrance(delay: Double(index) * 0.06)
            }
            Text("Your answers are a starting point, not a diagnosis.").font(.caption).foregroundStyle(AppTheme.shared.colors.textSecondary)
        } footer: {
            PrimaryButton(title: "Continue", icon: "arrow.right", isDisabled: answer == nil) {
                dietManager.saveOnboardingAnswers(data.quizAnswers)
                data.nextScreen()
            }
        }
    }
}
