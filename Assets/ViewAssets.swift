//
//  ViewAssets.swift
//  Hangeul
//
//  Created by 이주화 on 2022/04/27.
//

import SwiftUI
import Foundation
import UIKit
import AVFoundation

struct hangeul: Identifiable, Decodable{
    var id: Int
    var word: String
    var english: String
    var pron: String
    var firstSolf: Int
    var firstSols: Int
    var firstSolt: Int
    var secondSolf: Int
    var secondSols: Int
    var secondSolt: Int
    var stateA: [String]
}

class MyTimer: ObservableObject {
    @Published var value: Int = 0
    
    init() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.value += 1
        }
    }
}


struct MainBox : View{
    @ObservedObject var myTimer = MyTimer()
    let speak = AVSpeechSynthesizer()
    var text: String
    var body: some View{
        HStack {
            Button(action : {
                speak.stopSpeaking(at: .immediate)
                let utterence = AVSpeechUtterance(string: text)
                utterence.voice = AVSpeechSynthesisVoice(language: "ko-KR")
                if(self.myTimer.value < 3){
                    utterence.rate = 0.1
                }
                else{
                    utterence.rate = 0.5
                }
                
                speak.speak(utterence)
                self.myTimer.value = 0

            }){
                ZStack{
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(ColorManage.button)
                    VStack{
                        Text("\(text)")
                            .foregroundColor(ColorManage.plus)
                            .font(.system(size: UIScreen.screenWidth * 0.28))
                    }
                    VStack{
                        Spacer()
                        HStack{
                            Spacer()
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(ColorManage.buttontext)
                                .font(.system(size: UIScreen.screenWidth * 0.06))
                                .padding([.bottom, .trailing], UIScreen.screenHeight * 0.01)
                        }
                    }
                }
            }
        }.frame(width: UIScreen.screenWidth * 0.90, height: UIScreen.screenHeight * 0.25)
            .padding(.bottom, UIScreen.screenHeight * 0.03)
    }
}


struct SolBox: View{
    @ObservedObject var firstTimer = MyTimer()
    @ObservedObject var secondTimer = MyTimer()
    var letterFirst: String = ""
    var letterSecond: String = ""
    @Binding var check1: Bool
    @Binding var check2: Bool
    let speak = AVSpeechSynthesizer()

    var body: some View{
        HStack{
            Button(action : {
                let utterence = AVSpeechUtterance(string: letterFirst)
                utterence.voice = AVSpeechSynthesisVoice(language: "ko-KR")
                if(self.firstTimer.value < 3){
                    utterence.rate = 0.1
                }
                else{
                    utterence.rate = 0.4
                }
                speak.speak(utterence)
                self.firstTimer.value = 0
            }){
                ZStack{
                    if check1 {
                        RoundedRectangle(cornerRadius: 10.0)
                            .fill(ColorManage.button)
                        VStack {
                            Text("\(letterFirst)")
                                .foregroundColor(ColorManage.plus)
                                .font(.system(size: UIScreen.screenWidth * 0.13))
                                .opacity(0.6)
                        }
                    } else {
                        RoundedRectangle(cornerRadius: 10.0)
                            .fill(ColorManage.button)
                        RoundedRectangle(cornerRadius: 10.0)
                            .stroke(ColorManage.plus, lineWidth: 3)
                            .opacity(0.5)
                        VStack {
                            Text("\(letterFirst)")
                                .foregroundColor(ColorManage.buttontext)
                                .font(.system(size: UIScreen.screenWidth * 0.13))
                                .opacity(0.6)
                        }
                        
                    }
                    
                }
            } .frame(width: UIScreen.screenHeight * 0.09, height: UIScreen.screenHeight * 0.09)
            
            Button(action : {
                let utterence = AVSpeechUtterance(string: letterSecond)
                utterence.voice = AVSpeechSynthesisVoice(language: "ko-KR")
                
                if(self.secondTimer.value < 3){
                    utterence.rate = 0.1
                }
                else{
                    utterence.rate = 0.4
                }
                
                speak.speak(utterence)
                self.secondTimer.value = 0
            }){
                ZStack {
                    if check1 {
                        if check2 {
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(ColorManage.button)
                            VStack{
                                Text("\(letterSecond)")
                                    .foregroundColor(ColorManage.plus)
                                    .font(.system(size: UIScreen.screenWidth * 0.13))
                                    .opacity(0.6)
                            }
                        } else{
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(ColorManage.button)
                            RoundedRectangle(cornerRadius: 10.0)
                                .stroke(ColorManage.plus, lineWidth: 3)
                                .opacity(0.5)
                            VStack{
                                Text("\(letterSecond)")
                                    .foregroundColor(ColorManage.buttontext)
                                    .font(.system(size: UIScreen.screenWidth * 0.13))
                                    .opacity(0.6)
                            }
                        }
                    } else {
                        RoundedRectangle(cornerRadius: 10.0)
                            .fill(ColorManage.button)
                        VStack{
                            Text("\(letterSecond)")
                                .foregroundColor(ColorManage.buttontext)
                                .font(.system(size: UIScreen.screenWidth * 0.13))
                                .opacity(0.6)
                        }
                    }
                }
            }.frame(width: UIScreen.screenHeight * 0.09, height: UIScreen.screenHeight * 0.09)
        }
    }
}

struct EditBox: View{
    let text: String
    var letterKorea: String
    var letterEnglish: String
    var letterPron : String
    @ObservedObject var myTimer = MyTimer()
    let soundplayer = SoundPlayer()
    @Binding var check: Bool
    let speak = AVSpeechSynthesizer()
    
    var body: some View{
        HStack {
            if check {
                Button(action : {
                    speak.stopSpeaking(at: .immediate)
                    let utterence = AVSpeechUtterance(string: text)
                    utterence.voice = AVSpeechSynthesisVoice(language: "ko-KR")

                    if(self.myTimer.value < 3){
                        utterence.rate = 0.1
                    }
                    else{
                        utterence.rate = 0.5
                    }

                    speak.speak(utterence)
                    self.myTimer.value = 0
                }){
                    HStack {
                        Text("\(letterKorea)[\(letterPron)] means '\(letterEnglish)'.")
                            .foregroundColor(ColorManage.buttontext)
                            .font(.system(size: UIScreen.screenWidth * 0.04))
                    }
                }
            } else{
                HStack {
                    Text("Pick all the Lettes for This Box.")
                        .font(.system(size: UIScreen.screenWidth * 0.04))
                        .foregroundColor(ColorManage.buttontext)
                }
            }
        }.frame(width: UIScreen.screenWidth * 0.90, height: UIScreen.screenHeight * 0.03)
    }
}

struct LetterBox: View{
    var letter: String
    @Binding var check: Bool
    
    var body: some View{
        Button(action : {
            check.toggle()
        }){
            ZStack {
                if check {
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(ColorManage.plus)
                        .opacity(0.6)
                    VStack {
                        Text("\(letter)")
                            .foregroundColor(ColorManage.button)
                            .font(.system(size: UIScreen.screenWidth * 0.13))
                    }
                } else {
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(ColorManage.button)
                    VStack {
                        Text("\(letter)")
                            .foregroundColor(ColorManage.buttontext)
                            .font(.system(size: UIScreen.screenWidth * 0.13))
                            .opacity(0.6)
                    }
                }
            }
        }.frame(width: UIScreen.screenHeight * 0.09, height: UIScreen.screenHeight * 0.09)
    }
}

struct BodyBox: View {
    @ObservedObject var myTimer = MyTimer()
    @Binding var page: Int
    @Binding var han: hangeul
    @State var text: String
    let letterFirst: String
    @Binding var check1: Bool
    @Binding var check2: Bool
    @Binding var nextView: Bool
    @Binding var clearAlert: Bool
    @Binding var showAlert: Bool
    @State var buttonArray: [Bool] = [false, false, false, false, false, false, false, false, false, false, false, false, true]
    @State var letterArray: [String]
    @State var secondArray = [false, false, false, false, false, false, false, false, false, false, false, false, true]
    let speak = AVSpeechSynthesizer()
    let soundplayer = SoundPlayer()
    let sound = AVSpeechSynthesizer()
    
    var body: some View {
        VStack {
            HStack {
                ForEach(0..<4) { index in
                    if han.stateA.indices.contains(index) {
                        LetterBox(letter: "\(han.stateA[index])", check: $buttonArray[index])
                    }
                    if index < 3 { Spacer() }
                }
            }
            .padding([.leading, .trailing], UIScreen.screenWidth * 0.05 )
            HStack {
                ForEach(4..<8) { index in
                    if han.stateA.indices.contains(index) {
                        LetterBox(letter: "\(han.stateA[index])", check: $buttonArray[index])
                    }
                    if index < 7 { Spacer() }
                }
            }
            .padding([.leading, .trailing], UIScreen.screenWidth * 0.05 )
            HStack {
                ForEach(8..<12) { index in
                    if han.stateA.indices.contains(index) {
                        LetterBox(letter: "\(han.stateA[index])", check: $buttonArray[index])
                    }
                    if index < 11 { Spacer() }
                }
            }
            .padding([.leading, .trailing], UIScreen.screenWidth * 0.05 )
            .padding(.bottom, UIScreen.screenHeight * 0.01)
            HStack {
                Button(action: {
                    if check2 {
                        let utterance = AVSpeechUtterance(string: han.word)
                        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
                        
                        if self.myTimer.value < 3 {
                            utterance.rate = 0.1
                        } else {
                            utterance.rate = 0.5
                        }
                        
                        speak.speak(utterance)
                        self.myTimer.value = 0
                    } else {
                        buttonArray = [false, false, false, false, false, false, false, false, false, false, false, false]
                    }
                }) {
                    ZStack {
                        if check2 {
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(ColorManage.button)
                            VStack {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundColor(ColorManage.plus)
                                    .font(.system(size: UIScreen.screenWidth * 0.05))
                            }
                        } else {
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(ColorManage.clean)
                            VStack {
                                Text("CLEAN")
                                    .foregroundColor(ColorManage.button)
                                    .font(.system(size: UIScreen.screenWidth * 0.05))
                            }
                        }
                    }
                }
                .frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.058)
                Button(action: {
                    if check2 {
                        soundplayer.next_play()
                        nextView = true
                        page = page + 1
                    } else {
                        handleConfirmAction()
                    }
                }) {
                    ZStack {
                        if check2 {
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(ColorManage.clean)
                            VStack {
                                Text("NEXT")
                                    .foregroundColor(ColorManage.button)
                                    .font(.system(size: UIScreen.screenWidth * 0.05))
                            }
                        } else {
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(ColorManage.plus)
                            VStack {
                                Text("CONFIRM")
                                    .foregroundColor(ColorManage.button)
                                    .font(.system(size: UIScreen.screenWidth * 0.05))
                            }
                        }
                    }
                }
                .frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.058)
            }
            .padding([.leading, .trailing], UIScreen.screenWidth * 0.05 )
        }
    }
    
    func handleConfirmAction() {
        if check1 {
            if isValidSelection(solf: han.secondSolf, sols: han.secondSols, solt: han.secondSolt) {
                if isMatchingSelection(solf: han.secondSolf, sols: han.secondSols, solt: han.secondSolt) {
                    check2 = true
                    updateButtonArray()
                    clearAlert = true
                    speakWord(han.word)
                } else {
                    showMismatchAlert()
                }
            } else {
                showMismatchAlert()
            }
        } else {
            if isValidSelection(solf: han.firstSolf, sols: han.firstSols, solt: han.firstSolt) {
                if isMatchingSelection(solf: han.firstSolf, sols: han.firstSols, solt: han.firstSolt) {
                    check1 = true
                    speakWord(letterFirst)
                    resetButtonArray()
                } else {
                    showMismatchAlert()
                }
            } else {
                showMismatchAlert()
            }
        }
    }
    
    func isValidSelection(solf: Int, sols: Int, solt: Int) -> Bool {
        return buttonArray.indices.contains(solf) && buttonArray.indices.contains(sols) && buttonArray.indices.contains(solt) &&
               buttonArray[solf] == true && buttonArray[sols] == true && buttonArray[solt] == true
    }
    
    func isMatchingSelection(solf: Int, sols: Int, solt: Int) -> Bool {
        var firstArray = [false, false, false, false, false, false, false, false, false, false, false, false, true]
        firstArray[solf] = true
        firstArray[sols] = true
        firstArray[solt] = true
        return buttonArray == firstArray
    }
    
    func updateButtonArray() {
        buttonArray = [false, false, false, false, false, false, false, false, false, false, false, false, true]
        buttonArray[han.firstSolf] = true
        buttonArray[han.firstSols] = true
        buttonArray[han.firstSolt] = true
        buttonArray[han.secondSolf] = true
        buttonArray[han.secondSols] = true
        buttonArray[han.secondSolt] = true
    }
    
    func resetButtonArray() {
        buttonArray = [false, false, false, false, false, false, false, false, false, false, false, false, true]
    }
    
    func speakWord(_ word: String) {
        let utterance = AVSpeechUtterance(string: word)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        utterance.rate = 0.4
        speak.speak(utterance)
    }
    
    func showMismatchAlert() {
        showAlert.toggle()
        soundplayer.dding_play()
        resetButtonArray()
    }
}

struct ColorManage {
    static let background = Color("background")
    static let button = Color("button")
    static let buttontext = Color("buttontext")
    static let plus = Color("plus")
    static let clean = Color("clean")
}

extension UIScreen {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}

class TTS: NSObject {
    let speech = AVSpeechSynthesizer()
    var voice: AVSpeechSynthesisVoice!
    var utterance: AVSpeechUtterance!
    
    override init() {
        super.init()
    }
    
    func setText(_ s: String) {
        utterance = AVSpeechUtterance(string: s)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        speakVoice()
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: .allowBluetooth)
    }
    
    func speakVoice() {
        speech.speak(utterance)
    }
}
