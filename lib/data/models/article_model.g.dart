// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ArticleModelImpl _$$ArticleModelImplFromJson(Map<String, dynamic> json) =>
    _$ArticleModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String? ?? '',
      url: json['url'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      category: json['category'] as String? ?? '',
      isFavorite: json['isFavorite'] as bool? ?? false,
      terms:
          (json['terms'] as List<dynamic>?)
              ?.map(
                (e) => FinancialTermModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ArticleModelImplToJson(_$ArticleModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'url': instance.url,
      'imageUrl': instance.imageUrl,
      'publishedAt': instance.publishedAt.toIso8601String(),
      'category': instance.category,
      'isFavorite': instance.isFavorite,
      'terms': instance.terms,
    };
