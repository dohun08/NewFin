import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/article_model.dart';
import '../../data/models/financial_term_model.dart';
import '../../data/datasources/remote/gemini_service.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/repositories/mission_repository.dart';
import '../providers/providers.dart';
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
  bool _isLoading = false;
  FinancialTermModel? _selectedTerm;

  @override
  void initState() {
    super.initState();
    _markAsRead();
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
      final readCount = await db.getReadNewsIds().then((ids) => ids.length);
      final todayReadCount = await _getTodayReadCount();
      
      if (todayReadCount >= 2) {
        final missionRepo = ref.read(missionRepositoryProvider);
        await missionRepo.updateNewsReadMission(todayReadCount);
        ref.invalidate(todayMissionProvider); // 미션 상태 새로고침
      }
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
    } catch (e) {
      // 이미 저장된 용어일 수 있음 (UNIQUE 제약) - 무시
    }
  }

  Future<void> _generateSummary() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('원문을 붙여넣어주세요!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _summary = null;
    });

    try {
      final geminiService = GeminiService();
      final summary = await geminiService.summarizeNews(_contentController.text);
      setState(() {
        _summary = summary;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('요약 생성 실패: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            const Text(
              "📰 뉴스 본문",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildContentWithTerms(),
            
            // 선택된 용어 설명 표시
            if (_selectedTerm != null) ...[
              const SizedBox(height: 16),
              _buildTermExplanation(_selectedTerm!),
            ],
            
            const SizedBox(height: 24),
            
            // 원문 요약 섹션
            const Text(
              "📝 원문 요약하기",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "전체 원문을 붙여넣으면 AI가 요약해드려요!",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: '여기에 뉴스 전체 원문을 붙여넣어주세요...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _generateSummary,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 16, 
                        height: 16, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_isLoading ? '요약 생성 중...' : '요약 생성하기'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            // 요약 결과 표시
            if (_summary != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3)),
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
                  context.push('/quiz', extra: {
                    'newsId': widget.article.id, 
                    'summary': _summary ?? widget.article.content,
                  });
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentWithTerms() {
    final content = widget.article.content;
    
    if (widget.article.terms.isEmpty) {
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
      bool foundTerm = false;
      FinancialTermModel? foundTermModel;
      int foundIndex = -1;
      
      // 현재 위치에서 가장 먼저 나오는 용어 찾기
      for (final term in widget.article.terms) {
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
        
        spans.add(TextSpan(
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
                _selectedTerm = _selectedTerm?.term == capturedTerm.term ? null : capturedTerm;
              });
              // 용어 클릭 시 학습 기록 저장
              _saveLearnedTerm(capturedTerm);
            },
        ));
        
        remainingText = remainingText.substring(termText.length);
        processedLength += termText.length;
        foundTerm = true;
      } else if (foundIndex > 0 && foundTermModel != null) {
        // 다음 용어까지의 일반 텍스트
        spans.add(TextSpan(
          text: remainingText.substring(0, foundIndex),
          style: const TextStyle(fontSize: 15, height: 1.6),
        ));
        
        remainingText = remainingText.substring(foundIndex);
        processedLength += foundIndex;
      } else {
        // 더 이상 용어가 없음 - 나머지 텍스트 추가
        spans.add(TextSpan(
          text: remainingText,
          style: const TextStyle(fontSize: 15, height: 1.6),
        ));
        break;
      }
    }

    return SelectableText.rich(
      TextSpan(children: spans),
    );
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
                  const Icon(Icons.school, size: 18, color: AppTheme.primaryColor),
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
}
