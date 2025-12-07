import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/article_model.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../providers/providers.dart';
import '../widgets/news_card.dart';

// 뉴스 상태 관리
class NewsListNotifier extends StateNotifier<AsyncValue<List<ArticleModel>>> {
  final NewsRepositoryImpl repository;
  int _startPage = 1; // 다음 불러올 시작 페이지
  bool _hasMore = true;
  bool _isLoadingMore = false;

  NewsListNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadNews();
  }

  Future<void> loadNews() async {
    if (!_hasMore) return;

    state = const AsyncValue.loading();
    print('[NewsListNotifier] Initial load: page $_startPage');

    try {
      final articles = await repository.getNews(page: _startPage);
      print('[NewsListNotifier] Initial load: ${articles.length} articles');

      state = AsyncValue.data(articles);

      // 3개 미만이면 더 이상 없음
      if (articles.length < 3) {
        _hasMore = false;
        print('[NewsListNotifier] No more articles available');
      } else {
        _startPage += 1;
        print('[NewsListNotifier] Next page will be: $_startPage');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;

    final currentArticles = state.value ?? [];
    print('[NewsListNotifier] Loading more: page $_startPage...');

    // 현재 표시된 뉴스 ID 목록
    final currentIds = currentArticles.map((a) => a.id).toList();
    print('[NewsListNotifier] Current articles IDs: ${currentIds.length}개');

    try {
      final newArticles = await repository.getNews(
        page: _startPage,
        excludeIds: currentIds,
      );
      print('[NewsListNotifier] Loaded ${newArticles.length} new articles');

      if (newArticles.length < 3) {
        _hasMore = false;
        print('[NewsListNotifier] No more articles available');
      } else {
        _startPage += 1;
        print('[NewsListNotifier] Next page will be: $_startPage');
      }

      if (newArticles.isNotEmpty) {
        state = AsyncValue.data([...currentArticles, ...newArticles]);
        print(
          '[NewsListNotifier] Total articles now: ${currentArticles.length + newArticles.length}',
        );
      } else {
        print('[NewsListNotifier] No new articles to add');
      }
    } catch (e) {
      print('[NewsListNotifier] Error loading more: $e');
    } finally {
      _isLoadingMore = false;
    }
  }

  void refresh() {
    _startPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    loadNews();
  }

  // 수동으로 뉴스 추가
  void addManualNews(ArticleModel article) {
    final currentArticles = state.value ?? [];
    // 맨 앞에 추가
    state = AsyncValue.data([article, ...currentArticles]);
    print('[NewsListNotifier] Manual news added: ${article.title}');
  }

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
}

final newsListNotifierProvider =
    StateNotifierProvider<NewsListNotifier, AsyncValue<List<ArticleModel>>>((
      ref,
    ) {
      final repository = ref.watch(newsRepositoryProvider);
      return NewsListNotifier(repository);
    });

class NewsListScreen extends ConsumerStatefulWidget {
  const NewsListScreen({super.key});

  @override
  ConsumerState<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends ConsumerState<NewsListScreen> {
  final ScrollController _scrollController = ScrollController();

  Future<void> _showAddNewsDialog() async {
    final textController = TextEditingController();
    final urlController = TextEditingController();
    int selectedTab = 0; // 0: URL, 1: 텍스트

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('뉴스 추가하기'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 탭 선택
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('URL'),
                        selected: selectedTab == 0,
                        onSelected: (selected) {
                          if (selected) setState(() => selectedTab = 0);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('텍스트'),
                        selected: selectedTab == 1,
                        onSelected: (selected) {
                          if (selected) setState(() => selectedTab = 1);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // URL 탭
                if (selectedTab == 0) ...[
                  const Text(
                    '뉴스 원문 링크를 입력하세요',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: urlController,
                    decoration: const InputDecoration(
                      hintText: 'https://...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                ]
                // 텍스트 탭
                else ...[
                  const Text(
                    '뉴스 원문 텍스트를 붙여넣으세요',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: textController,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      hintText: '뉴스 텍스트를 여기에 붙여넣으세요...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                // URL 모드
                if (selectedTab == 0) {
                  final url = urlController.text.trim();
                  if (url.isEmpty) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('URL을 입력해주세요')),
                    );
                    return;
                  }

                  if (!url.startsWith('http')) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('올바른 URL을 입력해주세요 (http/https)'),
                      ),
                    );
                    return;
                  }

                  // URL로 빈 뉴스 만들어서 상세 화면으로 이동 (거기서 크롤링)
                  navigator.pop(); // 다이얼로그 닫기

                  final emptyArticle = ArticleModel(
                    id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
                    title: '외부 뉴스',
                    content: '', // 빈 내용 - 상세화면에서 자동 크롤링
                    url: url,
                    imageUrl: '',
                    publishedAt: DateTime.now(),
                    terms: [],
                  );

                  // GoRouter로 상세 화면 이동
                  if (mounted) {
                    context.push(
                      '/news/${emptyArticle.id}',
                      extra: emptyArticle,
                    );
                  }
                  return;
                }

                // 텍스트 모드
                if (textController.text.trim().isEmpty) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('텍스트를 입력해주세요')),
                  );
                  return;
                }

                final text = textController.text.trim();

                // 입력 다이얼로그 닫기
                navigator.pop();

                // 로딩 다이얼로그 표시
                navigator.push(
                  PageRouteBuilder(
                    opaque: false,
                    barrierDismissible: false,
                    pageBuilder: (_, __, ___) =>
                        const Center(child: CircularProgressIndicator()),
                  ),
                );

                try {
                  final repository = ref.read(newsRepositoryProvider);
                  final article = await repository.addManualNews(text);

                  // 로딩 다이얼로그 닫기
                  navigator.pop();

                  // 뉴스 리스트에 추가
                  ref
                      .read(newsListNotifierProvider.notifier)
                      .addManualNews(article);

                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('✅ 뉴스가 추가되었습니다!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  // 로딩 다이얼로그 닫기
                  navigator.pop();

                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('❌ 뉴스 추가 실패: $e')),
                  );
                }
              },
              child: Text(selectedTab == 0 ? '열기' : '추가'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final notifier = ref.read(newsListNotifierProvider.notifier);

    // 이미 로딩 중이거나 더 이상 없으면 리턴
    if (notifier.isLoadingMore || !notifier.hasMore) {
      return;
    }

    // 하단 근처에 도달하면 더 불러오기
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      notifier.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsAsyncValue = ref.watch(newsListNotifierProvider);
    final notifier = ref.read(newsListNotifierProvider.notifier);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddNewsDialog,
        icon: const Icon(Icons.add),
        label: const Text('뉴스 추가'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: newsAsyncValue.when(
        data: (articles) {
          if (articles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '모든 뉴스를 다 읽으셨어요!\n새로운 뉴스를 기다려주세요 📰',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddNewsDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('뉴스 직접 추가하기'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.read(newsListNotifierProvider.notifier).refresh();
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: articles.length + 1,
              itemBuilder: (context, index) {
                if (index == articles.length) {
                  // 하단 로딩 인디케이터
                  if (notifier.isLoadingMore) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (notifier.hasMore) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: notifier.isLoadingMore
                            ? Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 8),
                                  Text(
                                    '더 불러오는 중...',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              )
                            : Text(
                                '스크롤하여 더 불러오기...',
                                style: TextStyle(color: Colors.grey),
                              ),
                      ),
                    );
                  } else {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          '모든 뉴스를 불러왔습니다',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: NewsCard(article: articles[index]),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(newsListNotifierProvider.notifier).refresh();
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
