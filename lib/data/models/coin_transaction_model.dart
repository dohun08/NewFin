import 'package:freezed_annotation/freezed_annotation.dart';

part 'coin_transaction_model.freezed.dart';
part 'coin_transaction_model.g.dart';

@freezed
class CoinTransactionModel with _$CoinTransactionModel {
  const factory CoinTransactionModel({
    required String id,
    required int amount,
    required String type, // 'earn' or 'spend'
    required String description,
    required DateTime createdAt,
  }) = _CoinTransactionModel;

  factory CoinTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$CoinTransactionModelFromJson(json);
}
