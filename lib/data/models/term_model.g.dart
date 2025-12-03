// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'term_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TermModelImpl _$$TermModelImplFromJson(Map<String, dynamic> json) =>
    _$TermModelImpl(
      id: json['id'] as String,
      term: json['term'] as String,
      definition: json['definition'] as String,
      example: json['example'] as String? ?? '',
      relatedNewsId: json['relatedNewsId'] as String?,
      source: json['source'] as String? ?? 'gemini',
    );

Map<String, dynamic> _$$TermModelImplToJson(_$TermModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'term': instance.term,
      'definition': instance.definition,
      'example': instance.example,
      'relatedNewsId': instance.relatedNewsId,
      'source': instance.source,
    };
