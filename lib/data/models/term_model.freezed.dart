// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'term_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TermModel _$TermModelFromJson(Map<String, dynamic> json) {
  return _TermModel.fromJson(json);
}

/// @nodoc
mixin _$TermModel {
  String get id => throw _privateConstructorUsedError;
  String get term => throw _privateConstructorUsedError;
  String get definition => throw _privateConstructorUsedError;
  String get example => throw _privateConstructorUsedError;
  String? get relatedNewsId => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;

  /// Serializes this TermModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TermModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TermModelCopyWith<TermModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TermModelCopyWith<$Res> {
  factory $TermModelCopyWith(TermModel value, $Res Function(TermModel) then) =
      _$TermModelCopyWithImpl<$Res, TermModel>;
  @useResult
  $Res call({
    String id,
    String term,
    String definition,
    String example,
    String? relatedNewsId,
    String source,
  });
}

/// @nodoc
class _$TermModelCopyWithImpl<$Res, $Val extends TermModel>
    implements $TermModelCopyWith<$Res> {
  _$TermModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TermModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? term = null,
    Object? definition = null,
    Object? example = null,
    Object? relatedNewsId = freezed,
    Object? source = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
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
            relatedNewsId: freezed == relatedNewsId
                ? _value.relatedNewsId
                : relatedNewsId // ignore: cast_nullable_to_non_nullable
                      as String?,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TermModelImplCopyWith<$Res>
    implements $TermModelCopyWith<$Res> {
  factory _$$TermModelImplCopyWith(
    _$TermModelImpl value,
    $Res Function(_$TermModelImpl) then,
  ) = __$$TermModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String term,
    String definition,
    String example,
    String? relatedNewsId,
    String source,
  });
}

/// @nodoc
class __$$TermModelImplCopyWithImpl<$Res>
    extends _$TermModelCopyWithImpl<$Res, _$TermModelImpl>
    implements _$$TermModelImplCopyWith<$Res> {
  __$$TermModelImplCopyWithImpl(
    _$TermModelImpl _value,
    $Res Function(_$TermModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TermModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? term = null,
    Object? definition = null,
    Object? example = null,
    Object? relatedNewsId = freezed,
    Object? source = null,
  }) {
    return _then(
      _$TermModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
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
        relatedNewsId: freezed == relatedNewsId
            ? _value.relatedNewsId
            : relatedNewsId // ignore: cast_nullable_to_non_nullable
                  as String?,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TermModelImpl implements _TermModel {
  const _$TermModelImpl({
    required this.id,
    required this.term,
    required this.definition,
    this.example = '',
    this.relatedNewsId,
    this.source = 'gemini',
  });

  factory _$TermModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TermModelImplFromJson(json);

  @override
  final String id;
  @override
  final String term;
  @override
  final String definition;
  @override
  @JsonKey()
  final String example;
  @override
  final String? relatedNewsId;
  @override
  @JsonKey()
  final String source;

  @override
  String toString() {
    return 'TermModel(id: $id, term: $term, definition: $definition, example: $example, relatedNewsId: $relatedNewsId, source: $source)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TermModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.term, term) || other.term == term) &&
            (identical(other.definition, definition) ||
                other.definition == definition) &&
            (identical(other.example, example) || other.example == example) &&
            (identical(other.relatedNewsId, relatedNewsId) ||
                other.relatedNewsId == relatedNewsId) &&
            (identical(other.source, source) || other.source == source));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    term,
    definition,
    example,
    relatedNewsId,
    source,
  );

  /// Create a copy of TermModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TermModelImplCopyWith<_$TermModelImpl> get copyWith =>
      __$$TermModelImplCopyWithImpl<_$TermModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TermModelImplToJson(this);
  }
}

abstract class _TermModel implements TermModel {
  const factory _TermModel({
    required final String id,
    required final String term,
    required final String definition,
    final String example,
    final String? relatedNewsId,
    final String source,
  }) = _$TermModelImpl;

  factory _TermModel.fromJson(Map<String, dynamic> json) =
      _$TermModelImpl.fromJson;

  @override
  String get id;
  @override
  String get term;
  @override
  String get definition;
  @override
  String get example;
  @override
  String? get relatedNewsId;
  @override
  String get source;

  /// Create a copy of TermModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TermModelImplCopyWith<_$TermModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
