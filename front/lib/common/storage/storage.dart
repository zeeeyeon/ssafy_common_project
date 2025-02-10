import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static Future<SharedPreferences> getStorage() async {
    return await SharedPreferences.getInstance();
  }

  // 토큰 저장
  static Future<void> saveToken(String token) async {
    final storage = await getStorage();
    await storage.setString('jwt_token', token);
  }

  // 저장된 토큰 반환
  static Future<String?> getToken() async {
    final storage = await getStorage();
    return storage.getString('jwt_token');
  }

  // 토큰 삭제
  static Future<void> removeToken() async {
    final storage = await getStorage();
    await storage.remove('jwt_token');
  }
}