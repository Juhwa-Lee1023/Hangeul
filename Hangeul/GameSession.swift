import Combine
import Foundation

enum GameRoute: Equatable {
    case welcome
    case playing
    case completed
    case failure(String)
}

final class GameSession: ObservableObject {
    typealias Loader = () throws -> [HangeulWord]

    @Published private(set) var route: GameRoute = .welcome
    @Published private(set) var currentRoundIndex = 0
    @Published private(set) var completedPuzzles: [HangulPuzzle] = []
    @Published private(set) var currentPuzzle: HangulPuzzle?
    @Published private(set) var totalRounds = 0

    private let requestedRoundCount: Int
    private let deterministicSelection: Bool
    private let loader: Loader
    private var allWords: [HangeulWord] = []
    private var puzzles: [HangulPuzzle] = []

    init(
        words: [HangeulWord]? = nil,
        roundCount: Int = 5,
        deterministicSelection: Bool? = nil,
        loader: @escaping Loader = { try WordRepository.load() }
    ) {
        requestedRoundCount = max(1, roundCount)
        self.loader = loader
        self.deterministicSelection =
            deterministicSelection
            ?? ProcessInfo.processInfo.arguments.contains("--ui-testing")

        if let words = words {
            allWords = words
            route = words.isEmpty ? .failure("The problem dataset is empty.") : .welcome
        } else {
            reload()
        }
    }

    func reload() {
        do {
            allWords = try loader()
            resetRoundState()
            route = allWords.isEmpty ? .failure("The problem dataset is empty.") : .welcome
        } catch {
            allWords = []
            resetRoundState()
            route = .failure(error.localizedDescription)
        }
    }

    func startGame() {
        let uniqueWords = wordsWithUniqueSpelling(from: allWords)
        guard !uniqueWords.isEmpty else {
            route = .failure("There are no valid Hangeul words to play.")
            return
        }

        let roundCount = min(requestedRoundCount, uniqueWords.count)
        let selectedWords: [HangeulWord]
        if deterministicSelection {
            selectedWords = Array(uniqueWords.sorted { $0.id < $1.id }.prefix(roundCount))
        } else {
            selectedWords = Array(uniqueWords.shuffled().prefix(roundCount))
        }

        do {
            puzzles = try selectedWords.map { try HangulPuzzle.make(for: $0) }
            currentRoundIndex = 0
            totalRounds = puzzles.count
            completedPuzzles = []
            currentPuzzle = puzzles.first
            route = .playing
        } catch {
            resetRoundState()
            puzzles = []
            route = .failure(error.localizedDescription)
        }
    }

    func completeCurrentPuzzle() {
        guard route == .playing, let currentPuzzle = currentPuzzle else { return }

        completedPuzzles.append(currentPuzzle)
        let nextIndex = currentRoundIndex + 1
        guard puzzles.indices.contains(nextIndex) else {
            self.currentPuzzle = nil
            route = .completed
            return
        }

        currentRoundIndex = nextIndex
        self.currentPuzzle = puzzles[nextIndex]
    }

    private func wordsWithUniqueSpelling(from words: [HangeulWord]) -> [HangeulWord] {
        var seen = Set<String>()
        return words.filter { seen.insert($0.word).inserted }
    }

    private func resetRoundState() {
        currentRoundIndex = 0
        totalRounds = 0
        completedPuzzles = []
        currentPuzzle = nil
        puzzles = []
    }
}
