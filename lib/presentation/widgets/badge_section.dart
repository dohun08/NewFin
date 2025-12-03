import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum BadgeType {
  streak7,
  streak14,
  streak30,
  streak100,
  words50,
  news100,
  quiz50,
  perfectQuiz10,
}

class BadgeInfo {
  final BadgeType type;
  final String emoji;
  final String title;
  final String description;
  final Color color;

  const BadgeInfo({
    required this.type,
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
  });
}

class BadgeSection extends StatelessWidget {
  final int currentStreak;
  final int maxStreak;
  final int learnedWords;
  final int readNews;
  // TODO: quiz 관련 데이터 추가 필요

  const BadgeSection({
    super.key,
    required this.currentStreak,
    required this.maxStreak,
    required this.learnedWords,
    required this.readNews,
  });

  static const List<BadgeInfo> _allBadges = [
    BadgeInfo(
      type: BadgeType.streak7,
      emoji: '🔥',
      title: '7일 연속 학습',
      description: '7일 연속으로 학습했어요',
      color: Color(0xFFFF6B6B),
    ),
    BadgeInfo(
      type: BadgeType.streak14,
      emoji: '⚡',
      title: '14일 연속 학습',
      description: '2주 연속 학습 달성!',
      color: Color(0xFFFFD93D),
    ),
    BadgeInfo(
      type: BadgeType.streak30,
      emoji: '💎',
      title: '30일 연속 학습',
      description: '한 달 연속 학습 완료!',
      color: Color(0xFF6BCB77),
    ),
    BadgeInfo(
      type: BadgeType.streak100,
      emoji: '👑',
      title: '100일 연속 학습',
      description: '100일의 기적을 달성했어요',
      color: AppTheme.primaryColor,
    ),
    BadgeInfo(
      type: BadgeType.words50,
      emoji: '📚',
      title: '단어 수집가',
      description: '50개 이상의 단어 학습',
      color: Color(0xFF8DD8FF),
    ),
    BadgeInfo(
      type: BadgeType.news100,
      emoji: '📰',
      title: '뉴스 마스터',
      description: '100개 이상의 뉴스 읽기',
      color: Color(0xFF4F71FF),
    ),
    BadgeInfo(
      type: BadgeType.quiz50,
      emoji: '🎯',
      title: '퀴즈 도전자',
      description: '50회 이상 퀴즈 완료',
      color: Color(0xFF7FFFD4),
    ),
    BadgeInfo(
      type: BadgeType.perfectQuiz10,
      emoji: '🏆',
      title: '완벽주의자',
      description: '10회 만점 퀴즈 달성',
      color: Color(0xFFFFD700),
    ),
  ];

  bool _isBadgeUnlocked(BadgeType type) {
    switch (type) {
      case BadgeType.streak7:
        return maxStreak >= 7;
      case BadgeType.streak14:
        return maxStreak >= 14;
      case BadgeType.streak30:
        return maxStreak >= 30;
      case BadgeType.streak100:
        return maxStreak >= 100;
      case BadgeType.words50:
        return learnedWords >= 50;
      case BadgeType.news100:
        return readNews >= 100;
      case BadgeType.quiz50:
        return false; // TODO: quiz 데이터 연동
      case BadgeType.perfectQuiz10:
        return false; // TODO: perfect quiz 데이터 연동
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlockedCount = _allBadges.where((b) => _isBadgeUnlocked(b.type)).length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text(
                      '🏅',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '내 배지',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$unlockedCount/${_allBadges.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 배지 리스트 (가로 스크롤)
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _allBadges.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final badge = _allBadges[index];
                  final isUnlocked = _isBadgeUnlocked(badge.type);
                  return _buildBadgeCard(badge, isUnlocked);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeCard(BadgeInfo badge, bool isUnlocked) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: isUnlocked ? badge.color.withOpacity(0.1) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked ? badge.color : Colors.grey[400]!,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 이모지 (잠금 해제 시 컬러, 잠금 시 흑백)
          Text(
            badge.emoji,
            style: TextStyle(
              fontSize: 36,
              color: isUnlocked ? null : Colors.grey,
            ),
          ),

          const SizedBox(height: 8),

          // 제목
          Text(
            badge.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? Colors.black87 : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // 설명
          Text(
            badge.description,
            style: TextStyle(
              fontSize: 10,
              color: isUnlocked ? Colors.grey[700] : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // 잠금 아이콘
          if (!isUnlocked)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(
                Icons.lock,
                size: 16,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}
