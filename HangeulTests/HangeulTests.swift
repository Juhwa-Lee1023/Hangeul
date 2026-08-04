import XCTest

@testable import Hangeul

final class WordRepositoryTests: XCTestCase {
    func testDecodesMinimalWordMetadata() throws {
        let words = try WordRepository.decode(
            jsonData(
                """
                [
                  {"id": 1, "word": "한글", "english": "Hangeul", "pron": "hangeul"}
                ]
                """
            )
        )

        XCTAssertEqual(
            words,
            [HangeulWord(id: 1, word: "한글", english: "Hangeul", pron: "hangeul")]
        )
    }

    func testRejectsEmptyDataset() {
        XCTAssertThrowsError(try WordRepository.decode(jsonData("[]"))) { error in
            XCTAssertEqual(error as? WordRepositoryError, .emptyDataset)
        }
    }

    func testRejectsDuplicateIdentifiers() {
        let data = jsonData(
            """
            [
              {"id": 7, "word": "한글", "english": "Hangeul", "pron": "hangeul"},
              {"id": 7, "word": "사랑", "english": "love", "pron": "sarang"}
            ]
            """
        )

        XCTAssertThrowsError(try WordRepository.decode(data)) { error in
            XCTAssertEqual(error as? WordRepositoryError, .duplicateIdentifier(7))
        }
    }

    func testRejectsDuplicateWords() {
        let data = jsonData(
            """
            [
              {"id": 1, "word": "우리", "english": "we", "pron": "uri"},
              {"id": 2, "word": "우리", "english": "our", "pron": "uri"}
            ]
            """
        )

        XCTAssertThrowsError(try WordRepository.decode(data)) { error in
            XCTAssertEqual(error as? WordRepositoryError, .duplicateWord("우리"))
        }
    }

    func testRejectsIncompleteAndUnsupportedWords() {
        let incomplete = jsonData(
            """
            [{"id": 3, "word": "사랑", "english": "", "pron": "sarang"}]
            """
        )
        XCTAssertThrowsError(try WordRepository.decode(incomplete)) { error in
            XCTAssertEqual(error as? WordRepositoryError, .incompleteWord(3))
        }

        let unsupported = jsonData(
            """
            [{"id": 4, "word": "K팝", "english": "K-pop", "pron": "keipap"}]
            """
        )
        XCTAssertThrowsError(try WordRepository.decode(unsupported)) { error in
            XCTAssertEqual(error as? WordRepositoryError, .unsupportedWord(4, "K팝"))
        }
    }

    func testBundledDatasetContainsOnlyMetadataAndUsesSupportedLayout() throws {
        let words = try WordRepository.load()

        XCTAssertEqual(words.count, 1_500)
        XCTAssertEqual(Set(words.map(\.id)).count, words.count)
        XCTAssertEqual(Set(words.map(\.word)).count, words.count)

        let countsBySyllableLength = Dictionary(grouping: words, by: { $0.word.count })
            .mapValues(\.count)
        XCTAssertEqual(countsBySyllableLength, [2: 1_000, 3: 500])

        let dataURL = try XCTUnwrap(Bundle.main.url(forResource: "data.json", withExtension: nil))
        let records = try XCTUnwrap(
            JSONSerialization.jsonObject(with: Data(contentsOf: dataURL)) as? [[String: Any]]
        )
        let metadataKeys = Set(["id", "word", "english", "pron"])
        XCTAssertTrue(records.allSatisfy { Set($0.keys) == metadataKeys })

        for word in words {
            let puzzle = try HangulPuzzle.make(for: word)
            XCTAssertEqual(puzzle.syllables.count, word.word.count, "Failed for \(word.word)")
            XCTAssertEqual(puzzle.candidates.count, 12, "Candidate grid changed for \(word.word)")
        }
    }

    func testEveryBundledPuzzleCanBeSolvedUsingItsCandidateTiles() throws {
        let words = try WordRepository.load()

        XCTAssertEqual(words.count, 1_500)

        for word in words {
            let puzzle = try HangulPuzzle.make(for: word)

            for syllableIndex in puzzle.syllables.indices {
                let syllable = puzzle.syllables[syllableIndex]
                let context =
                    "Word \(word.id) \(word.word), syllable \(syllableIndex + 1) "
                    + "\(syllable.character)"
                let selectedIndices = try selectionForAnswer(
                    syllable.jamo,
                    in: puzzle.candidates,
                    context: context
                )
                XCTAssertTrue(
                    puzzle.isCorrect(syllableIndex: syllableIndex, selectedIndices: selectedIndices),
                    "\(context) cannot be solved with candidates \(puzzle.candidates)"
                )
            }
        }
    }

    private func selectionForAnswer(
        _ answer: [String],
        in candidates: [String],
        context: String
    ) throws -> Set<Int> {
        var selectedIndices = Set<Int>()

        for jamo in answer {
            let index = try XCTUnwrap(
                candidates.indices.first {
                    !selectedIndices.contains($0) && candidates[$0] == jamo
                },
                "\(context) is missing candidate tile \(jamo); candidates: \(candidates)"
            )
            selectedIndices.insert(index)
        }

        XCTAssertEqual(selectedIndices.count, answer.count, "\(context) reused a candidate tile")
        return selectedIndices
    }

    private func jsonData(_ json: String) -> Data {
        Data(json.utf8)
    }
}

final class GameSessionTests: XCTestCase {
    func testFiveRoundSessionUsesUniqueWordsAndCompletesInOrder() {
        let session = GameSession(
            words: makeWords(count: 6),
            roundCount: 5,
            deterministicSelection: true
        )

        XCTAssertEqual(session.route, .welcome)
        session.startGame()

        XCTAssertEqual(session.route, .playing)
        XCTAssertEqual(session.totalRounds, 5)
        XCTAssertEqual(session.currentRoundIndex, 0)
        XCTAssertEqual(session.currentPuzzle?.word.id, 1)

        for expectedID in 1...5 {
            XCTAssertEqual(session.currentPuzzle?.word.id, expectedID)
            session.completeCurrentPuzzle()
        }

        XCTAssertEqual(session.route, .completed)
        XCTAssertNil(session.currentPuzzle)
        XCTAssertEqual(session.completedPuzzles.map(\.word.id), Array(1...5))
    }

    func testRestartResetsCompletedProgress() {
        let session = GameSession(
            words: makeWords(count: 2),
            roundCount: 2,
            deterministicSelection: true
        )
        session.startGame()
        session.completeCurrentPuzzle()
        session.completeCurrentPuzzle()
        XCTAssertEqual(session.route, .completed)

        session.startGame()

        XCTAssertEqual(session.route, .playing)
        XCTAssertEqual(session.currentRoundIndex, 0)
        XCTAssertTrue(session.completedPuzzles.isEmpty)
        XCTAssertEqual(session.currentPuzzle?.word.id, 1)
    }

    func testRoundCountIsCappedByAvailableUniqueSpellings() {
        let duplicate = HangeulWord(id: 99, word: "가", english: "duplicate", pron: "ga")
        let session = GameSession(
            words: makeWords(count: 2) + [duplicate],
            roundCount: 5,
            deterministicSelection: true
        )

        session.startGame()

        XCTAssertEqual(session.totalRounds, 2)
    }

    func testLoaderFailureProducesRecoverableFailureRoute() {
        let session = GameSession(loader: {
            throw WordRepositoryError.missingResource("data.json")
        })
        let expectedMessage = "Could not find data.json in the app bundle."
        XCTAssertEqual(session.route, .failure(expectedMessage))

        session.reload()

        XCTAssertEqual(session.route, .failure(expectedMessage))
    }

    private func makeWords(count: Int) -> [HangeulWord] {
        let spellings = ["가", "나", "다", "라", "마", "바"]
        return (0..<count).map { index in
            HangeulWord(
                id: index + 1,
                word: spellings[index],
                english: "word-\(index + 1)",
                pron: "pronunciation-\(index + 1)"
            )
        }
    }
}
