//
//  HangulPuzzleTests.swift
//  HangeulTests
//

import XCTest

@testable import Hangeul

final class HangulPuzzleTests: XCTestCase {
    func testHangeulWordDecodesMetadataAndIgnoresUnrelatedFields() throws {
        let json = Data(
            #"{"id":5,"word":"한글","english":"Hangeul","pron":"hangeul","unused":true}"#.utf8
        )

        let word = try JSONDecoder().decode(HangeulWord.self, from: json)

        XCTAssertEqual(
            word,
            HangeulWord(id: 5, word: "한글", english: "Hangeul", pron: "hangeul")
        )
    }

    func testJamoTablesHaveAllModernUnicodeCombinations() {
        XCTAssertEqual(HangulDecomposer.initialJamo.count, 19)
        XCTAssertEqual(HangulDecomposer.medialJamo.count, 21)
        XCTAssertEqual(HangulDecomposer.finalJamo.count, 27)
    }

    func testDecomposesInitialMedialFinalComplexVowelAndRepeatedJamo() throws {
        let han = try HangulDecomposer.decompose(syllable: "한")
        XCTAssertEqual(han.initial, "ㅎ")
        XCTAssertEqual(han.medial, "ㅏ")
        XCTAssertEqual(han.finalJamo, "ㄴ")
        XCTAssertEqual(han.jamo, ["ㅎ", "ㅏ", "ㄴ"])

        let geul = try HangulDecomposer.decompose(syllable: "글")
        XCTAssertEqual(geul.jamo, ["ㄱ", "ㅡ", "ㄹ"])

        let nun = try HangulDecomposer.decompose(syllable: "눈")
        XCTAssertEqual(nun.jamo, ["ㄴ", "ㅜ", "ㄴ"])

        let gwa = try HangulDecomposer.decompose(syllable: "과")
        XCTAssertEqual(gwa.initial, "ㄱ")
        XCTAssertEqual(gwa.medial, "ㅘ")
        XCTAssertNil(gwa.finalJamo)
        XCTAssertEqual(gwa.jamo, ["ㄱ", "ㅘ"])

        let gaps = try HangulDecomposer.decompose(syllable: "값")
        XCTAssertEqual(gaps.finalJamo, "ㅄ")
    }

    func testDecomposesUnicodeBoundarySyllables() throws {
        XCTAssertEqual(
            try HangulDecomposer.decompose(syllable: "가").jamo,
            ["ㄱ", "ㅏ"]
        )
        XCTAssertEqual(
            try HangulDecomposer.decompose(syllable: "힣").jamo,
            ["ㅎ", "ㅣ", "ㅎ"]
        )
    }

    func testNonHangulCharacterThrowsExplicitError() {
        XCTAssertThrowsError(try HangulDecomposer.decompose(syllable: "A")) { error in
            XCTAssertEqual(error as? HangulPuzzleError, .nonHangulCharacter("A"))
        }

        XCTAssertThrowsError(try HangulDecomposer.decompose(word: "한글!")) { error in
            XCTAssertEqual(error as? HangulPuzzleError, .nonHangulCharacter("!"))
        }
    }

    func testEmptyWordThrowsExplicitError() {
        XCTAssertThrowsError(try HangulDecomposer.decompose(word: "")) { error in
            XCTAssertEqual(error as? HangulPuzzleError, .emptyWord)
        }

        XCTAssertThrowsError(try HangulPuzzle.make(for: makeWord(""))) { error in
            XCTAssertEqual(error as? HangulPuzzleError, .emptyWord)
        }
    }

    func testDecomposesTwoSyllableAndArbitraryLengthWords() throws {
        let twoSyllables = try HangulDecomposer.decompose(word: "한글")
        XCTAssertEqual(twoSyllables.map(\.character), Array("한글"))

        let longWord = "가나다라마바사아자차카타파하"
        let manySyllables = try HangulDecomposer.decompose(word: longWord)
        XCTAssertEqual(manySyllables.count, 14)
        XCTAssertEqual(manySyllables.map(\.character), Array(longWord))
    }

    func testCandidatesContainRequiredMaximumMultiplicityAndNoAnswerDistractors() throws {
        var generator = SeededGenerator(seed: 7)
        let puzzle = try HangulPuzzle.make(
            for: makeWord("눈과"),
            using: &generator
        )
        let counts = multiset(puzzle.candidates)

        XCTAssertEqual(puzzle.candidates.count, 12)
        XCTAssertEqual(counts["ㄴ"], 2)
        XCTAssertEqual(counts["ㅜ"], 1)
        XCTAssertEqual(counts["ㄱ"], 1)
        XCTAssertEqual(counts["ㅘ"], 1)

        let answerValues: Set<String> = ["ㄴ", "ㅜ", "ㄱ", "ㅘ"]
        let distractors = puzzle.candidates.filter { !answerValues.contains($0) }
        XCTAssertEqual(distractors.count, 7)
        XCTAssertTrue(distractors.allSatisfy { !answerValues.contains($0) })
    }

    func testCandidateMultiplicityUsesPerSyllableMaximumNotWholeWordTotal() throws {
        var generator = SeededGenerator(seed: 11)
        let puzzle = try HangulPuzzle.make(
            for: makeWord("나눈난"),
            using: &generator
        )

        XCTAssertEqual(multiset(puzzle.candidates)["ㄴ"], 2)
    }

    func testRequiredTilesCanIncreaseCandidatesBeyondRequestedMinimum() throws {
        var generator = SeededGenerator(seed: 13)
        let word = "가나다라마바사아자차카타파하"
        let puzzle = try HangulPuzzle.make(
            for: makeWord(word),
            minimumCandidateCount: 12,
            using: &generator
        )

        XCTAssertEqual(puzzle.candidates.count, 15)
        XCTAssertEqual(Set(puzzle.candidates).count, 15)
    }

    func testSameJamoAtDifferentCandidateIndicesIsInterchangeable() throws {
        var generator = SeededGenerator(seed: 17)
        let puzzle = try HangulPuzzle.make(
            for: makeWord("나눈"),
            using: &generator
        )

        let nieunIndices = puzzle.candidates.indices.filter { puzzle.candidates[$0] == "ㄴ" }
        let aIndex = try XCTUnwrap(puzzle.candidates.firstIndex(of: "ㅏ"))
        XCTAssertEqual(nieunIndices.count, 2)

        XCTAssertTrue(
            puzzle.isCorrect(
                syllableIndex: 0,
                selectedIndices: [nieunIndices[0], aIndex]
            )
        )
        XCTAssertTrue(
            puzzle.isCorrect(
                syllableIndex: 0,
                selectedIndices: Set([nieunIndices[1], aIndex])
            )
        )
    }

    func testRepeatedJamoAnswerNeedsTwoDistinctTiles() throws {
        var generator = SeededGenerator(seed: 19)
        let puzzle = try HangulPuzzle.make(
            for: makeWord("나눈"),
            using: &generator
        )

        let nieunIndices = puzzle.candidates.indices.filter { puzzle.candidates[$0] == "ㄴ" }
        let uIndex = try XCTUnwrap(puzzle.candidates.firstIndex(of: "ㅜ"))

        XCTAssertTrue(
            puzzle.isCorrect(
                syllableIndex: 1,
                selectedIndices: nieunIndices + [uIndex]
            )
        )
        XCTAssertFalse(
            puzzle.isCorrect(
                syllableIndex: 1,
                selectedIndices: [nieunIndices[0], uIndex]
            )
        )
        XCTAssertFalse(
            puzzle.isCorrect(
                syllableIndex: 1,
                selectedIndices: [nieunIndices[0], nieunIndices[0], uIndex]
            )
        )
    }

    func testInjectedGeneratorIsReproducibleAndSystemGeneratorIsSupported() throws {
        let word = makeWord("한글")
        var firstGenerator = SeededGenerator(seed: 23)
        var secondGenerator = SeededGenerator(seed: 23)

        let first = try HangulPuzzle.make(for: word, using: &firstGenerator)
        let second = try HangulPuzzle.make(for: word, using: &secondGenerator)
        let systemRandom = try HangulPuzzle.make(for: word)

        XCTAssertEqual(first.candidates, second.candidates)
        XCTAssertEqual(systemRandom.candidates.count, HangulPuzzle.defaultCandidateCount)
        XCTAssertEqual(systemRandom.syllables.count, 2)
    }

    func testInvalidSyllableOrCandidateIndicesAreNotCorrect() throws {
        var generator = SeededGenerator(seed: 29)
        let puzzle = try HangulPuzzle.make(for: makeWord("한"), using: &generator)

        XCTAssertFalse(puzzle.isCorrect(syllableIndex: -1, selectedIndices: []))
        XCTAssertFalse(puzzle.isCorrect(syllableIndex: 1, selectedIndices: []))
        XCTAssertFalse(puzzle.isCorrect(syllableIndex: 0, selectedIndices: [-1]))
        XCTAssertFalse(
            puzzle.isCorrect(
                syllableIndex: 0,
                selectedIndices: [puzzle.candidates.count]
            )
        )
    }

    private func makeWord(_ word: String) -> HangeulWord {
        HangeulWord(id: 1, word: word, english: "", pron: "")
    }

    private func multiset(_ values: [String]) -> [String: Int] {
        values.reduce(into: [:]) { counts, value in
            counts[value, default: 0] += 1
        }
    }
}

private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state
    }
}
