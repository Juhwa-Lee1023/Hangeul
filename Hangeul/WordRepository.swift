import Foundation

enum WordRepositoryError: LocalizedError, Equatable {
    case missingResource(String)
    case emptyDataset
    case duplicateIdentifier(Int)
    case duplicateWord(String)
    case incompleteWord(Int)
    case unsupportedWord(Int, String)

    var errorDescription: String? {
        switch self {
        case .missingResource(let name):
            return "Could not find \(name) in the app bundle."
        case .emptyDataset:
            return "The problem dataset is empty."
        case .duplicateIdentifier(let identifier):
            return "The problem dataset contains duplicate id \(identifier)."
        case .duplicateWord(let word):
            return "The problem dataset contains the word '\(word)' more than once."
        case .incompleteWord(let identifier):
            return "Word \(identifier) has missing text, meaning, or pronunciation."
        case .unsupportedWord(let identifier, let word):
            return "Word \(identifier) ('\(word)') contains a character that cannot be used in a Hangeul puzzle."
        }
    }
}

enum WordRepository {
    static func load(
        from bundle: Bundle = .main,
        resource name: String = "data.json"
    ) throws -> [HangeulWord] {
        guard let url = bundle.url(forResource: name, withExtension: nil) else {
            throw WordRepositoryError.missingResource(name)
        }

        return try decode(Data(contentsOf: url))
    }

    static func decode(_ data: Data) throws -> [HangeulWord] {
        let words = try JSONDecoder().decode([HangeulWord].self, from: data)
        guard !words.isEmpty else {
            throw WordRepositoryError.emptyDataset
        }

        var identifiers = Set<Int>()
        var spellings = Set<String>()

        for word in words {
            guard identifiers.insert(word.id).inserted else {
                throw WordRepositoryError.duplicateIdentifier(word.id)
            }
            guard spellings.insert(word.word).inserted else {
                throw WordRepositoryError.duplicateWord(word.word)
            }
            guard
                !word.word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                !word.english.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                !word.pron.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else {
                throw WordRepositoryError.incompleteWord(word.id)
            }

            do {
                _ = try HangulDecomposer.decompose(word: word.word)
            } catch {
                throw WordRepositoryError.unsupportedWord(word.id, word.word)
            }
        }

        return words
    }
}
