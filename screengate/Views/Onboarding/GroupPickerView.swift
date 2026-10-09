import SwiftUI
import FamilyControls

struct GroupPickerView: View {
    @ObservedObject var data: OnboardingData
    @Environment(DietManager.self) private var dietManager
    let group: FoodGroup
    var isSkippable = false
    @State private var selection = FamilyActivitySelection()
    @State private var isPickerPresented = false
    private var count: Int { selection.applicationTokens.count + selection.categoryTokens.count + selection.webDomainTokens.count }
    var body: some View {
        DietPage {
            DietArtwork(asset: "BalancedPantry", height: 200)
            DietHeading(eyebrow: group == .carbs ? "Ingredient one · Carbs" : "Ingredient two · Fats", title: group == .carbs ? "The apps you\nkeep reaching for." : "Keep the connection.\nGive it a bedtime.", detail: group == .carbs ? "Choose apps you tend to consume on autopilot. They get a portion and kitchen hours." : "Choose social apps to pause during fasts. They have no daily portion limit.", centered: true)
            Button { isPickerPresented = true } label: {
                VStack(spacing: 14) {
                    Image(systemName: count == 0 ? "plus.circle.fill" : "checkmark.seal.fill").font(.largeTitle).foregroundStyle(AppTheme.shared.colors.primary).contentTransition(.symbolEffect(.replace))
                    Text(count == 0 ? "Choose your apps" : "\(count) selections in your bowl").font(.headline).foregroundStyle(AppTheme.shared.colors.text).contentTransition(.numericText())
                    Text(count == 0 ? "Apps, categories and websites" : "Tap to review or change").font(.caption).foregroundStyle(AppTheme.shared.colors.textSecondary)
                    SelectionTokenStrip(selection: selection)
                }.frame(maxWidth: .infinity).dietCard()
            }.buttonStyle(TactileButtonStyle())
            Text("Choose each app in one group. Anything you leave out stays unrestricted.").font(.caption).foregroundStyle(AppTheme.shared.colors.textSecondary).multilineTextAlignment(.center)
        } footer: {
            PrimaryButton(title: "That’s my \(group == .carbs ? "Carbs" : "Fats")", icon: "arrow.right", isDisabled: count == 0) {
                dietManager.setFoodGroupSelection(selection, for: group); data.nextScreen()
            }
            if isSkippable { Button("Keep these unrestricted for now") { data.nextScreen() }.font(.caption).frame(minHeight: 44) }
        }.familyActivityPicker(isPresented: $isPickerPresented, selection: $selection)
            .onAppear { selection = dietManager.foodGroupSelections[group] ?? FamilyActivitySelection() }
            .sensoryFeedback(.selection, trigger: count)
    }
}

struct SelectionTokenStrip: View {
    let selection: FamilyActivitySelection
    var body: some View {
        HStack(spacing: 10) {
            ForEach(Array(selection.applicationTokens.prefix(5)), id: \.self) { token in
                Label(token).labelStyle(.iconOnly).frame(width: 32, height: 32)
            }
            if !selection.categoryTokens.isEmpty {
                Label("\(selection.categoryTokens.count)", systemImage: "square.grid.2x2.fill").font(.caption).foregroundStyle(AppTheme.shared.colors.textSecondary)
            }
            if !selection.webDomainTokens.isEmpty {
                Label("\(selection.webDomainTokens.count)", systemImage: "globe").font(.caption).foregroundStyle(AppTheme.shared.colors.textSecondary)
            }
        }.accessibilityLabel("Selected apps and categories")
    }
}
