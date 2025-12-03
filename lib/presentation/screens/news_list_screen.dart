import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    print('[UI] 🔄 초기 로딩 시작...');

    try {
      final articles = await repository.getNews(page: _startPage);
      print('[UI] ✅ 초기 로딩 완료: ${articles.length}개');
      
      state = AsyncValue.data(articles);

      // 5개 미만이면 더 이상 없음
      if (articles.length < 5) {
        _hasMore = false;
        print('[UI] ⛔ 더 이상 불러올 뉴스 없음 (${articles.length}개 < 5개)');
      } else {
        // 다음 번 시작 페이지 업데이트
        _startPage += 1;
        print('[UI] 📄 다음 시작 페이지: $_startPage');
      }
    } catch (e, stack) {
      print('[UI] ❌ 초기 로딩 에러: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) {
      print('[UI] ⏸️ 추가 로딩 스킵 (hasMore: $_hasMore, isLoading: $_isLoadingMore)');
      return;
    }

    _isLoadingMore = true;
    state = state; // 상태 업데이트를 위해 재할당
    
    final currentArticles = state.value ?? [];
    print('[UI] 🔄 추가 로딩 시작... 현재: ${currentArticles.length}개, 시작 페이지: $_startPage');

    try {
      final newArticles = await repository.getNews(page: _startPage);
      print('[UI] ✅ 추가 로딩 완료: ${newArticles.length}개');

      // 5개 미만이면 더 이상 없음
      if (newArticles.length < 5) {
        _hasMore = false;
        print('[UI] ⛔ 더 이상 불러올 뉴스 없음 (${newArticles.length}개 < 5개)');
      } else {
        // 다음 번 시작 페이지 업데이트
        _startPage += 1;
        print('[UI] 📄 다음 시작 페이지: $_startPage');
      }

      if (newArticles.isNotEmpty) {
        state = AsyncValue.data([...currentArticles, ...newArticles]);
        print('[UI] 📊 총 뉴스: ${currentArticles.length + newArticles.length}개');
      }
    } catch (e) {
      print('[UI] ❌ 추가 로딩 에러: $e');
    } finally {
      _isLoadingMore = false;
    }
  }

  void refresh() {
    print('[UI] 🔄 새로고침...');
    _startPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    loadNews();
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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(newsListNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsAsyncValue = ref.watch(newsListNotifierProvider);
    final notifier = ref.read(newsListNotifierProvider.notifier);

    return newsAsyncValue.when(
      data: (articles) {
        if (articles.isEmpty) {
          return const Center(
            child: Text(
              '모든 뉴스를 다 읽으셨어요!\n새로운 뉴스를 기다려주세요 📰',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
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
                  return const Center(
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
                          ? const Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 8),
                                Text(
                                  '더 불러오는 중...',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            )
                          : const Text(
                              '스크롤하여 더 불러오기...',
                              style: TextStyle(color: Colors.grey),
                            ),
                    ),
                  );
                } else {
                  return const Center(
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
    );
  }
}
