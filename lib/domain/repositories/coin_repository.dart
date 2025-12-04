import '../../data/models/coin_transaction_model.dart';
import '../../data/models/portfolio_model.dart';

abstract class CoinRepository {
  /// 현재 총 코인 조회
  Future<int> getTotalCoins();

  /// 포트폴리오 전체 정보 조회
  Future<PortfolioModel> getPortfolio();

  /// 코인 적립
  Future<void> addCoins({
    required int amount,
    required String description,
  });

  /// 코인 사용
  Future<bool> spendCoins({
    required int amount,
    required String description,
  });

  /// 코인 거래 내역 조회
  Future<List<CoinTransactionModel>> getCoinHistory({
    int? limit,
  });

  /// 투자로 코인 사용 (투자 테이블에도 기록)
  Future<void> investCoins({
    required int amount,
    required String investmentId,
  });

  /// 투자 회수 (매도 시)
  Future<void> retrieveInvestment({
    required int amount,
    required String investmentId,
  });
}
