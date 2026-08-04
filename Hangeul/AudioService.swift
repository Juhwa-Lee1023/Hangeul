//
//  AudioService.swift
//  Hangeul
//

import AVFoundation
import Combine
import Foundation
import UIKit

enum Effect: String {
    case success = "clear sound"
    case error = "dding sound"
    case next = "next sound"
}

final class AudioService: ObservableObject {
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var effectPlayer: AVAudioPlayer?

    private var lastSpokenText: String?
    private var lastSpokenAt: Date?

    private let repeatThreshold: TimeInterval = 3
    private let normalSpeechRate: Float = AVSpeechUtteranceDefaultSpeechRate
    private let slowSpeechRate: Float = 0.1

    func play(_ effect: Effect) {
        stopEffect()

        guard let asset = NSDataAsset(name: effect.rawValue) else {
            debugLog("Effect asset '\(effect.rawValue)' was not found. Playback was skipped.")
            return
        }

        do {
            let player = try AVAudioPlayer(data: asset.data)
            effectPlayer = player

            guard player.play() else {
                effectPlayer = nil
                debugLog("AVAudioPlayer could not start effect '\(effect.rawValue)'.")
                return
            }
        } catch {
            effectPlayer = nil
            debugLog(
                "Failed to create AVAudioPlayer for effect '\(effect.rawValue)': \(String(reflecting: error))"
            )
        }
    }

    func speak(_ text: String, language: String = "ko-KR") {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            debugLog("Speech request was ignored because the text was empty or whitespace-only.")
            return
        }

        let now = Date()
        let shouldSpeakSlowly: Bool

        if let lastSpokenText = lastSpokenText, let lastSpokenAt = lastSpokenAt {
            let elapsed = now.timeIntervalSince(lastSpokenAt)
            shouldSpeakSlowly = lastSpokenText == text && elapsed >= 0 && elapsed <= repeatThreshold
        } else {
            shouldSpeakSlowly = false
        }

        lastSpokenText = text
        lastSpokenAt = now

        speechSynthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: text)
        if let voice = AVSpeechSynthesisVoice(language: language) {
            utterance.voice = voice
        } else {
            debugLog(
                "Speech voice for language '\(language)' was not found. The system default voice will be used."
            )
        }
        utterance.rate = shouldSpeakSlowly ? slowSpeechRate : normalSpeechRate
        speechSynthesizer.speak(utterance)
    }

    func stopEffect() {
        effectPlayer?.stop()
        effectPlayer = nil
    }

    func stopSpeech() {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }

    func stopAll() {
        stopEffect()
        stopSpeech()
    }

    deinit {
        effectPlayer?.stop()
        speechSynthesizer.stopSpeaking(at: .immediate)
    }

    private func debugLog(_ message: String) {
        #if DEBUG
            print("[AudioService] \(message)")
        #endif
    }
}
