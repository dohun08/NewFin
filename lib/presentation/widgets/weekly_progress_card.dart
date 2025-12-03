import 'package:flutter/material.dart';
import '../../data/models/daily_mission_model.dart';
import '../../core/theme/app_theme.dart';

class WeeklyProgressCard extends StatelessWidget {
  final List<DailyMissionModel> weekMissions;

  const WeeklyProgressCard({
    super.key,
    required this.weekMissions,
  });

  @override
  Widget build(BuildContext context) {
    final completedDays = weekMissions.where((m) => m.isGrassEarned).length;
    final percentage = ((completedDays / 7) * 100).toInt();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            const Row(
              children: [
                Text(
                  '📊',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(width: 8),
                Text(
                  '이번 주 학습 현황',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 주간 바 차트
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
                final today = DateTime.now();
                final date = today.subtract(Duration(days: 6 - index));
                
                final mission = weekMissions.firstWhere(
                  (m) =>
                      m.date.year == date.year &&
                      m.date.month == date.month &&
                      m.date.day == date.day,
                  orElse: () => DailyMissionModel.empty(),
                );

                final isCompleted = mission.isGrassEarned;
                final isToday = date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;

                return _buildBar(
                  weekdays[index],
                  isCompleted,
                  isToday,
                );
              }),
            ),

            const SizedBox(height: 20),

            // 진행률 정보
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '이번 주: $completedDays일 학습 | 목표: 7일',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 자세히 보기 버튼
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: 학습 현황 상세 페이지로 이동
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('자세히 보기'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String label, bool isCompleted, bool isToday) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 80,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppTheme.secondaryColor
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
            border: isToday
                ? Border.all(
                    color: AppTheme.primaryColor,
                    width: 2,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? AppTheme.primaryColor : Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
