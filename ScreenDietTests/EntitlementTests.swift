import XCTest

final class EntitlementTests: XCTestCase {

    func testFreeTierClampsToOneCheat() {
        XCTAssertEqual(Entitlement.clampedCheats(5, isPremium: false), 1)
        XCTAssertEqual(Entitlement.clampedCheats(0, isPremium: false), 0)
    }

    func testPremiumKeepsRequestedCheats() {
        XCTAssertEqual(Entitlement.clampedCheats(5, isPremium: true), 5)
        XCTAssertEqual(Entitlement.clampedCheats(0, isPremium: true), 0, "premium users may go hardcore")
    }

    func testPremiumClampsToSeven() {
        XCTAssertEqual(Entitlement.clampedCheats(9, isPremium: true), 7)
    }

    func testFreeTierOnlyAllowsLeanPlan() {
        XCTAssertTrue(Entitlement.canUse(plan: .lean, isPremium: false))
        XCTAssertFalse(Entitlement.canUse(plan: .keto, isPremium: false))
        XCTAssertFalse(Entitlement.canUse(plan: .custom, isPremium: false))
        XCTAssertTrue(Entitlement.canUse(plan: .keto, isPremium: true))
    }

    func testPremiumGates() {
        XCTAssertFalse(Entitlement.isUnlocked(.nightFast, isPremium: false))
        XCTAssertTrue(Entitlement.isUnlocked(.nightFast, isPremium: true))
    }
}
