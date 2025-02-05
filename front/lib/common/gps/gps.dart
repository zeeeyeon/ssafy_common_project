import 'package:geolocator/geolocator.dart';

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  print("tlwkrsajkdhasjdhsakjdhsakjdhaskjdsh");
  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the 
    // App to enable the location services.
    print("위치정보 허용안함");
    return null;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print('위치 권한이 거부되었습니다.'); 
      return;
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    print('위치 권한이 거부되었습니다.'); 
    return;
  } 

  //현재 위치 구하기
  Position position = await Geolocator.getCurrentPosition(
  );
  return position;
}