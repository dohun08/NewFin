import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/database_helper.dart';
import '../../data/models/coin_transaction_model.dart';
import '../../data/models/portfolio_model.dart';
import '../../data/repositories/coin_repository_impl.dart';
import '../../domain/repositories/coin_repository.dart';

// Repository Provider
final coinRepositoryProvider = Provider<CoinRepository>((ref) {
  return CoinRepositoryImpl(DatabaseHelper());
});

// 총 코인 - StateNotifier로 변경하여 실시간 업데이트
class TotalCoinsNotifier extends StateNotifier<AsyncValue<int>> {
  final CoinRepository _repository;

  TotalCoinsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    state = const AsyncValue.loading();
    try {
      final coins = await _repository.getTotalCoins();
      state = AsyncValue.data(coins);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await _loadCoins();
  }
}

final totalCoinsProvider =
    StateNotifierProvider<TotalCoinsNotifier, AsyncValue<int>>((ref) {
      final repository = ref.watch(coinRepositoryProvider);
      return TotalCoinsNotifier(repository);
    });

// 포트폴리오 조회
final portfolioProvider = FutureProvider.autoDispose<PortfolioModel>((
  ref,
) async {
  final repository = ref.read(coinRepositoryProvider);
  return await repository.getPortfolio();
});

// 코인 거래 내역
final coinHistoryProvider = FutureProvider.autoDispose
    .family<List<CoinTransactionModel>, int?>((ref, limit) async {
      final repository = ref.read(coinRepositoryProvider);
      return await repository.getCoinHistory(limit: limit);
    });

// 코인 액션 (적립, 사용)
final coinActionsProvider = Provider<CoinActions>((ref) {
  final repository = ref.read(coinRepositoryProvider);
  return CoinActions(repository, ref);
});

class CoinActions {
  final CoinRepository _repository;
  final Ref _ref;

  CoinActions(this._repository, this._ref);

  /// 코인 적립
  Future<void> addCoins({
    required int amount,
    required String description,
  }) async {
    await _repository.addCoins(amount: amount, description: description);
    // Refresh providers
    _ref.read(totalCoinsProvider.notifier).refresh();
    _ref.invalidate(portfolioProvider);
    _ref.invalidate(coinHistoryProvider);
  }

  /// 코인 사용
  Future<bool> spendCoins({
    required int amount,
    required String description,
  }) async {
    final success = await _repository.spendCoins(
      amount: amount,
      description: description,
    );
    if (success) {
      // Refresh providers
      _ref.read(totalCoinsProvider.notifier).refresh();
      _ref.invalidate(portfolioProvider);
      _ref.invalidate(coinHistoryProvider);
    }
    return success;
  }
}
