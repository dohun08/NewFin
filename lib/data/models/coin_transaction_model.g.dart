// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CoinTransactionModelImpl _$$CoinTransactionModelImplFromJson(
  Map<String, dynamic> json,
) => _$CoinTransactionModelImpl(
  id: json['id'] as String,
  amount: (json['amount'] as num).toInt(),
  type: json['type'] as String,
  description: json['description'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$CoinTransactionModelImplToJson(
  _$CoinTransactionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'type': instance.type,
  'description': instance.description,
  'createdAt': instance.createdAt.toIso8601String(),
};
