import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../core/theme/app_theme.dart';

class ReadNewsScreen extends StatefulWidget {
  const ReadNewsScreen({super.key});

  @override
  State<ReadNewsScreen> createState() => _ReadNewsScreenState();
}

class _ReadNewsScreenState extends State<ReadNewsScreen> {
  List<Map<String, dynamic>> _readNews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReadNews();
  }

  Future<void> _loadReadNews() async {
    setState(() {
      _isLoading = true;
    });

    final db = DatabaseHelper();
    final news = await db.getReadNewsWithTime();

    setState(() {
      _readNews = news;
      _isLoading = false;
    });
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('URL을 열 수 없습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('읽은 뉴스'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _readNews.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '아직 읽은 뉴스가 없어요\n뉴스 탭에서 뉴스를 읽어보세요!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReadNews,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _readNews.length,
                    itemBuilder: (context, index) {
                      final newsData = _readNews[index];
                      final readAt = DateTime.parse(newsData['readAt']);
                      final daysAgo =
                          DateTime.now().difference(readAt).inDays;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.secondaryColor.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    newsData['title'] ?? '제목 없음',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  daysAgo == 0 ? '오늘' : '$daysAgo일 전',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            if (newsData['url'] != null) ...[
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _openUrl(newsData['url']),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        newsData['url'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.primaryColor,
                                          decoration:
                                              TextDecoration.underline,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.open_in_new,
                                      size: 16,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
