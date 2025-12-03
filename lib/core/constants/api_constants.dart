import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Marketaux API
  static const String marketauxApiUrl = 'https://api.marketaux.com/v1';
  static const String marketauxApiKey = 'IucDmnOm7gm2y6WljPy3N9e5RrLTo13uecrZsH6H';
  
  // Load API keys from .env file
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get wordApiUrl => dotenv.env['WORD_API_URL'] ?? '';
  static String get wordApiKey => dotenv.env['WORD_API_KEY'] ?? '';
}
