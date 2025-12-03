import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/daily_mission_model.dart';
import '../../core/utils/streak_calculator.dart';
import '../providers/providers.dart';

class GrassColors {
  static const none = Color(0xFFE0E0E0); // 회색 - 미완료
  static const light = Color(0xFF8DD8FF); // 연보라
  static const dark = Color(0xFF4F71FF); // 진보라
  static const todayBorder = Color(0xFF5409DB); // 오늘 테두리
  static const streakFire = Color(0xFF5409DB); // 불꽃 강조
}

class GrassCalendar extends ConsumerWidget {
  const GrassCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentMissionsAsync = ref.watch(recentMissionsProvider);
    final allMissionsAsync = ref.watch(allMissionsProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            const Text(
              '📅 이번 달 학습 기록',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 요일 라벨
            _buildWeekdayLabels(),
            const SizedBox(height: 8),

            // 잔디 그리드
            recentMissionsAsync.when(
              data: (missions) => _buildGrassGrid(missions),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('로딩 실패: $err'),
            ),

            const SizedBox(height: 16),

            // 스트릭 정보
            allMissionsAsync.when(
              data: (allMissions) => _buildStreakInfo(allMissions),
              loading: () => const SizedBox(),
              error: (err, stack) => const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayLabels() {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        return SizedBox(
          width: 40,
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGrassGrid(List<DailyMissionModel> missions) {
    final today = DateTime.now();
    final List<DateTime> last28Days = List.generate(28, (index) {
      return DateTime(today.year, today.month, today.day - (27 - index));
    });

    // 4주 x 7일 그리드로 재구성
    final List<List<DateTime>> weeks = [];
    for (int i = 0; i < 4; i++) {
      weeks.add(last28Days.sublist(i * 7, (i + 1) * 7));
    }

    return Column(
      children: weeks.map((week) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: week.map((date) {
              return _buildGrassCell(date, missions);
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGrassCell(DateTime date, List<DailyMissionModel> missions) {
    final today = DateTime.now();
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    final isFuture = date.isAfter(today);

    final mission = missions.firstWhere(
      (m) =>
          m.date.year == date.year &&
          m.date.month == date.month &&
          m.date.day == date.day,
      orElse: () => DailyMissionModel.empty(),
    );

    Color cellColor;
    if (isFuture) {
      cellColor = GrassColors.none;
    } else {
      switch (mission.grassLevel) {
        case GrassLevel.dark:
          cellColor = GrassColors.dark;
          break;
        case GrassLevel.light:
          cellColor = GrassColors.light;
          break;
        case GrassLevel.none:
          cellColor = GrassColors.none;
          break;
      }
    }

    return GestureDetector(
      onTap: () => _showMissionDetail(date, mission),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(6),
          border: isToday
              ? Border.all(color: GrassColors.todayBorder, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 10,
              color: mission.isGrassEarned ? Colors.white : Colors.grey[700],
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  void _showMissionDetail(DateTime date, DailyMissionModel mission) {
    // TODO: 바텀시트로 미션 상세 표시
  }

  Widget _buildStreakInfo(List<DailyMissionModel> allMissions) {
    final currentStreak = StreakCalculator.calculateCurrentStreak(allMissions);
    final maxStreak = StreakCalculator.calculateMaxStreak(allMissions);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GrassColors.streakFire.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                '$currentStreak일 연속!',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: GrassColors.streakFire,
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 20,
            color: Colors.grey[300],
          ),
          Text(
            '최고: $maxStreak일',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
