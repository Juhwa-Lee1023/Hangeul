//
//  WelcomeView.swift
//  Hangeul
//
//  Created by 이주화 on 2022/04/26.
//

import SwiftUI

struct WelcomeView: View {
    
    @Binding var page : Int
    @State var nextView = false
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
                            Text("한글")
                                .foregroundColor(ColorManage.plus)
                                .font(.system(size: UIScreen.screenWidth * 0.28))
                        }
                    }
                }.frame(width: UIScreen.screenWidth * 0.90, height: UIScreen.screenHeight * 0.25)
                    .padding(.bottom, UIScreen.screenHeight * 0.01)
                HStack{
                    Button(action : {
                        soundplayer.next_play()
                        nextView.toggle()
                        page = 1
                    }){
                        Text("Tap to Start")
                            .foregroundColor(ColorManage.plus)
                            .font(.system(size: UIScreen.screenWidth * 0.1))
                            .opacity(0.6)
                    }
                }.padding(.bottom, UIScreen.screenHeight * 0.01)
                
                HStack{
                    Text("Hangeul is the writing system for the Korean language. Consonants and vowels are constructed to like a puzzle to form a letter, and each syllable is represented in each letter. \n\nTap the correct elements for the letter in the highlighted box and press ‘CONFIRM’")
                        .foregroundColor(ColorManage.clean)
                        .font(.system(size: UIScreen.screenWidth * 0.05))
                        .opacity(0.6)
                }.padding([.leading, .trailing], UIScreen.screenWidth * 0.05)
            }.onTapGesture{
                nextView.toggle()
            }
            
                
            
            //                NavigationLink(destination: ContentView(), isActive: $nextView) {
            //                                    EmptyView()
            //                                }.disabled(true)
            //        }
            //
            //        .navigationBarTitle("")
            //        .navigationBarTitleDisplayMode(.inline)
        }
        //        .navigationBarHidden(true)
        
        
        
    }
}

