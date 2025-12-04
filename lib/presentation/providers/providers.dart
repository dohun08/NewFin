import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/remote/news_api_service.dart';
import '../../data/datasources/remote/gemini_service.dart';
import '../../data/datasources/remote/public_data_service.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../data/repositories/term_repository_impl.dart';
import '../../data/repositories/quiz_repository_impl.dart';
import '../../data/repositories/mission_repository.dart';
import '../../data/models/article_model.dart';
import '../../data/models/term_model.dart';
import '../../data/models/quiz_model.dart';
import '../../data/models/daily_mission_model.dart';

// Core Providers
final dioProvider = Provider((ref) {
  final dio = Dio();
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  return dio;
});
final databaseHelperProvider = Provider((ref) => DatabaseHelper());

// Service Providers
final newsApiServiceProvider = Provider(
  (ref) => NewsApiService(dio: ref.watch(dioProvider)),
);
final geminiServiceProvider = Provider((ref) => GeminiService());
final publicDataServiceProvider = Provider(
  (ref) => PublicDataService(dio: ref.watch(dioProvider)),
);

// Repository Providers
final newsRepositoryProvider = Provider(
  (ref) => NewsRepositoryImpl(
    newsApiService: ref.watch(newsApiServiceProvider),
    geminiService: ref.watch(geminiServiceProvider),
    databaseHelper: ref.watch(databaseHelperProvider),
  ),
);

final termRepositoryProvider = Provider(
  (ref) => TermRepositoryImpl(
    publicDataService: ref.watch(publicDataServiceProvider),
    geminiService: ref.watch(geminiServiceProvider),
    databaseHelper: ref.watch(databaseHelperProvider),
  ),
);

final quizRepositoryProvider = Provider(
  (ref) => QuizRepositoryImpl(
    geminiService: ref.watch(geminiServiceProvider),
    databaseHelper: ref.watch(databaseHelperProvider),
  ),
);

final missionRepositoryProvider = Provider(
  (ref) => MissionRepository(ref.watch(databaseHelperProvider)),
);

// Feature Providers

// News List
final newsListProvider = FutureProvider<List<ArticleModel>>((ref) async {
  final repository = ref.watch(newsRepositoryProvider);
  return await repository.getNews();
});

// Term Definition
final termProvider = FutureProvider.family<TermModel, String>((
  ref,
  term,
) async {
  final repository = ref.watch(termRepositoryProvider);
  return await repository.getTermDefinition(term);
});

// Daily Mission Provider
final todayMissionProvider = FutureProvider<DailyMissionModel>((ref) async {
  final repository = ref.watch(missionRepositoryProvider);
  return await repository.getTodayMission();
});

final recentMissionsProvider = FutureProvider<List<DailyMissionModel>>((
  ref,
) async {
  final repository = ref.watch(missionRepositoryProvider);
  return await repository.getRecentMissions(28); // 최근 4주
});

final allMissionsProvider = FutureProvider<List<DailyMissionModel>>((
  ref,
) async {
  final repository = ref.watch(missionRepositoryProvider);
  return await repository.getAllMissions();
});

// Quiz
final quizProvider =
    FutureProvider.family<List<QuizModel>, ({String newsId, String summary})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(quizRepositoryProvider);
      return await repository.getQuiz(params.newsId, params.summary);
    });
