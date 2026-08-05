import SwiftUI

struct PuzzleView: View {
    @EnvironmentObject private var audio: AudioService

    let puzzle: HangulPuzzle
    let roundNumber: Int
    let totalRounds: Int
    let completePuzzle: () -> Void

    @State private var currentSyllableIndex = 0
    @State private var solvedSyllableIndices = Set<Int>()
    @State private var selectedCandidateIndices = Set<Int>()
    @State private var showsMismatchAlert = false
    @State private var isPuzzleComplete = false

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            if usesOriginalLayout {
                puzzleContent
            } else {
                ScrollView(showsIndicators: false) {
                    puzzleContent
                }
            }
        }
        .alert(isPresented: $showsMismatchAlert) {
            Alert(
                title: Text("Didn't Match"),
                message: Text("Please try again."),
                dismissButton: .default(Text("RETRUN"))
            )
        }
    }

    private var usesOriginalLayout: Bool {
        (2...3).contains(puzzle.syllables.count)
            && puzzle.candidates.count == HangulPuzzle.defaultCandidateCount
    }

    private var puzzleContent: some View {
        VStack {
            WordCard(word: puzzle.word.word) {
                audio.speak(puzzle.word.word)
            }

            SyllableProgressRow(
                syllables: puzzle.syllables.map { String($0.character) },
                currentIndex: currentSyllableIndex,
                solvedIndices: solvedSyllableIndices
            ) { index in
                audio.speak(String(puzzle.syllables[index].character))
            }

            instructionRow
            candidateRows
            actionRow
        }
    }

    @ViewBuilder
    private var instructionRow: some View {
        HStack {
            if isPuzzleComplete {
                Button {
                    audio.speak(puzzle.word.word)
                } label: {
                    Text(
                        "\(puzzle.word.word)[\(puzzle.word.pron)] means '\(puzzle.word.english)'."
                    )
                    .foregroundColor(AppColors.buttonText)
                    .font(.system(size: UIScreen.screenWidth * 0.04))
                    .minimumScaleFactor(0.7)
                    .lineLimit(2)
                }
                .accessibilityIdentifier("word-meaning")
            } else {
                Text("Pick all the Lettes for This Box.")
                    .font(.system(size: UIScreen.screenWidth * 0.04))
                    .foregroundColor(AppColors.buttonText)
                    .accessibilityIdentifier("puzzle-instruction")
            }
        }
        .frame(width: UIScreen.screenWidth * 0.90, height: UIScreen.screenHeight * 0.03)
    }

    private var candidateRows: some View {
        VStack {
            ForEach(Array(stride(from: 0, to: puzzle.candidates.count, by: 4)), id: \.self) {
                rowStart in
                HStack {
                    ForEach(0..<4, id: \.self) { offset in
                        let index = rowStart + offset
                        if puzzle.candidates.indices.contains(index) {
                            CandidateTile(
                                value: puzzle.candidates[index],
                                index: index,
                                isSelected: displayedSelectedCandidateIndices.contains(index)
                            ) {
                                toggleCandidate(at: index)
                            }
                            .allowsHitTesting(!isPuzzleComplete)
                            .accessibilityHidden(isPuzzleComplete)
                        } else {
                            Color.clear
                                .frame(
                                    width: UIScreen.screenHeight * 0.09,
                                    height: UIScreen.screenHeight * 0.09
                                )
                        }

                        if offset < 3 {
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, UIScreen.screenWidth * 0.05)
            }
        }
        .padding(.bottom, UIScreen.screenHeight * 0.01)
    }

    private var actionRow: some View {
        HStack {
            if isPuzzleComplete {
                PuzzleActionButton(
                    title: "",
                    systemImage: "speaker.wave.2.fill",
                    fill: AppColors.button,
                    foreground: AppColors.accent
                ) {
                    audio.speak(puzzle.word.word)
                }
                .frame(
                    width: UIScreen.screenWidth * 0.45,
                    height: UIScreen.screenHeight * 0.058
                )
                .accessibilityIdentifier("action-listen")
            } else {
                PuzzleActionButton(
                    title: "CLEAN",
                    systemImage: nil,
                    fill: AppColors.secondary
                ) {
                    selectedCandidateIndices.removeAll()
                }
                .frame(
                    width: UIScreen.screenWidth * 0.45,
                    height: UIScreen.screenHeight * 0.058
                )
                .accessibilityIdentifier("action-clean")
            }

            PuzzleActionButton(
                title: isPuzzleComplete ? "NEXT" : "CONFIRM",
                systemImage: nil,
                fill: isPuzzleComplete ? AppColors.secondary : AppColors.accent
            ) {
                isPuzzleComplete ? goToNextPuzzle() : confirmSelection()
            }
            .frame(
                width: UIScreen.screenWidth * 0.45,
                height: UIScreen.screenHeight * 0.058
            )
            .accessibilityIdentifier(isPuzzleComplete ? "next-puzzle" : "confirm-selection")
        }
        .frame(height: UIScreen.screenHeight * 0.058)
        .padding(.horizontal, UIScreen.screenWidth * 0.05)
    }

    private var displayedSelectedCandidateIndices: Set<Int> {
        guard isPuzzleComplete else {
            return selectedCandidateIndices
        }

        let answerValues = Set(puzzle.syllables.flatMap(\.jamo))
        return Set(puzzle.candidates.indices.filter { answerValues.contains(puzzle.candidates[$0]) })
    }

    private func toggleCandidate(at index: Int) {
        if selectedCandidateIndices.contains(index) {
            selectedCandidateIndices.remove(index)
        } else {
            selectedCandidateIndices.insert(index)
        }
    }

    private func confirmSelection() {
        guard puzzle.syllables.indices.contains(currentSyllableIndex) else { return }

        guard
            puzzle.isCorrect(
                syllableIndex: currentSyllableIndex,
                selectedIndices: selectedCandidateIndices
            )
        else {
            audio.play(.error)
            selectedCandidateIndices.removeAll()
            showsMismatchAlert = true
            return
        }

        let solvedIndex = currentSyllableIndex
        solvedSyllableIndices.insert(solvedIndex)
        selectedCandidateIndices.removeAll()

        let nextIndex = solvedIndex + 1
        if puzzle.syllables.indices.contains(nextIndex) {
            audio.speak(String(puzzle.syllables[solvedIndex].character))
            currentSyllableIndex = nextIndex
        } else {
            isPuzzleComplete = true
            audio.speak(puzzle.word.word)
        }
    }

    private func goToNextPuzzle() {
        audio.play(.next)
        completePuzzle()
    }
}
