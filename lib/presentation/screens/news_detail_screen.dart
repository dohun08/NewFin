import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/article_model.dart';
import '../../data/models/financial_term_model.dart';
import '../../data/datasources/remote/gemini_service.dart';
import '../../data/datasources/remote/web_scraper_service.dart';
import '../../data/datasources/local/database_helper.dart';
import '../providers/providers.dart';
import '../providers/coin_provider.dart';
import '../providers/stats_provider.dart';
import '../../core/theme/app_theme.dart';

class NewsDetailScreen extends ConsumerStatefulWidget {
  final ArticleModel article;

  const NewsDetailScreen({super.key, required this.article});

  @override
  ConsumerState<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends ConsumerState<NewsDetailScreen> {
  final TextEditingController _contentController = TextEditingController();
  String? _summary;
  String? _scrapedContent; // 크롤링한 원문
  List<FinancialTermModel> _scrapedTerms = []; // 크롤링 내용의 금융 용어
  bool _isLoadingSummary = false;
  bool _isScraping = false;
  bool _isAnalyzingTerms = false;
  FinancialTermModel? _selectedTerm;

  @override
  void initState() {
    super.initState();
    _markAsRead();

    // API에서 본문이 없으면 자동으로 크롤링 시도
    if (widget.article.content.isEmpty || widget.article.content.length < 100) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrapeContent();
      });
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _markAsRead() async {
    try {
      final db = DatabaseHelper();
      await db.markNewsAsRead(
        widget.article.id,
        title: widget.article.title,
        url: widget.article.url,
      );

      // 읽은 뉴스 개수 확인 후 미션 업데이트
      final todayReadCount = await _getTodayReadCount();

      if (todayReadCount >= 2) {
        final missionRepo = ref.read(missionRepositoryProvider);
        await missionRepo.updateNewsReadMission(todayReadCount);
        ref.invalidate(todayMissionProvider); // 미션 상태 새로고침
      }

      // 💰 코인 적립 (오늘 읽은 뉴스 5개 이하만 적립)
      if (todayReadCount <= 5) {
        final coinActions = ref.read(coinActionsProvider);
        await coinActions.addCoins(amount: 20, description: '📰 뉴스 읽기');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('💰 +20 NC 적립! (오늘 $todayReadCount/5개)'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      // 📊 통계 업데이트
      ref.read(statsProvider.notifier).refresh();
    } catch (e) {
      // 읽음 처리 실패 시 무시
    }
  }

  Future<int> _getTodayReadCount() async {
    final db = DatabaseHelper();
    final allRead = await db.getReadNewsWithTime();
    final today = DateTime.now();

    return allRead.where((news) {
      final readAt = DateTime.parse(news['readAt'] as String);
      return readAt.year == today.year &&
          readAt.month == today.month &&
          readAt.day == today.day;
    }).length;
  }

  Future<void> _saveLearnedTerm(FinancialTermModel term) async {
    try {
      final db = DatabaseHelper();
      await db.saveLearnedTerm(term.term, term.definition, term.example);

      // 📊 통계 업데이트
      ref.read(statsProvider.notifier).refresh();
    } catch (e) {
      // 이미 저장된 용어일 수 있음 (UNIQUE 제약) - 무시
    }
  }

  /// 원문 URL에서 본문을 크롤링
  Future<void> _scrapeContent() async {
    if (widget.article.url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('원문 링크가 없습니다!')));
      return;
    }

    setState(() {
      _isScraping = true;
    });

    try {
      final scraper = WebScraperService();
      final content = await scraper.scrapeNewsContent(widget.article.url);

      if (content != null && content.isNotEmpty) {
        setState(() {
          _scrapedContent = content;
          _contentController.text = content;
        });

        // 크롤링 성공 후 자동으로 금융 용어 분석
        await _analyzeTermsInContent(content);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ 크롤링 완료! ${content.length}자'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ 본문을 찾을 수 없습니다.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('크롤링 실패: $e')));
      }
    } finally {
      setState(() {
        _isScraping = false;
      });
    }
  }

  /// 크롤링한 내용에서 금융 용어 분석
  Future<void> _analyzeTermsInContent(String content) async {
    setState(() {
      _isAnalyzingTerms = true;
    });

    try {
      final geminiService = GeminiService();

      // 1000자 이상이면 600자로 요약
      String contentForAnalysis = content;
      if (content.length > 1000) {
        print('[용어 분석] 본문이 ${content.length}자로 길어서 600자로 요약 중...');
        contentForAnalysis = await geminiService.summarizeToLength(
          content,
          600,
        );
        print('[용어 분석] 요약 완료: ${contentForAnalysis.length}자');
      }

      final terms = await geminiService.extractFinancialTerms(
        contentForAnalysis,
      );

      setState(() {
        _scrapedTerms = terms;
      });

      print('[용어 분석] ${terms.length}개 용어 발견');
    } catch (e) {
      print('[용어 분석 실패] $e');
    } finally {
      setState(() {
        _isAnalyzingTerms = false;
      });
    }
  }

  Future<void> _generateSummary() async {
    final textToSummarize = _contentController.text.trim().isEmpty
        ? (_scrapedContent ?? widget.article.content)
        : _contentController.text.trim();

    if (textToSummarize.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('요약할 내용이 없습니다!')));
      return;
    }

    setState(() {
      _isLoadingSummary = true;
      _summary = null;
    });

    try {
      final geminiService = GeminiService();
      final summary = await geminiService.summarizeNews(textToSummarize);
      setState(() {
        _summary = summary;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('요약 생성 실패: $e')));
    } finally {
      setState(() {
        _isLoadingSummary = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('뉴스 상세'),
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // 뉴스 이미지
            if (widget.article.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.article.imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            if (widget.article.imageUrl.isNotEmpty) const SizedBox(height: 16),

            Text(
              widget.article.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              widget.article.publishedAt.toString().split(' ')[0],
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // 본문 내용 (용어에 밑줄 표시)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "📰 뉴스 본문",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_isScraping || _isAnalyzingTerms)
                  Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isScraping ? '크롤링 중...' : '용어 분석 중...',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildContentWithTerms(),

            const SizedBox(height: 24),

            // 원문 요약 섹션
            const Text(
              "📝 AI 요약 및 용어 분석",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 현재 상태 안내
            if (_scrapedContent != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '✅ 원문 크롤링 완료 (${_scrapedContent!.length}자)',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (widget.article.content.isNotEmpty &&
                widget.article.content.length >= 100)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'API 뉴스 본문 사용 중',
                        style: TextStyle(fontSize: 13, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),

            // 자동 크롤링 버튼 (본문이 짧을 때만 표시)
            if (widget.article.content.isEmpty ||
                widget.article.content.length < 100)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isScraping ? null : _scrapeContent,
                  icon: _isScraping
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download),
                  label: Text(_isScraping ? '크롤링 중...' : '🔍 원문 자동 크롤링'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppTheme.primaryColor),
                    foregroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            if (widget.article.content.isEmpty ||
                widget.article.content.length < 100)
              const SizedBox(height: 24),

            // 요약 결과 표시
            if (_summary != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.secondaryColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.summarize, color: AppTheme.secondaryColor),
                        SizedBox(width: 8),
                        Text(
                          '📌 AI 요약',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _summary!,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push(
                    '/quiz',
                    extra: {
                      'newsId': widget.article.id,
                      'summary': _summary ?? widget.article.content,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "퀴즈 풀러 가기",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    // 하단 고정 용어 해설 패널
    if (_selectedTerm != null)
      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: _buildBottomTermPanel(_selectedTerm!),
      ),
    ],
  );
  }

  Widget _buildContentWithTerms() {
    // 1. 크롤링한 내용이 있으면 크롤링 내용 + 크롤링 용어 사용
    // 2. 없으면 API 내용 + API 용어 사용
    final content = _scrapedContent ?? widget.article.content;
    final terms = _scrapedContent != null
        ? _scrapedTerms
        : widget.article.terms;

    if (content.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.warning_amber, color: Colors.orange, size: 32),
            const SizedBox(height: 8),
            const Text(
              '본문 내용이 없습니다',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '위의 "원문 자동 크롤링" 버튼을 눌러주세요',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (terms.isEmpty) {
      return SelectableText(
        content,
        style: const TextStyle(fontSize: 15, height: 1.6),
      );
    }

    // 용어를 찾아서 밑줄 표시
    final List<TextSpan> spans = [];
    String remainingText = content;
    int processedLength = 0;

    while (remainingText.isNotEmpty && processedLength < content.length) {
      FinancialTermModel? foundTermModel;
      int foundIndex = -1;

      // 현재 위치에서 가장 먼저 나오는 용어 찾기
      for (final term in terms) {
        final index = remainingText.indexOf(term.term);
        if (index != -1 && (foundIndex == -1 || index < foundIndex)) {
          foundIndex = index;
          foundTermModel = term;
        }
      }

      if (foundIndex == 0 && foundTermModel != null) {
        // 용어 발견 - 밑줄 표시
        final termText = foundTermModel.term;
        final capturedTerm = foundTermModel; // 클로저를 위한 캡처

        spans.add(
          TextSpan(
            text: termText,
            style: const TextStyle(
              decoration: TextDecoration.underline,
              decorationColor: AppTheme.primaryColor,
              decorationThickness: 2,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              height: 1.6,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                setState(() {
                  _selectedTerm = _selectedTerm?.term == capturedTerm.term
                      ? null
                      : capturedTerm;
                });
                // 용어 클릭 시 학습 기록 저장
                _saveLearnedTerm(capturedTerm);
              },
          ),
        );

        remainingText = remainingText.substring(termText.length);
        processedLength += termText.length;
      } else if (foundIndex > 0 && foundTermModel != null) {
        // 다음 용어까지의 일반 텍스트
        spans.add(
          TextSpan(
            text: remainingText.substring(0, foundIndex),
            style: const TextStyle(fontSize: 15, height: 1.6),
          ),
        );

        remainingText = remainingText.substring(foundIndex);
        processedLength += foundIndex;
      } else {
        // 더 이상 용어가 없음 - 나머지 텍스트 추가
        spans.add(
          TextSpan(
            text: remainingText,
            style: const TextStyle(fontSize: 15, height: 1.6),
          ),
        );
        break;
      }
    }

    return SelectableText.rich(TextSpan(children: spans));
  }

  Widget _buildTermExplanation(FinancialTermModel term) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.school,
                    size: 18,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    term.term,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  setState(() {
                    _selectedTerm = null;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            term.definition,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡 ', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Text(
                    term.example,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 하단 고정 용어 해설 패널
  Widget _buildBottomTermPanel(FinancialTermModel term) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 헤더
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.school,
                          size: 20,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          term.term,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 24),
                      onPressed: () {
                        setState(() {
                          _selectedTerm = null;
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 정의
                Text(
                  term.definition,
                  style: const TextStyle(fontSize: 15, height: 1.6),
                ),
                const SizedBox(height: 16),
                // 예시
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡 ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Text(
                          term.example,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

