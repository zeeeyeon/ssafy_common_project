// import 'package:kkulkkulk/common/exceptions/exceptions.dart';
import 'package:dio/dio.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';
import 'package:kkulkkulk/features/challenge/data/models/challenge_all_model.dart';
import 'package:kkulkkulk/features/challenge/data/models/challenge_response_model.dart';
import 'package:kkulkkulk/features/challenge/data/models/detail_challenge_response_model.dart';
import 'package:kkulkkulk/features/challenge/data/models/near_challenge_model.dart';
import 'package:kkulkkulk/features/challenge/data/models/search_challenge_all_model.dart';
import 'package:kkulkkulk/features/challenge/data/models/unlock_challenge_model.dart';

class ChallengeRepository {
  final Dio _dio = DioClient().dio;

  // 챌린지 장소 전체 조회(GPS 거리순)
  Future<List<ChallengeResponseModel>> getAllChallenges(
      ChallengeAllModel challengeAllModel) async {
    try {
      final response = await _dio
          .get('/api/climbground/lock-climbground/list', queryParameters: {
        "latitude": challengeAllModel.latitude,
        "longitude": challengeAllModel.longitude,
      });
      List<dynamic> data = response.data['content'];
      return data
          .map<ChallengeResponseModel>(
              (json) => ChallengeResponseModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // 챌린지 장소 검색 조회
  Future<List<ChallengeResponseModel>> searchGetAllChallenges(
      SearchChallengeAllModel searchhallengeAllModel) async {
    try {
      final response = await _dio
          .get('/api/climbground/lock-climbground/search', queryParameters: {
        "keyword": searchhallengeAllModel.keyword,
        "latitude": searchhallengeAllModel.latitude,
        "longitude": searchhallengeAllModel.longitude,
      });
      List<dynamic> data = response.data['content'];
      return data
          .map<ChallengeResponseModel>(
              (json) => ChallengeResponseModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // 해당 반경 안의 해금 가능한 챌린지 장소 조회
  Future<ChallengeResponseModel> searchNearChallenges(
      NearChallengeModel nearChallengeModel) async {
    try {
      final response = await _dio
          .get('/api/climbground/lock-climbground/first', queryParameters: {
        "latitude": nearChallengeModel.latitude,
        "longitude": nearChallengeModel.longitude
      });
      ChallengeResponseModel data =
          ChallengeResponseModel.fromJson(response.data['content']);
      return data;
    } catch (e) {
      rethrow;
    }
  }

  // 챌린지 장소 해금
  Future<Response> unlockChallenge(
      UnlockChallengeModel unlockChallengeModel) async {
    print('시작');

    try {
      final response = await _dio.post('/api/record/unlock', data: {
        "climbGroundId": unlockChallengeModel.climbGroundId,
        "latitude": unlockChallengeModel.latitude,
        "longitude": unlockChallengeModel.longitude,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // 챌린지 장소 상세 조회
  Future<DetailChallengeResponseModel> detailChallenge(
      int climbGroundId) async {
    try {
      final response = await _dio
          .get('/api/climbground/lock-climbground/detail', queryParameters: {
        "climbGroundId": climbGroundId,
      });
      return DetailChallengeResponseModel.fromJson(response.data['content']);
    } catch (e) {
      rethrow;
    }
  }

  // 500m 내에 있는 장소 조회
  Future<ChallengeResponseModel> nearChallenge(
      NearChallengeModel nearChallengeModel) async {
    try {
      final response = await _dio
          .get('/api/climbground/lock-climbground/first', queryParameters: {
        "latitude": nearChallengeModel.latitude,
        "longitude": nearChallengeModel.longitude,
      });
      return ChallengeResponseModel.fromJson(response.data['content']);
    } catch (e) {
      rethrow;
    }
  }
}
