// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'investment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InvestmentModel _$InvestmentModelFromJson(Map<String, dynamic> json) {
  return _InvestmentModel.fromJson(json);
}

/// @nodoc
mixin _$InvestmentModel {
  String get id => throw _privateConstructorUsedError;
  InvestmentType get investmentType => throw _privateConstructorUsedError;
  String get symbol =>
      throw _privateConstructorUsedError; // 종목 코드 (예: 삼성전자, USD, BTC)
  double get buyPrice => throw _privateConstructorUsedError; // 매수 시 실제 가격
  double get buyAmount => throw _privateConstructorUsedError; // 매수 수량
  int get buyCoinAmount => throw _privateConstructorUsedError; // 매수에 사용한 코인
  DateTime get buyDate => throw _privateConstructorUsedError;
  double? get sellPrice => throw _privateConstructorUsedError; // 매도 시 가격
  int? get sellCoinAmount => throw _privateConstructorUsedError; // 매도로 받은 코인
  DateTime? get sellDate => throw _privateConstructorUsedError;
  InvestmentStatus get status => throw _privateConstructorUsedError;

  /// Serializes this InvestmentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InvestmentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InvestmentModelCopyWith<InvestmentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvestmentModelCopyWith<$Res> {
  factory $InvestmentModelCopyWith(
    InvestmentModel value,
    $Res Function(InvestmentModel) then,
  ) = _$InvestmentModelCopyWithImpl<$Res, InvestmentModel>;
  @useResult
  $Res call({
    String id,
    InvestmentType investmentType,
    String symbol,
    double buyPrice,
    double buyAmount,
    int buyCoinAmount,
    DateTime buyDate,
    double? sellPrice,
    int? sellCoinAmount,
    DateTime? sellDate,
    InvestmentStatus status,
  });
}

/// @nodoc
class _$InvestmentModelCopyWithImpl<$Res, $Val extends InvestmentModel>
    implements $InvestmentModelCopyWith<$Res> {
  _$InvestmentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InvestmentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? investmentType = null,
    Object? symbol = null,
    Object? buyPrice = null,
    Object? buyAmount = null,
    Object? buyCoinAmount = null,
    Object? buyDate = null,
    Object? sellPrice = freezed,
    Object? sellCoinAmount = freezed,
    Object? sellDate = freezed,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            investmentType: null == investmentType
                ? _value.investmentType
                : investmentType // ignore: cast_nullable_to_non_nullable
                      as InvestmentType,
            symbol: null == symbol
                ? _value.symbol
                : symbol // ignore: cast_nullable_to_non_nullable
                      as String,
            buyPrice: null == buyPrice
                ? _value.buyPrice
                : buyPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            buyAmount: null == buyAmount
                ? _value.buyAmount
                : buyAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            buyCoinAmount: null == buyCoinAmount
                ? _value.buyCoinAmount
                : buyCoinAmount // ignore: cast_nullable_to_non_nullable
                      as int,
            buyDate: null == buyDate
                ? _value.buyDate
                : buyDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            sellPrice: freezed == sellPrice
                ? _value.sellPrice
                : sellPrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            sellCoinAmount: freezed == sellCoinAmount
                ? _value.sellCoinAmount
                : sellCoinAmount // ignore: cast_nullable_to_non_nullable
                      as int?,
            sellDate: freezed == sellDate
                ? _value.sellDate
                : sellDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as InvestmentStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InvestmentModelImplCopyWith<$Res>
    implements $InvestmentModelCopyWith<$Res> {
  factory _$$InvestmentModelImplCopyWith(
    _$InvestmentModelImpl value,
    $Res Function(_$InvestmentModelImpl) then,
  ) = __$$InvestmentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    InvestmentType investmentType,
    String symbol,
    double buyPrice,
    double buyAmount,
    int buyCoinAmount,
    DateTime buyDate,
    double? sellPrice,
    int? sellCoinAmount,
    DateTime? sellDate,
    InvestmentStatus status,
  });
}

/// @nodoc
class __$$InvestmentModelImplCopyWithImpl<$Res>
    extends _$InvestmentModelCopyWithImpl<$Res, _$InvestmentModelImpl>
    implements _$$InvestmentModelImplCopyWith<$Res> {
  __$$InvestmentModelImplCopyWithImpl(
    _$InvestmentModelImpl _value,
    $Res Function(_$InvestmentModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InvestmentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? investmentType = null,
    Object? symbol = null,
    Object? buyPrice = null,
    Object? buyAmount = null,
    Object? buyCoinAmount = null,
    Object? buyDate = null,
    Object? sellPrice = freezed,
    Object? sellCoinAmount = freezed,
    Object? sellDate = freezed,
    Object? status = null,
  }) {
    return _then(
      _$InvestmentModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        investmentType: null == investmentType
            ? _value.investmentType
            : investmentType // ignore: cast_nullable_to_non_nullable
                  as InvestmentType,
        symbol: null == symbol
            ? _value.symbol
            : symbol // ignore: cast_nullable_to_non_nullable
                  as String,
        buyPrice: null == buyPrice
            ? _value.buyPrice
            : buyPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        buyAmount: null == buyAmount
            ? _value.buyAmount
            : buyAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        buyCoinAmount: null == buyCoinAmount
            ? _value.buyCoinAmount
            : buyCoinAmount // ignore: cast_nullable_to_non_nullable
                  as int,
        buyDate: null == buyDate
            ? _value.buyDate
            : buyDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        sellPrice: freezed == sellPrice
            ? _value.sellPrice
            : sellPrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        sellCoinAmount: freezed == sellCoinAmount
            ? _value.sellCoinAmount
            : sellCoinAmount // ignore: cast_nullable_to_non_nullable
                  as int?,
        sellDate: freezed == sellDate
            ? _value.sellDate
            : sellDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as InvestmentStatus,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InvestmentModelImpl extends _InvestmentModel {
  const _$InvestmentModelImpl({
    required this.id,
    required this.investmentType,
    required this.symbol,
    required this.buyPrice,
    required this.buyAmount,
    required this.buyCoinAmount,
    required this.buyDate,
    this.sellPrice,
    this.sellCoinAmount,
    this.sellDate,
    this.status = InvestmentStatus.holding,
  }) : super._();

  factory _$InvestmentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvestmentModelImplFromJson(json);

  @override
  final String id;
  @override
  final InvestmentType investmentType;
  @override
  final String symbol;
  // 종목 코드 (예: 삼성전자, USD, BTC)
  @override
  final double buyPrice;
  // 매수 시 실제 가격
  @override
  final double buyAmount;
  // 매수 수량
  @override
  final int buyCoinAmount;
  // 매수에 사용한 코인
  @override
  final DateTime buyDate;
  @override
  final double? sellPrice;
  // 매도 시 가격
  @override
  final int? sellCoinAmount;
  // 매도로 받은 코인
  @override
  final DateTime? sellDate;
  @override
  @JsonKey()
  final InvestmentStatus status;

  @override
  String toString() {
    return 'InvestmentModel(id: $id, investmentType: $investmentType, symbol: $symbol, buyPrice: $buyPrice, buyAmount: $buyAmount, buyCoinAmount: $buyCoinAmount, buyDate: $buyDate, sellPrice: $sellPrice, sellCoinAmount: $sellCoinAmount, sellDate: $sellDate, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvestmentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.investmentType, investmentType) ||
                other.investmentType == investmentType) &&
            (identical(other.symbol, symbol) || other.symbol == symbol) &&
            (identical(other.buyPrice, buyPrice) ||
                other.buyPrice == buyPrice) &&
            (identical(other.buyAmount, buyAmount) ||
                other.buyAmount == buyAmount) &&
            (identical(other.buyCoinAmount, buyCoinAmount) ||
                other.buyCoinAmount == buyCoinAmount) &&
            (identical(other.buyDate, buyDate) || other.buyDate == buyDate) &&
            (identical(other.sellPrice, sellPrice) ||
                other.sellPrice == sellPrice) &&
            (identical(other.sellCoinAmount, sellCoinAmount) ||
                other.sellCoinAmount == sellCoinAmount) &&
            (identical(other.sellDate, sellDate) ||
                other.sellDate == sellDate) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    investmentType,
    symbol,
    buyPrice,
    buyAmount,
    buyCoinAmount,
    buyDate,
    sellPrice,
    sellCoinAmount,
    sellDate,
    status,
  );

  /// Create a copy of InvestmentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvestmentModelImplCopyWith<_$InvestmentModelImpl> get copyWith =>
      __$$InvestmentModelImplCopyWithImpl<_$InvestmentModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InvestmentModelImplToJson(this);
  }
}

abstract class _InvestmentModel extends InvestmentModel {
  const factory _InvestmentModel({
    required final String id,
    required final InvestmentType investmentType,
    required final String symbol,
    required final double buyPrice,
    required final double buyAmount,
    required final int buyCoinAmount,
    required final DateTime buyDate,
    final double? sellPrice,
    final int? sellCoinAmount,
    final DateTime? sellDate,
    final InvestmentStatus status,
  }) = _$InvestmentModelImpl;
  const _InvestmentModel._() : super._();

  factory _InvestmentModel.fromJson(Map<String, dynamic> json) =
      _$InvestmentModelImpl.fromJson;

  @override
  String get id;
  @override
  InvestmentType get investmentType;
  @override
  String get symbol; // 종목 코드 (예: 삼성전자, USD, BTC)
  @override
  double get buyPrice; // 매수 시 실제 가격
  @override
  double get buyAmount; // 매수 수량
  @override
  int get buyCoinAmount; // 매수에 사용한 코인
  @override
  DateTime get buyDate;
  @override
  double? get sellPrice; // 매도 시 가격
  @override
  int? get sellCoinAmount; // 매도로 받은 코인
  @override
  DateTime? get sellDate;
  @override
  InvestmentStatus get status;

  /// Create a copy of InvestmentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvestmentModelImplCopyWith<_$InvestmentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
