import 'package:dio/dio.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';
import 'package:kkulkkulk/features/place/data/models/place_all_model.dart';
import 'package:kkulkkulk/features/place/data/models/place_all_pagination_model.dart';
import 'package:kkulkkulk/features/place/data/models/place_detail_model.dart';
import 'package:kkulkkulk/features/place/data/models/place_response_model.dart';
import 'package:kkulkkulk/features/place/data/models/search_place_all_model.dart';

class PlaceRepository {
  final Dio _dio = DioClient().dio;

  // 클라이밍 장소 전체 조회(GPS 거리순)
  Future<List<PlaceResponseModel>> getAllDisCLimbs(
      PlaceAllModel placeAllModel) async {
    try {
      final response = await _dio
          .get('/api/climbground/all/user-location', queryParameters: {
        "latitude": placeAllModel.latitude,
        "longitude": placeAllModel.longitude,
      });
      List<dynamic> data = response.data['content'];
      return data.map((json) => PlaceResponseModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // 클라이밍 장소 전체 조회(페이지네이션 스크롤 최적화, GPS 거리순)
  Future<List<PlaceResponseModel>> getAllDisClimbsPagination(
      PlaceAllPaginationModel placeAllPaginationModel) async {
    try {
      final response = await _dio
          .get('/api/climbground/all/user-location', queryParameters: {
        "latitude": placeAllPaginationModel.latitude,
        "longitude": placeAllPaginationModel.longitude,
        "page": placeAllPaginationModel.page,
      });
      List<dynamic> data = response.data['content'];
      return data.map((json) => PlaceResponseModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // 클라이밍 장소 전체 조회(GPS 거리순)
  Future<List<PlaceResponseModel>> searchClimbGround(
      SearchPlaceAllModel searchPlaceAllModel) async {
    try {
      final response =
          await _dio.get('/api/climbground/search', queryParameters: {
        "keyword": searchPlaceAllModel.keyword,
        "latitude": searchPlaceAllModel.latitude,
        "longitude": searchPlaceAllModel.longitude,
      });
      if (response.statusCode == 200) {
        List<dynamic> data = response.data['content'];
        return data.map((json) => PlaceResponseModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }

  // 클라이밍 장소 상세 조회
  Future<PlaceDetailModel> detailClimb(int climbground) async {
    try {
      final response = await _dio.get('/api/climbground/detail/$climbground');
      if (response.statusCode == 200) {
        // response.data에서 'content' 키로 장소 상세 데이터를 가져와서 모델로 변환
        var placeDetailData = response.data['content'];
        print(placeDetailData);
        return PlaceDetailModel.fromJson(placeDetailData); // 단일 객체 반환
      } else {
        throw Exception('Failed to load place details');
      }
    } catch (e) {
      rethrow;
    }
  }
}
