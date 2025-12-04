import 'package:freezed_annotation/freezed_annotation.dart';

part 'investment_model.freezed.dart';
part 'investment_model.g.dart';

enum InvestmentType {
  stock,   // 주식
  currency, // 환율
  crypto,   // 가상코인
}

enum InvestmentStatus {
  holding,  // 보유 중
  sold,     // 매도 완료
}

@freezed
class InvestmentModel with _$InvestmentModel {
  const InvestmentModel._();

  const factory InvestmentModel({
    required String id,
    required InvestmentType investmentType,
    required String symbol, // 종목 코드 (예: 삼성전자, USD, BTC)
    required double buyPrice, // 매수 시 실제 가격
    required double buyAmount, // 매수 수량
    required int buyCoinAmount, // 매수에 사용한 코인
    required DateTime buyDate,
    double? sellPrice, // 매도 시 가격
    int? sellCoinAmount, // 매도로 받은 코인
    DateTime? sellDate,
    @Default(InvestmentStatus.holding) InvestmentStatus status,
  }) = _InvestmentModel;

  factory InvestmentModel.fromJson(Map<String, dynamic> json) =>
      _$InvestmentModelFromJson(json);

  // 현재 평가액 계산 (코인 단위)
  int calculateCurrentValue(double currentPrice) {
    final currentRealValue = buyAmount * currentPrice;
    final buyRealValue = buyAmount * buyPrice;
    final ratio = currentRealValue / buyRealValue;
    return (buyCoinAmount * ratio).round();
  }

  // 수익률 계산
  double calculateProfitRate(double currentPrice) {
    if (status == InvestmentStatus.sold && sellPrice != null) {
      return ((sellPrice! - buyPrice) / buyPrice) * 100;
    }
    return ((currentPrice - buyPrice) / buyPrice) * 100;
  }

  // 수익/손실 코인
  int calculateProfitLoss(double currentPrice) {
    final currentValue = calculateCurrentValue(currentPrice);
    return currentValue - buyCoinAmount;
  }
}
