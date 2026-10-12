//
//  ShieldConfigurationExtension.swift
//  ShieldConfigurationExtension
//
//  Five state-driven shield designs (v2 spec §8: Kitchen closed, Portion served, Night Fast,
//  Focus Fast, Extra serving tap 2 of 2).
//
//  Precedence: fast > night > portion hit > kitchen closed.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit
import Foundation

class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    private let store = SharedStore.shared

    // MARK: - Theme (v2 spec §8; hex values from the v2 canvas)

    private struct Look {
        let bg: UIColor, fg: UIColor, muted: UIColor, secondary: UIColor
    }
    private static func hex(_ v: UInt32) -> UIColor {
        UIColor(red: CGFloat((v >> 16) & 0xFF) / 255, green: CGFloat((v >> 8) & 0xFF) / 255, blue: CGFloat(v & 0xFF) / 255, alpha: 1)
    }
    private let lamp = Look(bg: hex(0x15120F), fg: hex(0xF7F2E9), muted: hex(0xB5AC9F), secondary: hex(0xF3D9A4))
    private let daylight = Look(bg: hex(0xF5EFE4), fg: hex(0x1F1A14), muted: hex(0x5F564A), secondary: hex(0x8A6420))
    private let night = Look(bg: hex(0x0F1226), fg: hex(0xEEF0FA), muted: hex(0xABB0CC), secondary: hex(0xF3D9A4))

    private let lampButton = hex(0xF3D9A4), lampButtonText = hex(0x1D1812)
    private let inkButton = hex(0x1F1A14), inkButtonText = hex(0xF7F1E6)
    private let nightButtonText = hex(0x151830)
    private let proteinAmber = hex(0xEBA75A), proteinAmberText = hex(0x2A1A08)
    private let carbsRose = hex(0xB83E5E), carbsRoseText = hex(0xFFF8F0)

    /// Clay artwork from the extension's asset catalog, cropped to a circle (SF Symbol fallback).
    private func artwork(_ name: String, symbol: String, tint: UIColor) -> UIImage? {
        guard let image = UIImage(named: name) else { return UIImage(systemName: symbol)?.withTintColor(tint, renderingMode: .alwaysOriginal) }
        let size = CGSize(width: 96, height: 96)
        return UIGraphicsImageRenderer(size: size).image { _ in
            UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).addClip()
            // Aspect-fill so the circle is never letterboxed.
            let scale = max(size.width / image.size.width, size.height / image.size.height)
            let w = image.size.width * scale, h = image.size.height * scale
            image.draw(in: CGRect(x: (size.width - w) / 2, y: (size.height - h) / 2, width: w, height: h))
        }.withRenderingMode(.alwaysOriginal)
    }

    // MARK: - Context

    private struct ShieldContext {
        let kind: ShieldKind?
        let state: SharedState
        let itemName: String?
        /// True when this exact shield is showing the cheat confirmation.
        let confirmPending: Bool

        var profile: DietProfile? { state.profile }

        /// Weekly cheats allowed by the current tier (free = 1, premium = 0…7).
        var allowedCheats: Int {
            guard let profile else { return 0 }
            return Entitlement.clampedCheats(profile.cheatsPerWeek, isPremium: state.isPremium)
        }

        var cheatsRemaining: Int {
            max(0, allowedCheats - state.week.cheatsUsed)
        }

        var isCheatable: Bool {
            kind == .kitchenClosed || kind == .plateEmpty
        }

        /// Cheat is offered for kitchen-closed / plate-empty shields, but never
        /// during a fast and never with zero cheats left.
        var cheatOffered: Bool {
            isCheatable
                && cheatsRemaining > 0
                && !DietRules.isFastActive(state.fast)
                && !DietRules.isCheatActive(state.cheat)
        }

        /// "Instagram" / "These apps" / "This site".
        var displayItem: String { itemName ?? "This app" }
    }

    private func loadContext(scope: String, itemName: String?) -> ShieldContext {
        let state = store.load()
        let dietState = DietRules.state(
            profile: state.profile,
            counters: state.counters,
            fast: state.fast,
            cheat: state.cheat
        )
        let pending = state.shieldPending
        return ShieldContext(
            kind: DietRules.shieldKind(for: dietState),
            state: state,
            itemName: itemName,
            confirmPending: (pending?.isActive() ?? false) && pending?.scope == scope
        )
    }

    // MARK: - Design selection

    private func configuration(for context: ShieldContext) -> ShieldConfiguration {
        if context.confirmPending, context.cheatOffered {
            return confirmShield(context)
        }

        switch context.kind {
        case .focusFast:
            return focusFastShield(context)
        case .fasting:
            return nightFastShield(context)
        case .plateEmpty:
            return portionServedShield(context)
        case .kitchenClosed:
            return kitchenClosedShield(context)
        case nil:
            return kitchenClosedShield(context)
        }
    }

    private func extraServingLabel(_ context: ShieldContext, _ look: Look) -> ShieldConfiguration.Label? {
        guard context.cheatOffered else { return nil }
        return .init(text: "Use an extra serving", color: look.secondary)
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .none
        return f.string(from: date)
    }

    private func noExtraNote(_ context: ShieldContext) -> String {
        context.allowedCheats > 0 && context.cheatsRemaining == 0 ? " No extra servings left this week." : ""
    }

    private func shield(_ look: Look, icon: UIImage?, title: String, subtitle: String,
                        primary: String, primaryBg: UIColor, primaryText: UIColor,
                        secondary: ShieldConfiguration.Label?) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: nil,
            backgroundColor: look.bg,
            icon: icon,
            title: .init(text: title, color: look.fg),
            subtitle: .init(text: subtitle, color: look.muted),
            primaryButtonLabel: .init(text: primary, color: primaryText),
            primaryButtonBackgroundColor: primaryBg,
            secondaryButtonLabel: secondary
        )
    }

    // MARK: - Designs

    private func kitchenClosedShield(_ context: ShieldContext) -> ShieldConfiguration {
        let openAt = context.profile?.eatingWindow.startTimeString ?? "later"
        return shield(lamp, icon: artwork("NightGarden", symbol: "moon.fill", tint: lamp.secondary),
                      title: "Kitchen\u{2019}s closed",
                      subtitle: "\(context.displayItem) opens again at \(openAt). Your Protein apps are still on the table.\(noExtraNote(context))",
                      primary: "Close app", primaryBg: lampButton, primaryText: lampButtonText,
                      secondary: extraServingLabel(context, lamp))
    }

    private func portionServedShield(_ context: ShieldContext) -> ShieldConfiguration {
        let portion = context.profile?.portionMinutes ?? 0
        let openAt = context.profile?.eatingWindow.startTimeString ?? "the morning"
        return shield(daylight, icon: artwork("FreshStart", symbol: "takeoutbag.and.cup.and.straw.fill", tint: daylight.secondary),
                      title: "Today\u{2019}s portion is served",
                      subtitle: "You\u{2019}ve enjoyed your \(portion) minutes of Carbs. A fresh portion arrives tomorrow at \(openAt).\(noExtraNote(context))",
                      primary: "Close app", primaryBg: inkButton, primaryText: inkButtonText,
                      secondary: extraServingLabel(context, daylight))
    }

    private func nightFastShield(_ context: ShieldContext) -> ShieldConfiguration {
        let end = context.profile?.nightFast.endTimeString ?? "the morning"
        return shield(night, icon: artwork("NightGarden", symbol: "moon.zzz.fill", tint: night.secondary),
                      title: "The kitchen is resting",
                      subtitle: "Night Fast until \(end). Sleep well. Protein apps are still open.",
                      primary: "Goodnight", primaryBg: lampButton, primaryText: nightButtonText,
                      secondary: nil)
    }

    private func focusFastShield(_ context: ShieldContext) -> ShieldConfiguration {
        let endsAt = context.state.fast?.endsAt ?? Date()
        let left = max(1, Int((endsAt.timeIntervalSinceNow / 60).rounded(.up)))
        let leftText = left >= 60 ? "\(left / 60) h \(left % 60) min" : "\(left) minute\(left == 1 ? "" : "s")"
        return shield(lamp, icon: artwork("FocusGarden", symbol: "hourglass", tint: proteinAmber),
                      title: "Something good is cooking",
                      subtitle: "Focus Fast \u{B7} \(leftText) left. \(context.displayItem) will be back at \(timeString(endsAt)).",
                      primary: "Back to focus", primaryBg: proteinAmber, primaryText: proteinAmberText,
                      secondary: nil)
    }

    /// Tap 2 of 2. The primary button confirms; the secondary cancels (see ShieldActionExtension).
    private func confirmShield(_ context: ShieldContext) -> ShieldConfiguration {
        let minutes = DietRules.cheatMealMinutes
        let remaining = context.cheatsRemaining
        return shield(daylight, icon: artwork("DigitalGarden", symbol: "plus.circle.fill", tint: carbsRose),
                      title: "Tap again to confirm",
                      subtitle: "Open \(context.displayItem) for \(minutes) minutes? This uses \(remaining == 1 ? "your 1 extra serving" : "1 of your \(remaining) extra servings") this week.",
                      primary: "Yes, \(minutes) minutes", primaryBg: carbsRose, primaryText: carbsRoseText,
                      secondary: .init(text: "Never mind", color: daylight.secondary))
    }

    // MARK: - ShieldConfigurationDataSource

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        let scope = application.token.map(ShieldPending.scope(for:)) ?? application.bundleIdentifier ?? "any"
        return configuration(for: loadContext(scope: scope, itemName: application.localizedDisplayName))
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        let scope = application.token.map(ShieldPending.scope(for:)) ?? application.bundleIdentifier ?? "any"
        return configuration(for: loadContext(scope: scope, itemName: application.localizedDisplayName))
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        let scope = webDomain.token.map(ShieldPending.scope(for:)) ?? webDomain.domain ?? "any"
        return configuration(for: loadContext(scope: scope, itemName: webDomain.domain))
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        let scope = webDomain.token.map(ShieldPending.scope(for:)) ?? webDomain.domain ?? "any"
        return configuration(for: loadContext(scope: scope, itemName: webDomain.domain))
    }
}
