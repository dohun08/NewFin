import 'package:dio/dio.dart';
import '../../models/article_model.dart';
import '../../../core/constants/api_constants.dart';
import 'package:uuid/uuid.dart';

class NewsApiService {
  final Dio _dio;
  final _uuid = const Uuid();

  // 금융 관련 키워드 (포함되어야 함)
  static const _financialKeywords = [
    '금리',
    '환율',
    '주가',
    '코스피',
    '코스닥',
    '달러',
    '원화',
    '한국은행',
    '기준금리',
    '금융위',
    '금감원',
    '증권',
    '채권',
    '펀드',
    '예금',
    '대출',
    '이자',
    '투자',
    '자산',
    '배당',
    'GDP',
    '인플레',
    '통화정책',
    '재정',
    '외환',
    '파생상품',
    '선물',
    '옵션',
    '부동산금융',
    '은행',
    '카드',
    '보험',
    '신용',
    '금융',
    '경제',
    '시장',
    '거래',
    '상장',
    '공모',
    'IPO',
    '주식',
    '채무',
    '신용등급',
    '신용평가',
  ];

  // 제외할 키워드 (이게 있으면 걸러냄)
  static const _excludeKeywords = [
    '스무디',
    '커피',
    '음료',
    '식품',
    '맛집',
    '레시피',
    '요리',
    '패션',
    '뷰티',
    '화장품',
    '영화',
    '드라마',
    '아이돌',
    'K-POP',
    '게임',
    'e스포츠',
    '축구',
    '야구',
    '배구',
    '골프',
    '여행',
    '호텔',
    '날씨',
    '교통',
    '사고',
    '범죄',
    '연예',
    '셀럽',
    '아티스트',
  ];

  NewsApiService({Dio? dio})
    : _dio = dio != null
          ? (dio..options.baseUrl = ApiConstants.marketauxApiUrl)
          : Dio(BaseOptions(baseUrl: ApiConstants.marketauxApiUrl));

  Future<List<ArticleModel>> fetchBusinessNews({int page = 1}) async {
    try {
      // 날짜 범위 설정 (최근 7일) - 현재 미사용
      // final now = DateTime.now();
      // final sevenDaysAgo = now.subtract(const Duration(days: 7));
      // final dateFrom = sevenDaysAgo.toIso8601String().split('T').first;
      // final dateTo = now.toIso8601String().split('T').first;

      // API 요청 URL 로그
      final url = '/news/all?language=ko&search=금리&limit=3&page=$page&sort=published_on&sort_order=desc&api_token=${ApiConstants.marketauxApiKey}';
      print('[API] 📡 요청 URL: ${ApiConstants.marketauxApiUrl}$url');
      print('[API] 📄 페이지: $page');

      final response = await _dio.get(
        '/news/all',
        queryParameters: {
          'language': 'ko',
          'search': '금리',
          'limit': 3,
          'page': page,
          'sort': 'published_on', // 최신순 정렬
          'sort_order': 'desc', // 내림차순
          'api_token': ApiConstants.marketauxApiKey,
        },
      );

      if (response.statusCode == 200) {
        if (response.data['data'] == null) {
          throw Exception('No data field in response');
        }

        final List<dynamic> articlesJson = response.data['data'];
        final meta = response.data['meta'];
        
        print('[API] ✅ 응답: ${articlesJson.length}개 (found: ${meta?['found']}, returned: ${meta?['returned']}, limit: ${meta?['limit']}, page: ${meta?['page']})');

        final articles = articlesJson.asMap().entries.map((entry) {
          final json = entry.value;

          return ArticleModel(
            id: json['uuid'] ?? _uuid.v4(),
            title: json['title'] ?? 'No Title',
            content: json['description'] ?? json['snippet'] ?? '',
            url: json['url'] ?? '',
            imageUrl: json['image_url'] ?? '',
            publishedAt: DateTime.parse(json['published_at']),
            category: 'finance',
          );
        }).toList();

        // 금융 관련 뉴스 필터링
        final filteredArticles = articles.where((article) {
          final title = article.title.toLowerCase();
          final content = article.content.toLowerCase();
          final text = '$title $content';

          // 제외 키워드가 있으면 필터링
          for (var keyword in _excludeKeywords) {
            if (text.contains(keyword.toLowerCase())) {
              return false;
            }
          }

          // 금융 키워드가 하나라도 있으면 포함
          for (var keyword in _financialKeywords) {
            if (text.contains(keyword.toLowerCase())) {
              return true;
            }
          }

          return false;
        }).toList();

        print('[API] 🔍 필터링 후: ${filteredArticles.length}개');
        return filteredArticles;
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('[API] ❌ 에러: $e');
      throw Exception('Failed to load news: $e');
    }
  }
}
