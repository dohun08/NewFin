import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/article_model.dart';
import '../../core/theme/app_theme.dart';

class NewsCard extends StatefulWidget {
  final ArticleModel article;

  const NewsCard({super.key, required this.article});

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  int? _selectedTermIndex;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 뉴스 이미지
          if (widget.article.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                widget.article.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          
          InkWell(
            onTap: () {
              context.push('/news/${widget.article.id}', extra: widget.article);
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.article.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  
                  // 본문 내용 (용어에 밑줄 표시)
                  _buildContentWithTerms(),
                  
                  const SizedBox(height: 12),
                  
                  // 선택된 용어 설명 표시
                  if (_selectedTermIndex != null && widget.article.terms.isNotEmpty)
                    _buildTermExplanation(widget.article.terms[_selectedTermIndex!]),
                  
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.article.publishedAt.toString().split(' ')[0],
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Row(
                        children: [
                          // 원문 보기 버튼
                          TextButton.icon(
                            onPressed: () async {
                              final uri = Uri.parse(widget.article.url);
                              try {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              } catch (e) {
                                // 에뮬레이터에서는 inAppWebView로 fallback
                                await launchUrl(uri);
                              }
                            },
                            icon: const Icon(Icons.link, size: 16),
                            label: const Text('원문 보기'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.secondaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.secondaryColor),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentWithTerms() {
    final content = widget.article.content.isNotEmpty 
        ? widget.article.content 
        : widget.article.title;
    
    if (widget.article.terms.isEmpty) {
      return Text(
        content,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    // 용어를 찾아서 밑줄 표시
    final List<TextSpan> spans = [];
    String remainingText = content;
    int currentIndex = 0;

    while (remainingText.isNotEmpty && currentIndex < content.length) {
      bool foundTerm = false;
      
      for (int i = 0; i < widget.article.terms.length; i++) {
        final term = widget.article.terms[i].term;
        final termIndex = remainingText.indexOf(term);
        
        if (termIndex == 0) {
          // 용어 발견
          spans.add(TextSpan(
            text: term,
            style: const TextStyle(
              decoration: TextDecoration.underline,
              decorationColor: AppTheme.primaryColor,
              decorationThickness: 2,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                setState(() {
                  _selectedTermIndex = _selectedTermIndex == i ? null : i;
                });
              },
          ));
          
          remainingText = remainingText.substring(term.length);
          currentIndex += term.length;
          foundTerm = true;
          break;
        }
      }
      
      if (!foundTerm) {
        // 다음 용어까지의 텍스트 찾기
        int nextTermIndex = remainingText.length;
        
        for (final term in widget.article.terms) {
          final index = remainingText.indexOf(term.term);
          if (index > 0 && index < nextTermIndex) {
            nextTermIndex = index;
          }
        }
        
        spans.add(TextSpan(
          text: remainingText.substring(0, nextTermIndex),
          style: Theme.of(context).textTheme.bodyMedium,
        ));
        
        remainingText = remainingText.substring(nextTermIndex);
        currentIndex += nextTermIndex;
      }
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTermExplanation(term) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school, size: 16, color: AppTheme.primaryColor),
              const SizedBox(width: 4),
              Text(
                term.term,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            term.definition,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡 ', style: TextStyle(fontSize: 13)),
                Expanded(
                  child: Text(
                    term.example,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
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
