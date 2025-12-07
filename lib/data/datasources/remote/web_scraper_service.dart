import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';

class WebScraperService {
  /// 뉴스 URL에서 본문을 크롤링
  Future<String?> scrapeNewsContent(String url) async {
    try {
      print('[Scraper] 📡 크롤링 시작: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        print('[Scraper] ❌ HTTP 오류: ${response.statusCode}');
        return null;
      }

      final document = html_parser.parse(response.body);

      // 다양한 뉴스 사이트의 본문 선택자 시도
      String? content = _extractContent(document);

      if (content != null && content.length > 100) {
        print('[Scraper] ✅ 크롤링 성공: ${content.length}자');
        return _cleanContent(content);
      }

      print('[Scraper] ⚠️ 본문을 찾을 수 없음');
      return null;
    } catch (e) {
      print('[Scraper] ❌ 크롤링 실패: $e');
      return null;
    }
  }

  /// 다양한 선택자로 본문 추출 시도
  String? _extractContent(Document document) {
    // 일반적인 뉴스 본문 선택자들
    final selectors = [
      'article',
      '.article-body',
      '.article-content',
      '.news-content',
      '.content',
      '#content',
      '.post-content',
      '.entry-content',
      'div[itemprop="articleBody"]',
      '.article_body',
      '#articleBody',
      '.news_body',
    ];

    for (final selector in selectors) {
      final elements = document.querySelectorAll(selector);
      if (elements.isNotEmpty) {
        final text = elements.first.text.trim();
        if (text.length > 100) {
          return text;
        }
      }
    }

    // 선택자로 못 찾으면 p 태그들을 모아서 반환
    final paragraphs = document.querySelectorAll('p');
    if (paragraphs.length > 3) {
      final texts = paragraphs
          .map((p) => p.text.trim())
          .where((text) => text.isNotEmpty && text.length > 20)
          .toList();

      if (texts.isNotEmpty) {
        return texts.join('\n\n');
      }
    }

    return null;
  }

  /// 불필요한 공백 및 특수문자 제거
  String _cleanContent(String content) {
    return content
        .replaceAll(RegExp(r'\s+'), ' ') // 여러 공백을 하나로
        .replaceAll(RegExp(r'\n{3,}'), '\n\n') // 여러 줄바꿈을 두 개로
        .trim();
  }
}
