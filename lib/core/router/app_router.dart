import 'package:go_router/go_router.dart';
import '../../presentation/main_scaffold.dart';
import '../../presentation/screens/news_detail_screen.dart';
import '../../presentation/screens/quiz_screen.dart';
import '../../presentation/screens/my_page_screen.dart';
import '../../data/models/article_model.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScaffold(),
    ),
    GoRoute(
      path: '/news',
      builder: (context, state) => const MainScaffold(initialIndex: 1),
    ),
    GoRoute(
      path: '/news/:id',
      builder: (context, state) {
        final article = state.extra as ArticleModel;
        return NewsDetailScreen(article: article);
      },
    ),
    GoRoute(
      path: '/quiz',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return QuizScreen(
          newsId: extra['newsId'] as String,
          summary: extra['summary'] as String,
        );
      },
    ),
    GoRoute(
      path: '/mypage',
      builder: (context, state) => const MyPageScreen(),
    ),
  ],
);
