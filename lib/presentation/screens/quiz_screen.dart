import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../widgets/bentley_bubble.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String newsId;
  final String summary;

  const QuizScreen({
    super.key,
    required this.newsId,
    required this.summary,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedOption;
  bool _isSubmitted = false;
  final Map<int, bool> _results = {}; // Index -> IsCorrect

  void _nextQuestion(int totalQuestions) {
    if (_currentQuestionIndex < totalQuestions - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = null;
        _isSubmitted = false;
      });
    } else {
      // Show final results
      _showFinalResults();
    }
  }

  void _showFinalResults() async {
    int correctCount = _results.values.where((v) => v).length;
    int total = _results.length;
    double score = correctCount / total;
    
    // 퀴즈 미션 업데이트 (80% 이상이면 완료)
    try {
      final missionRepo = ref.read(missionRepositoryProvider);
      await missionRepo.updateQuizMission(score);
      ref.invalidate(todayMissionProvider); // 미션 상태 새로고침
    } catch (e) {
      // 미션 업데이트 실패 시 무시
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("퀴즈 완료!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text("총 $total문제 중 $correctCount문제를 맞췄어!"),
            const SizedBox(height: 8),
            Text(correctCount == total ? "완벽해! 금융 지식이 쑥쑥! 🎉" : "수고했어! 틀린 문제는 다시 확인해보자."),
            if (score >= 0.8) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '🌱 퀴즈 미션 완료!',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Go back to news detail
            },
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizAsyncValue = ref.watch(quizProvider((newsId: widget.newsId, summary: widget.summary)));

    return Scaffold(
      appBar: AppBar(
        title: const Text("퀴즈"),
        automaticallyImplyLeading: false,
      ),
      body: quizAsyncValue.when(
        data: (quizzes) {
          if (quizzes.isEmpty) {
            return const Center(child: Text("퀴즈를 생성할 수 없습니다."));
          }

          final quiz = quizzes[_currentQuestionIndex];
          final totalQuestions = quizzes.length;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Indicator
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / totalQuestions,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                ),
                const SizedBox(height: 16),
                Text(
                  "문제 ${_currentQuestionIndex + 1} / $totalQuestions",
                  style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                BentleyBubble(
                  message: _isSubmitted
                      ? (quiz.correctIndex == _selectedOption
                          ? "정답이야! 정말 대단해! 👏"
                          : "아쉽지만 틀렸어. 다시 한번 생각해보자! 💪")
                      : "오늘 배운 내용을 퀴즈로 복습해볼까?",
                ),
                const SizedBox(height: 24),
                Text(
                  quiz.question,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(quiz.options.length, (index) {
                        final isSelected = _selectedOption == index;
                        final isCorrect = quiz.correctIndex == index;
                        
                        Color? backgroundColor;
                        if (_isSubmitted) {
                          if (isCorrect) backgroundColor = Colors.green[100];
                          if (isSelected && !isCorrect) backgroundColor = Colors.red[100];
                        } else {
                          if (isSelected) backgroundColor = Theme.of(context).primaryColor.withOpacity(0.1);
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: _isSubmitted ? null : () {
                              setState(() {
                                _selectedOption = index;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: backgroundColor ?? Colors.white,
                                border: Border.all(
                                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      quiz.options[index],
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: _isSubmitted && isCorrect ? Colors.green[800] : Colors.black87,
                                        fontWeight: _isSubmitted && isCorrect ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (_isSubmitted && isCorrect)
                                    const Icon(Icons.check_circle, color: Colors.green),
                                  if (_isSubmitted && isSelected && !isCorrect)
                                    const Icon(Icons.cancel, color: Colors.red),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                if (_isSubmitted)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("해설", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(quiz.explanation),
                      ],
                    ),
                  ),
                ElevatedButton(
                  onPressed: _selectedOption == null
                      ? null
                      : () {
                          if (_isSubmitted) {
                            _nextQuestion(totalQuestions);
                          } else {
                            setState(() {
                              _isSubmitted = true;
                              _results[_currentQuestionIndex] = _selectedOption == quiz.correctIndex;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isSubmitted ? (_currentQuestionIndex < totalQuestions - 1 ? "다음 문제" : "결과 보기") : "정답 확인",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
