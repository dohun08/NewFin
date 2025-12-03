// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_mission_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DailyMissionModel _$DailyMissionModelFromJson(Map<String, dynamic> json) {
  return _DailyMissionModel.fromJson(json);
}

/// @nodoc
mixin _$DailyMissionModel {
  String get id => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  bool get newsRead => throw _privateConstructorUsedError; // 뉴스 2개 읽음
  bool get quizCompleted => throw _privateConstructorUsedError; // 퀴즈 1세트 완료
  bool get loginChecked => throw _privateConstructorUsedError; // 로그인
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this DailyMissionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyMissionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyMissionModelCopyWith<DailyMissionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyMissionModelCopyWith<$Res> {
  factory $DailyMissionModelCopyWith(
    DailyMissionModel value,
    $Res Function(DailyMissionModel) then,
  ) = _$DailyMissionModelCopyWithImpl<$Res, DailyMissionModel>;
  @useResult
  $Res call({
    String id,
    DateTime date,
    bool newsRead,
    bool quizCompleted,
    bool loginChecked,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$DailyMissionModelCopyWithImpl<$Res, $Val extends DailyMissionModel>
    implements $DailyMissionModelCopyWith<$Res> {
  _$DailyMissionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyMissionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? newsRead = null,
    Object? quizCompleted = null,
    Object? loginChecked = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            newsRead: null == newsRead
                ? _value.newsRead
                : newsRead // ignore: cast_nullable_to_non_nullable
                      as bool,
            quizCompleted: null == quizCompleted
                ? _value.quizCompleted
                : quizCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            loginChecked: null == loginChecked
                ? _value.loginChecked
                : loginChecked // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyMissionModelImplCopyWith<$Res>
    implements $DailyMissionModelCopyWith<$Res> {
  factory _$$DailyMissionModelImplCopyWith(
    _$DailyMissionModelImpl value,
    $Res Function(_$DailyMissionModelImpl) then,
  ) = __$$DailyMissionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime date,
    bool newsRead,
    bool quizCompleted,
    bool loginChecked,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$DailyMissionModelImplCopyWithImpl<$Res>
    extends _$DailyMissionModelCopyWithImpl<$Res, _$DailyMissionModelImpl>
    implements _$$DailyMissionModelImplCopyWith<$Res> {
  __$$DailyMissionModelImplCopyWithImpl(
    _$DailyMissionModelImpl _value,
    $Res Function(_$DailyMissionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyMissionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? newsRead = null,
    Object? quizCompleted = null,
    Object? loginChecked = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$DailyMissionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        newsRead: null == newsRead
            ? _value.newsRead
            : newsRead // ignore: cast_nullable_to_non_nullable
                  as bool,
        quizCompleted: null == quizCompleted
            ? _value.quizCompleted
            : quizCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        loginChecked: null == loginChecked
            ? _value.loginChecked
            : loginChecked // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyMissionModelImpl extends _DailyMissionModel {
  const _$DailyMissionModelImpl({
    required this.id,
    required this.date,
    this.newsRead = false,
    this.quizCompleted = false,
    this.loginChecked = false,
    this.createdAt,
  }) : super._();

  factory _$DailyMissionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyMissionModelImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime date;
  @override
  @JsonKey()
  final bool newsRead;
  // 뉴스 2개 읽음
  @override
  @JsonKey()
  final bool quizCompleted;
  // 퀴즈 1세트 완료
  @override
  @JsonKey()
  final bool loginChecked;
  // 로그인
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'DailyMissionModel(id: $id, date: $date, newsRead: $newsRead, quizCompleted: $quizCompleted, loginChecked: $loginChecked, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyMissionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.newsRead, newsRead) ||
                other.newsRead == newsRead) &&
            (identical(other.quizCompleted, quizCompleted) ||
                other.quizCompleted == quizCompleted) &&
            (identical(other.loginChecked, loginChecked) ||
                other.loginChecked == loginChecked) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    date,
    newsRead,
    quizCompleted,
    loginChecked,
    createdAt,
  );

  /// Create a copy of DailyMissionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyMissionModelImplCopyWith<_$DailyMissionModelImpl> get copyWith =>
      __$$DailyMissionModelImplCopyWithImpl<_$DailyMissionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyMissionModelImplToJson(this);
  }
}

abstract class _DailyMissionModel extends DailyMissionModel {
  const factory _DailyMissionModel({
    required final String id,
    required final DateTime date,
    final bool newsRead,
    final bool quizCompleted,
    final bool loginChecked,
    final DateTime? createdAt,
  }) = _$DailyMissionModelImpl;
  const _DailyMissionModel._() : super._();

  factory _DailyMissionModel.fromJson(Map<String, dynamic> json) =
      _$DailyMissionModelImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get date;
  @override
  bool get newsRead; // 뉴스 2개 읽음
  @override
  bool get quizCompleted; // 퀴즈 1세트 완료
  @override
  bool get loginChecked; // 로그인
  @override
  DateTime? get createdAt;

  /// Create a copy of DailyMissionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyMissionModelImplCopyWith<_$DailyMissionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
