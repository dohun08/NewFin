import 'package:flutter/material.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../core/theme/app_theme.dart';

class LearnedWordsScreen extends StatefulWidget {
  const LearnedWordsScreen({super.key});

  @override
  State<LearnedWordsScreen> createState() => _LearnedWordsScreenState();
}

class _LearnedWordsScreenState extends State<LearnedWordsScreen> {
  List<Map<String, dynamic>> _learnedTerms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLearnedTerms();
  }

  Future<void> _loadLearnedTerms() async {
    setState(() {
      _isLoading = true;
    });

    final db = DatabaseHelper();
    final terms = await db.getLearnedTerms();

    setState(() {
      _learnedTerms = terms;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('학습한 단어'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _learnedTerms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '아직 학습한 단어가 없어요\n뉴스를 읽고 용어를 클릭해보세요!',
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
                  onRefresh: _loadLearnedTerms,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _learnedTerms.length,
                    itemBuilder: (context, index) {
                      final termData = _learnedTerms[index];
                      final learnedAt =
                          DateTime.parse(termData['learnedAt']);
                      final daysAgo =
                          DateTime.now().difference(learnedAt).inDays;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.2),
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
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.bookmark,
                                        size: 16,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      termData['term'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  daysAgo == 0 ? '오늘' : '$daysAgo일 전',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              termData['definition'],
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.primaryColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('💡 ',
                                      style: TextStyle(fontSize: 14)),
                                  Expanded(
                                    child: Text(
                                      termData['example'],
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
                    },
                  ),
                ),
    );
  }
}
