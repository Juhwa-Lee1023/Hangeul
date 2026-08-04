import SwiftUI

struct RootView: View {
    @StateObject private var session: GameSession
    @StateObject private var audio = AudioService()

    init(session: GameSession = GameSession()) {
        _session = StateObject(wrappedValue: session)
    }

    var body: some View {
        content
            .environmentObject(audio)
    }

    @ViewBuilder
    private var content: some View {
        switch session.route {
        case .welcome:
            WelcomeView(startGame: session.startGame)

        case .playing:
            if let puzzle = session.currentPuzzle {
                PuzzleView(
                    puzzle: puzzle,
                    roundNumber: session.currentRoundIndex + 1,
                    totalRounds: session.totalRounds,
                    completePuzzle: session.completeCurrentPuzzle
                )
                .id(puzzle.word.id)
            } else {
                ErrorStateView(message: "The current puzzle is unavailable.", retry: session.startGame)
            }

        case .completed:
            ClearView(puzzles: session.completedPuzzles, restart: session.startGame)

        case .failure(let message):
            ErrorStateView(message: message, retry: session.reload)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(
            session: GameSession(
                words: [HangeulWord(id: 1, word: "한글", english: "Hangeul", pron: "hangeul")],
                roundCount: 1,
                deterministicSelection: true
            )
        )
    }
}
