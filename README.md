# Hangeul Puzzle

### WWDC 2022 Swift Student Challenge Winner

| ![WWDC 2022 Swift Student Challenge Winner](https://user-images.githubusercontent.com/63584245/198891996-fcba1e21-5ef8-4bbc-8fc8-8b3e1bd085ca.svg) | <img width="241" alt="Hangeul Puzzle 앱 화면" src="https://user-images.githubusercontent.com/63584245/200097948-806c0642-9581-4773-9822-d54f0266bf15.png"> |
|:---:|:---:|

_**한글을 그림처럼 느끼는 외국인들을 위한 한글을 퍼즐처럼 즐길 수 있는 앱입니다!**_<br>
_**퍼즐을 풀며 한글을 공부해봅시다.**_

[App Store에서 Hangeul Puzzle 보기](https://apps.apple.com/kr/app/hangeul-puzzle/id1634394239?l=en)

## 동작 화면

| ![한글 퍼즐 시작 화면](https://user-images.githubusercontent.com/63584245/191348063-6ad9b371-eb9c-4f53-aec7-efd562183656.gif) | ![한글 퍼즐 풀이 화면](https://user-images.githubusercontent.com/63584245/191348079-d4d2197f-7157-4fcb-8c2e-3c5c899f44e9.gif) | ![한글 퍼즐 완료 화면](https://user-images.githubusercontent.com/63584245/191348089-2b9fad5b-a6a9-4fab-938b-88927bcfd55f.gif) |
|:---:|:---:|:---:|

## 퍼즐 생성 방식

Hangeul Puzzle은 단어마다 정답 조각을 따로 저장하지 않습니다. 번들에 포함된 단어를 읽고 각 한글 음절의 초성·중성·종성을 유니코드 규칙으로 분해해 퍼즐 조각을 자동으로 만듭니다. 게임 세션은 생성된 조각과 오답 후보를 섞어 문제를 구성하고, 사용자의 선택을 원래 음절과 비교합니다.

이 방식은 새로운 단어를 추가할 때 화면이나 정답 로직을 다시 작성하지 않아도 같은 규칙으로 문제를 만들 수 있게 해 줍니다.

## 로컬 데이터

- 단어와 뜻은 [`Assets/data.json`](Assets/data.json)에 포함되어 있습니다.
- 효과음과 이미지도 앱 번들에서 읽습니다.
- 문제 생성과 채점은 기기 안에서 처리되며, 플레이에 계정이나 네트워크 연결이 필요하지 않습니다.

## 현재 구조

| 파일 | 역할 |
|---|---|
| `HangulPuzzle.swift` | 한글 음절 분해와 퍼즐 문제 모델 |
| `GameSession.swift` | 문제 선택, 라운드 진행, 화면 전환을 관리하는 게임 세션 |
| `PuzzleView.swift` | 자모 선택 상태와 풀이 상호작용을 담당하는 SwiftUI 화면 |
| `AudioService.swift` | AVFoundation 기반 음성 합성과 로컬 효과음 재생 |
| `WordRepository.swift` | 번들 JSON 디코딩, 스키마 및 데이터 유효성 검사 |

`RootView`가 저장소와 서비스를 조립하고, `GameSession`이 순수한 문제 생성 규칙과 SwiftUI 화면 사이를 연결합니다. 데이터·게임 규칙·UI·오디오를 분리해 각 부분을 독립적으로 테스트할 수 있는 방향을 따릅니다.

## 개발 환경

- SwiftUI
- AVFoundation
- 최소 배포 대상: iOS 14.0 이상
- 개발 및 검증: 최신 정식 Xcode 권장

CI는 GitHub의 `macos-latest` 러너가 제공하는 기본 Xcode에서 공유 `Hangeul` scheme을 빌드하고, 설치된 최신 iOS Simulator에서 테스트와 코드 커버리지를 수집합니다. 따라서 특정 iPhone 모델이 설치되어 있어야 한다는 전제는 없습니다.

## 빌드와 테스트

Xcode에서 프로젝트를 열려면 다음 명령을 실행합니다.

```sh
open Hangeul.xcodeproj
```

명령줄에서 공유 scheme을 빌드할 수 있습니다.

```sh
xcodebuild \
  -project Hangeul.xcodeproj \
  -scheme Hangeul \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  build
```

테스트 명령은 설치된 최신 iOS 런타임에서 사용 가능한 iPhone Simulator를 자동으로 선택합니다.

```sh
SIMULATOR_UDID="$(
  xcrun simctl list devices available --json |
    python3 -c 'import json, sys; data = json.load(sys.stdin)["devices"]; pools = sorted(((tuple(map(int, runtime.rsplit("iOS-", 1)[1].split("-"))), devices) for runtime, devices in data.items() if ".iOS-" in runtime), key=lambda item: item[0], reverse=True); print(next(device["udid"] for _, devices in pools for device in devices if device.get("isAvailable") and device["name"].startswith("iPhone")))'
)"

xcodebuild \
  -project Hangeul.xcodeproj \
  -scheme Hangeul \
  -configuration Debug \
  -destination "platform=iOS Simulator,id=${SIMULATOR_UDID}" \
  -derivedDataPath DerivedData \
  -enableCodeCoverage YES \
  test
```

Swift 포맷을 검사하거나 적용하려면 Xcode에 포함된 `swift-format`을 사용합니다.

```sh
xcrun swift-format lint \
  --configuration .swift-format \
  --recursive \
  --parallel \
  --strict \
  Hangeul HangeulTests HangeulUITests

xcrun swift-format format \
  --configuration .swift-format \
  --recursive \
  --parallel \
  --in-place \
  Hangeul HangeulTests HangeulUITests
```

## License

[MIT](license)
