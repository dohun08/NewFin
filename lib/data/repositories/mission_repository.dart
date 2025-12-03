import '../datasources/local/database_helper.dart';
import '../models/daily_mission_model.dart';
import 'package:uuid/uuid.dart';

class MissionRepository {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  MissionRepository(this._dbHelper);

  // 오늘 미션 가져오기 (없으면 생성)
  Future<DailyMissionModel> getTodayMission() async {
    var missionData = await _dbHelper.getTodayMission();

    if (missionData == null) {
      // 새로운 미션 생성 (로그인은 자동 체크)
      await _dbHelper.createTodayMission(_uuid.v4());
      missionData = await _dbHelper.getTodayMission();
    }

    return _convertToModel(missionData!);
  }

  // 뉴스 읽기 미션 업데이트 (2개 이상 읽으면 완료)
  Future<void> updateNewsReadMission(int readCount) async {
    final completed = readCount >= 2;
    await _dbHelper.updateMissionNewsRead(completed);
  }

  // 퀴즈 미션 업데이트 (80% 이상이면 완료)
  Future<void> updateQuizMission(double score) async {
    final completed = score >= 0.8;
    await _dbHelper.updateMissionQuizCompleted(completed);
  }

  // 최근 N일 미션 가져오기
  Future<List<DailyMissionModel>> getRecentMissions(int days) async {
    final results = await _dbHelper.getRecentMissions(days);
    return results.map((data) => _convertToModel(data)).toList();
  }

  // 전체 미션 가져오기 (스트릭 계산용)
  Future<List<DailyMissionModel>> getAllMissions() async {
    final results = await _dbHelper.getAllMissions();
    return results.map((data) => _convertToModel(data)).toList();
  }

  // DB 데이터를 모델로 변환
  DailyMissionModel _convertToModel(Map<String, dynamic> data) {
    return DailyMissionModel(
      id: data['id'] as String,
      date: DateTime.parse(data['date'] as String),
      newsRead: (data['news_read'] as int) == 1,
      quizCompleted: (data['quiz_completed'] as int) == 1,
      loginChecked: (data['login_checked'] as int) == 1,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'] as String)
          : null,
    );
  }
}
