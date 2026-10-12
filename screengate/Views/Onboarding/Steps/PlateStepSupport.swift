import SwiftUI
import FamilyControls
import ManagedSettings

/// Per-plate copy, stand-in apps (simulator only) and selection helpers for `PlateStep`.
struct PlateStepConfig {
    let group: KitchenFoodGroup
    let foodGroup: FoodGroup
    let eyebrow: String
    let first: String
    let second: String
    let note: String
    let cta: String

    static func make(_ group: KitchenFoodGroup) -> PlateStepConfig {
        switch group {
        case .carbs: PlateStepConfig(group: .carbs, foodGroup: .carbs, eyebrow: "Plate 1 of 3 · Consume", first: "The apps you", second: "snack on.",
                                     note: "These share one daily portion and rest outside kitchen hours.", cta: "Serve my Carbs plate")
        case .fats: PlateStepConfig(group: .fats, foodGroup: .fats, eyebrow: "Plate 2 of 3 · Connect", first: "The people", second: "you talk to.",
                                    note: "No daily limit. These rest only during Night Fast and Focus Fast.", cta: "Serve my Fats plate")
        case .protein: PlateStepConfig(group: .protein, foodGroup: .protein, eyebrow: "Plate 3 of 3 · Create", first: "Keep the good stuff", second: "on the table.",
                                       note: "Protein is never blocked by your diet, even during a fast.", cta: "Serve my Protein plate")
        }
    }

    /// Stand-in tiles shown only where Family Controls tokens don't exist (simulator).
    var samples: [PlateTile] {
        func t(_ id: String, _ name: String, _ symbol: String, _ hex: String) -> PlateTile { PlateTile(id: id, name: name, symbol: symbol, tint: Color(hex: hex)) }
        switch group {
        case .carbs: return [t("instagram", "Instagram", "camera.fill", "C2577A"), t("tiktok", "TikTok", "music.note", "2F343B"),
                             t("youtube", "YouTube", "play.rectangle.fill", "D2513E"), t("reddit", "Reddit", "bubble.left.fill", "E0703A"),
                             t("netflix", "Netflix", "film.fill", "8E2F2B")]
        case .fats: return [t("messages", "Messages", "message.fill", "4F9A5A"), t("whatsapp", "WhatsApp", "phone.fill", "2F8F6B"),
                            t("facetime", "FaceTime", "video.fill", "3E8A78")]
        case .protein: return [t("notes", "Notes", "note.text", "C29A2E"), t("books", "Books", "book.fill", "D88A45"),
                               t("calendar", "Calendar", "calendar", "4F76C9"), t("maps", "Maps", "map.fill", "5F8F6E")]
        }
    }
}

extension FamilyActivitySelection {
    /// Selection items as plate tiles (apps first, then categories, then websites), in a stable order.
    func plateTiles(tint: Color) -> [PlateTile] {
        var out: [PlateTile] = []
        for token in applicationTokens.sorted(by: { String(describing: $0) < String(describing: $1) }) {
            out.append(PlateTile(id: "app-\(token.hashValue)", source: .app(token), tint: tint))
        }
        for token in categoryTokens.sorted(by: { String(describing: $0) < String(describing: $1) }) {
            out.append(PlateTile(id: "cat-\(token.hashValue)", source: .category(token), tint: tint))
        }
        for token in webDomainTokens.sorted(by: { String(describing: $0) < String(describing: $1) }) {
            out.append(PlateTile(id: "web-\(token.hashValue)", source: .web(token), tint: tint))
        }
        return out
    }

    mutating func remove(_ tile: PlateTile) {
        switch tile.source {
        case .app(let t): applicationTokens.remove(t)
        case .category(let t): categoryTokens.remove(t)
        case .web(let t): webDomainTokens.remove(t)
        case .glyph: break
        }
    }
}

/// Wrapping row layout for the app chips.
struct PlateStepFlowLayout: Layout {
    var spacing: CGFloat = 8
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(width: proposal.width ?? 0, subviews: subviews).size
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(width: bounds.width, subviews: subviews)
        for (i, p) in result.origins.enumerated() { subviews[i].place(at: CGPoint(x: bounds.minX + p.x, y: bounds.minY + p.y), proposal: .unspecified) }
    }
    private func arrange(width: CGFloat, subviews: Subviews) -> (size: CGSize, origins: [CGPoint]) {
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0, maxX: CGFloat = 0
        var origins: [CGPoint] = []
        for s in subviews {
            let size = s.sizeThatFits(.unspecified)
            if x > 0, x + size.width > width { x = 0; y += rowH + spacing; rowH = 0 }
            origins.append(CGPoint(x: x, y: y))
            x += size.width + spacing; rowH = max(rowH, size.height); maxX = max(maxX, x - spacing)
        }
        return (CGSize(width: maxX, height: y + rowH), origins)
    }
}

/// Chip for one app on the plate: icon tile, name, 40 pt remove target.
struct PlateStepChip: View {
    @Environment(\.kitchenTheme) private var theme
    let tile: PlateTile
    let onRemove: () -> Void
    var body: some View {
        HStack(spacing: 8) {
            tile.icon(size: 28, glyphSize: 14)
                .background(tile.isToken ? theme.surface2 : tile.tint, in: RoundedRectangle(cornerRadius: 9))
            if tile.isToken {
                switch tile.source {
                case .app(let t): Label(t).labelStyle(.titleOnly).font(KitchenFont.label(13)).lineLimit(1)
                case .category(let t): Label(t).labelStyle(.titleOnly).font(KitchenFont.label(13)).lineLimit(1)
                case .web(let t): Label(t).labelStyle(.titleOnly).font(KitchenFont.label(13)).lineLimit(1)
                case .glyph: EmptyView()
                }
            } else {
                Text(tile.name).font(KitchenFont.label(13)).foregroundStyle(theme.text)
            }
            Button(action: onRemove) {
                Image(systemName: "xmark").font(.system(size: 11, weight: .bold)).foregroundStyle(theme.faint)
                    .frame(width: 44, height: 40).contentShape(Rectangle())
            }
            .buttonStyle(TactileButtonStyle())
            .accessibilityLabel("Remove \(tile.name.isEmpty ? "app" : tile.name)")
            .padding(.leading, -8).padding(.trailing, -8)
        }
        .foregroundStyle(theme.text)
        .padding(.leading, 6).padding(.trailing, 4)
        .frame(height: 40)
        .background(theme.surface, in: Capsule())
        .overlay(Capsule().stroke(theme.line, lineWidth: 1))
    }
}
