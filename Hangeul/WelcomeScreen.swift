import SwiftUI

struct WelcomeView: View {
    let startGame: () -> Void

    var body: some View {
        Button(action: startGame) {
            ZStack {
                AppColors.background

                VStack {
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(AppColors.button)
                            Text("한글")
                                .foregroundColor(AppColors.accent)
                                .font(.system(size: UIScreen.screenWidth * 0.28))
                        }
                    }
                    .frame(
                        width: UIScreen.screenWidth * 0.90,
                        height: UIScreen.screenHeight * 0.25
                    )
                    .padding(.bottom, UIScreen.screenHeight * 0.01)

                    HStack {
                        Text("Tap to Start")
                            .foregroundColor(AppColors.accent)
                            .font(.system(size: UIScreen.screenWidth * 0.10))
                            .opacity(0.6)
                    }
                    .padding(.bottom, UIScreen.screenHeight * 0.01)

                    HStack {
                        Text(
                            "Hangeul is the writing system for the Korean language. "
                                + "Consonants and vowels are constructed to like a puzzle to form a letter, "
                                + "and each syllable is represented in each letter.\n\n"
                                + "Tap the correct elements for the letter in the highlighted box and press ‘CONFIRM’"
                        )
                        .foregroundColor(AppColors.secondary)
                        .font(.system(size: UIScreen.screenWidth * 0.05))
                        .multilineTextAlignment(.center)
                        .opacity(0.6)
                    }
                    .padding(.horizontal, UIScreen.screenWidth * 0.05)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Tap to Start")
        .accessibilityIdentifier("start-game")
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(startGame: {})
    }
}
