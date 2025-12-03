import '../datasources/remote/public_data_service.dart';
import '../datasources/remote/gemini_service.dart';
import '../datasources/local/database_helper.dart';
import '../models/term_model.dart';
import 'package:uuid/uuid.dart';

class TermRepositoryImpl {
  final PublicDataService _publicDataService;
  final GeminiService _geminiService;
  final DatabaseHelper _databaseHelper;
  final _uuid = const Uuid();

  TermRepositoryImpl({
    required PublicDataService publicDataService,
    required GeminiService geminiService,
    required DatabaseHelper databaseHelper,
  })  : _publicDataService = publicDataService,
        _geminiService = geminiService,
        _databaseHelper = databaseHelper;

  Future<TermModel> getTermDefinition(String term) async {
    // 1. Check Local DB
    final cachedTerm = await _databaseHelper.getTerm(term);
    if (cachedTerm != null) {
      return cachedTerm;
    }

    // 2. Check Public Data API
    final publicData = await _publicDataService.getTermDefinition(term);
    if (publicData != null) {
      final newTerm = TermModel(
        id: _uuid.v4(),
        term: term,
        definition: publicData['definition']!,
        example: publicData['example'] ?? '',
        source: 'public_api',
      );
      await _databaseHelper.insertTerm(newTerm);
      return newTerm;
    }

    // 3. Fallback to Gemini
    final explanation = await _geminiService.explainTerm(term);
    // Parse explanation to separate definition and example if possible, 
    // but for now let's just put it all in definition or parse simply.
    // The prompt asked for specific format.
    String definition = explanation;
    String example = '';
    
    if (explanation.contains('정의:') && explanation.contains('예시:')) {
      final parts = explanation.split('예시:');
      definition = parts[0].replaceAll('정의:', '').trim();
      example = parts[1].trim();
    }

    final newTerm = TermModel(
      id: _uuid.v4(),
      term: term,
      definition: definition,
      example: example,
      source: 'gemini',
    );
    await _databaseHelper.insertTerm(newTerm);
    return newTerm;
  }
}
