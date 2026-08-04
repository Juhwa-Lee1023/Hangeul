import SwiftUI

struct LettersView: View {
    @EnvironmentObject private var audio: AudioService

    private let consonants = [
        "ㄱ", "ㅋ", "ㄲ", "ㄹ", "ㄴ", "ㄷ", "ㅌ", "ㄸ", "ㅁ", "ㅂ", "ㅍ", "ㅃ", "ㅅ", "ㅈ", "ㅊ", "ㅉ",
        "ㅇ", "ㅎ",
    ]
    private let vowels = [
        "ㅏ", "ㅑ", "ㅓ", "ㅕ", "ㅗ", "ㅛ", "ㅜ", "ㅠ", "ㅡ", "ㅣ", "ㅔ", "ㅖ", "ㅐ", "ㅒ", "ㅘ", "ㅚ",
        "ㅝ", "ㅟ", "ㅙ", "ㅞ", "ㅢ",
    ]
    private let columns = Array(repeating: GridItem(.flexible()), count: 4)

    var body: some View {
        ScrollView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                VStack {
                    letterSection(
                        title: "Consonants",
                        letters: consonants,
                        topPadding: UIScreen.screenHeight * 0.05,
                        bottomPadding: 0
                    )

                    letterSection(
                        title: "Vowels",
                        letters: vowels,
                        topPadding: UIScreen.screenHeight * 0.02,
                        bottomPadding: UIScreen.screenHeight * 0.02
                    )

                    VStack {}
                        .frame(height: UIScreen.screenHeight * 0.30)
                }
                .padding(.horizontal, UIScreen.screenWidth * 0.05)
            }
        }
    }

    private func letterSection(
        title: String,
        letters: [String],
        topPadding: CGFloat,
        bottomPadding: CGFloat
    ) -> some View {
        VStack {
            HStack {
                Text(title)
                    .foregroundColor(AppColors.buttonText)
                    .font(.system(size: UIScreen.screenWidth * 0.09))
                    .opacity(0.6)
                Spacer()
            }
            .padding(.top, topPadding)
            .padding(.leading, UIScreen.screenWidth * 0.01)

            HStack {
                LazyVGrid(columns: columns) {
                    ForEach(Array(letters.enumerated()), id: \.offset) { index, letter in
                        Button {
                            audio.speak(letter)
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppColors.button)
                                Text(letter)
                                    .foregroundColor(AppColors.buttonText)
                                    .font(.system(size: UIScreen.screenWidth * 0.13))
                                    .opacity(0.6)
                            }
                        }
                        .frame(
                            width: UIScreen.screenHeight * 0.09,
                            height: UIScreen.screenHeight * 0.09
                        )
                        .accessibilityLabel("Listen to \(letter)")
                        .accessibilityIdentifier("syllable-\(title.lowercased())-\(index)")
                    }
                }
            }
            .padding(.vertical, UIScreen.screenHeight * 0.01)
            .padding(.bottom, bottomPadding)
        }
    }
}
