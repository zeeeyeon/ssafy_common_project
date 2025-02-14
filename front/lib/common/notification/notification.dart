import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotification =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 안드로이드 초기화 설정
    AndroidInitializationSettings initSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/rock3');

    // iOS 초기화 설정 (필요시 권한 요청을 추가할 수 있음)
    DarwinInitializationSettings initSettingsIOS =
        const DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    // 전체 초기화 설정
    InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    // 초기화
    await _localNotification.initialize(initSettings);

    // 안드로이드에서 알림 채널 설정
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'alarm_1', // 채널 ID
      '1번 푸시', // 채널 이름
      description: '푸시 알림 채널 설명', // 채널 설명
      importance: Importance.max, // 중요도
    );

    // 채널 등록
    await _localNotification
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // 알림 세부 설정
  final NotificationDetails _details = const NotificationDetails(
    android: AndroidNotificationDetails(
      'alarm_1', // 채널 ID (위에서 설정한 ID)
      '1번 푸시', // 채널 이름
      channelDescription: '푸시 알림 채널 설명',
      importance: Importance.max, // 중요도
      priority: Priority.high, // 우선순위
      showWhen: false, // 표시 시간 숨김
      visibility: NotificationVisibility.public, // Heads-up Notification
      fullScreenIntent: true, // 화면에 바로 띄우기
    ),
  );

  // 알림 표시 함수
  Future<void> showPushAlarm(String title, String content) async {
    await _localNotification.show(
      0, // 알림 ID
      title, // 알림 제목
      content, // 알림 내용
      _details, // 알림 세부 설정
      payload: 'deepLink', // 알림 클릭 시 처리할 페이로드
    );
  }
}
