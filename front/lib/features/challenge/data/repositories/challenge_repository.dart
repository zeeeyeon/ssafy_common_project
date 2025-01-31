// import 'package:kkulkkulk/common/exceptions/exceptions.dart';
import 'package:kkulkkulk/features/challenge/data/models/challenge_model.dart';

class ChallengeRepository {
  Future<List<ChallengeModel>> getChallenges() async {
    // 테스트를 위한 임시 코드
    await Future.delayed(const Duration(seconds: 2)); // 로딩 상태 확인용 딜레이

    // 네트워크 에러 테스트
    // throw NetworkException();

    // // 1. 빈 데이터 테스트
    // return [];

    // 2. 네트워크 에러 테스트
    // throw NetworkException();

    // 3. 서버 에러 테스트
    // throw ServerException();

    // 4. 알 수 없는 에러 테스트
    // throw Exception('Unknown error');

    // 5. 정상 데이터 테스트
    return [
      ChallengeModel(
        id: '1',
        title: '30일 운동 챌린지',
        description: '매일 30분 운동하기',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      ),
    ];
  }
}
