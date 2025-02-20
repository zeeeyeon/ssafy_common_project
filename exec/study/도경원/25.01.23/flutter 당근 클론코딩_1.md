# Flutter 당근마켓 클론 코딩

## 1. 프로젝트 생성
```bash
$ flutter create --platforms ios,android --org com.devman.cloneapp bamtol_market_app
```
- **`--platforms` 옵션**: 특정 플랫폼만 설정 가능  
- **`--org` 옵션**: 기본적인 패키지명 설정 가능  
  - `--org` 옵션으로 패키지명을 설정하면, 이후 별다른 수정 없이 Firebase 연동이나 앱 배포 가능

---

## 2. Assets 구성
플러터에서 리소스에 접근하려면 `pubspec.yaml` 파일에 경로를 정의해야 함.

### 예시
```yaml
assets:
  - assets/images/
  - assets/svg/
  - assets/svg/icons/
```

---

## 3. 프로젝트 초기 라이브러리 설치
```bash
$ flutter pub add flutter_svg equatable google_fonts
```
- 라이브러리 설치

```bash
$ flutter pub add get flutter_svg equatable google_fonts
```
- 라이브러리 설치 및 `pubspec.yaml` 파일에 자동 추가된 것 확인 가능

---

## 4. MaterialApp vs GetMaterialApp

### MaterialApp
- Flutter 기본 구조를 사용하거나, 다른 상태 관리 패키지(Provider, Riverpod 등)를 사용하려는 경우
- 간단한 앱을 만들거나, GetX를 사용할 계획이 없는 경우

### GetMaterialApp
- GetX를 사용하여 앱을 개발할 경우
- 상태 관리, 라우팅, 의존성 주입을 더 간단하게 구현하려는 경우

---

## 5. GetMaterialApp의 `getPages` 옵션 파라미터
`getPages`는 GetX에서 라우팅을 관리하기 위해 사용하는 옵션 파라미터.

### `getPages`
- `getPages`는 앱 내의 모든 라우트를 정의하는 데 사용됨.
- 리스트 형태로 라우트 정보를 전달하며, 각 라우트는 `GetPage` 객체로 정의됨.

### `GetPage`
- 개별 페이지의 경로와 빌더 함수, 기타 옵션을 설정하는 객체.
- `name`: 라우트 경로를 설정.
- `page`: 해당 경로에 대응되는 위젯을 반환하는 함수.

#### 예제 코드
```dart
GetMaterialApp(
  getPages: [
    GetPage(name: '/', page: () => HomePage()),
    GetPage(name: '/details', page: () => DetailsPage()),
  ],
);
```

---

## 6. ThemeData 분석

### 코드
```dart
ThemeData(
  appBarTheme: const AppBarTheme(
    elevation: 0,
    color: Color(0xff212123),
    titleTextStyle: TextStyle(
      color: Colors.white,
    ),
  ),
  scaffoldBackgroundColor: const Color(0xff212123),
)
```

### 설명
- **`appBarTheme`**: AppBar의 스타일을 설정.
  - `elevation`: AppBar의 그림자를 없앰 (`0`).
  - `color`: AppBar 배경색 (어두운 회색, `#212123`).
  - `titleTextStyle`: AppBar 제목 텍스트를 흰색으로 설정.
- **`scaffoldBackgroundColor`**: 앱 화면 배경색을 설정 (어두운 회색, `#212123`).

이 설정은 어두운 테마를 기반으로 앱의 디자인 통일성을 제공합니다.
