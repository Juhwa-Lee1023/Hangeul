import XCTest

final class HangeulUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
    }

    func testCompletesFiveRoundGameAndRestarts() {
        let startButton = app.buttons["start-game"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.tap()

        let rounds = [
            ("우리", [["ㅇ", "ㅜ"], ["ㄹ", "ㅣ"]]),
            ("사랑", [["ㅅ", "ㅏ"], ["ㄹ", "ㅏ", "ㅇ"]]),
            ("웃음", [["ㅇ", "ㅜ", "ㅅ"], ["ㅇ", "ㅡ", "ㅁ"]]),
            ("안녕", [["ㅇ", "ㅏ", "ㄴ"], ["ㄴ", "ㅕ", "ㅇ"]]),
            ("한글", [["ㅎ", "ㅏ", "ㄴ"], ["ㄱ", "ㅡ", "ㄹ"]]),
        ]

        for (word, syllables) in rounds {
            assertWord(word)
            for jamo in syllables {
                solveSyllable(with: jamo)
            }

            XCTAssertTrue(app.buttons["word-meaning"].waitForExistence(timeout: 2))
            let nextButton = app.buttons["next-puzzle"]
            XCTAssertTrue(nextButton.waitForExistence(timeout: 2))
            nextButton.tap()
        }

        XCTAssertTrue(app.buttons["completion-card"].waitForExistence(timeout: 5))

        let restartButton = app.buttons["restart-game"]
        XCTAssertTrue(restartButton.waitForExistence(timeout: 2))
        restartButton.tap()
        assertWord("우리")
    }

    func testCleanClearsASelectionWithoutChangingTheRound() {
        let startButton = app.buttons["start-game"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.tap()
        assertWord("우리")

        let candidate = candidateButton(label: "ㅇ")
        candidate.tap()
        XCTAssertEqual(candidate.value as? String, "Selected")

        let cleanButton = app.buttons["action-clean"]
        XCTAssertTrue(cleanButton.waitForExistence(timeout: 2))
        cleanButton.tap()

        XCTAssertEqual(candidate.value as? String, "Not selected")
        assertWord("우리")

        candidate.tap()
        let confirmButton = app.buttons["confirm-selection"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 2))
        confirmButton.tap()

        let mismatchAlert = app.alerts["Didn't Match"]
        XCTAssertTrue(mismatchAlert.waitForExistence(timeout: 2))
        mismatchAlert.buttons["RETRUN"].tap()
        XCTAssertEqual(candidate.value as? String, "Not selected")
        assertWord("우리")
    }

    private func solveSyllable(with jamo: [String]) {
        for value in jamo {
            candidateButton(label: value).tap()
        }

        let confirmButton = app.buttons["confirm-selection"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 2))
        confirmButton.tap()
    }

    private func candidateButton(label: String) -> XCUIElement {
        let element =
            app.buttons
            .matching(NSPredicate(format: "label BEGINSWITH %@", "\(label), tile"))
            .firstMatch
        XCTAssertTrue(element.waitForExistence(timeout: 2), "Missing candidate tile \(label)")
        return element
    }

    private func assertWord(_ expected: String) {
        let wordButton = app.buttons["Listen to \(expected)"]
        XCTAssertTrue(wordButton.waitForExistence(timeout: 5))
        XCTAssertEqual(wordButton.label, "Listen to \(expected)")
    }
}
