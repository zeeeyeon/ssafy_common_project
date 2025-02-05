import 'package:dio/dio.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';
import 'package:kkulkkulk/features/place/data/models/place_all_model.dart';

class PlaceRepository {
  final Dio _dio = DioClient().dio;

  // 클라이밍 장소 전체 조회(GPS 거리순)
  Future<Response> getAllDisCLimbs(PlaceAllModel placeAllModel) async {
    try {
      final response = await _dio.get(
        '/api/climbground/all/user-location',
        data: placeAllModel.toJson(),
      );
      return response;
    } catch(e) {
      rethrow;
    }
  }
}