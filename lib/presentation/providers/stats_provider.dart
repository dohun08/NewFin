import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/database_helper.dart';

// 학습 통계를 위한 StateNotifier
class StatsNotifier extends StateNotifier<AsyncValue<StatsData>> {
  StatsNotifier() : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final db = DatabaseHelper();
      final readNewsCount = await db.getReadNewsCount();
      final learnedTermsCount = await db.getLearnedTermsCount();
      
      state = AsyncValue.data(StatsData(
        readNewsCount: readNewsCount,
        learnedTermsCount: learnedTermsCount,
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// 학습 통계 데이터 모델
class StatsData {
  final int readNewsCount;
  final int learnedTermsCount;

  StatsData({
    required this.readNewsCount,
    required this.learnedTermsCount,
  });
}

// Provider 정의
final statsProvider = StateNotifierProvider<StatsNotifier, AsyncValue<StatsData>>((ref) {
  return StatsNotifier();
});
