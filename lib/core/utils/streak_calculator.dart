import '../../data/models/daily_mission_model.dart';
import 'dart:math';

class StreakCalculator {
  // 현재 연속 일수 계산
  static int calculateCurrentStreak(List<DailyMissionModel> missions) {
    if (missions.isEmpty) return 0;

    int streak = 0;
    final today = DateTime.now();

    // 최신순으로 정렬
    final sortedMissions = List<DailyMissionModel>.from(missions)
      ..sort((a, b) => b.date.compareTo(a.date));

    for (int i = 0; i < sortedMissions.length; i++) {
      final expectedDate = DateTime(
        today.year,
        today.month,
        today.day - i,
      );

      final mission = sortedMissions.firstWhere(
        (m) => _isSameDay(m.date, expectedDate),
        orElse: () => DailyMissionModel.empty(),
      );

      if (mission.isGrassEarned) {
        streak++;
      } else {
        break; // 연속 끊김
      }
    }

    return streak;
  }

  // 역대 최고 기록 계산
  static int calculateMaxStreak(List<DailyMissionModel> allMissions) {
    if (allMissions.isEmpty) return 0;

    int maxStreak = 0;
    int currentStreak = 0;

    // 날짜순 정렬
    final sortedMissions = List<DailyMissionModel>.from(allMissions)
      ..sort((a, b) => a.date.compareTo(b.date));

    DateTime? lastDate;

    for (var mission in sortedMissions) {
      if (mission.isGrassEarned) {
        // 연속인지 확인
        if (lastDate == null ||
            _isNextDay(lastDate, mission.date) ||
            _isSameDay(lastDate, mission.date)) {
          currentStreak++;
          maxStreak = max(maxStreak, currentStreak);
        } else {
          currentStreak = 1; // 새로운 스트릭 시작
        }
        lastDate = mission.date;
      } else {
        currentStreak = 0;
        lastDate = null;
      }
    }

    return maxStreak;
  }

  // 같은 날인지 확인
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // 다음 날인지 확인
  static bool _isNextDay(DateTime date1, DateTime date2) {
    final nextDay = DateTime(date1.year, date1.month, date1.day + 1);
    return _isSameDay(nextDay, date2);
  }
}
