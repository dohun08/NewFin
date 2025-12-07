import '../datasources/remote/news_api_service.dart';
import '../datasources/remote/gemini_service.dart';
import '../datasources/remote/web_scraper_service.dart';
import '../datasources/local/database_helper.dart';
import '../models/article_model.dart';

class NewsRepositoryImpl {
  final NewsApiService _newsApiService;
  final GeminiService _geminiService;
  final DatabaseHelper _databaseHelper;
  final WebScraperService _webScraperService;

  NewsRepositoryImpl({
    required NewsApiService newsApiService,
    required GeminiService geminiService,
    required DatabaseHelper databaseHelper,
    WebScraperService? webScraperService,
  }) : _newsApiService = newsApiService,
       _geminiService = geminiService,
       _databaseHelper = databaseHelper,
       _webScraperService = webScraperService ?? WebScraperService();

  Future<List<ArticleModel>> getNews({
    int page = 1,
    List<String>? excludeIds,
  }) async {
    try {
      print('[Repository] 🎯 페이지 요청: $page');

      // 읽은 뉴스 ID 목록 가져오기
      final readNewsIds = await _databaseHelper.getReadNewsIds();
      print('[Repository] 📚 읽은 뉴스: ${readNewsIds.length}개');

      // 제외할 ID 목록 (이미 화면에 표시된 뉴스)
      final excludeSet = {...readNewsIds, ...(excludeIds ?? [])};
      if (excludeIds != null && excludeIds.isNotEmpty) {
        print('[Repository] 🚫 제외할 뉴스 ID: ${excludeIds.length}개');
      }

      int currentPage = page;
      final List<ArticleModel> processedArticles = [];
      const int targetCount = 3; // 목표: 읽지 않은 뉴스 3개
      const int maxAttempts = 10; // 최대 페이지 시도 횟수
      int attempts = 0;

      // 읽지 않은 뉴스 3개를 찾을 때까지 페이지를 증가시키며 검색
      while (processedArticles.length < targetCount && attempts < maxAttempts) {
        attempts++;
        print(
          '[Repository] 📰 페이지 $currentPage 조회 중... (시도 $attempts/$maxAttempts)',
        );

        // 해당 페이지의 뉴스 가져오기
        final articles = await _newsApiService.fetchBusinessNews(
          page: currentPage,
        );

        if (articles.isEmpty) {
          print('[Repository] ⚠️ 페이지 $currentPage: API에서 더 이상 뉴스 없음');
          break;
        }

        print('[Repository] 📥 페이지 $currentPage: API에서 ${articles.length}개 받음');

        // 읽지 않은 뉴스 & 중복되지 않은 뉴스만 필터링
        final unreadArticles = articles.where((article) {
          final shouldExclude = excludeSet.contains(article.id);
          if (shouldExclude) {
            final titlePreview = article.title.length > 30
                ? article.title.substring(0, 30)
                : article.title;
            print('[Repository] 🔖 제외: $titlePreview...');
          }
          return !shouldExclude;
        }).toList();

        print(
          '[Repository] 📊 페이지 $currentPage: 유효한 뉴스 ${unreadArticles.length}개',
        );

        // 1. 크롤링 + 2. Gemini로 용어 추출
        for (var article in unreadArticles) {
          if (processedArticles.length >= targetCount) {
            print('[Repository] ✅ 목표 개수($targetCount) 달성!');
            break;
          }

          try {
            final titlePreview = article.title.length > 50
                ? article.title.substring(0, 50) + '...'
                : article.title;
            print('\n[Repository] 📰 처리 시작: $titlePreview');
            print('[Repository] 📍 URL: ${article.url}');
            print('[Repository] 📄 API 본문 길이: ${article.content.length}자');

            String contentToExtract = article.content;

            // 🔍 크롤링 시도 (URL이 있고 본문이 350자 미만이면)
            if (article.url.isNotEmpty &&
                (article.content.isEmpty || article.content.length < 350)) {
              print('[Repository] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
              print(
                '[Repository] 🔍 크롤링 시작 (API 본문 부족: ${article.content.length}자 < 350자)',
              );
              print('[Repository] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

              final scrapedContent = await _webScraperService.scrapeNewsContent(
                article.url,
              );

              if (scrapedContent != null && scrapedContent.isNotEmpty) {
                contentToExtract = scrapedContent;
                article = article.copyWith(content: scrapedContent);
                print('[Repository] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
                print('[Repository] ✅ 크롤링 성공!');
                print('[Repository]    📊 API 본문: ${article.content.length}자');
                print('[Repository]    🌐 크롤링: ${scrapedContent.length}자');
                print(
                  '[Repository]    📈 증가량: +${scrapedContent.length - article.content.length}자',
                );
                print('[Repository] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
                print(
                  '[Repository] 📝 크롤링 본문 미리보기:\n${scrapedContent.substring(0, scrapedContent.length > 150 ? 150 : scrapedContent.length)}...',
                );
                print('[Repository] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
              } else {
                print('[Repository] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
                print(
                  '[Repository] ❌ 크롤링 실패 → API 본문 사용 (${article.content.length}자)',
                );
                print('[Repository] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
                contentToExtract = article.content.isNotEmpty
                    ? article.content
                    : article.title;
              }
            } else {
              print(
                '[Repository] ⏭️ 크롤링 건너뛰기 (본문 충분: ${article.content.length}자 ≥ 350자)\n',
              );
            }

            print(
              '[Repository] 🤖 Gemini 용어 추출 시작 (${contentToExtract.length}자)...',
            );

            // 용어 추출
            final terms = await _geminiService.extractTerms(contentToExtract);

            print('[Repository] 💡 추출된 용어 ${terms.length}개:');
            for (var i = 0; i < terms.length; i++) {
              print(
                '[Repository]    ${i + 1}. ${terms[i].term} - ${terms[i].definition.substring(0, terms[i].definition.length > 40 ? 40 : terms[i].definition.length)}...',
              );
            }

            final processedArticle = article.copyWith(terms: terms);
            processedArticles.add(processedArticle);

            print(
              '[Repository] ✨ 처리 완료 (${processedArticles.length}/$targetCount): $titlePreview\n',
            );
          } catch (e) {
            // 크롤링/용어 추출 실패시 원본 그대로 추가
            processedArticles.add(article);
            final titlePreview = article.title.length > 30
                ? article.title.substring(0, 30) + '...'
                : article.title;
            print('[Repository] ⚠️ 처리 실패, 그대로 추가: $titlePreview');
            print('[Repository] ❌ 에러: $e\n');
          }
        }

        // 목표 개수를 채웠으면 종료
        if (processedArticles.length >= targetCount) {
          break;
        }

        // 다음 페이지로
        currentPage++;
        print('[Repository] ➡️ 다음 페이지로 이동: $currentPage');
      }

      print(
        '[Repository] 🎯 최종 반환: ${processedArticles.length}개의 뉴스 (페이지 $page~${currentPage} 조회)',
      );
      return processedArticles;
    } catch (e) {
      print('[Repository] ❌ 뉴스 불러오기 실패: $e');
      return [];
    }
  }

  // 사용자가 뉴스를 읽었을 때 호출 (읽은 기록 저장)
  Future<void> markAsRead(String newsId) async {
    try {
      await _databaseHelper.markNewsAsRead(newsId);
      print('[Repository] 📖 뉴스 읽음 표시: $newsId');
    } catch (e) {
      print('[Repository] ❌ 읽음 표시 실패: $e');
    }
  }

  // 읽은 뉴스 목록 가져오기
  Future<List<String>> getReadNewsIds() async {
    try {
      final readIds = await _databaseHelper.getReadNewsIds();
      print('[Repository] 📚 읽은 뉴스 개수: ${readIds.length}개');
      return readIds;
    } catch (e) {
      print('[Repository] ❌ 읽은 뉴스 목록 가져오기 실패: $e');
      return [];
    }
  }

  // 수동으로 뉴스 추가 (붙여넣기)
  Future<ArticleModel> addManualNews(String newsText) async {
    try {
      print('[Repository] 📝 수동 뉴스 추가 시작...');

      // Gemini로 용어 추출
      final terms = await _geminiService.extractTerms(newsText);

      final now = DateTime.now();
      final article = ArticleModel(
        id: 'manual_${now.millisecondsSinceEpoch}',
        title: '직접 추가한 뉴스 - ${now.year}.${now.month}.${now.day}',
        content: newsText,
        url: '',
        imageUrl: '',
        publishedAt: now,
        category: '직접 추가',
        terms: terms,
      );

      print('[Repository] ✅ 수동 뉴스 생성 완료: ${terms.length}개 용어 추출');
      return article;
    } catch (e) {
      print('[Repository] ❌ 수동 뉴스 추가 실패: $e');
      rethrow;
    }
  }
}
