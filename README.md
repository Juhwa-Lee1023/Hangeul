# Hangeul Puzzle
### WWDC2022 Chanllenge Winner
|![Frame 6](https://user-images.githubusercontent.com/63584245/198891996-fcba1e21-5ef8-4bbc-8fc8-8b3e1bd085ca.svg)|<img width="241" alt="image" src="https://user-images.githubusercontent.com/63584245/200097948-806c0642-9581-4773-9822-d54f0266bf15.png">|
|:---:|:---:|


 _**한글을 그림처럼 느끼는 외국인들을 위한 한글을 퍼즐처럼 즐길 수 있는 앱입니다!**_ <br/>
 _**퍼즐을 풀며 한글을 공부해봅시다.**_


🔗App Store : <a href="https://apps.apple.com/kr/app/hangeul-puzzle/id1634394239?l=en">HangeulPuzzle</a>

---
### 동작화면
|![한글](https://user-images.githubusercontent.com/63584245/191348063-6ad9b371-eb9c-4f53-aec7-efd562183656.gif)|![한글2](https://user-images.githubusercontent.com/63584245/191348079-d4d2197f-7157-4fcb-8c2e-3c5c899f44e9.gif)|![한글3](https://user-images.githubusercontent.com/63584245/191348089-2b9fad5b-a6a9-4fab-938b-88927bcfd55f.gif)|
|:---:|:---:|:---:|





---
### :sparkles: Skills & Tech Stack
* SwiftUI
* AVFoundation

### 🛠 Development Environment

<img width="77" alt="스크린샷 2021-11-19 오후 3 52 02" src="https://img.shields.io/badge/iOS-15.0+-silver"> <img width="95" alt="스크린샷 2021-11-19 오후 3 52 02" src="https://img.shields.io/badge/Xcode-13.3-blue">


## 기술적 도전

> **화면전환**
* 뷰에 tag를 걸어 화면전환시 네비게이션을 이용하는 것이 아니라 태그가 변할때 화면이 전환되도록 시도해았다.
```swift
struct SplashView: View {
    @State var page:Int = 0
    @State var num: [Int] = []
    var body: some View {
        switch page{
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
```

> **기종 대응**
* 뷰의 모든 요소를 화면 비율을 따라 변하도록 설정하여 분기처리없이 하나의 코드로 모든 기종에 대응이 가능하도록 시도해보았다.
```swift
extension UIScreen{
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}
```
```swift
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
      text("CONFIRM")
       .foregroundColor(ColorManage.button)
       .font(.system(size: UIScreen.screenWidth * 0.05))
    }
   }
  }
 }
 .frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.058)  
```  


### :lock_with_ink_pen: License

[MIT](https://choosealicense.com/licenses/mit/)
