import 'package:freezed_annotation/freezed_annotation.dart';

part 'financial_term_model.freezed.dart';
part 'financial_term_model.g.dart';

@freezed
class FinancialTermModel with _$FinancialTermModel {
  const factory FinancialTermModel({
    required String term,
    required String definition,
    required String example,
  }) = _FinancialTermModel;

  factory FinancialTermModel.fromJson(Map<String, dynamic> json) =>
      _$FinancialTermModelFromJson(json);
}
