import '../datasources/remote/news_api_service.dart';
import '../datasources/remote/gemini_service.dart';
import '../datasources/local/database_helper.dart';
import '../models/article_model.dart';

class NewsRepositoryImpl {
  final NewsApiService _newsApiService;
  final GeminiService _geminiService;
  final DatabaseHelper _databaseHelper;

  NewsRepositoryImpl({
    required NewsApiService newsApiService,
    required GeminiService geminiService,
    required DatabaseHelper databaseHelper,
  })  : _newsApiService = newsApiService,
        _geminiService = geminiService,
        _databaseHelper = databaseHelper;

  Future<List<ArticleModel>> getNews({int page = 1}) async {
    try {
      print('[Repository] 🎯 시작 페이지: $page');
      final List<ArticleModel> unreadArticles = [];
      int currentPage = page;
      const int targetCount = 5; // 목표: 읽지 않은 뉴스 5개
      const int maxAttempts = 10; // 최대 시도 횟수
      int attempts = 0;

      // 읽은 뉴스 ID 목록 가져오기
      final readNewsIds = await _databaseHelper.getReadNewsIds();
      print('[Repository] 📚 읽은 뉴스: ${readNewsIds.length}개');

      while (unreadArticles.length < targetCount && attempts < maxAttempts) {
        attempts++;
        print('[Repository] 📰 페이지 $currentPage 불러오는 중... (시도 $attempts/$maxAttempts)');

        final articles = await _newsApiService.fetchBusinessNews(page: currentPage);
        
        if (articles.isEmpty) {
          print('[Repository] ⚠️ 페이지 $currentPage: 뉴스 없음 (API 끝)');
          break;
        }

        // 읽지 않은 뉴스만 필터링
        final newUnreadArticles = articles.where((article) {
          final isUnread = !readNewsIds.contains(article.id);
          if (!isUnread) {
            print('[Repository] 🔖 이미 읽은 뉴스 제외: ${article.title.substring(0, 30)}...');
          }
          return isUnread;
        }).toList();

        print('[Repository] 📊 페이지 $currentPage: API ${articles.length}개 → 읽지 않은 ${newUnreadArticles.length}개');

        // Gemini로 용어 추출
        for (var article in newUnreadArticles) {
          if (unreadArticles.length >= targetCount) {
            print('[Repository] ✅ 목표 달성! 더 이상 처리 안함');
            break;
          }

          try {
            final contentToExtract = article.content.isNotEmpty ? article.content : article.title;
            final terms = await _geminiService.extractTerms(contentToExtract);
            
            final processedArticle = article.copyWith(terms: terms);
            unreadArticles.add(processedArticle);
            print('[Repository] ✨ 처리 완료 (${unreadArticles.length}/$targetCount): ${article.title.substring(0, 30)}...');
          } catch (e) {
            // 용어 추출 실패시 빈 리스트로 추가
            unreadArticles.add(article);
            print('[Repository] ⚠️ 용어 추출 실패, 그대로 추가: ${article.title.substring(0, 30)}...');
          }
        }

        // 목표 개수를 채웠으면 종료
        if (unreadArticles.length >= targetCount) {
          print('[Repository] 🎉 목표 달성: ${unreadArticles.length}개의 읽지 않은 뉴스');
          break;
        }

        // 다음 페이지로
        currentPage++;
        print('[Repository] ➡️ 다음 페이지로 이동: $currentPage');
      }

      print('[Repository] 🎯 최종 반환: ${unreadArticles.length}개의 뉴스');
      return unreadArticles;
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
}
