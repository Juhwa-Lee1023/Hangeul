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

    func testThreeSyllablePuzzleUsesTwoSyllableLayout() {
        let twoSyllableLayout = capturePuzzleLayout(wordID: 1, attachmentName: "2-syllable")
        let threeSyllableLayout = capturePuzzleLayout(wordID: 1002, attachmentName: "3-syllable")

        assertFramesEqual(
            threeSyllableLayout.wordCard,
            twoSyllableLayout.wordCard,
            component: "word card"
        )
        XCTAssertLessThanOrEqual(
            threeSyllableLayout.wordText.height,
            twoSyllableLayout.wordText.height + 1,
            "The three-syllable word must remain on one line."
        )
        XCTAssertEqual(
            threeSyllableLayout.wordText.midY,
            twoSyllableLayout.wordText.midY,
            accuracy: 1,
            "The word must stay vertically centered in its card."
        )
        assertFramesEqual(
            threeSyllableLayout.instruction,
            twoSyllableLayout.instruction,
            component: "instruction"
        )

        for index in twoSyllableLayout.candidates.indices {
            assertFramesEqual(
                threeSyllableLayout.candidates[index],
                twoSyllableLayout.candidates[index],
                component: "candidate \(index)"
            )
        }

        assertFramesEqual(
            threeSyllableLayout.cleanButton,
            twoSyllableLayout.cleanButton,
            component: "clean button"
        )
        assertFramesEqual(
            threeSyllableLayout.confirmButton,
            twoSyllableLayout.confirmButton,
            component: "confirm button"
        )

        XCTAssertEqual(twoSyllableLayout.progressTiles.count, 2)
        XCTAssertEqual(threeSyllableLayout.progressTiles.count, 3)
        guard
            let referenceFirstTile = twoSyllableLayout.progressTiles.first,
            let referenceLastTile = twoSyllableLayout.progressTiles.last,
            let actualFirstTile = threeSyllableLayout.progressTiles.first,
            let actualLastTile = threeSyllableLayout.progressTiles.last
        else {
            XCTFail("The compared layouts have no progress tiles.")
            return
        }
        for tile in threeSyllableLayout.progressTiles {
            XCTAssertEqual(
                tile.width,
                referenceFirstTile.width,
                accuracy: 1
            )
            XCTAssertEqual(
                tile.height,
                referenceFirstTile.height,
                accuracy: 1
            )
            XCTAssertEqual(
                tile.midY,
                referenceFirstTile.midY,
                accuracy: 1
            )
        }

        let referenceCenterX = (referenceFirstTile.minX + referenceLastTile.maxX) / 2
        let actualCenterX = (actualFirstTile.minX + actualLastTile.maxX) / 2
        XCTAssertEqual(
            actualCenterX,
            referenceCenterX,
            accuracy: 1,
            "The progress row must stay horizontally centered."
        )

        let referenceSpacing =
            twoSyllableLayout.progressTiles[1].minX
            - twoSyllableLayout.progressTiles[0].maxX
        for (leftTile, rightTile) in zip(
            threeSyllableLayout.progressTiles,
            threeSyllableLayout.progressTiles.dropFirst()
        ) {
            XCTAssertLessThanOrEqual(
                leftTile.maxX,
                rightTile.minX,
                "Progress tiles must not overlap."
            )
            XCTAssertEqual(
                rightTile.minX - leftTile.maxX,
                referenceSpacing,
                accuracy: 1,
                "Progress tile spacing must match the two-syllable layout."
            )
        }
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

    private func capturePuzzleLayout(wordID: Int, attachmentName: String) -> PuzzleLayoutSnapshot {
        app.terminate()
        app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--ui-testing-word-id=\(wordID)"]
        app.launch()

        let startButton = app.buttons["start-game"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.tap()

        let wordCard = app.buttons["word-audio"]
        let instruction = app.staticTexts["puzzle-instruction"]
        let cleanButton = app.buttons["action-clean"]
        let confirmButton = app.buttons["confirm-selection"]
        XCTAssertTrue(wordCard.waitForExistence(timeout: 5))
        XCTAssertTrue(instruction.waitForExistence(timeout: 2))
        XCTAssertTrue(cleanButton.waitForExistence(timeout: 2))
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 2))

        let wordText = wordCard.descendants(matching: .staticText).firstMatch
        XCTAssertTrue(wordText.exists)

        let firstCandidate = app.buttons["candidate-0"]
        XCTAssertTrue(firstCandidate.waitForExistence(timeout: 2))
        let candidates = (0..<12).map { index in
            let candidate = app.buttons["candidate-\(index)"]
            XCTAssertTrue(candidate.exists)
            XCTAssertTrue(candidate.isHittable)
            return candidate.frame
        }

        let progressQuery = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "syllable")
        )
        let progressTiles = progressQuery.allElementsBoundByIndex.map(\.frame)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "\(attachmentName)-layout"
        attachment.lifetime = .keepAlways
        add(attachment)

        return PuzzleLayoutSnapshot(
            wordCard: wordCard.frame,
            wordText: wordText.frame,
            instruction: instruction.frame,
            candidates: candidates,
            cleanButton: cleanButton.frame,
            confirmButton: confirmButton.frame,
            progressTiles: progressTiles
        )
    }

    private func assertFramesEqual(
        _ actual: CGRect,
        _ expected: CGRect,
        component: String,
        accuracy: CGFloat = 1
    ) {
        XCTAssertEqual(actual.minX, expected.minX, accuracy: accuracy, "\(component) x changed")
        XCTAssertEqual(actual.minY, expected.minY, accuracy: accuracy, "\(component) y changed")
        XCTAssertEqual(actual.width, expected.width, accuracy: accuracy, "\(component) width changed")
        XCTAssertEqual(
            actual.height,
            expected.height,
            accuracy: accuracy,
            "\(component) height changed"
        )
    }

    private func assertWord(_ expected: String) {
        let wordButton = app.buttons["Listen to \(expected)"]
        XCTAssertTrue(wordButton.waitForExistence(timeout: 5))
        XCTAssertEqual(wordButton.label, "Listen to \(expected)")
    }
}

private struct PuzzleLayoutSnapshot {
    let wordCard: CGRect
    let wordText: CGRect
    let instruction: CGRect
    let candidates: [CGRect]
    let cleanButton: CGRect
    let confirmButton: CGRect
    let progressTiles: [CGRect]
}
