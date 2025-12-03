// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_mission_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyMissionModelImpl _$$DailyMissionModelImplFromJson(
  Map<String, dynamic> json,
) => _$DailyMissionModelImpl(
  id: json['id'] as String,
  date: DateTime.parse(json['date'] as String),
  newsRead: json['newsRead'] as bool? ?? false,
  quizCompleted: json['quizCompleted'] as bool? ?? false,
  loginChecked: json['loginChecked'] as bool? ?? false,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$DailyMissionModelImplToJson(
  _$DailyMissionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'date': instance.date.toIso8601String(),
  'newsRead': instance.newsRead,
  'quizCompleted': instance.quizCompleted,
  'loginChecked': instance.loginChecked,
  'createdAt': instance.createdAt?.toIso8601String(),
};
