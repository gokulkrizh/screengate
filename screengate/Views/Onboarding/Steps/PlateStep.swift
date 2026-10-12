import SwiftUI
import FamilyControls

/// Onboarding steps 08–10 (Carbs / Fats / Protein plates), canvas V2-08/09/10.
/// Pick apps with the Family Controls picker; they land on a plate. Protein is never blocked, so its copy says so.
struct PlateStep: View {
    @ObservedObject var data: OnboardingData
    let group: KitchenFoodGroup
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(DietManager.self) private var dietManager
    @State private var selection = FamilyActivitySelection()
    @State private var isPickerPresented = false
    @State private var removedSamples: Set<String> = []

    private var config: PlateStepConfig { .make(group) }

    private var tiles: [PlateTile] {
        let real = selection.plateTiles(tint: theme.color(for: group))
        #if targetEnvironment(simulator)
        if real.isEmpty { return config.samples.filter { !removedSamples.contains($0.id) } }
        #endif
        return real
    }

    var body: some View {
        let accent = theme.color(for: group)
        OnboardingPage {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(config.eyebrow).kitchenEyebrow().foregroundStyle(accent).rise(1)
                    OnboardingTitle(first: config.first, second: config.second, emphasis: false).rise(2)
                }
                ZStack(alignment: .bottomTrailing) {
                    PlateView(group: group, tiles: tiles).frame(maxWidth: .infinity)
                    Text("\(tiles.count) \(tiles.count == 1 ? "app" : "apps")")
                        .font(.custom(KitchenFont.manrope, size: 12, relativeTo: .caption).weight(.heavy))
                        .foregroundStyle(Color(hex: "FFF8EA")).padding(.horizontal, 12).frame(height: 30)
                        .background(accent, in: Capsule())
                        .contentTransition(.numericText()).animation(.default, value: tiles.count)
                        .padding(.trailing, -4).padding(.bottom, 18).rise(3)
                }
                .padding(.top, 14)
                Text(config.note).kitchenBody(13).foregroundStyle(theme.muted)
                    .fixedSize(horizontal: false, vertical: true).padding(.top, 8).rise(3)
                PlateStepFlowLayout {
                    ForEach(tiles) { tile in
                        PlateStepChip(tile: tile) { remove(tile) }
                            .transition(reduceMotion ? .opacity : .scale(scale: 0.8).combined(with: .opacity))
                    }
                    Button { isPickerPresented = true } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus").font(.system(size: 12, weight: .heavy))
                            Text("Add apps").font(.custom(KitchenFont.manrope, size: 13, relativeTo: .footnote).weight(.bold))
                        }
                        .foregroundStyle(theme.text).padding(.horizontal, 14).frame(minHeight: 44)
                        .overlay(Capsule().stroke(theme.line2, lineWidth: 1.5))
                    }
                    .buttonStyle(TactileButtonStyle())
                }
                .animation(reduceMotion ? .easeOut(duration: 0.2) : KitchenMetrics.spring, value: tiles)
                .padding(.top, 12).editorialEntrance(delay: 0.8)
            }
        } footer: {
            KitchenPrimaryButton(title: config.cta, systemImage: "arrow.right", isEnabled: canServe) { serve() }
                .editorialEntrance(delay: 1.1)
        }
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $selection)
        .onAppear { selection = dietManager.foodGroupSelections[config.foodGroup] ?? FamilyActivitySelection() }
        .sensoryFeedback(.selection, trigger: tiles.count)
    }

    /// Carbs needs at least one app on device (the portion has nothing to limit otherwise).
    private var canServe: Bool {
        #if targetEnvironment(simulator)
        true
        #else
        group != .carbs || selection.hasAnyTokens
        #endif
    }

    private func remove(_ tile: PlateTile) {
        if tile.isToken { selection.remove(tile) } else { removedSamples.insert(tile.id) }
    }

    private func serve() {
        if selection.hasAnyTokens || dietManager.foodGroupSelections[config.foodGroup]?.hasAnyTokens == true {
            dietManager.setFoodGroupSelection(selection, for: config.foodGroup)
        }
        data.nextScreen()
    }
}
