import SwiftUI
import FamilyControls
import ManagedSettings

/// One item on a plate. On device it wraps a Family Controls token and renders with `Label(token)`;
/// elsewhere (simulator, previews) it is a stand-in glyph tile.
struct PlateTile: Identifiable, Equatable {
    enum Source: Equatable {
        case glyph(String)
        case app(ApplicationToken)
        case category(ActivityCategoryToken)
        case web(WebDomainToken)
    }
    let id: String
    let name: String
    let source: Source
    let tint: Color

    init(id: String, name: String = "", symbol: String, tint: Color) {
        self.id = id; self.name = name; self.source = .glyph(symbol); self.tint = tint
    }
    init(id: String, name: String = "", source: Source, tint: Color) {
        self.id = id; self.name = name; self.source = source; self.tint = tint
    }

    /// Icon content at `size` pt (the token labels render their own artwork).
    @ViewBuilder func icon(size: CGFloat, glyphSize: CGFloat) -> some View {
        switch source {
        case .glyph(let symbol):
            Image(systemName: symbol).font(.system(size: glyphSize, weight: .semibold)).foregroundStyle(.white)
                .frame(width: size, height: size)
        case .app(let token):
            Label(token).labelStyle(.iconOnly).scaleEffect(size / 30).frame(width: size, height: size)
        case .category(let token):
            Label(token).labelStyle(.iconOnly).scaleEffect(size / 30).frame(width: size, height: size)
        case .web(let token):
            Label(token).labelStyle(.iconOnly).scaleEffect(size / 30).frame(width: size, height: size)
        }
    }

    var isToken: Bool { if case .glyph = source { false } else { true } }
}

/// White ceramic disc with inner well + bottom edge, a 10 pt halo in the group colour,
/// and 54 pt app tiles on a circle of radius 56 that drop in one by one (spec §4, §6).
struct PlateView: View {
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let group: KitchenFoodGroup
    let tiles: [PlateTile]
    var diameter: CGFloat = 230
    /// Seconds before the first tile drops (canvas: plate fades in at 0.2 s, tiles from 0.5 s).
    var firstDrop: Double = 0.5
    @State private var plateIn = false
    @State private var revealed = 0
    @State private var started = false

    private var shown: [PlateTile] { Array(tiles.prefix(min(revealed, 6))) }

    var body: some View {
        let accent = theme.color(for: group)
        let inner = diameter - 44
        ZStack {
            Circle().fill(accent.opacity(0.12)).frame(width: diameter + 20, height: diameter + 20)
            Circle().fill(theme.plateEdge).frame(width: diameter, height: diameter).offset(y: 5)
            Circle().fill(theme.plate).frame(width: diameter, height: diameter)
                .shadow(color: Color(hex: "5A401E").opacity(0.16), radius: 20, y: 22)
            Circle().fill(theme.plateInner).frame(width: inner, height: inner)
                .overlay(Circle().stroke(Color(hex: "3C2814").opacity(0.06), lineWidth: 2).blur(radius: 3).clipShape(Circle()))
            let n = shown.count
            ForEach(Array(shown.enumerated()), id: \.element.id) { i, tile in
                let angle = Double(i) / Double(max(n, 1)) * 2 * .pi - .pi / 2
                let r: CGFloat = n > 1 ? 56 : 0
                tile.icon(size: 54, glyphSize: 22)
                    .background(tile.isToken ? Color.white : tile.tint, in: RoundedRectangle(cornerRadius: 54 * 0.28))
                    .rotationEffect(.degrees(i % 2 == 1 ? 7 : -6))
                    .shadow(color: Color(hex: "3C2814").opacity(0.22), radius: 7, y: 8)
                    .matchedGeometryEffect(id: tile.id, in: ns)
                    .offset(x: cos(angle) * r, y: sin(angle) * r)
                    .transition(reduceMotion ? .opacity : .asymmetric(
                        insertion: .offset(y: -80).combined(with: .scale(scale: 0.9)).combined(with: .opacity),
                        removal: .scale(scale: 0.6).combined(with: .opacity)))
            }
        }
        .frame(width: diameter + 20, height: diameter + 24)
        .scaleEffect(plateIn || reduceMotion ? 1 : 0.85).opacity(plateIn ? 1 : 0)
        .animation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.5, dampingFraction: 0.65), value: shown)
        .task {
            withAnimation(.easeOut(duration: reduceMotion ? 0.2 : 0.8).delay(reduceMotion ? 0 : 0.2)) { plateIn = true }
            if reduceMotion { revealed = tiles.count; started = true; return }
            try? await Task.sleep(for: .seconds(firstDrop))
            for i in 1...max(tiles.count, 1) where i <= tiles.count {
                revealed = i
                try? await Task.sleep(for: .milliseconds(120))
            }
            revealed = tiles.count; started = true
        }
        .onChange(of: tiles.count) { _, new in if started { revealed = new } else if revealed > new { revealed = new } }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(group.title) plate with \(tiles.count) \(tiles.count == 1 ? "app" : "apps")")
    }

    @Namespace private var ns
}
