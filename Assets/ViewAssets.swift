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
    var text: String
    var body: some View{
        HStack {
            Button(action : {
                let speak = AVSpeechSynthesizer()
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
    
    
    
    
    var body: some View{
        
        HStack{
            Button(action : {
                let utterence = AVSpeechUtterance(string: letterFirst)
                utterence.voice = AVSpeechSynthesisVoice(language: "ko-KR")
                
                let speak = AVSpeechSynthesizer()
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
                        VStack{
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
                        VStack{
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
                
                let speak = AVSpeechSynthesizer()
                if(self.secondTimer.value < 3){
                    utterence.rate = 0.1
                }
                else{
                    utterence.rate = 0.4
                }
                
                speak.speak(utterence)
                self.secondTimer.value = 0
            }){
                ZStack{
                    
                    if check1{
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
                    } else{
                        RoundedRectangle(cornerRadius: 10.0)
                            .fill(ColorManage.button)
                        VStack{
                            Text("\(letterSecond)")
                                .foregroundColor(ColorManage.buttontext)
                                .font(.system(size: UIScreen.screenWidth * 0.13))
                                .opacity(0.6)
                        }
                    }                }
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
    
    var body: some View{
        HStack{
            if check {
                Button(action : {
                    let speak = AVSpeechSynthesizer()
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
                    HStack{
                        
                        Text("\(letterKorea)[\(letterPron)] means '\(letterEnglish)'.")
                            .foregroundColor(ColorManage.buttontext)
                            .font(.system(size: UIScreen.screenWidth * 0.04))
                        
                        
                    }
                }
            } else{
                HStack{
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
            ZStack{
                if check {
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(ColorManage.plus)
                        .opacity(0.6)
                    VStack{
                        Text("\(letter)")
                            .foregroundColor(ColorManage.button)
                            .font(.system(size: UIScreen.screenWidth * 0.13))
                    }
                } else{
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(ColorManage.button)
                    VStack{
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

struct BodyBox: View{
    @ObservedObject var myTimer = MyTimer()
    @Binding var page : Int
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
    

    
    
    let soundplayer = SoundPlayer()
    let sound = AVSpeechSynthesizer()
    
    var body: some View{
        VStack{
            HStack{
                LetterBox(letter: "\(han.stateA[0])", check: $buttonArray[0])
                Spacer()
                LetterBox(letter: "\(han.stateA[1])", check: $buttonArray[1])
                Spacer()
                LetterBox(letter: "\(han.stateA[2])", check: $buttonArray[2])
                Spacer()
                LetterBox(letter: "\(han.stateA[3])", check: $buttonArray[3])
                
            } .padding([.leading, .trailing], UIScreen.screenWidth * 0.05 )
            HStack{
                LetterBox(letter: "\(han.stateA[4])", check: $buttonArray[4])
                Spacer()
                LetterBox(letter: "\(han.stateA[5])", check: $buttonArray[5])
                Spacer()
                LetterBox(letter: "\(han.stateA[6])", check: $buttonArray[6])
                Spacer()
                LetterBox(letter: "\(han.stateA[7])", check: $buttonArray[7])
            }.padding([.leading, .trailing], UIScreen.screenWidth * 0.05 )
            HStack{
                LetterBox(letter: "\(han.stateA[8])", check: $buttonArray[8])
                Spacer()
                LetterBox(letter: "\(han.stateA[9])", check: $buttonArray[9])
                Spacer()
                LetterBox(letter: "\(han.stateA[10])", check: $buttonArray[10])
                Spacer()
                LetterBox(letter: "\(han.stateA[11])", check: $buttonArray[11])
            }.padding([.leading, .trailing], UIScreen.screenWidth * 0.05 )
                .padding(.bottom, UIScreen.screenHeight * 0.01)
            HStack{
                Button( action : {
                    if check2{
                        let utterence = AVSpeechUtterance(string: han.word)
                        utterence.voice = AVSpeechSynthesisVoice(language: "ko-KR")
                        
                        let speak = AVSpeechSynthesizer()
                        if(self.myTimer.value < 3){
                            utterence.rate = 0.1
                        }
                        else{
                            utterence.rate = 0.5
                        }
                        
                        speak.speak(utterence)
                        self.myTimer.value = 0
                    } else{
                        buttonArray = [false, false, false, false, false, false, false, false, false, false, false, false]
                    }
                    
                }){
                    ZStack{
                        if check2{
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(ColorManage.button)
                            VStack{
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundColor(ColorManage.plus)
                                    .font(.system(size: UIScreen.screenWidth * 0.05))
                            }
                        } else{
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(ColorManage.clean)
                            VStack{
                                Text("CLEAN")
                                    .foregroundColor(ColorManage.button)
                                    .font(.system(size: UIScreen.screenWidth * 0.05))
                            }
                        }
                    }
                }.frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.058)
                Button( action : {
                    if check2{
                        soundplayer.next_play()
                        nextView = true
                        page = page + 1
                    }else{
                        if check1 {
                            if ( buttonArray[han.secondSolf] == true && buttonArray[han.secondSols] == true && buttonArray[han.secondSolt] == true ){
                                var firstArray = [false, false, false, false, false, false, false, false, false, false, false, false, true]
                                firstArray[han.secondSolf] = true
                                firstArray[han.secondSols] = true
                                firstArray[han.secondSolt] = true
                                if(buttonArray == firstArray){
                                    check2 = true
                                    buttonArray = [false, false, false, false, false, false, false, false, false, false, false, false, true]
                                    buttonArray[han.firstSolf] = true
                                    buttonArray[han.firstSols] = true
                                    buttonArray[han.firstSolt] = true
                                    buttonArray[han.secondSolf] = true
                                    buttonArray[han.secondSols] = true
                                    buttonArray[han.secondSolt] = true
                                    clearAlert = true
                                    let utterence = AVSpeechUtterance(string: han.word)
                                    utterence.voice = AVSpeechSynthesisVoice(language: "ko-KR")
                                    utterence.rate = 0.4
                                    let speak = AVSpeechSynthesizer()
                                    speak.speak(utterence)
                                }else{
                                    showAlert.toggle()
                                    soundplayer.dding_play()
                                    buttonArray = [false, false, false, false, false, false, false, false, false, false, false, false, true]
                                }
                                
                            } else{
                                showAlert.toggle()
                                soundplayer.dding_play()
                                buttonArray = [false, false, false, false, false, false, false, false, false, false, false, false, true]
                            }
                        } else {
                            if ( buttonArray[han.firstSolf] == true && buttonArray[han.firstSols] == true && buttonArray[han.firstSolt] ){
                                
                                var firstArray = [false, false, false, false, false, false, false, false, false, false, false, false, true]
                                firstArray[han.firstSolf] = true
                                firstArray[han.firstSols] = true
                                firstArray[han.firstSolt] = true
                                if(buttonArray == firstArray){
                                    check1 = true
                                    let utterence = AVSpeechUtterance(string: letterFirst)
                                    utterence.voice = AVSpeechSynthesisVoice(language: "ko-KR")
                                    utterence.rate = 0.4
                                    let speak = AVSpeechSynthesizer()
                                    speak.speak(utterence)
                                    buttonArray = [false, false, false, false, false, false, false, false, false, false, false, false, true]
                                }else{
                                    showAlert.toggle()
                                    buttonArray = [false, false, false, false, false, false, false, false, false, false, false, false, true]
                                    soundplayer.dding_play()
                                }
                                
                            } else{
                                showAlert.toggle()
                                buttonArray = [false, false, false, false, false, false, false, false, false, false, false, false, true]
                                soundplayer.dding_play()
                            }
                        }
                    }
                    
                }){
                    ZStack{
                        if check2 {
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(ColorManage.clean)
                            VStack{
                                Text("NEXT")
                                    .foregroundColor(ColorManage.button)
                                    .font(.system(size: UIScreen.screenWidth * 0.05))
                            }
                        } else{
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(ColorManage.plus)
                            VStack{
                                Text("CONFIRM")
                                    .foregroundColor(ColorManage.button)
                                    .font(.system(size: UIScreen.screenWidth * 0.05))
                            }
                        }
                    }
                }.frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.058)
            }
            .padding([.leading, .trailing], UIScreen.screenWidth * 0.05 )
        }
        
    }
        
    
    
}

struct ColorManage{
    static let background = Color("background")
    static let button = Color("button")
    static let buttontext = Color("buttontext")
    static let plus = Color("plus")
    static let clean = Color("clean")
}

extension UIScreen{
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}

enum letter {
    
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

//
//struct BodyBox: View{
//    @Binding var page : Int
//
//    @State var text: String
//    @State var letterFirst: String
//    @Binding var check1: Bool
//    @Binding var check2: Bool
//    @Binding var nextView: Bool
//    @Binding var clearAlert: Bool
//    @Binding var showAlert: Bool
//    @State var buttonArray: [Bool] = [false, false, false, false, false, false, false, false, false, false, false, false, true]
//    @State var letterArray: [String]
//    @State var firstSolf: Int
//    @State var firstSols: Int
//    @State var firstSolt: Int
//    @State var secondSolf: Int
//    @State var secondSols: Int
//    @State var secondSolt: Int
//
//
//    let soundplayer = SoundPlayer()
//    let sound = AVSpeechSynthesizer()
//
//    var body: some View{
//        HStack{
//            LetterBox(letter: "\(letterArray[0])", check: $buttonArray[0])
//            Spacer()
//            LetterBox(letter: "\(letterArray[1])", check: $buttonArray[1])
//            Spacer()
//            LetterBox(letter: "\(letterArray[2])", check: $buttonArray[2])
//            Spacer()
//            LetterBox(letter: "\(letterArray[3])", check: $buttonArray[3])
//
//        } .padding([.leading, .trailing], UIScreen.screenWidth * 0.05 )
//        HStack{
//            LetterBox(letter: "\(letterArray[4])", check: $buttonArray[4])
//            Spacer()
//            LetterBox(letter: "\(letterArray[5])", check: $buttonArray[5])
//            Spacer()
//            LetterBox(letter: "\(letterArray[6])", check: $buttonArray[6])
//            Spacer()
//            LetterBox(letter: "\(letterArray[7])", check: $buttonArray[7])
//        }.padding([.leading, .trailing], UIScreen.screenWidth * 0.05 )
//        HStack{
//            LetterBox(letter: "\(letterArray[8])", check: $buttonArray[8])
//            Spacer()
//            LetterBox(letter: "\(letterArray[9])", check: $buttonArray[9])
//            Spacer()
//            LetterBox(letter: "\(letterArray[10])", check: $buttonArray[10])
//            Spacer()
//            LetterBox(letter: "\(letterArray[11])", check: $buttonArray[11])
//        }.padding([.leading, .trailing], UIScreen.screenWidth * 0.05 )
//            .padding(.bottom, UIScreen.screenHeight * 0.01)
//        HStack{
//            Button( action : {
//                if check2{
//                    let utterence = AVSpeechUtterance(string: text)
//                    utterence.voice = AVSpeechSynthesisVoice(language: "ko-KR")
//                    utterence.rate = 0.4
//                    let speak = AVSpeechSynthesizer()
//                    speak.speak(utterence)
//                } else{
//                    buttonArray = [false, false, false, false, false, false, false, false, false, false, false, false]
//                }
//
//            }){
//                ZStack{
//                    if check2{
//                        RoundedRectangle(cornerRadius: 10.0)
//                            .fill(ColorManage.button)
//                        VStack{
//                            Image(systemName: "speaker.wave.2.fill")
//                                .foregroundColor(ColorManage.plus)
//                                .font(.system(size: UIScreen.screenWidth * 0.05))
//                        }
//                    } else{
//                        RoundedRectangle(cornerRadius: 10.0)
//                            .fill(ColorManage.clean)
//                        VStack{
//                            Text("CLEAN")
//                                .foregroundColor(ColorManage.button)
//                                .font(.system(size: UIScreen.screenWidth * 0.05))
//                        }
//                    }
//                }
//            }.frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.058)
//            Button( action : {
//                if check2{
//                    soundplayer.next_play()
//                    nextView = true
//                    page = page + 1
//                }else{
//                    if check1 {
//                        if ( buttonArray[secondSolf] == true && buttonArray[secondSols] == true && buttonArray[secondSolt] == true ){
//                            check2 = true
//                            buttonArray[firstSolf] = true
//                            buttonArray[firstSols] = true
//                            buttonArray[firstSolt] = true
//                            clearAlert = true
//                            let utterence = AVSpeechUtterance(string: text)
//                            utterence.voice = AVSpeechSynthesisVoice(language: "ko-KR")
//                            utterence.rate = 0.4
//                            let speak = AVSpeechSynthesizer()
//                            speak.speak(utterence)
//                        } else{
//                            showAlert.toggle()
//                            soundplayer.dding_play()
//                            buttonArray = [false, false, false, false, false, false, false, false, false, false, false, false, true]
//                        }
//                    } else {
//                        if ( buttonArray[firstSolf] == true && buttonArray[firstSols]  == true && buttonArray[firstSolt] == true ){
//                            check1 = true
//                            let utterence = AVSpeechUtterance(string: letterFirst)
//                            utterence.voice = AVSpeechSynthesisVoice(language: "ko-KR")
//                            utterence.rate = 0.4
//                            let speak = AVSpeechSynthesizer()
//                            speak.speak(utterence)
//                            buttonArray = [false, false, false, false, false, false, false, false, false, false, false, false, true]
//                        } else{
//                            showAlert.toggle()
//                            buttonArray = [false, false, false, false, false, false, false, false, false, false, false, false, true]
//                            soundplayer.dding_play()
//                        }
//                    }
//                }
//
//            }){
//                ZStack{
//                    if check2 {
//                        RoundedRectangle(cornerRadius: 10.0)
//                            .fill(ColorManage.clean)
//                        VStack{
//                            Text("NEXT")
//                                .foregroundColor(ColorManage.button)
//                                .font(.system(size: UIScreen.screenWidth * 0.05))
//                        }
//                    } else{
//                        RoundedRectangle(cornerRadius: 10.0)
//                            .fill(ColorManage.plus)
//                        VStack{
//                            Text("CONFIRM")
//                                .foregroundColor(ColorManage.button)
//                                .font(.system(size: UIScreen.screenWidth * 0.05))
//                        }
//                    }
//                }
//            }.frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.058)
//        }
//        .padding([.leading, .trailing], UIScreen.screenWidth * 0.05 )
//    }
//
//}
