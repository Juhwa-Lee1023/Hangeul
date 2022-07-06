//
//  ClearView.swift
//  Hangeul
//
//  Created by 이주화 on 2022/04/26.
//

import SwiftUI
import AVFoundation

struct ClearView: View {
    @Binding var page : Int
    @State private var showAlert = false
    @State private var clearAlert = false
    @State var nextView = false
    @Binding var num: [Int]
    let soundplayer = SoundPlayer()
    
    var body: some View {
//        NavigationView{
        ZStack{
            ColorManage.background
                .ignoresSafeArea()
            VStack{
            HStack {
                ZStack{
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(ColorManage.button)
                    VStack{
                        Text("CLEAR!")
                            .foregroundColor(ColorManage.plus)
                            .font(.system(size: UIScreen.screenWidth * 0.25))
                    }
                }
            }.frame(width: UIScreen.screenWidth * 0.98, height: UIScreen.screenHeight * 0.25)
            .padding(.bottom, UIScreen.screenHeight * 0.03)
                
            HStack{
                Button(action : {
                    let utterence = AVSpeechUtterance(string: hangeuls[num[4]].word)
                    utterence.voice = AVSpeechSynthesisVoice(language: "ko-KR")
                    utterence.rate = 0.4
                    let speak = AVSpeechSynthesizer()
                    speak.speak(utterence)
                }){
                ZStack{
                        RoundedRectangle(cornerRadius: 10.0)
                        .fill(ColorManage.button)
                        VStack{
                            Text("\(hangeuls[num[4]].word)")
                                .foregroundColor(ColorManage.plus)
                                .font(.system(size: UIScreen.screenWidth * 0.13))
                                .opacity(0.6)
                        }
                }
                }.frame(width: UIScreen.screenHeight * 0.23, height: UIScreen.screenHeight * 0.09)
                
                
            }
            .padding(.bottom, UIScreen.screenHeight * 0.03)
            HStack{
                Button(action : {
                    let utterence = AVSpeechUtterance(string: hangeuls[num[3]].word)
                    utterence.voice = AVSpeechSynthesisVoice(language: "ko-KR")
                    utterence.rate = 0.4
                    let speak = AVSpeechSynthesizer()
                    speak.speak(utterence)
                }){
                ZStack{
                        RoundedRectangle(cornerRadius: 10.0)
                        .fill(ColorManage.button)
                        VStack{
                            Text("\(hangeuls[num[3]].word)")
                                .foregroundColor(ColorManage.buttontext)
                                .font(.system(size: UIScreen.screenWidth * 0.13))
                                .opacity(0.6)
                        }
                }
                }.frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.058)
                    .padding(.leading)
                Spacer()
                Button(action : {
                    let utterence = AVSpeechUtterance(string: hangeuls[num[2]].word)
                    utterence.voice = AVSpeechSynthesisVoice(language: "ko-KR")
                    utterence.rate = 0.4
                    let speak = AVSpeechSynthesizer()
                    speak.speak(utterence)
                }){
                ZStack{
                        RoundedRectangle(cornerRadius: 10.0)
                        .fill(ColorManage.button)
                        VStack{
                            Text("\(hangeuls[num[2]].word)")
                                .foregroundColor(ColorManage.buttontext)
                                .font(.system(size: UIScreen.screenWidth * 0.13))
                                .opacity(0.6)
                        }
                }
                }.frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.058)
                    .padding(.trailing)
            }.padding(.bottom, UIScreen.screenHeight * 0.03)
                HStack{
                    Button(action : {
                        let utterence = AVSpeechUtterance(string: hangeuls[num[1]].word)
                        utterence.voice = AVSpeechSynthesisVoice(language: "ko-KR")
                        utterence.rate = 0.4
                        let speak = AVSpeechSynthesizer()
                        speak.speak(utterence)
                    }){
                    ZStack{
                            RoundedRectangle(cornerRadius: 10.0)
                            .fill(ColorManage.button)
                            VStack{
                                Text("\(hangeuls[num[1]].word)")
                                    .foregroundColor(ColorManage.buttontext)
                                    .font(.system(size: UIScreen.screenWidth * 0.13))
                                    .opacity(0.6)
                            }
                    }
                    }.frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.058)
                        .padding(.leading)
                    Spacer()
                    Button(action : {
                        let utterence = AVSpeechUtterance(string: hangeuls[num[0]].word)
                        utterence.voice = AVSpeechSynthesisVoice(language: "ko-KR")
                        utterence.rate = 0.4
                        let speak = AVSpeechSynthesizer()
                        speak.speak(utterence)
                    }){
                    ZStack{
                            RoundedRectangle(cornerRadius: 10.0)
                            .fill(ColorManage.button)
                            VStack{
                                Text("\(hangeuls[num[0]].word)")
                                    .foregroundColor(ColorManage.buttontext)
                                    .font(.system(size: UIScreen.screenWidth * 0.13))
                                    .opacity(0.6)
                            }
                    }
                    }.frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.058)
                        .padding(.trailing)
                }.padding(.bottom, UIScreen.screenHeight * 0.03)
                HStack{
                    Button(action : {
                        showAlert.toggle()
                    }){
                    ZStack{
                            RoundedRectangle(cornerRadius: 10.0)
                            .fill(ColorManage.clean)
                            VStack{
                                Text("Congratulations")
                                    .foregroundColor(ColorManage.button)
                                    .font(.system(size: UIScreen.screenWidth * 0.05))
                                    .opacity(0.6)
                            }
                    }
                    }.frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.058)
                        .padding(.leading)
                    
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
                    }.frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.058)
                        .padding(.trailing)
                }.padding(.bottom, UIScreen.screenHeight * 0.1)
                .alert(isPresented: $showAlert) {
                            Alert(title: Text("Thank you for playing so far"),
                                  message: Text("Please keep interest for Hangeul."),
                                  dismissButton: .default(Text("RETRUN")))
                        }
//                NavigationLink(destination: ContentView(), isActive: $nextView) {
//                                    EmptyView()
//                                }.disabled(true)
//        }
            
        }
//        .navigationBarTitle("")
//        .navigationBarTitleDisplayMode(.inline)
        }
       
//        .navigationBarHidden(true)

        
    }
}
