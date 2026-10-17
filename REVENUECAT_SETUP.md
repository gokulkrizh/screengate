# ScreenDiet RevenueCat Setup

- Project: `proj7d5f72bb` (ScreenDiet)
- iOS app: `app37bca6f2e2`, bundle ID `com.gia.screendiet`
- Entitlement: `premium` (ScreenDiet Plus)
- Current offering: `default` (`ofrng740d616140`)
- Packages: `$rc_annual`, `$rc_monthly`, `$rc_lifetime`
- Store product IDs: `screendiet.premium.yearly`, `screendiet.premium.monthly`, `screendiet.premium.lifetime`
- Paywall draft: https://app.revenuecat.com/projects/7d5f72bb/paywalls/pw5c199bd5e18d4f1b/builder

Debug builds configure RevenueCat with the project's Test Store public SDK key;
Release builds use its public Apple SDK key in `EntitlementManager`.
RevenueCatUI handles purchases and restores in onboarding and all existing upgrade
placements. Unmapped placements use the current offering. Customer info updates
write the active `premium` entitlement to the app group and refresh widgets.
Failed refreshes preserve cached access. Debug purchase buttons no longer grant
premium; the explicit debug override remains available.

## Before Purchases Go Live

1. Configure fresh App Store Connect and In-App Purchase credentials in the
   RevenueCat iOS app settings. Never use revoked keys or commit `.p8` files.
2. Verify the three product IDs exist in App Store Connect, with the intended
   prices, durations, availability, and any introductory offers. Registering
   products in RevenueCat does not create them in App Store Connect.
3. Review and publish the dashboard paywall draft. ScreenDiet's privacy policy
   is at `https://gokulkrish.com/apps/screendiet/privacy/`.
4. Verify on a sandbox device: paywall rendering, purchase, restore, cancellation,
   pending approval, relaunch, expiration, and offline cached access. Verify
   premium changes reconcile shields and update widgets.

## Testing the Paywall

The dashboard paywall is published. Test Store products are attached to the same
annual, monthly and lifetime packages and the `premium` entitlement. Debug builds
use synthetic USD prices of $29.99/year, $4.99/month and $59.99 lifetime.
These products do not charge money or create products in App Store Connect.

Run the `screengate` scheme in Debug, then open Settings > Membership or the
onboarding membership step. Select a plan and tap Unlock ScreenDiet Plus. The
Test Store dialog offers Successful Purchase, Failed Purchase and Cancel.
Check that success unlocks Plus, failure/cancel preserve free access, and Restore
recovers the test membership. Apple trial eligibility still requires sandbox testing.

The unapplied Apple pricing plan was saved in
`concept/revenuecat-apple-pricing-plan.json` and discarded in RevenueCat to free
the project's single active plan slot for Test Store setup. Recreate that plan
when ready to configure the real store products; no Apple prices were applied.

The app shows a retry/continue-free state if offerings, products, or a published
paywall are unavailable. Dashboard drafts are not delivered by the SDK.
