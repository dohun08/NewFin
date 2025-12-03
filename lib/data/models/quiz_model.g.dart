// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuizModelImpl _$$QuizModelImplFromJson(Map<String, dynamic> json) =>
    _$QuizModelImpl(
      id: json['id'] as String,
      newsId: json['newsId'] as String,
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      correctIndex: (json['correctIndex'] as num).toInt(),
      explanation: json['explanation'] as String,
      userAnswer: (json['userAnswer'] as num?)?.toInt(),
      isCorrect: json['isCorrect'] as bool?,
      attemptedAt: json['attemptedAt'] == null
          ? null
          : DateTime.parse(json['attemptedAt'] as String),
    );

Map<String, dynamic> _$$QuizModelImplToJson(_$QuizModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'newsId': instance.newsId,
      'question': instance.question,
      'options': instance.options,
      'correctIndex': instance.correctIndex,
      'explanation': instance.explanation,
      'userAnswer': instance.userAnswer,
      'isCorrect': instance.isCorrect,
      'attemptedAt': instance.attemptedAt?.toIso8601String(),
    };
