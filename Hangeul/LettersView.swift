//
//  LettersView.swift
//  Hangeul
//
//  Created by 이주화 on 2022/07/11.
//

import SwiftUI
import AVFoundation

struct LettersView: View {
    
    let consonant : [String] = ["ㄱ", "ㅋ", "ㄲ", "ㄹ", "ㄴ", "ㄷ", "ㅌ", "ㄸ", "ㅁ", "ㅂ", "ㅍ", "ㅃ", "ㅅ", "ㅈ", "ㅊ", "ㅉ", "ㅇ", "ㅎ"]
    let vowel : [String] = ["ㅏ", "ㅑ", "ㅓ", "ㅕ", "ㅗ", "ㅛ", "ㅜ", "ㅠ", "ㅡ", "ㅣ", "ㅔ", "ㅖ", "ㅐ", "ㅒ", "ㅘ", "ㅚ", "ㅝ", "ㅟ", "ㅙ", "ㅞ", "ㅢ"]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        ScrollView{
            ZStack{
                ColorManage.background
                    .ignoresSafeArea()
                VStack{
                    VStack{
                        HStack{
                            Text("Consonants")
                                .foregroundColor(ColorManage.buttontext)
                                .font(.system(size: UIScreen.screenWidth * 0.09))
                                .opacity(0.6)
                            Spacer()
                        }
                        .padding(.top, UIScreen.screenHeight * 0.05 )
                        .padding(.leading, UIScreen.screenWidth * 0.01 )
                        
                        HStack{
                            LazyVGrid(columns: columns) {
                                ForEach(consonant, id: \.self){ i in
                                    LettersBox(letter: i)
                                }
                            }
                        }
                        .padding(.vertical, UIScreen.screenHeight * 0.01 )
                        
                    }
                    VStack{
                        HStack{
                            Text("Vowels")
                                .foregroundColor(ColorManage.buttontext)
                                .font(.system(size: UIScreen.screenWidth * 0.09))
                                .opacity(0.6)
                            Spacer()
                        }
                        .padding(.top, UIScreen.screenHeight * 0.02 )
                        .padding(.leading, UIScreen.screenWidth * 0.01)
                        
                        HStack{
                            LazyVGrid(columns: columns) {
                                ForEach(vowel, id: \.self){ i in
                                    LettersBox(letter: i)
                                }
                            }
                        }
                        .padding(.vertical, UIScreen.screenHeight * 0.01 )
                        .padding(.bottom, UIScreen.screenHeight * 0.02 )
                        
                    }
                    VStack{
                        
                    }
                    .frame(height: UIScreen.screenHeight * 0.3 )
                }
                .padding([.leading, .trailing], UIScreen.screenWidth * 0.05 )
                
                
            }
        }
        
    }
}

struct LettersBox: View{
    
    @ObservedObject var myTimer = MyTimer()
    var letter: String
    let speak = AVSpeechSynthesizer()
    var body: some View{
        Button(action : {
            
            speak.stopSpeaking(at: .immediate)
            let utterence = AVSpeechUtterance(string: letter)
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
                    Text("\(letter)")
                        .foregroundColor(ColorManage.buttontext)
                        .font(.system(size: UIScreen.screenWidth * 0.13))
                        .opacity(0.6)
                }
            }
        }
        .frame(width: UIScreen.screenHeight * 0.09, height: UIScreen.screenHeight * 0.09)
    }
}
