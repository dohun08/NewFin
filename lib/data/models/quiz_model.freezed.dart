// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quiz_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

QuizModel _$QuizModelFromJson(Map<String, dynamic> json) {
  return _QuizModel.fromJson(json);
}

/// @nodoc
mixin _$QuizModel {
  String get id => throw _privateConstructorUsedError;
  String get newsId => throw _privateConstructorUsedError;
  String get question => throw _privateConstructorUsedError;
  List<String> get options => throw _privateConstructorUsedError;
  int get correctIndex => throw _privateConstructorUsedError;
  String get explanation => throw _privateConstructorUsedError;
  int? get userAnswer => throw _privateConstructorUsedError;
  bool? get isCorrect => throw _privateConstructorUsedError;
  DateTime? get attemptedAt => throw _privateConstructorUsedError;

  /// Serializes this QuizModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuizModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuizModelCopyWith<QuizModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuizModelCopyWith<$Res> {
  factory $QuizModelCopyWith(QuizModel value, $Res Function(QuizModel) then) =
      _$QuizModelCopyWithImpl<$Res, QuizModel>;
  @useResult
  $Res call({
    String id,
    String newsId,
    String question,
    List<String> options,
    int correctIndex,
    String explanation,
    int? userAnswer,
    bool? isCorrect,
    DateTime? attemptedAt,
  });
}

/// @nodoc
class _$QuizModelCopyWithImpl<$Res, $Val extends QuizModel>
    implements $QuizModelCopyWith<$Res> {
  _$QuizModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuizModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? newsId = null,
    Object? question = null,
    Object? options = null,
    Object? correctIndex = null,
    Object? explanation = null,
    Object? userAnswer = freezed,
    Object? isCorrect = freezed,
    Object? attemptedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            newsId: null == newsId
                ? _value.newsId
                : newsId // ignore: cast_nullable_to_non_nullable
                      as String,
            question: null == question
                ? _value.question
                : question // ignore: cast_nullable_to_non_nullable
                      as String,
            options: null == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            correctIndex: null == correctIndex
                ? _value.correctIndex
                : correctIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            explanation: null == explanation
                ? _value.explanation
                : explanation // ignore: cast_nullable_to_non_nullable
                      as String,
            userAnswer: freezed == userAnswer
                ? _value.userAnswer
                : userAnswer // ignore: cast_nullable_to_non_nullable
                      as int?,
            isCorrect: freezed == isCorrect
                ? _value.isCorrect
                : isCorrect // ignore: cast_nullable_to_non_nullable
                      as bool?,
            attemptedAt: freezed == attemptedAt
                ? _value.attemptedAt
                : attemptedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuizModelImplCopyWith<$Res>
    implements $QuizModelCopyWith<$Res> {
  factory _$$QuizModelImplCopyWith(
    _$QuizModelImpl value,
    $Res Function(_$QuizModelImpl) then,
  ) = __$$QuizModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String newsId,
    String question,
    List<String> options,
    int correctIndex,
    String explanation,
    int? userAnswer,
    bool? isCorrect,
    DateTime? attemptedAt,
  });
}

/// @nodoc
class __$$QuizModelImplCopyWithImpl<$Res>
    extends _$QuizModelCopyWithImpl<$Res, _$QuizModelImpl>
    implements _$$QuizModelImplCopyWith<$Res> {
  __$$QuizModelImplCopyWithImpl(
    _$QuizModelImpl _value,
    $Res Function(_$QuizModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuizModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? newsId = null,
    Object? question = null,
    Object? options = null,
    Object? correctIndex = null,
    Object? explanation = null,
    Object? userAnswer = freezed,
    Object? isCorrect = freezed,
    Object? attemptedAt = freezed,
  }) {
    return _then(
      _$QuizModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        newsId: null == newsId
            ? _value.newsId
            : newsId // ignore: cast_nullable_to_non_nullable
                  as String,
        question: null == question
            ? _value.question
            : question // ignore: cast_nullable_to_non_nullable
                  as String,
        options: null == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        correctIndex: null == correctIndex
            ? _value.correctIndex
            : correctIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        explanation: null == explanation
            ? _value.explanation
            : explanation // ignore: cast_nullable_to_non_nullable
                  as String,
        userAnswer: freezed == userAnswer
            ? _value.userAnswer
            : userAnswer // ignore: cast_nullable_to_non_nullable
                  as int?,
        isCorrect: freezed == isCorrect
            ? _value.isCorrect
            : isCorrect // ignore: cast_nullable_to_non_nullable
                  as bool?,
        attemptedAt: freezed == attemptedAt
            ? _value.attemptedAt
            : attemptedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QuizModelImpl implements _QuizModel {
  const _$QuizModelImpl({
    required this.id,
    required this.newsId,
    required this.question,
    required final List<String> options,
    required this.correctIndex,
    required this.explanation,
    this.userAnswer,
    this.isCorrect,
    this.attemptedAt,
  }) : _options = options;

  factory _$QuizModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuizModelImplFromJson(json);

  @override
  final String id;
  @override
  final String newsId;
  @override
  final String question;
  final List<String> _options;
  @override
  List<String> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  final int correctIndex;
  @override
  final String explanation;
  @override
  final int? userAnswer;
  @override
  final bool? isCorrect;
  @override
  final DateTime? attemptedAt;

  @override
  String toString() {
    return 'QuizModel(id: $id, newsId: $newsId, question: $question, options: $options, correctIndex: $correctIndex, explanation: $explanation, userAnswer: $userAnswer, isCorrect: $isCorrect, attemptedAt: $attemptedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuizModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.newsId, newsId) || other.newsId == newsId) &&
            (identical(other.question, question) ||
                other.question == question) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.correctIndex, correctIndex) ||
                other.correctIndex == correctIndex) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation) &&
            (identical(other.userAnswer, userAnswer) ||
                other.userAnswer == userAnswer) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.attemptedAt, attemptedAt) ||
                other.attemptedAt == attemptedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    newsId,
    question,
    const DeepCollectionEquality().hash(_options),
    correctIndex,
    explanation,
    userAnswer,
    isCorrect,
    attemptedAt,
  );

  /// Create a copy of QuizModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuizModelImplCopyWith<_$QuizModelImpl> get copyWith =>
      __$$QuizModelImplCopyWithImpl<_$QuizModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuizModelImplToJson(this);
  }
}

abstract class _QuizModel implements QuizModel {
  const factory _QuizModel({
    required final String id,
    required final String newsId,
    required final String question,
    required final List<String> options,
    required final int correctIndex,
    required final String explanation,
    final int? userAnswer,
    final bool? isCorrect,
    final DateTime? attemptedAt,
  }) = _$QuizModelImpl;

  factory _QuizModel.fromJson(Map<String, dynamic> json) =
      _$QuizModelImpl.fromJson;

  @override
  String get id;
  @override
  String get newsId;
  @override
  String get question;
  @override
  List<String> get options;
  @override
  int get correctIndex;
  @override
  String get explanation;
  @override
  int? get userAnswer;
  @override
  bool? get isCorrect;
  @override
  DateTime? get attemptedAt;

  /// Create a copy of QuizModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuizModelImplCopyWith<_$QuizModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
