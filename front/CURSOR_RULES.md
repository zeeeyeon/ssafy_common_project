# 프로젝트 규칙 및 가이드라인

## 1. 기본 설정
- equatable, dio, riverpod (어노테이션 없이) 사용
- Riverpod을 사용한 상태관리
- 추천 라이브러리 사용 가능
- 재사용 가능한 위젯은 components 폴더에서 관리

## 2. 기본 규칙
- 시니어 풀스택 앱개발자 수준의 코드 품질 유지
- 단계별 계획을 세우고 구현
- DRY 원칙 준수 (중복 코드 최소화)
- 가독성과 성능을 모두 고려한 구현
- 요청된 모든 기능의 완전한 구현
- 간결한 코드와 필수적인 설명만 포함
- 불확실한 부분은 명시적으로 표현

## 3. 프로젝트 구조 

your-flutter-project/
├── lib/
│ ├── features/ # Feature 단위 관리
│ │ ├── featureName/ # 기능별 폴더
│ │ │ ├── screens/ # View(UI) 관리
│ │ │ ├── viewModels/ # ViewModel 상태 관리
│ │ │ ├── data/ # 데이터 처리 및 API 호출
│ │ │ └── components/ # 해당 기능 전용 컴포넌트
│ │ └── ...
│ ├── common/ # 공통 모듈 관리
│ │ ├── components/ # 재사용 가능한 공통 컴포넌트
│ │ ├── utils/ # 유틸리티 함수 및 클래스
│ │ ├── providers/ # 전역 상태 관리
│ │ ├── api/ # API 관련 설정
│ │ └── constants/ # 상수 정의
│ └── main.dart # 앱 진입점


## 4. 코딩 컨벤션
### 네이밍
- 클래스, 변수, 함수: camelCase
- 파일 이름: snake_case
- 상수: UPPER_SNAKE_CASE
- 변수이름 선언할때 _ 사용하지 않기 ex) _calendarScreenState -> calendarScreenStat

### API 및 데이터
- API 호출: Dio + Repository 패턴 사용
- 모델 클래스: Equatable 사용
- 컴포넌트: 재사용성 고려한 파라미터화

## 5. Git 규칙
### 브랜치 구조
- `main`: 프로덕션 코드
- `develop`: 개발 기본 브랜치
- `feature/*`: 새로운 기능 개발
- `hotfix/*`: 긴급 버그 수정
- `release/*`: 배포 준비

### 브랜치 네이밍
- Feature: `[FE]feature/login`
- Hotfix: `[FE]hotfix/login-crash`
- Release: `[FE]release/v1.0.0`

### Pull Request
- 제목: `[JIRA-123] type: 작업내용`
- 본문: 변경사항, 테스트여부 필수 작성
- 리뷰어: 최소 1명 이상 지정

### 브랜치 관리
- feature 브랜치는 develop에 머지 후 삭제
- develop은 정기 배포시 main에 머지
- hotfix는 main과 develop 모두에 머지

## 6. 상태 관리 (Riverpod)
### 기본 원칙
- 모든 상태 관리는 Riverpod 사용
- StateNotifier: 단순 상태 관리
- AsyncNotifier: 비동기 상태 관리

### 네이밍 규칙
- Provider: `*_provider` (예: counterProvider)
- NotifierProvider: `*_notifier` (예: counterNotifier)

### 구현 가이드
- 상태 변경은 NotifierProvider 내부에서만 수행
- View에서는 ref.watch() 또는 ref.listen()만 사용
- 전역 상태: common/providers/ 폴더에 정의
- Feature별 상태: 해당 feature의 viewModels/ 폴더에 정의

### Provider 사용 패턴
- 읽기 전용 데이터: Provider
- 단순 상태 관리: StateProvider
- 복잡한 상태 관리: StateNotifierProvider
- 비동기 상태 관리: AsyncNotifierProvider

## 7. 보안 가이드라인
- API 키, 시크릿 등은 .env 파일에서 관리
- 민감한 정보는 git에 커밋하지 않음
- 보안 관련 설정은 common/config/security.dart에서 관리

## 8. 성능 최적화
- 불필요한 빌드 최소화
- 이미지 최적화 필수
- 메모리 누수 방지
- const 생성자 적극 활용