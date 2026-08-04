import SwiftUI
import UIKit

enum AppColors {
    static let background = Color("background")
    static let button = Color("button")
    static let buttonText = Color("buttontext")
    static let accent = Color("plus")
    static let secondary = Color("clean")
}

extension UIScreen {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
}

struct WordCard: View {
    let word: String
    let action: () -> Void

    var body: some View {
        HStack {
            Button(action: action) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppColors.button)

                    Text(word)
                        .foregroundColor(AppColors.accent)
                        .font(.system(size: UIScreen.screenWidth * 0.28))
                        .minimumScaleFactor(0.35)
                        .lineLimit(2)
                        .allowsTightening(true)
                        .padding()

                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(AppColors.buttonText)
                                .font(.system(size: UIScreen.screenWidth * 0.06))
                                .padding([.bottom, .trailing], UIScreen.screenHeight * 0.01)
                        }
                    }
                }
            }
            .accessibilityLabel("Listen to \(word)")
            .accessibilityIdentifier("word-audio")
        }
        .frame(width: UIScreen.screenWidth * 0.90, height: UIScreen.screenHeight * 0.25)
        .padding(.bottom, UIScreen.screenHeight * 0.03)
    }
}

struct SyllableProgressRow: View {
    let syllables: [String]
    let currentIndex: Int
    let solvedIndices: Set<Int>
    let action: (Int) -> Void

    var body: some View {
        Group {
            if syllables.count <= 2 {
                HStack {
                    tiles
                }
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            tiles
                        }
                        .frame(minWidth: UIScreen.screenWidth * 0.90)
                    }
                    .frame(width: UIScreen.screenWidth * 0.90)
                    .onChange(of: currentIndex) { index in
                        withAnimation {
                            proxy.scrollTo(index, anchor: .center)
                        }
                    }
                }
            }
        }
        .frame(height: UIScreen.screenHeight * 0.09)
    }

    @ViewBuilder
    private var tiles: some View {
        ForEach(syllables.indices, id: \.self) { index in
            Button {
                action(index)
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppColors.button)

                    if index == currentIndex && !solvedIndices.contains(index) {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(AppColors.accent, lineWidth: 3)
                            .opacity(0.5)
                    }

                    Text(syllables[index])
                        .foregroundColor(
                            solvedIndices.contains(index) ? AppColors.accent : AppColors.buttonText
                        )
                        .font(.system(size: UIScreen.screenWidth * 0.13))
                        .opacity(0.6)
                }
            }
            .frame(width: UIScreen.screenHeight * 0.09, height: UIScreen.screenHeight * 0.09)
            .accessibilityLabel(accessibilityLabel(at: index))
            .id(index)
        }
    }

    private func accessibilityLabel(at index: Int) -> String {
        if solvedIndices.contains(index) {
            return "Solved syllable \(syllables[index]), listen"
        }
        if index == currentIndex {
            return "Current syllable \(syllables[index]), listen"
        }
        return "Pending syllable \(syllables[index]), listen"
    }
}

struct CandidateTile: View {
    let value: String
    let index: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? AppColors.accent.opacity(0.6) : AppColors.button)

                Text(value)
                    .foregroundColor(isSelected ? AppColors.button : AppColors.buttonText.opacity(0.6))
                    .font(.system(size: UIScreen.screenWidth * 0.13))
            }
        }
        .frame(width: UIScreen.screenHeight * 0.09, height: UIScreen.screenHeight * 0.09)
        .accessibilityLabel("\(value), tile \(index + 1)")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityIdentifier("candidate-\(index)")
    }
}

struct PuzzleActionButton: View {
    let title: String
    let systemImage: String?
    let fill: Color
    var foreground: Color = AppColors.button
    var textOpacity = 1.0
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(fill)

                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .foregroundColor(foreground)
                        .font(.system(size: UIScreen.screenWidth * 0.05))
                } else {
                    Text(title)
                        .foregroundColor(foreground)
                        .font(.system(size: UIScreen.screenWidth * 0.05))
                        .opacity(textOpacity)
                }
            }
        }
    }
}

struct ErrorStateView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            VStack(spacing: UIScreen.screenHeight * 0.02) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: UIScreen.screenWidth * 0.12))
                    .foregroundColor(AppColors.accent)
                Text("Unable to load the puzzle")
                    .font(.system(size: UIScreen.screenWidth * 0.06))
                    .foregroundColor(AppColors.buttonText)
                Text(message)
                    .font(.system(size: UIScreen.screenWidth * 0.04))
                    .foregroundColor(AppColors.buttonText)
                    .multilineTextAlignment(.center)
                PuzzleActionButton(
                    title: "RETRY",
                    systemImage: nil,
                    fill: AppColors.accent,
                    action: retry
                )
                .frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.058)
            }
            .padding(.horizontal, UIScreen.screenWidth * 0.05)
        }
    }
}
