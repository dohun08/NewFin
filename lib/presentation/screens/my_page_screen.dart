import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/models/daily_mission_model.dart';
import '../../core/utils/streak_calculator.dart';
import '../widgets/profile_card.dart';
import '../widgets/quick_menu_grid.dart';

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  int _readNewsCount = 0;
  int _learnedTermsCount = 0;
  int _currentStreak = 0;
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
    final readCount = await db.getReadNewsCount();
    final termsCount = await db.getLearnedTermsCount();
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

    setState(() {
      _readNewsCount = readCount;
      _learnedTermsCount = termsCount;
      _currentStreak = currentStreak;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('마이페이지'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
                    // 1. 프로필 카드
                    ProfileCard(
                      streak: _currentStreak,
                      learnedWords: _learnedTermsCount,
                      readNews: _readNewsCount,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 3. 빠른 메뉴
                    const Text(
                      '빠른 메뉴',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    QuickMenuGrid(
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
