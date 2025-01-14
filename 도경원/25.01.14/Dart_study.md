# Dart 언어의 핵심 개념과 예제

---

## 1. 기본 데이터 타입
Dart는 기본적으로 다음과 같은 데이터 타입을 지원합니다:

- `int`, `double` (숫자 타입)
- `String` (문자열)
- `bool` (논리 타입)
- `List` (리스트)
- `Map` (키-값 쌍)

```dart
void main() {
  int age = 25;
  double pi = 3.14;
  String name = 'Chaekwang';
  bool isStudent = true;

  print('Name: $name, Age: $age, Pi: $pi, Is Student: $isStudent');
}
```

---

## 2. 변수 선언과 `var`, `final`, `const`

- `var`: 타입 추론 사용
- `final`: 값을 변경할 수 없음 (런타임 상수)
- `const`: 컴파일타임 상수

```dart
void main() {
  var city = 'Seoul'; // 타입 추론
  final country = 'Korea'; // 변경 불가
  const pi = 3.14159; // 상수

  print('City: $city, Country: $country, Pi: $pi');
}
```

---

## 3. 조건문과 반복문

Dart는 `if`, `else`, `for`, `while`, `do-while` 같은 제어 구조를 지원합니다.

```dart
void main() {
  int score = 85;

  if (score >= 90) {
    print('A grade');
  } else if (score >= 80) {
    print('B grade');
  } else {
    print('C grade');
  }

  for (int i = 0; i < 3; i++) {
    print('Count: $i');
  }
}
```

---

## 4. 함수 선언과 람다식

Dart에서는 함수도 객체입니다. 따라서 익명 함수나 화살표 함수(람다)를 사용할 수 있습니다.

```dart
// 일반 함수
int add(int a, int b) {
  return a + b;
}

// 화살표 함수
int subtract(int a, int b) => a - b;

void main() {
  print(add(5, 3));       // 8
  print(subtract(5, 3));  // 2
}
```

---

## 5. 클래스와 객체

Dart는 객체지향 언어로, 클래스와 객체를 사용해 코드를 구조화합니다.

```dart
class Person {
  String name;
  int age;

  // 생성자
  Person(this.name, this.age);

  void greet() {
    print('Hi, my name is $name and I am $age years old.');
  }
}

void main() {
  var person = Person('Chaekwang', 27);
  person.greet();
}
```

---

## 6. Null-safety와 `?`, `!` 연산자

Dart는 null-safety를 지원하여 변수의 null 가능성을 명시합니다:

- `?`: 값이 null일 수 있음
- `!`: null 아님을 보장
- `??`: null일 경우 기본값 제공

```dart
void main() {
  String? nullableName; // null 가능
  nullableName = 'Chaekwang';
  print(nullableName ?? 'Unknown'); // 기본값: 'Unknown'
}
```

---

## 7. List와 Map

Dart에서 리스트와 맵은 매우 자주 사용됩니다.

```dart
void main() {
  // 리스트
  List<int> numbers = [1, 2, 3];
  numbers.add(4);
  print(numbers); // [1, 2, 3, 4]

  // 맵
  Map<String, String> capitals = {'Korea': 'Seoul', 'Japan': 'Tokyo'};
  capitals['USA'] = 'Washington D.C.';
  print(capitals); // {Korea: Seoul, Japan: Tokyo, USA: Washington D.C.}
}
```

---

## 8. Future와 비동기 처리

### 비동기 처리란?
비동기(asynchronous)란 작업이 완료될 때까지 기다리지 않고, 다른 작업을 수행할 수 있는 프로그래밍 방식을 의미합니다. 예를 들어, 데이터를 서버에서 가져오는 동안 애플리케이션이 멈추지 않고 다른 UI 작업을 계속 처리할 수 있습니다.

Dart에서 비동기 처리는 `Future`를 사용하며, `async`와 `await` 키워드로 관리합니다.

### Future 사용 예제

```dart
Future<String> fetchData() async {
  await Future.delayed(Duration(seconds: 2)); // 2초 대기
  return 'Data loaded';
}

void main() async {
  print('Fetching data...');
  String data = await fetchData();
  print(data);
}
```

### 추가 설명
1. `Future`: 미래의 값을 나타냅니다. 비동기 작업의 결과가 준비되면 해당 값을 반환합니다.
2. `async`: 함수가 비동기 작업을 포함하고 있음을 나타냅니다.
3. `await`: 비동기 작업이 완료될 때까지 기다립니다.

### 콜백 없이 Future 사용하기
`then` 메서드를 사용하면 콜백으로 비동기 작업 결과를 처리할 수 있습니다.

```dart
void main() {
  Future.delayed(Duration(seconds: 2), () {
    return 'Data loaded';
  }).then((data) {
    print(data);
  });
  print('Fetching data...');
}
```

위와 같은 방식으로 콜백을 활용하여 비동기 처리를 수행할 수도 있지만, `async`와 `await`이 더 읽기 쉽고 직관적입니다.

---

## 9. 익명 함수와 고차 함수

Dart는 함수형 프로그래밍 스타일을 지원하며, 함수 자체를 인수로 전달할 수 있습니다.

```dart
void main() {
  List<int> numbers = [1, 2, 3, 4];
  
  // map 함수로 리스트 변환
  var squared = numbers.map((num) => num * num).toList();
  print(squared); // [1, 4, 9, 16]
}
```

---
