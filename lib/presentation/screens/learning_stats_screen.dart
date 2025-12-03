import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/models/daily_mission_model.dart';
import '../../core/utils/streak_calculator.dart';
import '../providers/providers.dart';
import '../widgets/weekly_progress_card.dart';
import '../widgets/badge_section.dart';
import '../widgets/monthly_grass_calendar.dart';

class LearningStatsScreen extends ConsumerStatefulWidget {
  const LearningStatsScreen({super.key});

  @override
  ConsumerState<LearningStatsScreen> createState() =>
      _LearningStatsScreenState();
}

class _LearningStatsScreenState extends ConsumerState<LearningStatsScreen> {
  int _learnedTermsCount = 0;
  int _readNewsCount = 0;
  int _currentStreak = 0;
  int _maxStreak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
    });

    final db = DatabaseHelper();
    final termsCount = await db.getLearnedTermsCount();
    final newsCount = await db.getReadNewsCount();
    final allMissionsMap = await db.getAllMissions();
    final allMissions = allMissionsMap.map((data) {
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
    }).toList();

    final currentStreak = StreakCalculator.calculateCurrentStreak(allMissions);
    final maxStreak = StreakCalculator.calculateMaxStreak(allMissions);

    setState(() {
      _learnedTermsCount = termsCount;
      _readNewsCount = newsCount;
      _currentStreak = currentStreak;
      _maxStreak = maxStreak;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final weekMissionsAsync = ref.watch(recentMissionsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('학습 현황'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 주간 학습 현황
                    weekMissionsAsync.when(
                      data: (missions) =>
                          WeeklyProgressCard(weekMissions: missions),
                      loading: () => const Card(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                      error: (error, stack) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text('주간 데이터를 불러올 수 없습니다: $error'),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 월별 잔디 캘린더
                    const MonthlyGrassCalendar(),

                    const SizedBox(height: 16),

                    // 배지 섹션
                    BadgeSection(
                      currentStreak: _currentStreak,
                      maxStreak: _maxStreak,
                      learnedWords: _learnedTermsCount,
                      readNews: _readNewsCount,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}
