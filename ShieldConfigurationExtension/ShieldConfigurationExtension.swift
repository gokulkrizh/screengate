//
//  ShieldConfigurationExtension.swift
//  ShieldConfigurationExtension
//
//  Five state-driven shield designs (Kitchen Closed, Plate's Empty, Night Fast,
//  Focus Fast, No Cheats Left) plus the 2-tap cheat confirmation re-render.
//
//  Precedence: fast > night > portion hit > kitchen closed.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit
import Foundation

class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    private let store = SharedStore.shared

    // MARK: - Theme

    private let backgroundColor = UIColor(red: 0.045, green: 0.085, blue: 0.07, alpha: 1.0) // #0F1014
    private let primaryGreen = UIColor(red: 0.70, green: 0.86, blue: 0.55, alpha: 1.0)       // #00FF63
    private let warningYellow = UIColor(red: 0.96, green: 0.71, blue: 0.46, alpha: 1)
    private let errorRed = UIColor.systemRed
    private let nightPurple = UIColor(red: 0.73, green: 0.65, blue: 0.88, alpha: 1)
    private let textWhite = UIColor(red: 0.97, green: 0.95, blue: 0.88, alpha: 1)
    private let textSecondary = UIColor.white.withAlphaComponent(0.6)

    private func artwork(_ name: String, symbol: String, tint: UIColor) -> UIImage? {
        guard let image = UIImage(named: name) else { return UIImage(systemName: symbol)?.withTintColor(tint, renderingMode: .alwaysOriginal) }
        let size = CGSize(width: 96, height: 96)
        return UIGraphicsImageRenderer(size: size).image { _ in
            UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 22).addClip()
            image.draw(in: CGRect(origin: .zero, size: size))
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
            return context.allowedCheats > 0 && context.cheatsRemaining == 0
                ? noCheatsLeftShield(context, base: .plateEmpty)
                : plateEmptyShield(context)
        case .kitchenClosed:
            return context.allowedCheats > 0 && context.cheatsRemaining == 0
                ? noCheatsLeftShield(context, base: .kitchenClosed)
                : kitchenClosedShield(context)
        case nil:
            return kitchenClosedShield(context)
        }
    }

    private func cheatLabel(_ context: ShieldContext) -> ShieldConfiguration.Label? {
        guard context.cheatOffered else { return nil }
        return .init(text: "Cheat meal (\(context.cheatsRemaining) left)", color: warningYellow)
    }

    private func countdownLabel(_ minutes: Int) -> String {
        guard minutes > 0 else { return "" }
        return " · \(minutes / 60)h \(minutes % 60)m"
    }

    // MARK: - Designs

    private func kitchenClosedShield(_ context: ShieldContext) -> ShieldConfiguration {
        let openAt = context.profile?.eatingWindow.startTimeString ?? "later"
        let minutes = context.profile?.eatingWindow.minutesUntilOpen() ?? 0

        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterialDark,
            backgroundColor: backgroundColor,
            icon: artwork("NightGarden", symbol: "moon.fill", tint: warningYellow),
            title: .init(text: "A little breathing room.", color: warningYellow),
            subtitle: .init(
                text: "\(context.displayItem) is off the menu. Opens at \(openAt)\(countdownLabel(minutes)).",
                color: textSecondary
            ),
            primaryButtonLabel: .init(text: "Back to life", color: backgroundColor),
            primaryButtonBackgroundColor: warningYellow,
            secondaryButtonLabel: cheatLabel(context)
        )
    }

    private func plateEmptyShield(_ context: ShieldContext) -> ShieldConfiguration {
        let portion = context.profile?.portionMinutes ?? 0
        let openAt = context.profile?.eatingWindow.startTimeString ?? "tomorrow"

        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterialDark,
            backgroundColor: backgroundColor,
            icon: artwork("FreshStart", symbol: "takeoutbag.and.cup.and.straw.fill", tint: errorRed),
            title: .init(text: "Your plate is full.", color: errorRed),
            subtitle: .init(text: "\(portion) min of carbs used. \(context.displayItem) is back at \(openAt).", color: textSecondary),
            primaryButtonLabel: .init(text: "Back to life", color: backgroundColor),
            primaryButtonBackgroundColor: errorRed,
            secondaryButtonLabel: cheatLabel(context)
        )
    }

    private func nightFastShield(_ context: ShieldContext) -> ShieldConfiguration {
        let end = context.profile?.nightFast.endTimeString ?? "the morning"

        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterialDark,
            backgroundColor: backgroundColor,
            icon: artwork("NightGarden", symbol: "moon.zzz.fill", tint: nightPurple),
            title: .init(text: "Let the night be yours.", color: nightPurple),
            subtitle: .init(text: "\(context.displayItem) is asleep until \(end). Protein is always available.", color: textSecondary),
            primaryButtonLabel: .init(text: "Back to life", color: textWhite),
            primaryButtonBackgroundColor: nightPurple,
            secondaryButtonLabel: nil
        )
    }

    private func focusFastShield(_ context: ShieldContext) -> ShieldConfiguration {
        let endsAt = context.state.fast?.endsAt ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let end = formatter.string(from: endsAt)

        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterialDark,
            backgroundColor: backgroundColor,
            icon: artwork("FocusGarden", symbol: "bolt.fill", tint: primaryGreen),
            title: .init(text: "Room to focus.", color: primaryGreen),
            subtitle: .init(text: "\(context.displayItem) is blocked until \(end).", color: textSecondary),
            primaryButtonLabel: .init(text: "Back to life", color: backgroundColor),
            primaryButtonBackgroundColor: primaryGreen,
            secondaryButtonLabel: nil
        )
    }

    private func noCheatsLeftShield(_ context: ShieldContext, base: ShieldKind) -> ShieldConfiguration {
        let portion = context.profile?.portionMinutes ?? 0
        let subtitle: String
        switch base {
        case .plateEmpty:
            subtitle = "\(portion) min of carbs used — and all \(context.allowedCheats) cheat meals are spent this week."
        default:
            subtitle = "\(context.displayItem) stays blocked — all \(context.allowedCheats) cheat meals are spent this week."
        }

        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterialDark,
            backgroundColor: backgroundColor,
            icon: artwork("DigitalGarden", symbol: "ticket.fill", tint: textSecondary),
            title: .init(text: "Back to your rhythm.", color: textSecondary),
            subtitle: .init(text: subtitle, color: textSecondary),
            primaryButtonLabel: .init(text: "Back to life", color: backgroundColor),
            primaryButtonBackgroundColor: textSecondary,
            secondaryButtonLabel: nil
        )
    }

    private func confirmShield(_ context: ShieldContext) -> ShieldConfiguration {
        let remaining = context.cheatsRemaining

        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterialDark,
            backgroundColor: backgroundColor,
            icon: artwork("DigitalGarden", symbol: "ticket.fill", tint: warningYellow),
            title: .init(text: "USE A CHEAT MEAL?", color: warningYellow),
            subtitle: .init(
                text: "\(remaining) left this week. Unlocks \(context.displayItem) for \(DietRules.cheatMealMinutes) min. Tap Confirm within 20 s.",
                color: textSecondary
            ),
            primaryButtonLabel: .init(text: "Cancel", color: textWhite),
            primaryButtonBackgroundColor: backgroundColor,
            secondaryButtonLabel: .init(text: "Confirm", color: warningYellow)
        )
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
