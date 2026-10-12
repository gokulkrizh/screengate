import SwiftUI
import UserNotifications

/// Onboarding step 16 · V2-16 "A helpful reminder. Never a lecture." Skippable.
struct RemindersStep: View {
    @ObservedObject var data: OnboardingData
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var requesting = false
    @State private var message: String?

    private var night: NightFast { data.resolvedNightFast(enabled: true) }

    private var notes: [ReminderNote] {
        let open = EatingWindow.formatTime(hour: data.windowStartHour, minute: data.windowStartMinute)
        let nightStart = OnboardingFormat.compactTime(hour: night.startHour, minute: night.startMinute)
        let before = Calendar.current.date(bySettingHour: night.startHour, minute: night.startMinute, second: 0, of: Date())?.addingTimeInterval(-15 * 60) ?? Date()
        let c = Calendar.current.dateComponents([.hour, .minute], from: before)
        return [
            ReminderNote(group: .fats, symbol: "sun.max", title: "Your kitchen is open", body: "A fresh \(data.dailyCarbLimitMinutes)-minute portion is ready.", time: open),
            ReminderNote(group: .carbs, symbol: "circle.circle", title: "10 minutes of Carbs left", body: "Finish what you came for.", time: "5:42 PM"),
            ReminderNote(group: .protein, symbol: "moon", title: "Night Fast at \(nightStart)", body: "Time to let the kitchen rest.", time: EatingWindow.formatTime(hour: c.hour ?? 21, minute: c.minute ?? 45)),
        ]
    }

    var body: some View {
        OnboardingPage {
            phone.rise(1).padding(.horizontal, -4)
            VStack(alignment: .leading, spacing: 10) {
                OnboardingEyebrow(text: "A gentle nudge").editorialEntrance(delay: 1.1)
                OnboardingTitle(first: "A helpful reminder.", second: "Never a lecture.", emphasis: false, size: 34).editorialEntrance(delay: 1.2)
                OnboardingBody(text: "When the kitchen opens, when your portion is nearly served, and when it’s time to rest.").editorialEntrance(delay: 1.2)
                if let message { Text(message).font(KitchenFont.label(12)).foregroundStyle(theme.color(for: .carbs)) }
            }.padding(.top, 8)
        } footer: {
            VStack(spacing: 2) {
                KitchenPrimaryButton(title: requesting ? "Waiting for iOS…" : "Turn on reminders", systemImage: "arrow.right", isEnabled: !requesting) { request() }
                KitchenSecondaryButton(title: "Skip for now") { data.remindersEnabled = false; data.nextScreen() }
            }.editorialEntrance(delay: reduceMotion ? 0 : 1.35)
        }
    }

    private func request() {
        requesting = true
        Task { @MainActor in
            defer { requesting = false }
            do {
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
                data.remindersEnabled = granted
                data.nextScreen()
            } catch { message = "Reminders couldn’t be enabled. You can try again or continue without them." }
        }
    }

    // MARK: Phone preview

    private var phone: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 10) {
                ForEach(Array(notes.enumerated()), id: \.offset) { i, n in
                    NotificationCard(note: n, delay: 0.45 + Double(i) * 0.22)
                }
                Spacer(minLength: 0)
            }
            .padding(.top, 64).padding(.horizontal, 14)
            Bell().padding(.top, 18)
        }
        .frame(height: 316)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "26221D"), in: RoundedRectangle(cornerRadius: 32))
        .shadow(color: .black.opacity(0.2), radius: 20, y: 18)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Preview of three reminders: \(notes.map { "\($0.title). \($0.body)" }.joined(separator: " ")))")
    }
}

private struct ReminderNote {
    let group: KitchenFoodGroup, symbol: String, title: String, body: String, time: String
}

private struct NotificationCard: View {
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let note: ReminderNote
    let delay: Double
    @State private var shown = false
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: note.symbol).font(.system(size: 17, weight: .medium)).foregroundStyle(theme.color(for: note.group))
                .frame(width: 38, height: 38).background(theme.soft(note.group, opacity: 0.12), in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(note.title).font(KitchenFont.label(13).weight(.heavy)).foregroundStyle(theme.text)
                    Spacer(minLength: 4)
                    Text(note.time).font(KitchenFont.label(11).weight(.medium)).monospacedDigit().foregroundStyle(theme.faint)
                }
                Text(note.body).font(KitchenFont.body(12)).foregroundStyle(theme.muted).fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(Color(hex: "FFFDF8").opacity(0.96), in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.25), radius: 12, y: 10)
        .scaleEffect(shown || reduceMotion ? 1 : 0.96)
        .offset(y: shown || reduceMotion ? 0 : -40)
        .opacity(shown ? 1 : 0)
        .onAppear { withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .timingCurve(0.2, 0.8, 0.2, 1, duration: 0.7).delay(delay)) { shown = true } }
    }
}

private struct Bell: View {
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        let icon = Image(systemName: "bell").font(.system(size: 17, weight: .medium)).foregroundStyle(Color(hex: "FFF8EA"))
            .frame(width: 36, height: 36).background(theme.lamp, in: Circle())
        if reduceMotion { icon } else {
            PhaseAnimator([0.0, 14, -12, 8, -5, 0, 0.001]) { angle in
                icon.rotationEffect(.degrees(angle), anchor: UnitPoint(x: 0.5, y: 0.1))
            } animation: { phase in phase == 0.001 ? .linear(duration: 1.3) : .easeInOut(duration: 0.24) }
        }
    }
}
