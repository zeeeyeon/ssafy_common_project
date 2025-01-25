# Firebase와 Flutter 연동 및 API 활용 가이드

Flutter 애플리케이션에서 Firebase와 연동하여 자체 API를 구축하거나 외부 API를 호출하는 방법을 단계별로 정리했습니다.

---

## 1. Firebase Cloud Functions를 활용한 API 구축

Firebase **Cloud Functions**를 사용하면 백엔드에서 커스텀 API를 작성하고 Firebase와 연동하여 호출할 수 있습니다.

### 1) Firebase 프로젝트 설정

1. Firebase 콘솔에서 프로젝트를 생성합니다.
2. Firebase CLI를 설치하고 로그인합니다.
   ```bash
   npm install -g firebase-tools
   firebase login
   ```
3. Firebase 프로젝트를 초기화합니다.
   ```bash
   firebase init functions
   ```

---

### 2) Cloud Functions 작성

1. `functions/index.js` 파일을 열어 HTTP API를 작성합니다.
   ```javascript
   const functions = require('firebase-functions');

   exports.getUserData = functions.https.onRequest((req, res) => {
     const userId = req.query.id; // 클라이언트에서 전달받은 매개변수
     res.json({
       success: true,
       userId: userId,
       message: "User data fetched successfully",
     });
   });
   ```

---

### 3) Cloud Functions 배포

1. 작성한 함수를 배포합니다.
   ```bash
   firebase deploy --only functions
   ```
2. 배포 후 생성된 함수의 URL을 Firebase CLI 또는 콘솔에서 확인합니다.

---

### 4) Flutter에서 호출

1. `http` 패키지를 추가합니다.
   ```yaml
   dependencies:
     http: 최신_버전
   ```
2. Flutter 애플리케이션에서 Cloud Functions API를 호출합니다.
   ```dart
   import 'package:http/http.dart' as http;
   import 'dart:convert';

   Future<void> fetchUserData(String userId) async {
     final url = 'https://[REGION]-[PROJECT_ID].cloudfunctions.net/getUserData?id=$userId';
     final response = await http.get(Uri.parse(url));

     if (response.statusCode == 200) {
       final data = json.decode(response.body);
       print(data);
     } else {
       print("Failed to fetch data: ${response.statusCode}");
     }
   }
   ```

---

## 2. 외부 REST API 통합

Firebase를 사용하지 않는 외부 API를 Flutter 애플리케이션에서 호출하는 방법입니다.

### 1) `http` 패키지 추가

1. `pubspec.yaml`에 `http` 패키지를 추가하고 설치합니다.
   ```yaml
   dependencies:
     http: 최신_버전
   ```

---

### 2) Flutter에서 API 호출

1. API를 호출하여 데이터를 가져오거나 전송합니다.
   ```dart
   import 'package:http/http.dart' as http;
   import 'dart:convert';

   Future<void> fetchPosts() async {
     final url = 'https://jsonplaceholder.typicode.com/posts';
     final response = await http.get(Uri.parse(url));

     if (response.statusCode == 200) {
       final List<dynamic> posts = json.decode(response.body);
       print(posts);
     } else {
       print("Failed to fetch posts: ${response.statusCode}");
     }
   }
   ```

---

## 3. Firebase와 REST API 결합

### Firebase Authentication과 REST API 통합

1. Firebase Authentication을 사용하여 사용자 인증 후 API 요청에 인증 토큰을 추가합니다.
   ```dart
   import 'package:firebase_auth/firebase_auth.dart';
   import 'package:http/http.dart' as http;

   Future<void> fetchSecuredData() async {
     final user = FirebaseAuth.instance.currentUser;

     if (user != null) {
       final idToken = await user.getIdToken(); // Firebase 인증 토큰 가져오기
       final url = 'https://your-secured-api.com/data';
       final response = await http.get(
         Uri.parse(url),
         headers: {
           'Authorization': 'Bearer $idToken',
         },
       );

       if (response.statusCode == 200) {
         print("Data fetched: ${response.body}");
       } else {
         print("Failed to fetch data: ${response.statusCode}");
       }
     }
   }
   ```

---

## 결론

1. **Firebase와 연동하여 자체 API를 구축하려면** Firebase Cloud Functions를 활용하세요.
2. **외부 API를 사용하려면** `http` 패키지를 이용하여 호출할 수 있습니다.
3. **Firebase 인증과 외부 API를 결합하면** 사용자 인증을 강화한 REST API를 구축할 수 있습니다.

---

### 추가 내용

1. Firebase Cloud Functions는 별도의 서버를 구축하지 않고도 백엔드 로직을 작성할 수 있습니다.
2. 외부 API를 호출할 때는 네트워크 연결 상태와 에러 핸들링을 항상 고려하세요.
3. Firebase Authentication은 사용자 인증뿐만 아니라 API 호출 시 보안을 강화하는 데 유용합니다.
4. Flutter의 `http` 패키지는 간단한 REST API 호출에 적합하며, 복잡한 HTTP 클라이언트 기능이 필요할 경우 Dio 패키지를 고려할 수 있습니다.

