//
//  ThirdView.swift
//  Hangeul
//
//  Created by 이주화 on 2022/04/26.
//

import SwiftUI

struct ThirdView: View {
    @Binding var page : Int
    @State var firstText = false
    @State var secondText = false
    @State private var showAlert = false
    @State private var clearAlert = false
    @State var nextView = false
    @State var letterFirst = ""
    @State var letterSecond = ""
    let soundplayer = SoundPlayer()
    @State var han: hangeul = hangeul(id: 0, word: "", english: "", pron: "", firstSolf: 0, firstSols: 0, firstSolt: 0, secondSolf: 0, secondSols: 0, secondSolt: 0, stateA: ["ㄱ", "ㅋ", "ㄴ", "ㅏ", "ㄷ", "ㅁ", "ㅂ", "ㅗ", "ㅅ", "ㅈ", "ㅕ", "ㅖ"])
    @State var i = Int.random(in: 0...154)
    @Binding var num: [Int]
    @State var check: Bool = false
    
    
    
    var body: some View {
//        NavigationView{
            ZStack{
                ColorManage.background
                    .ignoresSafeArea()
                VStack{
                    MainBox(text: hangeuls[i].word)
                    SolBox(letterFirst: letterFirst, letterSecond: letterSecond, check1: $firstText, check2: $secondText)
                    EditBox(text: hangeuls[i].word, letterKorea: hangeuls[i].word, letterEnglish: hangeuls[i].english, letterPron: hangeuls[i].pron, check: $secondText)
                    BodyBox(page: $page, han: $han, text: hangeuls[i].word, letterFirst: letterFirst, check1: $firstText, check2: $secondText, nextView: $nextView, clearAlert: $clearAlert, showAlert: $showAlert, letterArray: hangeuls[i].stateA)
                    
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Didn't Match"),
                                  message: Text("Please try again."),
                                  dismissButton: .default(Text("RETRUN")))
                        }
//                    NavigationLink(destination: FourthView(num: num), isActive: $nextView) {
//                        EmptyView()
//                    }.disabled(true)
//                }
            }
//            .navigationBarTitle("")
//            .navigationBarTitleDisplayMode(.inline)
        }.onAppear(){
            while(!check){
                if(!num.contains(i)){
                    num.append(i)
                    check = true
                }
                else{
                    i = Int.random(in: 0...154)
                }
                
            }
            letterFirst = String(hangeuls[i].word.prefix(1))
            letterSecond = String(hangeuls[i].word.suffix(1))
            han = hangeuls[i]
            
        }
        
//        .navigationBarHidden(true)
        
        
    }
}
