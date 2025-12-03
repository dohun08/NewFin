import 'package:freezed_annotation/freezed_annotation.dart';

part 'term_model.freezed.dart';
part 'term_model.g.dart';

@freezed
class TermModel with _$TermModel {
  const factory TermModel({
    required String id,
    required String term,
    required String definition,
    @Default('') String example,
    String? relatedNewsId,
    @Default('gemini') String source, // 'public_api' or 'gemini'
  }) = _TermModel;

  factory TermModel.fromJson(Map<String, dynamic> json) =>
      _$TermModelFromJson(json);
}
