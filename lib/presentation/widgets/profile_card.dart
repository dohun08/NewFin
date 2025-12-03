import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ProfileCard extends StatelessWidget {
  final int streak;
  final int learnedWords;
  final int readNews;

  const ProfileCard({
    super.key,
    required this.streak,
    required this.learnedWords,
    required this.readNews,
  });

  String _getUserLevel(int wordCount) {
    if (wordCount >= 201) return '금융 고수';
    if (wordCount >= 101) return '금융 전문가';
    if (wordCount >= 51) return '금융 숙련자';
    if (wordCount >= 21) return '금융 입문자';
    return '금융 초보자';
  }

  @override
  Widget build(BuildContext context) {
    final level = _getUserLevel(learnedWords);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 프로필 영역
            Row(
              children: [
                // 프로필 이미지
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                // 닉네임 + 레벨
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '윤도훈',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          level,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // 주요 통계 3개
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('🔥', streak.toString(), '연속 학습'),
                _buildDivider(),
                _buildStatItem('📚', learnedWords.toString(), '학습한 단어'),
                _buildDivider(),
                _buildStatItem('📰', readNews.toString(), '읽은 뉴스'),
              ],
            ),

            const SizedBox(height: 20),

            // 프로필 수정 버튼
            OutlinedButton(
              onPressed: () {
                // TODO: 프로필 수정 화면으로 이동
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(color: AppTheme.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 44),
              ),
              child: const Text('프로필 수정'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }
}
