//
//  HangulPuzzle.swift
//  Hangeul
//

import Foundation

/// The word metadata consumed by the puzzle. Extra keys in the legacy JSON are ignored.
struct HangeulWord: Decodable, Identifiable, Equatable {
    let id: Int
    let word: String
    let english: String
    let pron: String

    private enum CodingKeys: String, CodingKey {
        case id
        case word
        case english
        case pron
    }
}

enum HangulPuzzleError: Error, Equatable {
    /// A puzzle needs at least one syllable to be playable.
    case emptyWord

    /// The decomposition engine accepts only precomposed Hangul syllables (U+AC00...U+D7A3).
    case nonHangulCharacter(Character)

    /// Every known jamo is part of the answer, so a non-answer distractor cannot be produced.
    case noAvailableDistractor
}

extension HangulPuzzleError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .emptyWord:
            return "A Hangeul puzzle word cannot be empty."
        case .nonHangulCharacter(let character):
            return "'\(character)' is not a precomposed Hangul syllable."
        case .noAvailableDistractor:
            return "There is no jamo available that is not already part of the answer."
        }
    }
}

/// The compatibility-jamo decomposition of one precomposed Hangul syllable.
struct HangulSyllable: Equatable {
    let character: Character
    let initial: String
    let medial: String
    let finalJamo: String?

    /// The exact tiles needed to solve this syllable, including repeated values.
    var jamo: [String] {
        var result = [initial, medial]
        if let finalJamo = finalJamo {
            result.append(finalJamo)
        }
        return result
    }
}

/// Algorithmic decomposition for every modern, precomposed Hangul syllable.
enum HangulDecomposer {
    static let initialJamo = [
        "ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ",
        "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ",
    ]

    static let medialJamo = [
        "ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ",
        "ㅚ", "ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ",
    ]

    /// The 27 non-empty jongseong values. Index zero in the Unicode formula means no final.
    static let finalJamo = [
        "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ",
        "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ",
        "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ",
    ]

    /// All tile values in stable order, with consonants shared by initial/final included once.
    static let allJamo: [String] = {
        var seen = Set<String>()
        return (initialJamo + medialJamo + finalJamo).filter { seen.insert($0).inserted }
    }()

    static func decompose(syllable: Character) throws -> HangulSyllable {
        let scalars = String(syllable).unicodeScalars
        guard scalars.count == 1,
            let value = scalars.first?.value,
            (0xAC00...0xD7A3).contains(value)
        else {
            throw HangulPuzzleError.nonHangulCharacter(syllable)
        }

        let offset = Int(value - 0xAC00)
        let initialIndex = offset / (medialJamo.count * 28)
        let medialIndex = (offset % (medialJamo.count * 28)) / 28
        let finalIndex = offset % 28

        return HangulSyllable(
            character: syllable,
            initial: initialJamo[initialIndex],
            medial: medialJamo[medialIndex],
            finalJamo: finalIndex == 0 ? nil : finalJamo[finalIndex - 1]
        )
    }

    static func decompose(word: String) throws -> [HangulSyllable] {
        guard !word.isEmpty else {
            throw HangulPuzzleError.emptyWord
        }
        return try word.map { try decompose(syllable: $0) }
    }
}

struct HangulPuzzle {
    static let defaultCandidateCount = 12

    let word: HangeulWord
    let syllables: [HangulSyllable]

    /// One candidate grid shared by every syllable in the word.
    let candidates: [String]

    /// Creates a puzzle using the platform's cryptographically seeded system generator.
    static func make(
        for word: HangeulWord,
        minimumCandidateCount: Int = defaultCandidateCount
    ) throws -> HangulPuzzle {
        var generator = SystemRandomNumberGenerator()
        return try make(
            for: word,
            minimumCandidateCount: minimumCandidateCount,
            using: &generator
        )
    }

    /// Creates a puzzle with an injectable generator for reproducible tests or game sessions.
    static func make<R: RandomNumberGenerator>(
        for word: HangeulWord,
        minimumCandidateCount: Int = defaultCandidateCount,
        using generator: inout R
    ) throws -> HangulPuzzle {
        let syllables = try HangulDecomposer.decompose(word: word.word)
        let requirements = maximumRequiredJamoCounts(in: syllables)

        var requiredTiles: [String] = []
        for jamo in HangulDecomposer.allJamo {
            requiredTiles.append(contentsOf: repeatElement(jamo, count: requirements[jamo, default: 0]))
        }

        let targetCount = max(requiredTiles.count, minimumCandidateCount)
        let correctValues = Set(requirements.keys)
        var distractorPool = HangulDecomposer.allJamo.filter { !correctValues.contains($0) }
        let distractorCount = targetCount - requiredTiles.count

        guard distractorCount == 0 || !distractorPool.isEmpty else {
            throw HangulPuzzleError.noAvailableDistractor
        }

        var distractors: [String] = []
        distractors.reserveCapacity(distractorCount)

        // Prefer distinct distractors. For unusually large grids, reshuffle and reuse only
        // after the complete non-answer pool has been exhausted.
        while distractors.count < distractorCount {
            distractorPool.shuffle(using: &generator)
            let remaining = distractorCount - distractors.count
            distractors.append(contentsOf: distractorPool.prefix(remaining))
        }

        var candidates = requiredTiles + distractors
        candidates.shuffle(using: &generator)

        return HangulPuzzle(word: word, syllables: syllables, candidates: candidates)
    }

    /// Checks selected tile positions by comparing their values as a multiset.
    /// Different positions containing the same jamo are therefore interchangeable.
    func isCorrect(syllableIndex: Int, selectedIndices: [Int]) -> Bool {
        guard syllables.indices.contains(syllableIndex),
            Set(selectedIndices).count == selectedIndices.count
        else {
            return false
        }

        var selectedJamo: [String] = []
        selectedJamo.reserveCapacity(selectedIndices.count)

        for index in selectedIndices {
            guard candidates.indices.contains(index) else {
                return false
            }
            selectedJamo.append(candidates[index])
        }

        return isCorrect(syllableIndex: syllableIndex, selectedJamo: selectedJamo)
    }

    /// Set-based convenience for SwiftUI selection state.
    func isCorrect(syllableIndex: Int, selectedIndices: Set<Int>) -> Bool {
        isCorrect(syllableIndex: syllableIndex, selectedIndices: Array(selectedIndices))
    }

    /// Value-based variant useful when the UI already stores selected tile values.
    func isCorrect(syllableIndex: Int, selectedJamo: [String]) -> Bool {
        guard syllables.indices.contains(syllableIndex) else {
            return false
        }

        return Self.multiset(of: selectedJamo) == Self.multiset(of: syllables[syllableIndex].jamo)
    }

    private static func maximumRequiredJamoCounts(
        in syllables: [HangulSyllable]
    ) -> [String: Int] {
        var maximumCounts: [String: Int] = [:]

        for syllable in syllables {
            let counts = multiset(of: syllable.jamo)
            for (jamo, count) in counts {
                maximumCounts[jamo] = max(maximumCounts[jamo, default: 0], count)
            }
        }

        return maximumCounts
    }

    private static func multiset(of values: [String]) -> [String: Int] {
        values.reduce(into: [:]) { counts, value in
            counts[value, default: 0] += 1
        }
    }
}
