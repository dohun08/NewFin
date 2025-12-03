import 'package:flutter/material.dart';
import '../screens/learned_words_screen.dart';
import '../screens/read_news_screen.dart';
import '../screens/learning_stats_screen.dart';
import '../screens/quiz_history_screen.dart';

class QuickMenuGrid extends StatelessWidget {
  final int learnedWords;
  final int readNews;

  const QuickMenuGrid({
    super.key,
    required this.learnedWords,
    required this.readNews,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildMenuItem(
          context,
          icon: '📚',
          title: '학습한 단어',
          count: '$learnedWords개',
          backgroundColor: const Color(0xFF8DD8FF),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LearnedWordsScreen(),
              ),
            );
          },
        ),
        _buildMenuItem(
          context,
          icon: '📰',
          title: '읽은 뉴스',
          count: '$readNews개',
          backgroundColor: const Color(0xFF4F71FF),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReadNewsScreen(),
              ),
            );
          },
        ),
        _buildMenuItem(
          context,
          icon: '📊',
          title: '학습 현황',
          count: '통계',
          backgroundColor: const Color(0xFF5409DB),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LearningStatsScreen(),
              ),
            );
          },
        ),
        _buildMenuItem(
          context,
          icon: '🎯',
          title: '퀴즈 기록',
          count: '기록',
          backgroundColor: const Color(0xFF7FFFD4),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const QuizHistoryScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String icon,
    required String title,
    required String count,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
