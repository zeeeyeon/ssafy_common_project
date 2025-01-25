# Flutter 날씨 앱 핵심 요약

## 1. 위치 데이터 처리
Flutter 앱에서 **Geolocator 패키지**를 사용하여 GPS 좌표(위도, 경도)를 가져옵니다.

### 주요 코드
```dart
Future<Position> _determinePosition() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied.');
    }
  }

  return await Geolocator.getCurrentPosition();
}
```

### 핵심 포인트
- `isLocationServiceEnabled`: 위치 서비스 활성화 여부 확인.
- `requestPermission`: 위치 권한 요청.
- `getCurrentPosition`: GPS 좌표(위도, 경도) 가져오기.

---

## 2. OpenWeatherMap API로 날씨 데이터 가져오기
**OpenWeatherMap API**를 호출하여 현재 위치 기반의 날씨 데이터를 가져옵니다. JSON 데이터를 파싱하여 도시 이름, 온도, 날씨 설명 등을 추출합니다.

### 주요 코드
```dart
Future<void> _getWeather() async {
  Position position = await _determinePosition();
  double latitude = position.latitude;
  double longitude = position.longitude;

  const String apiKey = 'YOUR_API_KEY';
  final url =
      'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=metric&appid=$apiKey';

  final response = await http.get(Uri.parse(url));
  final data = jsonDecode(response.body);

  setState(() {
    _cityName = data['name'];
    _temperature = '${data['main']['temp']}°C';
    _description = data['weather'][0]['description'];
  });
}
```

### 핵심 포인트
- `API 요청 URL 구성`: `lat`, `lon`, `appid`를 포함한 URL 생성.
- `http.get`: OpenWeatherMap에서 JSON 데이터를 요청 및 수신.
- `JSON 파싱`: 필요한 값(`name`, `temp`, `description`)을 추출하여 상태 업데이트.

---

## 3. 간단하고 보기 좋은 UI 설계
카드 스타일의 컨테이너를 사용해 **도시 이름, 온도, 날씨 설명**을 표시합니다.

### 주요 코드
```dart
Center(
  child: Container(
    padding: const EdgeInsets.all(20.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _cityName ?? '',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _temperature ?? '',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _description ?? '',
          style: const TextStyle(
            fontSize: 20,
            fontStyle: FontStyle.italic,
            color: Colors.black54,
          ),
        ),
      ],
    ),
  ),
)
```

### 핵심 포인트
- `Container`: 둥근 모서리와 그림자 효과로 카드 스타일 적용.
- `텍스트 스타일링`: 도시 이름, 온도, 날씨 설명에 적절한 폰트 크기와 색상 사용.
- `간격 조정`: `SizedBox`를 사용하여 요소 간의 간격 추가.

---

## 요약
1. **위치 데이터 처리**: GPS 좌표를 가져오기 위해 권한 요청 및 활성화 확인.
2. **API 데이터 가져오기**: OpenWeatherMap API를 통해 JSON 데이터를 가져와 파싱.
3. **UI 설계**: 카드 스타일로 보기 좋은 날씨 정보 화면 구성.

