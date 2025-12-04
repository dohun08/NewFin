import 'package:freezed_annotation/freezed_annotation.dart';

part 'portfolio_model.freezed.dart';
part 'portfolio_model.g.dart';

@freezed
class PortfolioModel with _$PortfolioModel {
  const PortfolioModel._();

  const factory PortfolioModel({
    @Default(0) int totalCoins, // 총 보유 코인
    @Default(0) int investedAmount, // 투자 중인 코인
    required DateTime updatedAt,
  }) = _PortfolioModel;

  factory PortfolioModel.fromJson(Map<String, dynamic> json) =>
      _$PortfolioModelFromJson(json);

  // 사용 가능한 코인 (총 코인 - 투자 중)
  int get availableCoins => totalCoins - investedAmount;

  // 투자 비율
  double get investmentRatio {
    if (totalCoins == 0) return 0;
    return (investedAmount / totalCoins) * 100;
  }
}
