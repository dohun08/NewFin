import 'package:google_generative_ai/google_generative_ai.dart';
import '../../models/quiz_model.dart';
import '../../models/financial_term_model.dart';
import '../../../core/constants/api_constants.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class GeminiService {
  late final GenerativeModel _model;
  final _uuid = const Uuid();

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: ApiConstants.geminiApiKey,
    );
  }

  // 뉴스 본문에서 금융 용어 추출 및 설명 생성
  Future<List<FinancialTermModel>> extractTerms(String content) async {
    print('\n[✨ Gemini] 금융 용어 추출 요청');
    print('[✨ Gemini] 입력 길이: ${content.length}자');
    print(
      '[✨ Gemini] 본문 미리보기: ${content.substring(0, content.length > 100 ? 100 : content.length)}...',
    );

    final prompt =
        '''
다음 뉴스 내용에서 10대 학습자가 배워야 할 **모든** 금융/경제 용어를 추출하고, 
각 용어에 대해 간단한 설명(1~2문장)과 쉬운 예시 문장(1개)을 작성해줘.

**중요**: 
- 반드시 뉴스 본문에 실제로 등장하는 용어만 추출
- 어려운 금융/경제 용어는 모두 포함 (개수 제한 없음)
- 예: 환율, 기준금리, 달러인덱스, 연방준비제도, 인플레이션, 코스피, 순매도, 외환시장, 금리 인하, 관세, 선물, 연방기금선물 등

뉴스 내용:
$content

**필수**: 아래 JSON 형식으로만 응답해줘. 다른 설명 없이 JSON 배열만:
[
  {
    "term": "원·달러 환율",
    "definition": "원화와 달러의 교환 비율을 말해요",
    "example": "환율이 오르면 해외여행 갈 때 더 많은 원화가 필요해요"
  }
]
''';

    try {
      final contentObj = [Content.text(prompt)];
      final response = await _model.generateContent(contentObj);
      final responseText = response.text
          ?.replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      if (responseText != null && responseText.isNotEmpty) {
        print(
          '[✨ Gemini] 응답 받음: ${responseText.substring(0, responseText.length > 200 ? 200 : responseText.length)}...',
        );

        final jsonList = jsonDecode(responseText) as List;
        print('[✨ Gemini] ✅ 용어 ${jsonList.length}개 추출 완료');

        final terms = jsonList
            .map(
              (json) => FinancialTermModel(
                term: json['term'],
                definition: json['definition'],
                example: json['example'],
              ),
            )
            .toList();

        for (var i = 0; i < terms.length; i++) {
          print('[✨ Gemini]   ${i + 1}. ${terms[i].term}');
        }
        print('');

        return terms;
      } else {
        print('[✨ Gemini] ❌ 응답 없음\n');
        return [];
      }
    } catch (e) {
      print('[✨ Gemini] ❌ 파싱 오류: $e');
      return [];
    }
  }

  // 별칭 (호환성)
  Future<List<FinancialTermModel>> extractFinancialTerms(String content) =>
      extractTerms(content);

  // 긴 텍스트를 지정된 길이로 요약
  Future<String> summarizeToLength(String content, int targetLength) async {
    print('\n[✨ Gemini] 텍스트 요약 요청 (목표: ${targetLength}자)');
    print('[✨ Gemini] 입력 길이: ${content.length}자');

    final prompt =
        '''
    다음 뉴스 내용을 약 ${targetLength}자 내외로 요약해줘. 
    핵심 내용을 유지하면서 간결하게 정리해줘.
    
    뉴스 내용:
    $content
    ''';

    try {
      final contentObj = [Content.text(prompt)];
      final response = await _model.generateContent(contentObj);
      final summary = response.text ?? content.substring(0, targetLength);

      print('[✨ Gemini] ✅ 요약 완료');
      print('[✨ Gemini] 결과 길이: ${summary.length}자\n');
      return summary;
    } catch (e) {
      print('[✨ Gemini] ❌ 요약 실패, 앞부분 ${targetLength}자 사용: $e\n');
      // 실패 시 앞부분만 잘라서 반환
      return content.substring(0, targetLength.clamp(0, content.length));
    }
  }

  // 상세보기 화면에서 사용자가 붙여넣은 원문 요약
  Future<String> summarizeNews(String content) async {
    print('\n[✨ Gemini] 뉴스 요약 요청');
    print('[✨ Gemini] 입력 길이: ${content.length}자');

    final prompt =
        '''
    다음 금융 뉴스를 10대 후반이 이해하기 쉽게 3~5문장으로 요약해줘. 핵심만 간결하게.
    뉴스 내용:
    $content
    ''';

    try {
      final contentObj = [Content.text(prompt)];
      final response = await _model.generateContent(contentObj);
      final summary = response.text ?? '요약을 생성할 수 없습니다.';

      print('[✨ Gemini] ✅ 요약 완료');
      print('[✨ Gemini] 결과 길이: ${summary.length}자\n');
      return summary;
    } catch (e) {
      print('[✨ Gemini] ❌ 오류: $e\n');
      throw Exception('Gemini API error: $e');
    }
  }

  Future<String> explainTerm(String term) async {
    print('\n[✨ Gemini] 용어 해설 요청: "$term"');

    final prompt =
        '''
    '$term'라는 금융 용어를 10대가 이해할 수 있도록 1~2문장으로 쉽게 설명하고, 간단한 예시 문장 1개를 추가해줘.
    형식:
    정의: ...
    예시: ...
    ''';

    try {
      final contentObj = [Content.text(prompt)];
      final response = await _model.generateContent(contentObj);
      final explanation = response.text ?? '설명을 생성할 수 없습니다.';

      print('[✨ Gemini] ✅ 해설 완료\n');
      return explanation;
    } catch (e) {
      print('[✨ Gemini] ❌ 오류: $e\n');
      throw Exception('Gemini API error: $e');
    }
  }

  Future<List<QuizModel>> generateQuiz(
    String newsSummary,
    String newsId,
  ) async {
    print('\n[✨ Gemini] 퀴즈 생성 요청');

    final prompt =
        '''
    다음 뉴스 요약을 바탕으로 10대 학습자를 위한 객관식 문제 3개를 생성해줘.
    
    뉴스 요약:
    $newsSummary

    JSON 형식으로만 응답해줘. 최상위는 배열이어야 해:
    [
      {
        "question": "질문 내용",
        "options": ["선택지1", "선택지2", "선택지3", "선택지4"],
        "correctIndex": 0, // 0~3 사이의 정답 인덱스
        "explanation": "해설 내용 1~2문장"
      },
      ...
    ]
    ''';

    try {
      final contentObj = [Content.text(prompt)];
      final response = await _model.generateContent(contentObj);
      final responseText = response.text
          ?.replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      if (responseText != null) {
        final jsonList = jsonDecode(responseText) as List;
        print('[✨ Gemini] ✅ 퀴즈 ${jsonList.length}개 생성 완료\n');
        return jsonList
            .map(
              (json) => QuizModel(
                id: _uuid.v4(),
                newsId: newsId,
                question: json['question'],
                options: List<String>.from(json['options']),
                correctIndex: json['correctIndex'],
                explanation: json['explanation'],
              ),
            )
            .toList();
      } else {
        print('[✨ Gemini] ❌ 응답 없음\n');
        throw Exception('Failed to generate quiz');
      }
    } catch (e) {
      print('[✨ Gemini] ❌ 오류: $e\n');
      rethrow;
    }
  }
}
