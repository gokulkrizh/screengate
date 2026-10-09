import XCTest

final class OnboardingAnswersTests: XCTestCase {
    func testExistingAnswersDecodeWithoutAnIntention() throws {
        let legacy = Data(#"{"dailyHours":4,"worstTime":"evening","goal":"cutdown"}"#.utf8)
        let answers = try JSONDecoder().decode(OnboardingAnswers.self, from: legacy)
        XCTAssertEqual(answers.dailyHours, 4)
        XCTAssertNil(answers.intention)
    }

    func testIntentionSurvivesSharedStateEncoding() throws {
        let answers = OnboardingAnswers(dailyHours: 4, worstTime: "evening", goal: "cutdown", intention: "Reading")
        let encoded = try JSONEncoder().encode(answers)
        XCTAssertEqual(try JSONDecoder().decode(OnboardingAnswers.self, from: encoded), answers)
    }
}
