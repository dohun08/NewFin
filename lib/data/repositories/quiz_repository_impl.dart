import '../datasources/remote/gemini_service.dart';
import '../datasources/local/database_helper.dart';
import '../models/quiz_model.dart';

class QuizRepositoryImpl {
  final GeminiService _geminiService;
  final DatabaseHelper _databaseHelper;

  QuizRepositoryImpl({
    required GeminiService geminiService,
    required DatabaseHelper databaseHelper,
  })  : _geminiService = geminiService,
        _databaseHelper = databaseHelper;

  Future<List<QuizModel>> getQuiz(String newsId, String newsSummary) async {
    // Check Local DB
    final cachedQuizzes = await _databaseHelper.getQuizzesByNewsId(newsId);
    if (cachedQuizzes.isNotEmpty) {
      return cachedQuizzes;
    }

    // Generate with Gemini
    final newQuizzes = await _geminiService.generateQuiz(newsSummary, newsId);
    await _databaseHelper.insertQuizzes(newQuizzes);
    return newQuizzes;
  }

  Future<void> saveQuizResult(QuizModel quiz) async {
    // For now, we just update the single quiz. 
    // If we want to update a list, we might need a different method, 
    // but usually we update one question at a time as the user answers.
    // Since insertQuizzes uses replace conflict algorithm, we can use it for single update too if we wrap in list.
    await _databaseHelper.insertQuizzes([quiz]);
  }
}
