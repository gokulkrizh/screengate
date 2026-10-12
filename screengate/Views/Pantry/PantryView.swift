import SwiftUI
import FamilyControls
import ManagedSettings

/// Pantry tab (canvas V2A-Pantry). Daylight look is provided by HomeScreen.
/// Behaviour is unchanged: one `FamilyActivityPicker` per food group, saved through `DietManager`.
struct PantryView: View {
    @Environment(DietManager.self) private var diet
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var group: FoodGroup?
    @State private var editing = FamilyActivitySelection()
    @State private var saved = false
    @State private var open: FoodGroup? = .carbs

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                KitchenTitleBlock(eyebrow: "Good ingredients. Your choices.", title: "Your Pantry")
                    .padding(.horizontal, 4).riseIn(0)
                VStack(spacing: 10) {
                    ForEach(Array(FoodGroup.allCases.enumerated()), id: \.element.id) { index, item in
                        groupCard(item, index: index).riseIn(index + 1)
                    }
                }.padding(.top, 18)
                if saved {
                    Label("Your pantry is updated", systemImage: "checkmark.circle.fill")
                        .font(KitchenFont.label(12)).foregroundStyle(theme.color(for: .fats))
                        .padding(.top, 12).padding(.horizontal, 4).transition(.opacity)
                }
                note.padding(.top, 14).riseIn(4)
            }
            .padding(.horizontal, KitchenMetrics.cardMargin)
            .padding(.top, 8).padding(.bottom, 24)
            .frame(maxWidth: 600).frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .foregroundStyle(theme.text)
        .familyActivityPicker(isPresented: Binding(get: { group != nil }, set: { if !$0 {
            if let group { diet.setFoodGroupSelection(editing, for: group); withAnimation { saved = true } }
            group = nil
        } }), selection: $editing)
        .sensoryFeedback(.success, trigger: saved)
    }

    // MARK: Group card

    private func kitchenGroup(_ item: FoodGroup) -> KitchenFoodGroup {
        switch item { case .carbs: .carbs; case .fats: .fats; case .protein: .protein }
    }

    private func groupCard(_ item: FoodGroup, index: Int) -> some View {
        let selection = diet.foodGroupSelections[item] ?? FamilyActivitySelection()
        let kg = kitchenGroup(item)
        let accent = theme.color(for: kg)
        let isOpen = open == item
        let tokens = Array(selection.applicationTokens)
        return VStack(spacing: 0) {
            Button {
                withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.4, dampingFraction: 0.85)) { open = isOpen ? nil : item }
            } label: {
                HStack(spacing: 14) {
                    PantryPlate(group: kg, tokens: Array(tokens.prefix(3)), index: index)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(item.displayName.capitalized).font(KitchenFont.headline(20)).tracking(-0.4)
                            Text(kg.verb).font(KitchenFont.eyebrow).tracking(1.1).textCase(.uppercase).foregroundStyle(accent)
                        }
                        Text(rule(item)).font(KitchenFont.body(12)).foregroundStyle(theme.muted).fixedSize(horizontal: false, vertical: true)
                        HStack(spacing: 8) {
                            Text(countLabel(selection))
                                .font(.custom(KitchenFont.manrope, size: 11, relativeTo: .caption2).weight(.heavy))
                                .foregroundStyle(accent).padding(.horizontal, 9).frame(height: 22)
                                .background(theme.soft(kg, opacity: 0.11), in: Capsule())
                            if item == .carbs && diet.todayLog.carbsMinutes > 0 {
                                Text("≈ \(diet.todayLog.carbsMinutes)m today").font(KitchenFont.label(11)).monospacedDigit().foregroundStyle(theme.muted)
                            }
                        }.padding(.top, 2)
                        Text(status(item)).font(KitchenFont.body(11)).foregroundStyle(theme.faint)
                    }
                    Spacer(minLength: 4)
                    Image(systemName: "chevron.down").font(.system(size: 12, weight: .bold)).foregroundStyle(theme.muted)
                        .frame(width: 28, height: 28).rotationEffect(.degrees(isOpen ? 180 : 0))
                }
                .padding(12).frame(maxWidth: .infinity, alignment: .leading).contentShape(Rectangle())
            }
            .buttonStyle(TactileButtonStyle())
            .accessibilityValue(isOpen ? "Expanded" : "Collapsed")
            .accessibilityHint("Shows the apps on this plate")

            if isOpen {
                VStack(alignment: .leading, spacing: 10) {
                    if !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty || !selection.webDomainTokens.isEmpty {
                        PantryFlow(spacing: 6) {
                            ForEach(tokens, id: \.self) { token in
                                Label(token).labelStyle(PantryChipStyle()).modifier(PantryChip())
                            }
                            ForEach(Array(selection.categoryTokens), id: \.self) { token in
                                Label(token).labelStyle(PantryChipStyle()).modifier(PantryChip())
                            }
                            ForEach(Array(selection.webDomainTokens), id: \.self) { token in
                                Label(token).labelStyle(PantryChipStyle()).modifier(PantryChip())
                            }
                        }
                    }
                    Button {
                        saved = false; editing = selection; group = item
                    } label: {
                        Text(isEmpty(selection) ? "Add ingredients" : "Edit with Apple’s picker")
                            .font(KitchenFont.body(14).weight(.bold)).foregroundStyle(theme.buttonText)
                            .frame(maxWidth: .infinity, minHeight: 44).background(theme.buttonBg, in: Capsule())
                    }.buttonStyle(TactileButtonStyle())
                }
                .padding(.horizontal, 12).padding(.bottom, 12)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .offset(y: -6)))
            }
        }
        .background(theme.surface, in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(isOpen ? accent : theme.line, lineWidth: isOpen ? 1.5 : 1))
        .shadow(color: Color(hex: "5A401E").opacity(isOpen ? 0.16 : 0), radius: 20, y: 14)
        .animation(.easeInOut(duration: 0.3), value: isOpen)
    }

    private var note: some View {
        HStack(spacing: 10) {
            Image(systemName: "shield").font(.system(size: 16, weight: .semibold)).foregroundStyle(theme.lamp)
            Text("Apps not on a plate are never limited. Moving an app takes it off its old plate.")
                .font(KitchenFont.body(12)).foregroundStyle(theme.muted).fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 14).padding(.vertical, 12).frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.surface.opacity(0.55), in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(theme.line, lineWidth: 1))
    }

    // MARK: Copy

    private func isEmpty(_ s: FamilyActivitySelection) -> Bool {
        s.applicationTokens.isEmpty && s.categoryTokens.isEmpty && s.webDomainTokens.isEmpty
    }

    private func countLabel(_ s: FamilyActivitySelection) -> String {
        let apps = s.applicationTokens.count, cats = s.categoryTokens.count, sites = s.webDomainTokens.count
        if apps + cats + sites == 0 { return "Nothing yet" }
        var parts: [String] = []
        if apps > 0 { parts.append("\(apps) \(apps == 1 ? "app" : "apps")") }
        if cats > 0 { parts.append("\(cats) \(cats == 1 ? "category" : "categories")") }
        if sites > 0 { parts.append("\(sites) \(sites == 1 ? "site" : "sites")") }
        return parts.joined(separator: " · ")
    }

    private func rule(_ item: FoodGroup) -> String {
        switch item {
        case .carbs:
            let minutes = diet.dietProfile?.portionMinutes
            return minutes.map { $0 == 0 ? "Off the menu · within kitchen hours" : "\($0) min a day · within kitchen hours" } ?? "A daily portion · within kitchen hours"
        case .fats: return "Unlimited · rests during fasts"
        case .protein: return "Always on the table"
        }
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

// MARK: - Plate

/// 96 pt plate: ceramic disc, inner well, bottom edge, 5 pt soft halo, up to three app tiles that drop in.
private struct PantryPlate: View {
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let group: KitchenFoodGroup
    let tokens: [ApplicationToken]
    let index: Int
    @State private var dropped = false

    private let slots: [(x: CGFloat, y: CGFloat, r: Double)] = [(20, 18, -8), (46, 22, 8), (32, 46, 4)]

    var body: some View {
        ZStack(alignment: .topLeading) {
            Circle().fill(theme.soft(group, opacity: 0.11)).frame(width: 106, height: 106).offset(x: -5, y: -5)
            Circle().fill(theme.plateEdge).frame(width: 96, height: 96).offset(y: 3)
            Circle().fill(theme.plate).frame(width: 96, height: 96)
                .shadow(color: Color(hex: "5A401E").opacity(0.14), radius: 8, y: 8)
            Circle().fill(theme.plateInner).frame(width: 78, height: 78).offset(x: 9, y: 9)
            if tokens.isEmpty {
                Image(systemName: "plus").font(.system(size: 18, weight: .bold)).foregroundStyle(theme.color(for: group).opacity(0.6))
                    .frame(width: 96, height: 96)
            }
            ForEach(Array(tokens.enumerated()), id: \.offset) { i, token in
                Label(token).labelStyle(.iconOnly)
                    .frame(width: 30, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                    .shadow(color: Color(hex: "3C2814").opacity(0.2), radius: 4, y: 4)
                    .rotationEffect(.degrees(slots[i].r))
                    .offset(x: slots[i].x, y: slots[i].y + (dropped ? 0 : -30))
                    .scaleEffect(dropped ? 1 : 0.8)
                    .opacity(dropped ? 1 : 0)
                    .animation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.5, dampingFraction: 0.6).delay(0.4 + Double(index) * 0.15 + Double(i) * 0.08), value: dropped)
            }
        }
        .frame(width: 96, height: 99, alignment: .topLeading)
        .padding(5)
        .onAppear { dropped = true }
        .accessibilityHidden(true)
    }
}

// MARK: - Chips

private struct PantryChipStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 6) {
            configuration.icon.frame(width: 24, height: 24).clipShape(RoundedRectangle(cornerRadius: 8))
            configuration.title.lineLimit(1)
        }
    }
}

private struct PantryChip: ViewModifier {
    @Environment(\.kitchenTheme) private var theme
    func body(content: Content) -> some View {
        content.font(KitchenFont.label(12)).foregroundStyle(theme.text)
            .padding(.leading, 4).padding(.trailing, 10).frame(height: 32)
            .background(theme.surface2, in: Capsule())
    }
}

/// Simple wrapping layout for the chips.
private struct PantryFlow: Layout {
    var spacing: CGFloat = 6
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(width: proposal.width ?? .infinity, subviews: subviews).size
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(width: bounds.width, subviews: subviews)
        for (i, f) in result.frames.enumerated() {
            subviews[i].place(at: CGPoint(x: bounds.minX + f.minX, y: bounds.minY + f.minY), proposal: .unspecified)
        }
    }
    private func arrange(width: CGFloat, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0, maxX: CGFloat = 0
        var frames: [CGRect] = []
        for s in subviews {
            let size = s.sizeThatFits(.unspecified)
            if x > 0 && x + size.width > width { x = 0; y += rowH + spacing; rowH = 0 }
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            x += size.width + spacing; rowH = max(rowH, size.height); maxX = max(maxX, x - spacing)
        }
        return (CGSize(width: maxX, height: y + rowH), frames)
    }
}
