import SwiftUI

/// Settings → Adjust Diet. Loosening changes are queued behind the 24 h cooldown.
struct AdjustDietView: View {
    @Environment(DietManager.self) private var dietManager
    @Environment(EntitlementManager.self) private var entitlements
    @Environment(\.dismiss) private var dismiss
    private let appTheme = AppTheme.shared

    @State private var portion: Int
    @State private var start: Date
    @State private var end: Date
    @State private var nightEnabled: Bool
    @State private var nightStart: Date
    @State private var cheats: Int
    @State private var queued = false
    @State private var errorMessage: String?

    init(profile: DietProfile) {
        let calendar = Calendar.current
        let base = calendar.startOfDay(for: Date())
        _portion = State(initialValue: profile.portionMinutes)
        _start = State(initialValue: calendar.date(bySettingHour: profile.eatingWindow.startHour, minute: profile.eatingWindow.startMinute, second: 0, of: base) ?? base)
        _end = State(initialValue: calendar.date(bySettingHour: profile.eatingWindow.endHour, minute: profile.eatingWindow.endMinute, second: 0, of: base) ?? base)
        _nightEnabled = State(initialValue: profile.nightFast.isEnabled)
        _nightStart = State(initialValue: calendar.date(bySettingHour: profile.nightFast.startHour, minute: profile.nightFast.startMinute, second: 0, of: base) ?? base)
        _cheats = State(initialValue: profile.cheatsPerWeek)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("PORTION") {
                    Stepper("\(portion) min of carbs", value: $portion, in: 0...180, step: 15)
                        .tint(appTheme.colors.primary)
                }

                Section("EATING WINDOW") {
                    DatePicker("Opens", selection: $start, displayedComponents: .hourAndMinute)
                    DatePicker("Closes", selection: $end, displayedComponents: .hourAndMinute)
                }

                Section("NIGHT FAST") {
                    Toggle("Enabled", isOn: $nightEnabled)
                        .tint(appTheme.colors.primary)
                        .onChange(of: nightEnabled, initial: false) { _, isOn in
                            if isOn && !entitlements.isPremium {
                                nightEnabled = false
                                entitlements.presentPaywall(.featureNightFast)
                            }
                        }

                    if nightEnabled {
                        DatePicker("Starts", selection: $nightStart, displayedComponents: .hourAndMinute)
                    }
                }

                Section("CHEAT MEALS") {
                    Stepper("\(cheats) per week", value: $cheats, in: 0...7)
                        .tint(appTheme.colors.primary)
                        .onChange(of: cheats, initial: false) { _, value in
                            if value > 1 && !entitlements.isPremium {
                                cheats = 1
                                entitlements.presentPaywall(.cheatOut)
                            }
                        }
                }

                if queued {
                    Section {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Changes queued")
                                .font(appTheme.fonts.titleSmall)
                                .foregroundColor(appTheme.colors.warning)
                            Text("Loosening your rules takes effect after 24 hours. Tightening is instant.")
                                .font(appTheme.fonts.bodySmall)
                                .foregroundColor(appTheme.colors.textSecondary)
                        }
                    }
                } else {
                    Section(footer: Text("Tightening your rules applies instantly. Loosening waits 24 hours.")) {
                        EmptyView()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(appTheme.colors.background)
            .navigationTitle("Adjust Diet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(queued ? "Done" : "Save") {
                        if queued { dismiss() } else { save() }
                    }
                    .foregroundColor(appTheme.colors.primary)
                }
            }
            .alert("Can't save this", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
        .preferredColorScheme(.dark)
        .sensoryFeedback(.impact, trigger: queued)
    }

    private func save() {
        guard var profile = dietManager.dietProfile else { return }

        let calendar = Calendar.current
        profile.portionMinutes = portion
        profile.eatingWindow = EatingWindow(
            startHour: calendar.component(.hour, from: start),
            startMinute: calendar.component(.minute, from: start),
            endHour: calendar.component(.hour, from: end),
            endMinute: calendar.component(.minute, from: end)
        )
        profile.nightFast = NightFast(
            isEnabled: nightEnabled,
            startHour: calendar.component(.hour, from: nightStart),
            startMinute: calendar.component(.minute, from: nightStart),
            endHour: profile.eatingWindow.startHour,
            endMinute: profile.eatingWindow.startMinute
        )
        profile.cheatsPerWeek = cheats

        let issues = DietRules.validate(profile)
        guard issues.isEmpty else {
            errorMessage = issues.joined(separator: "\n")
            return
        }

        let wasQueued = dietManager.requestProfileUpdate(profile)
        if wasQueued {
            queued = true
        } else {
            dismiss()
        }
    }
}
