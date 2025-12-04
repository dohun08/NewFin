// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvestmentModelImpl _$$InvestmentModelImplFromJson(
  Map<String, dynamic> json,
) => _$InvestmentModelImpl(
  id: json['id'] as String,
  investmentType: $enumDecode(_$InvestmentTypeEnumMap, json['investmentType']),
  symbol: json['symbol'] as String,
  buyPrice: (json['buyPrice'] as num).toDouble(),
  buyAmount: (json['buyAmount'] as num).toDouble(),
  buyCoinAmount: (json['buyCoinAmount'] as num).toInt(),
  buyDate: DateTime.parse(json['buyDate'] as String),
  sellPrice: (json['sellPrice'] as num?)?.toDouble(),
  sellCoinAmount: (json['sellCoinAmount'] as num?)?.toInt(),
  sellDate: json['sellDate'] == null
      ? null
      : DateTime.parse(json['sellDate'] as String),
  status:
      $enumDecodeNullable(_$InvestmentStatusEnumMap, json['status']) ??
      InvestmentStatus.holding,
);

Map<String, dynamic> _$$InvestmentModelImplToJson(
  _$InvestmentModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'investmentType': _$InvestmentTypeEnumMap[instance.investmentType]!,
  'symbol': instance.symbol,
  'buyPrice': instance.buyPrice,
  'buyAmount': instance.buyAmount,
  'buyCoinAmount': instance.buyCoinAmount,
  'buyDate': instance.buyDate.toIso8601String(),
  'sellPrice': instance.sellPrice,
  'sellCoinAmount': instance.sellCoinAmount,
  'sellDate': instance.sellDate?.toIso8601String(),
  'status': _$InvestmentStatusEnumMap[instance.status]!,
};

const _$InvestmentTypeEnumMap = {
  InvestmentType.stock: 'stock',
  InvestmentType.currency: 'currency',
  InvestmentType.crypto: 'crypto',
};

const _$InvestmentStatusEnumMap = {
  InvestmentStatus.holding: 'holding',
  InvestmentStatus.sold: 'sold',
};
