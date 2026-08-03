import SwiftUI

struct ClearView: View {
    @EnvironmentObject private var audio: AudioService
    @State private var showsLetters = false

    let puzzles: [HangulPuzzle]
    let restart: () -> Void

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack {
                Spacer()
                successCard
                Spacer()

                if let newestPuzzle = reversedPuzzles.first {
                    solvedWordButton(newestPuzzle.word)
                        .frame(
                            width: UIScreen.screenHeight * 0.23,
                            height: UIScreen.screenHeight * 0.09
                        )
                        .padding(.bottom, UIScreen.screenHeight * 0.015)
                        .padding(.horizontal, UIScreen.screenWidth * 0.05)
                }

                ForEach(pairedPuzzles.indices, id: \.self) { pairIndex in
                    HStack {
                        ForEach(pairedPuzzles[pairIndex], id: \.word.id) { puzzle in
                            solvedWordButton(puzzle.word)
                                .frame(
                                    width: UIScreen.screenWidth * 0.45,
                                    height: UIScreen.screenHeight * 0.09
                                )
                        }

                        if pairedPuzzles[pairIndex].count == 1 {
                            Color.clear
                                .frame(
                                    width: UIScreen.screenWidth * 0.45,
                                    height: UIScreen.screenHeight * 0.09
                                )
                        }
                    }
                    .padding(.bottom, UIScreen.screenHeight * 0.015)
                    .padding(.horizontal, UIScreen.screenWidth * 0.05)
                }

                HStack {
                    PuzzleActionButton(
                        title: "Syllable",
                        systemImage: nil,
                        fill: AppColors.secondary,
                        textOpacity: 0.6
                    ) {
                        showsLetters = true
                    }
                    .frame(
                        width: UIScreen.screenWidth * 0.45,
                        height: UIScreen.screenHeight * 0.058
                    )

                    PuzzleActionButton(
                        title: "Restart",
                        systemImage: nil,
                        fill: AppColors.accent,
                        textOpacity: 0.6,
                        action: restart
                    )
                    .frame(
                        width: UIScreen.screenWidth * 0.45,
                        height: UIScreen.screenHeight * 0.058
                    )
                    .accessibilityIdentifier("restart-game")
                }
                .padding(.bottom, UIScreen.screenHeight * 0.05)
                .padding(.horizontal, UIScreen.screenWidth * 0.05)
            }
        }
        .sheet(isPresented: $showsLetters) {
            LettersView()
                .environmentObject(audio)
        }
    }

    private var reversedPuzzles: [HangulPuzzle] {
        Array(puzzles.reversed())
    }

    private var pairedPuzzles: [[HangulPuzzle]] {
        let remaining = Array(reversedPuzzles.dropFirst())
        return stride(from: 0, to: remaining.count, by: 2).map { start in
            Array(remaining[start..<min(start + 2, remaining.count)])
        }
    }

    private var successCard: some View {
        Button {
            audio.speak("성공")
        } label: {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppColors.button)
                    VStack {
                        Text("성공!")
                            .foregroundColor(AppColors.accent)
                            .font(.system(size: UIScreen.screenWidth * 0.25))
                        Text("(Clear)")
                            .foregroundColor(AppColors.accent)
                            .font(.system(size: UIScreen.screenWidth * 0.10))
                    }
                }
            }
            .frame(
                width: UIScreen.screenWidth * 0.90,
                height: UIScreen.screenHeight * 0.25
            )
            .padding(.bottom, UIScreen.screenHeight * 0.03)
            .padding(.horizontal, UIScreen.screenWidth * 0.05)
        }
        .accessibilityLabel("성공, Clear, listen")
        .accessibilityIdentifier("completion-card")
    }

    private func solvedWordButton(_ word: HangeulWord) -> some View {
        Button {
            audio.speak(word.word)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppColors.button)
                Text(word.word)
                    .foregroundColor(AppColors.buttonText)
                    .font(.system(size: UIScreen.screenWidth * 0.13))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .opacity(0.6)
            }
        }
        .accessibilityLabel("\(word.word), listen")
        .accessibilityIdentifier("solved-word-\(word.id)")
    }
}
