//
//  ShieldConfigurationExtension.swift
//  ShieldConfigurationExtension
//
//  Picks the shield design from live state (Fast Now > Night Fast > portion hit >
//  kitchen closed) via the shared rules. Phase 2 adds the final designs and the
//  2-tap cheat confirmation; this file is already state-driven.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit
import Foundation

class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    private let store = SharedStore.shared

    // MARK: - Theme

    private let backgroundColor = UIColor(red: 0.06, green: 0.06, blue: 0.08, alpha: 1.0) // #0F1014
    private let primaryGreen = UIColor(red: 0.0, green: 1.0, blue: 0.39, alpha: 1.0)       // #00FF63
    private let warningYellow = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
    private let errorRed = UIColor.systemRed
    private let nightPurple = UIColor.systemPurple
    private let textWhite = UIColor.white
    private let textSecondary = UIColor.white.withAlphaComponent(0.6)

    // MARK: - Context

    private struct ShieldContext {
        let kind: ShieldKind?
        let state: SharedState

        var profile: DietProfile? { state.profile }

        var cheatsRemaining: Int {
            guard let profile else { return 0 }
            return max(0, profile.cheatsPerWeek - state.week.cheatsUsed)
        }

        /// Cheat is offered for kitchen-closed / portion-hit shields, but never
        /// during a fast and never with zero cheats left.
        var cheatOffered: Bool {
            guard let kind else { return false }
            let cheatable = kind == .kitchenClosed || kind == .plateEmpty
            return cheatable
                && cheatsRemaining > 0
                && !DietRules.isFastActive(state.fast)
                && !DietRules.isCheatActive(state.cheat)
        }
    }

    private func loadContext() -> ShieldContext {
        let state = store.load()
        let dietState = DietRules.state(
            profile: state.profile,
            counters: state.counters,
            fast: state.fast,
            cheat: state.cheat
        )
        return ShieldContext(kind: DietRules.shieldKind(for: dietState), state: state)
    }

    // MARK: - Shield Configuration

    private func configuration(for context: ShieldContext) -> ShieldConfiguration {
        switch context.kind {
        case .focusFast: return focusFastShield(context)
        case .fasting: return nightFastShield(context)
        case .plateEmpty: return plateEmptyShield(context)
        case .kitchenClosed: return kitchenClosedShield(context)
        case nil: return kitchenClosedShield(context)
        }
    }

    private func cheatLabel(_ context: ShieldContext) -> ShieldConfiguration.Label? {
        guard context.cheatOffered else { return nil }
        return .init(text: "Cheat meal (\(context.cheatsRemaining) left)", color: warningYellow)
    }

    private func kitchenClosedShield(_ context: ShieldContext) -> ShieldConfiguration {
        let openAt = context.profile?.eatingWindow.startTimeString ?? "later"
        let minutes = context.profile?.eatingWindow.minutesUntilOpen() ?? 0
        let countdown = minutes > 0 ? " · \(minutes / 60)h \(minutes % 60)m" : ""

        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterialDark,
            backgroundColor: backgroundColor,
            icon: UIImage(systemName: "moon.fill")?.withTintColor(warningYellow, renderingMode: .alwaysOriginal),
            title: .init(text: "KITCHEN CLOSED", color: warningYellow),
            subtitle: .init(text: "Opens at \(openAt)\(countdown). Protein is always available.", color: textSecondary),
            primaryButtonLabel: .init(text: "Close", color: backgroundColor),
            primaryButtonBackgroundColor: warningYellow,
            secondaryButtonLabel: cheatLabel(context)
        )
    }

    private func plateEmptyShield(_ context: ShieldContext) -> ShieldConfiguration {
        let portion = context.profile?.portionMinutes ?? 0
        let closeAt = context.profile?.eatingWindow.endTimeString ?? ""

        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterialDark,
            backgroundColor: backgroundColor,
            icon: UIImage(systemName: "takeoutbag.and.cup.and.straw.fill")?.withTintColor(errorRed, renderingMode: .alwaysOriginal),
            title: .init(text: "PLATE'S EMPTY", color: errorRed),
            subtitle: .init(text: "\(portion) min of carbs used\(closeAt.isEmpty ? "" : " · kitchen closes \(closeAt)").", color: textSecondary),
            primaryButtonLabel: .init(text: "Close", color: backgroundColor),
            primaryButtonBackgroundColor: errorRed,
            secondaryButtonLabel: cheatLabel(context)
        )
    }

    private func nightFastShield(_ context: ShieldContext) -> ShieldConfiguration {
        let end = context.profile?.nightFast.endTimeString ?? "morning"

        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterialDark,
            backgroundColor: backgroundColor,
            icon: UIImage(systemName: "moon.zzz.fill")?.withTintColor(nightPurple, renderingMode: .alwaysOriginal),
            title: .init(text: "NIGHT FAST", color: nightPurple),
            subtitle: .init(text: "Carbs and social apps are blocked until \(end).", color: textSecondary),
            primaryButtonLabel: .init(text: "Close", color: textWhite),
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
            icon: UIImage(systemName: "bolt.fill")?.withTintColor(primaryGreen, renderingMode: .alwaysOriginal),
            title: .init(text: "FOCUS FAST", color: primaryGreen),
            subtitle: .init(text: "Fasting until \(end). Protein is always available.", color: textSecondary),
            primaryButtonLabel: .init(text: "Close", color: backgroundColor),
            primaryButtonBackgroundColor: primaryGreen,
            secondaryButtonLabel: nil
        )
    }

    // MARK: - ShieldConfigurationDataSource

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        configuration(for: loadContext())
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        configuration(for: loadContext())
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        configuration(for: loadContext())
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        configuration(for: loadContext())
    }
}
