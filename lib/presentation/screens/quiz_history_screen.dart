import 'package:flutter/material.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../core/theme/app_theme.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({super.key});

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  List<Map<String, dynamic>> _quizHistory = [];
  int _attemptedCount = 0;
  int _correctCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizHistory();
  }

  Future<void> _loadQuizHistory() async {
    setState(() {
      _isLoading = true;
    });

    final db = DatabaseHelper();
    final history = await db.getAttemptedQuizzes();
    final stats = await db.getQuizStats();

    setState(() {
      _quizHistory = history;
      _attemptedCount = stats['attempted'] ?? 0;
      _correctCount = stats['correct'] ?? 0;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accuracy =
        _attemptedCount > 0 ? (_correctCount / _attemptedCount * 100) : 0.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('퀴즈 기록'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadQuizHistory,
              child: CustomScrollView(
                slivers: [
                  // 통계 섹션
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryColor.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '📊 퀴즈 통계',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem('총 문제', '$_attemptedCount개'),
                              _buildStatItem('정답', '$_correctCount개'),
                              _buildStatItem(
                                  '정답률', '${accuracy.toStringAsFixed(1)}%'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 기록 리스트
                  _quizHistory.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.quiz_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '아직 푼 퀴즈가 없어요\n퀴즈 탭에서 퀴즈를 풀어보세요!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final quiz = _quizHistory[index];
                                final attemptedAt = quiz['attemptedAt'] != null
                                    ? DateTime.parse(quiz['attemptedAt'])
                                    : null;
                                final daysAgo = attemptedAt != null
                                    ? DateTime.now()
                                        .difference(attemptedAt)
                                        .inDays
                                    : 0;
                                final isCorrect = quiz['isCorrect'] == true;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isCorrect
                                          ? Colors.green.withOpacity(0.3)
                                          : Colors.red.withOpacity(0.3),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: isCorrect
                                                  ? Colors.green
                                                      .withOpacity(0.1)
                                                  : Colors.red
                                                      .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              isCorrect
                                                  ? Icons.check_circle
                                                  : Icons.cancel,
                                              color: isCorrect
                                                  ? Colors.green
                                                  : Colors.red,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              quiz['question'] ?? '질문 없음',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (attemptedAt != null)
                                            Text(
                                              daysAgo == 0
                                                  ? '오늘'
                                                  : '$daysAgo일 전',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  '정답: ',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    quiz['correctAnswer'] ??
                                                        '',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (quiz['selectedAnswer'] !=
                                                null) ...[
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Text(
                                                    '선택: ',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      quiz['selectedAnswer'],
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: isCorrect
                                                            ? Colors.green
                                                            : Colors.red,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              childCount: _quizHistory.length,
                            ),
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
