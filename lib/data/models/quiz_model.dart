import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz_model.freezed.dart';
part 'quiz_model.g.dart';

@freezed
class QuizModel with _$QuizModel {
  const factory QuizModel({
    required String id,
    required String newsId,
    required String question,
    required List<String> options,
    required int correctIndex,
    required String explanation,
    int? userAnswer,
    bool? isCorrect,
    DateTime? attemptedAt,
  }) = _QuizModel;

  factory QuizModel.fromJson(Map<String, dynamic> json) =>
      _$QuizModelFromJson(json);
}
