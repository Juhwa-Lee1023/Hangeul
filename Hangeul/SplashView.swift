//
//  SplashView.swift
//  Hangeul
//
//  Created by 이주화 on 2022/07/06.
//

import SwiftUI

struct SplashView: View {
    @State var page: Int = 0
    @State var num: [Int] = []
    var body: some View {
        switch page {
        case 0:
            WelcomeView(page: $page)
        case 1:
            ContentView(page: $page, num: $num)
        case 2:
            SecondView(page: $page, num: $num)
        case 3:
            ThirdView(page: $page, num: $num)
        case 4:
            FourthView(page: $page, num: $num)
        case 5:
            FifthView(page: $page, num: $num)
        case 6:
            ClearView(page: $page, num: $num)
        default:
            WelcomeView(page: $page)
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
