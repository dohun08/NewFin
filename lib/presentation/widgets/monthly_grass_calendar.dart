import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/daily_mission_model.dart';
import '../../core/theme/app_theme.dart';
import '../../presentation/providers/providers.dart';

class MonthlyGrassCalendar extends ConsumerStatefulWidget {
  const MonthlyGrassCalendar({super.key});

  @override
  ConsumerState<MonthlyGrassCalendar> createState() =>
      _MonthlyGrassCalendarState();
}

class _MonthlyGrassCalendarState extends ConsumerState<MonthlyGrassCalendar> {
  DateTime _selectedMonth = DateTime.now();

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final allMissionsAsync = ref.watch(allMissionsProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 및 월 네비게이션
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🌱',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(width: 6),
                      Text(
                        '학습 잔디',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _previousMonth,
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_selectedMonth.year}년 ${_selectedMonth.month}월',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _nextMonth,
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 캘린더 그리드
            allMissionsAsync.when(
              data: (missions) => _buildCalendar(missions),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(
                child: Text('캘린더를 불러올 수 없습니다: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(List<DailyMissionModel> missions) {
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    
    // 첫 날의 요일 (월요일=0, 일요일=6)
    final firstWeekday = (firstDayOfMonth.weekday - 1) % 7;
    
    // 전체 셀 개수 (빈 셀 + 실제 날짜)
    final totalCells = firstWeekday + lastDayOfMonth.day;
    final weekCount = (totalCells / 7).ceil();

    final today = DateTime.now();
    final isCurrentMonth = _selectedMonth.year == today.year && 
                          _selectedMonth.month == today.month;

    return Column(
      children: [
        // 요일 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['월', '화', '수', '목', '금', '토', '일']
              .map((day) => SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),

        const SizedBox(height: 8),

        // 날짜 그리드
        ...List.generate(weekCount, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                final cellIndex = weekIndex * 7 + dayIndex;
                final dayNumber = cellIndex - firstWeekday + 1;

                if (cellIndex < firstWeekday || dayNumber > lastDayOfMonth.day) {
                  return const SizedBox(width: 40, height: 40);
                }

                final date = DateTime(_selectedMonth.year, _selectedMonth.month, dayNumber);
                final mission = missions.firstWhere(
                  (m) => m.date.year == date.year && 
                         m.date.month == date.month && 
                         m.date.day == date.day,
                  orElse: () => DailyMissionModel.empty(),
                );

                final isToday = isCurrentMonth && 
                               date.day == today.day;

                return _buildDateCell(dayNumber, mission.grassLevel, isToday);
              }),
            ),
          );
        }),

        const SizedBox(height: 16),

        // 범례
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegend('없음', const Color(0xFFE0E0E0)),
            const SizedBox(width: 12),
            _buildLegend('연한 잔디', const Color(0xFF8DD8FF)),
            const SizedBox(width: 12),
            _buildLegend('진한 잔디', const Color(0xFF4F71FF)),
          ],
        ),

        const SizedBox(height: 16),

        // 연간 통계
        _buildAnnualStats(missions),
      ],
    );
  }

  Widget _buildDateCell(int day, GrassLevel level, bool isToday) {
    Color cellColor;
    switch (level) {
      case GrassLevel.dark:
        cellColor = const Color(0xFF4F71FF);
        break;
      case GrassLevel.light:
        cellColor = const Color(0xFF8DD8FF);
        break;
      case GrassLevel.none:
        cellColor = const Color(0xFFE0E0E0);
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(4),
        border: isToday
            ? Border.all(
                color: AppTheme.primaryColor,
                width: 2,
              )
            : null,
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: level == GrassLevel.none ? Colors.grey[700] : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildAnnualStats(List<DailyMissionModel> missions) {
    final currentYear = _selectedMonth.year;
    final yearMissions = missions.where((m) => m.date.year == currentYear).toList();
    final totalDays = yearMissions.where((m) => m.isGrassEarned).length;
    final lightGrass = yearMissions.where((m) => m.grassLevel == GrassLevel.light).length;
    final darkGrass = yearMissions.where((m) => m.grassLevel == GrassLevel.dark).length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '$currentYear년 학습 기록',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('총 학습일', '$totalDays일'),
              _buildStatItem('연한 잔디', '$lightGrass일'),
              _buildStatItem('진한 잔디', '$darkGrass일'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
}
