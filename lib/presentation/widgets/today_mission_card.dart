import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/daily_mission_model.dart';
import '../providers/providers.dart';

class TodayMissionCard extends ConsumerWidget {
  const TodayMissionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionAsync = ref.watch(todayMissionProvider);

    return missionAsync.when(
      data: (mission) => _buildMissionCard(context, mission),
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('미션 로딩 실패: $err'),
        ),
      ),
    );
  }

  Widget _buildMissionCard(BuildContext context, DailyMissionModel mission) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 + 진행률
            Row(
              children: [
                const Text(
                  '📊 오늘의 미션',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${mission.completedCount}/3',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: mission.isGrassEarned ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 미션 1: 뉴스
            _buildMissionRow(
              context: context,
              icon: '📰',
              title: '뉴스 2개 읽기',
              completed: mission.newsRead,
              onTap: () => context.go('/main/1'), // 뉴스 탭으로 이동
            ),

            const SizedBox(height: 12),

            // 미션 2: 퀴즈
            _buildMissionRow(
              context: context,
              icon: '🎯',
              title: '퀴즈 1세트 풀기',
              completed: mission.quizCompleted,
              onTap: () => context.go('/main/1'), // 뉴스 탭으로 이동
            ),

            const SizedBox(height: 12),

            // 미션 3: 로그인
            _buildMissionRow(
              context: context,
              icon: '✅',
              title: '로그인',
              completed: mission.loginChecked,
              subtitle: '(자동 완료)',
            ),

            const SizedBox(height: 16),

            // 격려 메시지
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: mission.isGrassEarned
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    mission.isGrassEarned ? '🌱' : '💪',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      mission.isGrassEarned
                          ? '오늘 잔디 획득!'
                          : '조금만 더! ${2 - mission.completedCount}개 남았어요',
                      style: TextStyle(
                        color: mission.isGrassEarned ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionRow({
    required BuildContext context,
    required String icon,
    required String title,
    required bool completed,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 15),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            Icon(
              completed ? Icons.check_circle : Icons.circle_outlined,
              color: completed ? Colors.green : Colors.grey,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
