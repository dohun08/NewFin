import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/models/daily_mission_model.dart';
import '../../core/utils/streak_calculator.dart';
import '../widgets/profile_card.dart';
import '../widgets/quick_menu_grid.dart';
import '../providers/stats_provider.dart';
import '../providers/coin_provider.dart';

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  int _currentStreak = 0;
  bool _isLoading = true;
  bool _isResetting = false;

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
      _currentStreak = currentStreak;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(statsProvider);

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
              onRefresh: () async {
                await _loadStats();
                ref.read(statsProvider.notifier).refresh();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. 프로필 카드
                    statsAsync.when(
                      data: (stats) => ProfileCard(
                        streak: _currentStreak,
                        learnedWords: stats.learnedTermsCount,
                        readNews: stats.readNewsCount,
                      ),
                      loading: () => ProfileCard(
                        streak: _currentStreak,
                        learnedWords: 0,
                        readNews: 0,
                      ),
                      error: (_, __) => ProfileCard(
                        streak: _currentStreak,
                        learnedWords: 0,
                        readNews: 0,
                      ),
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
                    statsAsync.when(
                      data: (stats) => QuickMenuGrid(
                        learnedWords: stats.learnedTermsCount,
                        readNews: stats.readNewsCount,
                      ),
                      loading: () => const QuickMenuGrid(
                        learnedWords: 0,
                        readNews: 0,
                      ),
                      error: (_, __) => const QuickMenuGrid(
                        learnedWords: 0,
                        readNews: 0,
                      ),
                    ),
                   
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isResetting ? null : () async {
          setState(() {
            _isResetting = true;
          });
          
          try {
            final coinRepo = ref.read(coinRepositoryProvider);
            await coinRepo.resetCoins(amount: 1000);
            ref.read(totalCoinsProvider.notifier).refresh();
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ 코인이 1000NC로 초기화되었습니다!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } finally {
            if (mounted) {
              setState(() {
                _isResetting = false;
              });
            }
          }
        },
        backgroundColor: _isResetting ? Colors.grey : null,
        child: _isResetting 
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.refresh),
        tooltip: '코인 초기화 (1000NC)',
      ),
    );
  }
}
