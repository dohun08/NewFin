import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_mission_model.freezed.dart';
part 'daily_mission_model.g.dart';

enum GrassLevel {
  none,   // 회색 - 미완료
  light,  // 연보라 - 미션 2개
  dark,   // 진보라 - 미션 3개
}

@freezed
class DailyMissionModel with _$DailyMissionModel {
  const DailyMissionModel._();

  const factory DailyMissionModel({
    required String id,
    required DateTime date,
    @Default(false) bool newsRead,        // 뉴스 2개 읽음
    @Default(false) bool quizCompleted,   // 퀴즈 1세트 완료
    @Default(false) bool loginChecked,    // 로그인
    DateTime? createdAt,
  }) = _DailyMissionModel;

  factory DailyMissionModel.fromJson(Map<String, dynamic> json) =>
      _$DailyMissionModelFromJson(json);

  // 완료된 미션 개수
  int get completedCount {
    int count = 0;
    if (newsRead) count++;
    if (quizCompleted) count++;
    if (loginChecked) count++;
    return count;
  }

  // 잔디 획득 여부 (2개 이상 달성)
  bool get isGrassEarned => completedCount >= 2;

  // 잔디 레벨
  GrassLevel get grassLevel {
    if (completedCount == 3) return GrassLevel.dark;  // 진보라
    if (completedCount == 2) return GrassLevel.light; // 연보라
    return GrassLevel.none; // 회색
  }

  // 빈 미션 생성
  factory DailyMissionModel.empty() {
    return DailyMissionModel(
      id: '',
      date: DateTime.now(),
    );
  }
}
