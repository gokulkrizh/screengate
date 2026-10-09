import SwiftUI
import FamilyControls

struct PantryView: View {
    @Environment(DietManager.self) private var diet
    @State private var group: FoodGroup?
    @State private var editing = FamilyActivitySelection()
    @State private var saved = false
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                DietHeading(eyebrow: "Know your ingredients", title: "Your Pantry", detail: "The same phone. A more thoughtful mix.")
                DietArtwork(asset: "BalancedPantry", height: 220)
                ForEach(Array(FoodGroup.allCases.enumerated()), id: \.element.id) { index, item in
                    pantryCard(item).editorialEntrance(delay: Double(index) * 0.08)
                }
                if saved { Label("Your pantry is updated", systemImage: "checkmark.circle.fill").font(.caption).foregroundStyle(AppTheme.shared.colors.primary).transition(.opacity) }
                DietFeatureRow(icon: "info.circle", title: "A useful distinction", detail: "Anything you don’t select is unrestricted. Each app should belong to one group. Categories can include many apps.").dietCard()
            }.padding(24).frame(maxWidth: 600).frame(maxWidth: .infinity)
        }.background(AppTheme.shared.colors.background.ignoresSafeArea())
            .familyActivityPicker(isPresented: Binding(get: { group != nil }, set: { if !$0 {
                if let group { diet.setFoodGroupSelection(editing, for: group); withAnimation { saved = true } }
                group = nil
            } }), selection: $editing)
            .sensoryFeedback(.success, trigger: saved)
    }
    private func pantryCard(_ item: FoodGroup) -> some View {
        let selection = diet.foodGroupSelections[item] ?? FamilyActivitySelection()
        let count = selection.applicationTokens.count + selection.categoryTokens.count + selection.webDomainTokens.count
        let tint: Color = item == .carbs ? .orange : item == .fats ? Color(red: 0.73, green: 0.65, blue: 0.88) : AppTheme.shared.colors.primary
        return VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text(item.emoji).font(.largeTitle)
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.displayName.capitalized).font(.system(.title2, design: .serif).weight(.semibold)).foregroundStyle(AppTheme.shared.colors.text)
                    Text(item == .carbs ? "Consume · Portion with care" : item == .fats ? "Connect · Rest during fasts" : "Create · Always available").font(.caption).foregroundStyle(tint)
                }
                Spacer()
            }
            Text(item == .carbs ? "The feeds, games and videos that pull you into one more minute." : item == .fats ? "The conversations you want to keep, with a little space during fasts." : "Tools that help you learn, make and bring ideas to life.").font(.subheadline).foregroundStyle(AppTheme.shared.colors.textSecondary)
            SelectionTokenStrip(selection: selection)
            HStack {
                Label(status(item), systemImage: item == .protein ? "checkmark.circle" : "circle.lefthalf.filled").font(.caption).foregroundStyle(tint)
                Spacer()
                if item == .carbs { Text("≈ \(diet.todayLog.carbsMinutes)m today").font(.caption.monospacedDigit()).foregroundStyle(AppTheme.shared.colors.textSecondary) }
            }
            Button {
                saved = false; editing = selection; group = item
            } label: {
                HStack { Text(count == 0 ? "Add ingredients" : "Edit \(count) selections"); Spacer(); Image(systemName: "plus") }
                    .font(.subheadline.weight(.semibold)).foregroundStyle(tint).padding(14).background(tint.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 14))
            }.buttonStyle(TactileButtonStyle())
        }.dietCard(tint: tint)
    }
    private func status(_ group: FoodGroup) -> String {
        if group == .protein { return "Always available" }
        switch diet.currentDietState {
        case .inactive: return "No active routine"
        case .nightFast, .fastNow: return "Resting during this fast"
        case .portionHit, .fasting: return group == .carbs ? "Off the menu for now" : "Available"
        case .windowOpen: return "Available"
        }
    }
}
