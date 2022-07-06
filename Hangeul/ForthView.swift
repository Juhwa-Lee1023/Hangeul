//
//  ForthView.swift
//  Hangeul
//
//  Created by 이주화 on 2022/04/26.
//

import SwiftUI

struct FourthView: View {
    
    @State var buttonArray: [Bool] = Array(repeating: false, count: 12)
    @State var firstText = false
    @State var secondText = false
    @State private var showAlert = false
    @State private var clearAlert = false
    @State var nextView = false
    let soundplayer = SoundPlayer()
    
    var body: some View {
        NavigationView{
        ZStack{
            ColorManage.background
                .ignoresSafeArea()
            VStack{
            HStack {
                ZStack{
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(ColorManage.button)
                    VStack{
                        Text("안녕")
                            .foregroundColor(ColorManage.plus)
                            .font(.system(size: UIScreen.screenWidth * 0.28))
                    }
                }
            }.frame(width: UIScreen.screenWidth * 0.98, height: UIScreen.screenHeight * 0.25)
            .padding(.bottom, UIScreen.screenHeight * 0.03)
            HStack{
                ZStack{
                    if firstText {
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(ColorManage.button)
                        VStack{
                            Text("안")
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
                            Text("안")
                                .foregroundColor(ColorManage.buttontext)
                                .font(.system(size: UIScreen.screenWidth * 0.13))
                                .opacity(0.6)
                        }
                        
                    }
                } .frame(width: UIScreen.screenHeight * 0.09, height: UIScreen.screenHeight * 0.09)
                ZStack{
                        if firstText{
                            if secondText {
                                RoundedRectangle(cornerRadius: 10.0)
                                    .fill(ColorManage.button)
                                VStack{
                                Text("녕")
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
                                Text("녕")
                                    .foregroundColor(ColorManage.buttontext)
                                    .font(.system(size: UIScreen.screenWidth * 0.13))
                                    .opacity(0.6)
                                }
                            }
                        } else{
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(ColorManage.button)
                            VStack{
                            Text("녕")
                                .foregroundColor(ColorManage.buttontext)
                                .font(.system(size: UIScreen.screenWidth * 0.13))
                                .opacity(0.6)
                            }
                        }
                }.frame(width: UIScreen.screenHeight * 0.09, height: UIScreen.screenHeight * 0.09)
                
                
            }
                if secondText {
                    Button(action : {
                        soundplayer.annyeong_play()
                    }){
                    HStack{
                        
                        Text("'안녕'(annyeong) means 'Hi'.")
                            .foregroundColor(ColorManage.buttontext)
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(ColorManage.buttontext)
                        
                        }
                    }
                } else{
                    HStack{
                        Text("Pick all the Lettes for This Box.")
                            .foregroundColor(ColorManage.buttontext)
                    }
                }
                 
            HStack{
                Button(action : {
                    buttonArray[0].toggle()
                }){
                ZStack{
                    if buttonArray[0] {
                        RoundedRectangle(cornerRadius: 10.0)
                        .fill(ColorManage.plus)
                        .opacity(0.6)
                        VStack{
                            Text("ㄱ")
                                .foregroundColor(ColorManage.button)
                                .font(.system(size: UIScreen.screenWidth * 0.13))
                        }
                    } else{
                        RoundedRectangle(cornerRadius: 10.0)
                        .fill(ColorManage.button)
                        VStack{
                            Text("ㄱ")
                                .foregroundColor(ColorManage.buttontext)
                                .font(.system(size: UIScreen.screenWidth * 0.13))
                                .opacity(0.6)
                        }
                    }
                    }
                }.frame(width: UIScreen.screenHeight * 0.09, height: UIScreen.screenHeight * 0.09)
                    .padding(.leading)
                Spacer()
                Button(action : {
                    buttonArray[1].toggle()
                }){
                ZStack{
                    if buttonArray[1] {
                        RoundedRectangle(cornerRadius: 10.0)
                        .fill(ColorManage.plus)
                        .opacity(0.6)
                        VStack{
                            Text("ㄴ")
                                .foregroundColor(ColorManage.button)
                                .font(.system(size: UIScreen.screenWidth * 0.13))
                        }
                    } else{
                        RoundedRectangle(cornerRadius: 10.0)
                        .fill(ColorManage.button)
                        VStack{
                            Text("ㄴ")
                                .foregroundColor(ColorManage.buttontext)
                                .font(.system(size: UIScreen.screenWidth * 0.13))
                                .opacity(0.6)
                        }
                    }
                    }
                }.frame(width: UIScreen.screenHeight * 0.09, height: UIScreen.screenHeight * 0.09)
                Spacer()
                Button(action : {
                    buttonArray[2].toggle()
                }){
                ZStack{
                    if buttonArray[2] {
                        RoundedRectangle(cornerRadius: 10.0)
                        .fill(ColorManage.plus)
                        .opacity(0.6)
                        VStack{
                            Text("ㄷ")
                                .foregroundColor(ColorManage.button)
                                .font(.system(size: UIScreen.screenWidth * 0.13))
                        }
                    } else{
                        RoundedRectangle(cornerRadius: 10.0)
                        .fill(ColorManage.button)
                        VStack{
                            Text("ㄷ")
                                .foregroundColor(ColorManage.buttontext)
                                .font(.system(size: UIScreen.screenWidth * 0.13))
                                .opacity(0.6)
                        }
                    }
                    }
                }.frame(width: UIScreen.screenHeight * 0.09, height: UIScreen.screenHeight * 0.09)
                Spacer()
                Button(action : {
                    buttonArray[3].toggle()
                }){
                ZStack{
                    if buttonArray[3] {
                        RoundedRectangle(cornerRadius: 10.0)
                        .fill(ColorManage.plus)
                        .opacity(0.6)
                        VStack{
                            Text("ㅏ")
                                .foregroundColor(ColorManage.button)
                                .font(.system(size: UIScreen.screenWidth * 0.13))
                        }
                    } else{
                        RoundedRectangle(cornerRadius: 10.0)
                        .fill(ColorManage.button)
                        VStack{
                            Text("ㅏ")
                                .foregroundColor(ColorManage.buttontext)
                                .font(.system(size: UIScreen.screenWidth * 0.13))
                                .opacity(0.6)
                        }
                    }
                    }
                }.frame(width: UIScreen.screenHeight * 0.09, height: UIScreen.screenHeight * 0.09)
                .padding(.trailing)
            }
                HStack{
                    Button(action : {
                        buttonArray[4].toggle()
                    }){
                    ZStack{
                        if buttonArray[4] {
                            RoundedRectangle(cornerRadius: 10.0)
                            .fill(ColorManage.plus)
                            .opacity(0.6)
                            VStack{
                                Text("ㅈ")
                                    .foregroundColor(ColorManage.button)
                                    .font(.system(size: UIScreen.screenWidth * 0.13))
                            }
                        } else{
                            RoundedRectangle(cornerRadius: 10.0)
                            .fill(ColorManage.button)
                            VStack{
                                Text("ㅈ")
                                    .foregroundColor(ColorManage.buttontext)
                                    .font(.system(size: UIScreen.screenWidth * 0.13))
                                    .opacity(0.6)
                            }
                        }
                        }
                    }.frame(width: UIScreen.screenHeight * 0.09, height: UIScreen.screenHeight * 0.09)
                        .padding(.leading)
                    Spacer()
                    Button(action : {
                        buttonArray[5].toggle()
                    }){
                    ZStack{
                        if buttonArray[5] {
                            RoundedRectangle(cornerRadius: 10.0)
                            .fill(ColorManage.plus)
                            .opacity(0.6)
                            VStack{
                                Text("ㅉ")
                                    .foregroundColor(ColorManage.button)
                                    .font(.system(size: UIScreen.screenWidth * 0.13))
                            }
                        } else{
                            RoundedRectangle(cornerRadius: 10.0)
                            .fill(ColorManage.button)
                            VStack{
                                Text("ㅉ")
                                    .foregroundColor(ColorManage.buttontext)
                                    .font(.system(size: UIScreen.screenWidth * 0.13))
                                    .opacity(0.6)
                            }
                        }
                        }
                    }.frame(width: UIScreen.screenHeight * 0.09, height: UIScreen.screenHeight * 0.09)
                    Spacer()
                    Button(action : {
                        buttonArray[6].toggle()
                    }){
                    ZStack{
                        if buttonArray[6] {
                            RoundedRectangle(cornerRadius: 10.0)
                            .fill(ColorManage.plus)
                            .opacity(0.6)
                            VStack{
                                Text("ㅊ")
                                    .foregroundColor(ColorManage.button)
                                    .font(.system(size: UIScreen.screenWidth * 0.13))
                            }
                        } else{
                            RoundedRectangle(cornerRadius: 10.0)
                            .fill(ColorManage.button)
                            VStack{
                                Text("ㅊ")
                                    .foregroundColor(ColorManage.buttontext)
                                    .font(.system(size: UIScreen.screenWidth * 0.13))
                                    .opacity(0.6)
                            }
                        }
                        }
                    }.frame(width: UIScreen.screenHeight * 0.09, height: UIScreen.screenHeight * 0.09)
                    Spacer()
                    Button(action : {
                        buttonArray[7].toggle()
                    }){
                    ZStack{
                        if buttonArray[7] {
                            RoundedRectangle(cornerRadius: 10.0)
                            .fill(ColorManage.plus)
                            .opacity(0.6)
                            VStack{
                                Text("ㅓ")
                                    .foregroundColor(ColorManage.button)
                                    .font(.system(size: UIScreen.screenWidth * 0.13))
                            }
                        } else{
                            RoundedRectangle(cornerRadius: 10.0)
                            .fill(ColorManage.button)
                            VStack{
                                Text("ㅓ")
                                    .foregroundColor(ColorManage.buttontext)
                                    .font(.system(size: UIScreen.screenWidth * 0.13))
                                    .opacity(0.6)
                            }
                        }
                        }
                    }.frame(width: UIScreen.screenHeight * 0.09, height: UIScreen.screenHeight * 0.09)
                    .padding(.trailing)
                }
                HStack{
                    Button(action : {
                        buttonArray[8].toggle()
                    }){
                    ZStack{
                        if buttonArray[8] {
                            RoundedRectangle(cornerRadius: 10.0)
                            .fill(ColorManage.plus)
                            .opacity(0.6)
                            VStack{
                                Text("ㅇ")
                                    .foregroundColor(ColorManage.button)
                                    .font(.system(size: UIScreen.screenWidth * 0.13))
                            }
                        } else{
                            RoundedRectangle(cornerRadius: 10.0)
                            .fill(ColorManage.button)
                            VStack{
                                Text("ㅇ")
                                    .foregroundColor(ColorManage.buttontext)
                                    .font(.system(size: UIScreen.screenWidth * 0.13))
                                    .opacity(0.6)
                            }
                        }
                        }
                    }.frame(width: UIScreen.screenHeight * 0.09, height: UIScreen.screenHeight * 0.09)
                        .padding(.leading)
                    Spacer()
                    Button(action : {
                        buttonArray[9].toggle()
                    }){
                    ZStack{
                        if buttonArray[9] {
                            RoundedRectangle(cornerRadius: 10.0)
                            .fill(ColorManage.plus)
                            .opacity(0.6)
                            VStack{
                                Text("ㅂ")
                                    .foregroundColor(ColorManage.button)
                                    .font(.system(size: UIScreen.screenWidth * 0.13))
                            }
                        } else{
                            RoundedRectangle(cornerRadius: 10.0)
                            .fill(ColorManage.button)
                            VStack{
                                Text("ㅂ")
                                    .foregroundColor(ColorManage.buttontext)
                                    .font(.system(size: UIScreen.screenWidth * 0.13))
                                    .opacity(0.6)
                            }
                        }
                        }
                    }.frame(width: UIScreen.screenHeight * 0.09, height: UIScreen.screenHeight * 0.09)
                    Spacer()
                    Button(action : {
                        buttonArray[10].toggle()
                    }){
                    ZStack{
                        if buttonArray[10] {
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(ColorManage.plus)
                            .opacity(0.6)
                            VStack{
                                Text("ㅃ")
                                    .foregroundColor(ColorManage.button)
                                    .font(.system(size: UIScreen.screenWidth * 0.13))
                            }
                        } else{
                            RoundedRectangle(cornerRadius: 10.0)
                            .fill(ColorManage.button)
                            VStack{
                                Text("ㅃ")
                                    .foregroundColor(ColorManage.buttontext)
                                    .font(.system(size: UIScreen.screenWidth * 0.13))
                                    .opacity(0.6)
                            }
                        }
                        }
                    }.frame(width: UIScreen.screenHeight * 0.09, height: UIScreen.screenHeight * 0.09)
                    Spacer()
                    Button(action : {
                        buttonArray[11].toggle()
                    }){
                    ZStack{
                        if buttonArray[11] {
                            RoundedRectangle(cornerRadius: 10.0)
                            .fill(ColorManage.plus)
                            .opacity(0.6)
                            VStack{
                                Text("ㅕ")
                                    .foregroundColor(ColorManage.button)
                                    .font(.system(size: UIScreen.screenWidth * 0.13))
                            }
                        } else{
                            RoundedRectangle(cornerRadius: 10.0)
                            .fill(ColorManage.button)
                            VStack{
                                Text("ㅕ")
                                    .foregroundColor(ColorManage.buttontext)
                                    .font(.system(size: UIScreen.screenWidth * 0.13))
                                    .opacity(0.6)
                            }
                        }
                        }
                    }.frame(width: UIScreen.screenHeight * 0.09, height: UIScreen.screenHeight * 0.09)
                    .padding(.trailing)
                }   .padding(.bottom, UIScreen.screenHeight * 0.01)
                HStack{
                    Button( action : {
                        if secondText{
                            soundplayer.annyeong_play()
                        } else{
                            buttonArray = [false, false, false, false, false, false, false, false, false, false, false, false]
                        }
                        
                    }){
                    ZStack{
                        if secondText{
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
                                Text("CLAEN")
                                    .foregroundColor(ColorManage.button)
                                    .font(.system(size: UIScreen.screenWidth * 0.05))
                            }
                        }
                    }
                    }.frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.058)
                        .padding(.leading)
                    Button( action : {
                        if secondText{
                            nextView = true
                            soundplayer.next_play()
                        }else{
                            if firstText {
                                if (  buttonArray == [false, true, false, false, false, false, false, false, true, false, false, true] ){
                                    secondText = true
                                    buttonArray = [false, true, false, true, false, false, false, false, true, false, false, true]
                                    clearAlert = true
                                    soundplayer.annyeong_play()
                                } else{
                                    showAlert.toggle()
                                    soundplayer.dding_play()
                                    buttonArray = [false, false, false, false, false, false, false, false, false, false, false, false]
                                }
                            } else {
                            if ( buttonArray == [false, true, false, true, false, false, false, false, true, false, false, false] ){
                                firstText = true
                                soundplayer.an_play()
                                buttonArray = [false, false, false, false, false, false, false, false, false, false, false, false]
                            } else{
                                showAlert.toggle()
                                soundplayer.dding_play()
                                buttonArray = [false, false, false, false, false, false, false, false, false, false, false, false]
                            }
                            }
                        }
                        
                    }){
                        ZStack{
                            if secondText {
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
                        .padding(.trailing)
                }
                .alert(isPresented: $showAlert) {
                            Alert(title: Text("Didn't Match"),
                                  message: Text("Please try again."),
                                  dismissButton: .default(Text("RETRUN")))
                        }
                .confirmationDialog(
                    "Completed '안녕' with the meaning of 'Hi'.",
                    isPresented: $clearAlert,
                    titleVisibility: .visible,
                    actions: {
                        Button("Press NEXT to Move On", role: .cancel) { }
                    })
                NavigationLink(destination: FifthView(), isActive: $nextView) {
                                    EmptyView()
                                }.disabled(true)
        }
            
        }
        .navigationBarTitle("")
        .navigationBarTitleDisplayMode(.inline)
        }
       
        .navigationBarHidden(true)

        
    }
}

struct ForthView_Previews: PreviewProvider {
    static var previews: some View {
        FourthView()
    }
}
