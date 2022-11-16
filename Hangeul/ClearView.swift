//
//  ClearView.swift
//  Hangeul
//
//  Created by 이주화 on 2022/04/26.
//

import SwiftUI
import AVFoundation

struct ClearView: View {
    @ObservedObject var Timer = MyTimer()
    @ObservedObject var Timer1 = MyTimer()
    @ObservedObject var Timer2 = MyTimer()
    @ObservedObject var Timer3 = MyTimer()
    @ObservedObject var Timer4 = MyTimer()
    @ObservedObject var Timer5 = MyTimer()
    @Binding var page : Int
    @State private var showAlert = false
    @State private var clearAlert = false
    @State var nextView = false
    @Binding var num: [Int]
    let soundplayer = SoundPlayer()
    @State var showModal = false
    let speak = AVSpeechSynthesizer()
    
    var body: some View {
        ZStack{
            ColorManage.background
                .ignoresSafeArea()
            VStack{
                Button(action : {
                    let utterence = AVSpeechUtterance(string: "성공")
                    utterence.voice = AVSpeechSynthesisVoice(language: "ko-KR")
                    if(self.Timer.value < 3){
                        utterence.rate = 0.1
                    }
                    else{
                        utterence.rate = 0.5
                    }
                    
                    speak.speak(utterence)
                    self.Timer.value = 0
                }){
                    HStack{
                        ZStack{
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(ColorManage.button)
                            VStack{
                                Text("성공!")
                                    .foregroundColor(ColorManage.plus)
                                    .font(.system(size: UIScreen.screenWidth * 0.25))
                                Text("(Clear)")
                                    .foregroundColor(ColorManage.plus)
                                    .font(.system(size: UIScreen.screenWidth * 0.1))
                            }
                        }
                    }
                    .frame(width: UIScreen.screenWidth * 0.90, height: UIScreen.screenHeight * 0.25)
                    .padding(.bottom, UIScreen.screenHeight * 0.03)
                    .padding([.leading, .trailing], UIScreen.screenWidth * 0.05 )
                }
                
                
                HStack{
                    Button(action : {
                        let utterence = AVSpeechUtterance(string: hangeuls[num[4]].word)
                        utterence.voice = AVSpeechSynthesisVoice(language: "ko-KR")
                        if(self.Timer1.value < 3) {
                            utterence.rate = 0.1
                        }
                        else {
                            utterence.rate = 0.5
                        }
                        
                        speak.speak(utterence)
                        self.Timer1.value = 0
                    }){
                        ZStack{
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(ColorManage.button)
                            VStack{
                                if num.count > 4 {
                                    Text("\(hangeuls[num[4]].word)")
                                        .foregroundColor(ColorManage.buttontext)
                                        .font(.system(size: UIScreen.screenWidth * 0.13))
                                        .opacity(0.6)
                                }
                            }
                        }
                    }
                    .frame(width: UIScreen.screenHeight * 0.23, height: UIScreen.screenHeight * 0.09)
                }
                .padding(.bottom, UIScreen.screenHeight * 0.015)
                .padding([.leading, .trailing], UIScreen.screenWidth * 0.05 )
                HStack{
                    Button(action : {
                        let utterence = AVSpeechUtterance(string: hangeuls[num[3]].word)
                        utterence.voice = AVSpeechSynthesisVoice(language: "ko-KR")
                        if(self.Timer2.value < 3){
                            utterence.rate = 0.1
                        }
                        else{
                            utterence.rate = 0.5
                        }
                        
                        speak.speak(utterence)
                        self.Timer2.value = 0
                    }){
                        ZStack{
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(ColorManage.button)
                            VStack{
                                if num.count > 4 {
                                    Text("\(hangeuls[num[3]].word)")
                                        .foregroundColor(ColorManage.buttontext)
                                        .font(.system(size: UIScreen.screenWidth * 0.13))
                                        .opacity(0.6)
                                }
                            }
                        }
                    }
                    .frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.09)
                    Button(action : {
                        let utterence = AVSpeechUtterance(string: hangeuls[num[2]].word)
                        utterence.voice = AVSpeechSynthesisVoice(language: "ko-KR")
                        if(self.Timer3.value < 3) {
                            utterence.rate = 0.1
                        }
                        else {
                            utterence.rate = 0.5
                        }
                        
                        speak.speak(utterence)
                        self.Timer3.value = 0
                    }){
                        ZStack{
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(ColorManage.button)
                            VStack{
                                if num.count > 4 {
                                    Text("\(hangeuls[num[2]].word)")
                                        .foregroundColor(ColorManage.buttontext)
                                        .font(.system(size: UIScreen.screenWidth * 0.13))
                                        .opacity(0.6)
                                }
                            }
                        }
                    }
                    .frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.09)
                }
                .padding(.bottom, UIScreen.screenHeight * 0.015)
                .padding([.leading, .trailing], UIScreen.screenWidth * 0.05 )
                HStack{
                    Button(action : {
                        let utterence = AVSpeechUtterance(string: hangeuls[num[1]].word)
                        utterence.voice = AVSpeechSynthesisVoice(language: "ko-KR")
                        if(self.Timer4.value < 3){
                            utterence.rate = 0.1
                        }
                        else{
                            utterence.rate = 0.5
                        }
                        
                        speak.speak(utterence)
                        self.Timer4.value = 0
                    }){
                        ZStack{
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(ColorManage.button)
                            VStack{
                                if num.count > 4 {
                                    Text("\(hangeuls[num[1]].word)")
                                        .foregroundColor(ColorManage.buttontext)
                                        .font(.system(size: UIScreen.screenWidth * 0.13))
                                        .opacity(0.6)
                                }
                            }
                        }
                    }
                    .frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.09)
                    Button(action : {
                        let utterence = AVSpeechUtterance(string: hangeuls[num[0]].word)
                        utterence.voice = AVSpeechSynthesisVoice(language: "ko-KR")
                        if(self.Timer5.value < 3) {
                            utterence.rate = 0.1
                        }
                        else {
                            utterence.rate = 0.5
                        }
                        
                        speak.speak(utterence)
                        self.Timer5.value = 0
                    }){
                        ZStack{
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(ColorManage.button)
                            VStack{
                                if num.count > 4 {
                                    Text("\(hangeuls[num[0]].word)")
                                        .foregroundColor(ColorManage.buttontext)
                                        .font(.system(size: UIScreen.screenWidth * 0.13))
                                        .opacity(0.6)
                                }
                            }
                        }
                    }
                    .frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.09)
                }
                .padding(.bottom, UIScreen.screenHeight * 0.015)
                .padding([.leading, .trailing], UIScreen.screenWidth * 0.05 )
                HStack{
                    Button(action : {
                        showModal.toggle()
                    }){
                        ZStack{
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(ColorManage.clean)
                            VStack{
                                Text("Syllable")
                                    .foregroundColor(ColorManage.button)
                                    .font(.system(size: UIScreen.screenWidth * 0.05))
                                    .opacity(0.6)
                            }
                        }
                    }
                    .frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.058)
                    
                    Button(action : {
                        page = 1
                    }){
                        ZStack{
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(ColorManage.plus)
                            VStack{
                                Text("Restart")
                                    .foregroundColor(ColorManage.button)
                                    .font(.system(size: UIScreen.screenWidth * 0.05))
                                    .opacity(0.6)
                            }
                        }
                    }
                    .frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.058)
                }
                .padding(.bottom, UIScreen.screenHeight * 0.1)
                .padding([.leading, .trailing], UIScreen.screenWidth * 0.05 )
                
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Thank you for playing so far"),
                          message: Text("Please keep interest for Hangeul."),
                          dismissButton: .default(Text("RETRUN")))
                }
                .sheet(isPresented: self.$showModal) {
                    LettersView()
                }
            }
        }
    }
}
