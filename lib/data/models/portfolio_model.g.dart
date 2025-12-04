// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PortfolioModelImpl _$$PortfolioModelImplFromJson(Map<String, dynamic> json) =>
    _$PortfolioModelImpl(
      totalCoins: (json['totalCoins'] as num?)?.toInt() ?? 0,
      investedAmount: (json['investedAmount'] as num?)?.toInt() ?? 0,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PortfolioModelImplToJson(
  _$PortfolioModelImpl instance,
) => <String, dynamic>{
  'totalCoins': instance.totalCoins,
  'investedAmount': instance.investedAmount,
  'updatedAt': instance.updatedAt.toIso8601String(),
};
