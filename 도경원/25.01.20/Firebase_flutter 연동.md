# Firebase와 Flutter 연동 가이드

## 1. Firebase 프로젝트 설정

1. **Firebase 콘솔 접속**
   - [Firebase 웹사이트](https://console.firebase.google.com/)에 접속하여 Google 계정으로 로그인합니다.
   - Firebase 콘솔로 이동합니다.

2. **새 프로젝트 생성 또는 기존 프로젝트 선택**
   - 새 프로젝트를 생성하거나 기존 Firebase 프로젝트를 선택합니다.

3. **Flutter 플랫폼 설정**
   - Firebase 프로젝트 설정에서 **앱 추가**를 선택하고 Flutter 플랫폼을 선택합니다.

---

## 2. Firebase CLI 설치 및 로그인

1. **Firebase CLI 설치**
   - Firebase CLI를 설치합니다. (Node.js와 npm이 설치되어 있어야 합니다.)
     ```bash
     npm install -g firebase-tools
     ```

2. **Firebase CLI 로그인**
   - Firebase CLI를 사용하여 Firebase 계정에 로그인합니다.
     ```bash
     firebase login
     ```

---

## 3. Flutter 프로젝트와 Firebase 연동

1. **Firebase 프로젝트와 Flutter 연동**
   - 터미널에서 아래 명령어를 실행합니다.
     ```bash
     flutterfire configure
     ```

2. **연동 과정**
   - 연동 도중 지원할 플랫폼(Android, iOS, 웹 등)을 선택합니다.
   - Firebase 프로젝트를 선택합니다.

3. **결과**
   - 연동이 성공적으로 완료되면 프로젝트 내에 `firebase_options.dart` 파일이 생성됩니다.

---

## 4. Firebase Core 플러그인 추가

1. **Firebase Core 패키지 추가**
   - `pubspec.yaml` 파일에 `firebase_core` 패키지를 추가합니다.
     ```yaml
     dependencies:
       firebase_core: 최신_버전
     ```

2. **패키지 설치**
   - 아래 명령어를 실행하여 패키지를 설치합니다.
     ```bash
     flutter pub get
     ```

3. **firebase_options.dart 오류 해결**
   - 위 과정을 완료하면 `firebase_options.dart` 파일의 오류가 해결됩니다.

---

## 참고

- Firebase와 Flutter 연동 후, `firebase_core`를 초기화하여 Firebase 서비스를 사용할 수 있습니다.
- 추가적인 서비스(Firestore, Authentication 등)를 사용하려면 해당 패키지를 추가하여 활용하세요.

