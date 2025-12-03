// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'financial_term_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FinancialTermModel _$FinancialTermModelFromJson(Map<String, dynamic> json) {
  return _FinancialTermModel.fromJson(json);
}

/// @nodoc
mixin _$FinancialTermModel {
  String get term => throw _privateConstructorUsedError;
  String get definition => throw _privateConstructorUsedError;
  String get example => throw _privateConstructorUsedError;

  /// Serializes this FinancialTermModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FinancialTermModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FinancialTermModelCopyWith<FinancialTermModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FinancialTermModelCopyWith<$Res> {
  factory $FinancialTermModelCopyWith(
    FinancialTermModel value,
    $Res Function(FinancialTermModel) then,
  ) = _$FinancialTermModelCopyWithImpl<$Res, FinancialTermModel>;
  @useResult
  $Res call({String term, String definition, String example});
}

/// @nodoc
class _$FinancialTermModelCopyWithImpl<$Res, $Val extends FinancialTermModel>
    implements $FinancialTermModelCopyWith<$Res> {
  _$FinancialTermModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FinancialTermModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? term = null,
    Object? definition = null,
    Object? example = null,
  }) {
    return _then(
      _value.copyWith(
            term: null == term
                ? _value.term
                : term // ignore: cast_nullable_to_non_nullable
                      as String,
            definition: null == definition
                ? _value.definition
                : definition // ignore: cast_nullable_to_non_nullable
                      as String,
            example: null == example
                ? _value.example
                : example // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FinancialTermModelImplCopyWith<$Res>
    implements $FinancialTermModelCopyWith<$Res> {
  factory _$$FinancialTermModelImplCopyWith(
    _$FinancialTermModelImpl value,
    $Res Function(_$FinancialTermModelImpl) then,
  ) = __$$FinancialTermModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String term, String definition, String example});
}

/// @nodoc
class __$$FinancialTermModelImplCopyWithImpl<$Res>
    extends _$FinancialTermModelCopyWithImpl<$Res, _$FinancialTermModelImpl>
    implements _$$FinancialTermModelImplCopyWith<$Res> {
  __$$FinancialTermModelImplCopyWithImpl(
    _$FinancialTermModelImpl _value,
    $Res Function(_$FinancialTermModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FinancialTermModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? term = null,
    Object? definition = null,
    Object? example = null,
  }) {
    return _then(
      _$FinancialTermModelImpl(
        term: null == term
            ? _value.term
            : term // ignore: cast_nullable_to_non_nullable
                  as String,
        definition: null == definition
            ? _value.definition
            : definition // ignore: cast_nullable_to_non_nullable
                  as String,
        example: null == example
            ? _value.example
            : example // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FinancialTermModelImpl implements _FinancialTermModel {
  const _$FinancialTermModelImpl({
    required this.term,
    required this.definition,
    required this.example,
  });

  factory _$FinancialTermModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FinancialTermModelImplFromJson(json);

  @override
  final String term;
  @override
  final String definition;
  @override
  final String example;

  @override
  String toString() {
    return 'FinancialTermModel(term: $term, definition: $definition, example: $example)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FinancialTermModelImpl &&
            (identical(other.term, term) || other.term == term) &&
            (identical(other.definition, definition) ||
                other.definition == definition) &&
            (identical(other.example, example) || other.example == example));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, term, definition, example);

  /// Create a copy of FinancialTermModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FinancialTermModelImplCopyWith<_$FinancialTermModelImpl> get copyWith =>
      __$$FinancialTermModelImplCopyWithImpl<_$FinancialTermModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FinancialTermModelImplToJson(this);
  }
}

abstract class _FinancialTermModel implements FinancialTermModel {
  const factory _FinancialTermModel({
    required final String term,
    required final String definition,
    required final String example,
  }) = _$FinancialTermModelImpl;

  factory _FinancialTermModel.fromJson(Map<String, dynamic> json) =
      _$FinancialTermModelImpl.fromJson;

  @override
  String get term;
  @override
  String get definition;
  @override
  String get example;

  /// Create a copy of FinancialTermModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FinancialTermModelImplCopyWith<_$FinancialTermModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
