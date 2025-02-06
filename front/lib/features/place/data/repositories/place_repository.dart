import 'package:dio/dio.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';
import 'package:kkulkkulk/features/place/data/models/place_all_model.dart';
import 'package:kkulkkulk/features/place/data/models/place_response_model.dart';
import 'package:kkulkkulk/features/place/data/models/search_place_all_model.dart';

class PlaceRepository {
  final Dio _dio = DioClient().dio;

  // 클라이밍 장소 전체 조회(GPS 거리순)
  Future<List<PlaceResponseModel>> getAllDisCLimbs(PlaceAllModel placeAllModel) async {
    try {
      final response = await _dio.get(
        '/api/climbground/all/user-location',
        queryParameters: {
          "latitude": placeAllModel.latitude,
          "longitude": placeAllModel.longitude,
        }
      );
      List<dynamic> data = response.data['content'];
      return data.map((json) => PlaceResponseModel.fromJson(json)).toList();
    } catch(e) {
      rethrow;
    }
  }

  // 클라이밍 장소 검색어 조회(GPS 거리순)
  Future<List<PlaceResponseModel>> searchClimbGround(SearchPlaceAllModel searchPlaceAllModel) async {
    try {
      final response = await _dio.get(
        '/api/climbground/search',
        queryParameters: {
          "keyword": searchPlaceAllModel.keyword,
          "latitude": searchPlaceAllModel.latitude,
          "longitude": searchPlaceAllModel.longitude,
        }
      );
      if(response.statusCode == 200) {
        List<dynamic> data = response.data['content'];
        return data.map((json) => PlaceResponseModel.fromJson(json)).toList();
      }else {
        return [];
      }
    } catch(e) {
      rethrow;
    }
  }
}