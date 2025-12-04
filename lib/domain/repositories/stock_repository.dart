import '../../data/models/stock_model.dart';
import '../../data/models/investment_model.dart';

abstract class StockRepository {
  /// 주식 목록 조회
  Future<List<StockModel>> getStocks();

  /// 특정 주식 조회
  Future<StockModel> getStock(String symbol);

  /// 일일 주식 가격 업데이트 (뉴스 기반)
  Future<void> updateDailyPrices();

  /// 주식 매수
  Future<InvestmentModel> buyStock({
    required String symbol,
    required int quantity,
    required int totalCoinAmount,
  });

  /// 주식 매도
  Future<void> sellStock(String investmentId);

  /// 내 투자 목록
  Future<List<InvestmentModel>> getMyInvestments();

  /// 특정 투자 조회
  Future<InvestmentModel?> getInvestment(String id);
}
