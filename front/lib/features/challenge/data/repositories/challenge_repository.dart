// import 'package:kkulkkulk/common/exceptions/exceptions.dart';
import 'package:dio/dio.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';
import 'package:kkulkkulk/features/challenge/data/models/challenge_all_model.dart';
import 'package:kkulkkulk/features/challenge/data/models/challenge_response_model.dart';
import 'package:kkulkkulk/features/challenge/data/models/detail_challenge_model.dart';
import 'package:kkulkkulk/features/challenge/data/models/detail_challenge_response_model.dart';
import 'package:kkulkkulk/features/challenge/data/models/search_challenge_all_model.dart';

class ChallengeRepository {
  final Dio _dio = DioClient().dio;

  // 챌린지 장소 전체 조회(GPS 거리순)
  Future<List<ChallengeResponseModel>> getAllChallenges(ChallengeAllModel challengeAllModel) async {
    try {
      final response = await _dio.get(
        '/api/climbground/lock-climbground/list',
        queryParameters: {
          "userId": challengeAllModel.userId,
          "latitude": challengeAllModel.latitude,
          "longitude": challengeAllModel.longitude,
        }
      );
      List<dynamic> data = response.data['content'];
      return data.map<ChallengeResponseModel>((json) => ChallengeResponseModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // 챌린지 장소 검색 조회
  Future<List<ChallengeResponseModel>> searchGetAllChallenges(SearchChallengeAllModel searchhallengeAllModel) async {
    try {
      final response = await _dio.get(
        'api/climbground/lock-glimbground/',
        queryParameters: {
          "userId": searchhallengeAllModel.userId,
          "latitude": searchhallengeAllModel.latitude,
          "longitude": searchhallengeAllModel.longitude,
        }
      );
      List<dynamic> data = response.data['content'];
      return data.map<ChallengeResponseModel>((json) => ChallengeResponseModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // 챌린지 장소 상세 조회
  Future<DetailChallengeResponseModel> detailChallenge(DetailChallengeModel detailChallengeModel) async {
      try {
        final response = await _dio.get(
          '/api/climbground/lock-climbground/detail',
          queryParameters: {
            "userId": detailChallengeModel.userId,
            "latitude": detailChallengeModel.latitude,
            "longitude": detailChallengeModel.longitude,
          }
        );
        return DetailChallengeResponseModel.fromJson(response.data['content']);
      } catch (e) {
        rethrow;
      }
  }
}
