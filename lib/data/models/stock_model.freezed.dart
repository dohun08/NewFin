// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$StockModel {
  String get symbol =>
      throw _privateConstructorUsedError; // 종목 코드 (예: SAMSUNG, LG, SK)
  String get name =>
      throw _privateConstructorUsedError; // 종목명 (예: 삼성전자, LG전자, SK하이닉스)
  int get currentPrice => throw _privateConstructorUsedError; // 현재가 (NC 단위)
  int get previousClose => throw _privateConstructorUsedError; // 전일 종가
  double get changeRate => throw _privateConstructorUsedError; // 변동률 (%)
  int get volume => throw _privateConstructorUsedError; // 거래량
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  /// Create a copy of StockModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StockModelCopyWith<StockModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StockModelCopyWith<$Res> {
  factory $StockModelCopyWith(
    StockModel value,
    $Res Function(StockModel) then,
  ) = _$StockModelCopyWithImpl<$Res, StockModel>;
  @useResult
  $Res call({
    String symbol,
    String name,
    int currentPrice,
    int previousClose,
    double changeRate,
    int volume,
    DateTime lastUpdated,
  });
}

/// @nodoc
class _$StockModelCopyWithImpl<$Res, $Val extends StockModel>
    implements $StockModelCopyWith<$Res> {
  _$StockModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StockModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? symbol = null,
    Object? name = null,
    Object? currentPrice = null,
    Object? previousClose = null,
    Object? changeRate = null,
    Object? volume = null,
    Object? lastUpdated = null,
  }) {
    return _then(
      _value.copyWith(
            symbol: null == symbol
                ? _value.symbol
                : symbol // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            currentPrice: null == currentPrice
                ? _value.currentPrice
                : currentPrice // ignore: cast_nullable_to_non_nullable
                      as int,
            previousClose: null == previousClose
                ? _value.previousClose
                : previousClose // ignore: cast_nullable_to_non_nullable
                      as int,
            changeRate: null == changeRate
                ? _value.changeRate
                : changeRate // ignore: cast_nullable_to_non_nullable
                      as double,
            volume: null == volume
                ? _value.volume
                : volume // ignore: cast_nullable_to_non_nullable
                      as int,
            lastUpdated: null == lastUpdated
                ? _value.lastUpdated
                : lastUpdated // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StockModelImplCopyWith<$Res>
    implements $StockModelCopyWith<$Res> {
  factory _$$StockModelImplCopyWith(
    _$StockModelImpl value,
    $Res Function(_$StockModelImpl) then,
  ) = __$$StockModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String symbol,
    String name,
    int currentPrice,
    int previousClose,
    double changeRate,
    int volume,
    DateTime lastUpdated,
  });
}

/// @nodoc
class __$$StockModelImplCopyWithImpl<$Res>
    extends _$StockModelCopyWithImpl<$Res, _$StockModelImpl>
    implements _$$StockModelImplCopyWith<$Res> {
  __$$StockModelImplCopyWithImpl(
    _$StockModelImpl _value,
    $Res Function(_$StockModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StockModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? symbol = null,
    Object? name = null,
    Object? currentPrice = null,
    Object? previousClose = null,
    Object? changeRate = null,
    Object? volume = null,
    Object? lastUpdated = null,
  }) {
    return _then(
      _$StockModelImpl(
        symbol: null == symbol
            ? _value.symbol
            : symbol // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        currentPrice: null == currentPrice
            ? _value.currentPrice
            : currentPrice // ignore: cast_nullable_to_non_nullable
                  as int,
        previousClose: null == previousClose
            ? _value.previousClose
            : previousClose // ignore: cast_nullable_to_non_nullable
                  as int,
        changeRate: null == changeRate
            ? _value.changeRate
            : changeRate // ignore: cast_nullable_to_non_nullable
                  as double,
        volume: null == volume
            ? _value.volume
            : volume // ignore: cast_nullable_to_non_nullable
                  as int,
        lastUpdated: null == lastUpdated
            ? _value.lastUpdated
            : lastUpdated // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$StockModelImpl extends _StockModel {
  const _$StockModelImpl({
    required this.symbol,
    required this.name,
    this.currentPrice = 0,
    this.previousClose = 0,
    this.changeRate = 0.0,
    this.volume = 0,
    required this.lastUpdated,
  }) : super._();

  @override
  final String symbol;
  // 종목 코드 (예: SAMSUNG, LG, SK)
  @override
  final String name;
  // 종목명 (예: 삼성전자, LG전자, SK하이닉스)
  @override
  @JsonKey()
  final int currentPrice;
  // 현재가 (NC 단위)
  @override
  @JsonKey()
  final int previousClose;
  // 전일 종가
  @override
  @JsonKey()
  final double changeRate;
  // 변동률 (%)
  @override
  @JsonKey()
  final int volume;
  // 거래량
  @override
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'StockModel(symbol: $symbol, name: $name, currentPrice: $currentPrice, previousClose: $previousClose, changeRate: $changeRate, volume: $volume, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StockModelImpl &&
            (identical(other.symbol, symbol) || other.symbol == symbol) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.currentPrice, currentPrice) ||
                other.currentPrice == currentPrice) &&
            (identical(other.previousClose, previousClose) ||
                other.previousClose == previousClose) &&
            (identical(other.changeRate, changeRate) ||
                other.changeRate == changeRate) &&
            (identical(other.volume, volume) || other.volume == volume) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    symbol,
    name,
    currentPrice,
    previousClose,
    changeRate,
    volume,
    lastUpdated,
  );

  /// Create a copy of StockModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StockModelImplCopyWith<_$StockModelImpl> get copyWith =>
      __$$StockModelImplCopyWithImpl<_$StockModelImpl>(this, _$identity);
}

abstract class _StockModel extends StockModel {
  const factory _StockModel({
    required final String symbol,
    required final String name,
    final int currentPrice,
    final int previousClose,
    final double changeRate,
    final int volume,
    required final DateTime lastUpdated,
  }) = _$StockModelImpl;
  const _StockModel._() : super._();

  @override
  String get symbol; // 종목 코드 (예: SAMSUNG, LG, SK)
  @override
  String get name; // 종목명 (예: 삼성전자, LG전자, SK하이닉스)
  @override
  int get currentPrice; // 현재가 (NC 단위)
  @override
  int get previousClose; // 전일 종가
  @override
  double get changeRate; // 변동률 (%)
  @override
  int get volume; // 거래량
  @override
  DateTime get lastUpdated;

  /// Create a copy of StockModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StockModelImplCopyWith<_$StockModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
