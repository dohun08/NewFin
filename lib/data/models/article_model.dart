import 'package:freezed_annotation/freezed_annotation.dart';
import 'financial_term_model.dart';

part 'article_model.freezed.dart';
part 'article_model.g.dart';

@freezed
class ArticleModel with _$ArticleModel {
  const factory ArticleModel({
    required String id,
    required String title,
    @Default('') String content,
    required String url,
    @Default('') String imageUrl,
    required DateTime publishedAt,
    @Default('') String category,
    @Default(false) bool isFavorite,
    @Default([]) List<FinancialTermModel> terms,
  }) = _ArticleModel;

  factory ArticleModel.fromJson(Map<String, dynamic> json) =>
      _$ArticleModelFromJson(json);
}
