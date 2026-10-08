import XCTest

final class ShieldPendingTests: XCTestCase {

    func testPendingIsActiveBeforeExpiry() {
        let pending = ShieldPending(scope: "x", expiresAt: Date().addingTimeInterval(20))
        XCTAssertTrue(pending.isActive())
    }

    func testPendingExpires() {
        let pending = ShieldPending(scope: "x", expiresAt: Date().addingTimeInterval(-1))
        XCTAssertFalse(pending.isActive())
    }

    func testMakerTtl() {
        let pending = ShieldPending.make(for: "token", ttl: 20)
        XCTAssertEqual(pending.scope, ShieldPending.scope(for: "token"))
        XCTAssertTrue(pending.isActive())
        XCTAssertLessThan(pending.expiresAt.timeIntervalSinceNow, 21)
    }
}
