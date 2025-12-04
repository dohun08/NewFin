import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_model.freezed.dart';

@freezed
class StockModel with _$StockModel {
  const StockModel._();

  const factory StockModel({
    required String symbol, // 종목 코드 (예: SAMSUNG, LG, SK)
    required String name, // 종목명 (예: 삼성전자, LG전자, SK하이닉스)
    @Default(0) int currentPrice, // 현재가 (NC 단위)
    @Default(0) int previousClose, // 전일 종가
    @Default(0.0) double changeRate, // 변동률 (%)
    @Default(0) int volume, // 거래량
    required DateTime lastUpdated, // 마지막 업데이트
  }) = _StockModel;

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      currentPrice: json['current_price'] as int? ?? 0,
      previousClose: json['previous_close'] as int? ?? 0,
      changeRate: (json['change_rate'] as num?)?.toDouble() ?? 0.0,
      volume: json['volume'] as int? ?? 0,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'current_price': currentPrice,
      'previous_close': previousClose,
      'change_rate': changeRate,
      'volume': volume,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  // 가격 변동 (뉴스 기반)
  int get changeAmount => currentPrice - previousClose;

  // 상승/하락 여부
  bool get isUp => changeAmount > 0;
  bool get isDown => changeAmount < 0;
}
