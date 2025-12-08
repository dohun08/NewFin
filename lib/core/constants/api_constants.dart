import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Marketaux API
  static const String marketauxApiUrl = 'https://api.marketaux.com/v1';
  static const String marketauxApiKey = 'Z4tBMTk8RbFB4WuY7YVWfY4ejxbwDGHEhdmbBEHL';
  
  
  // Load API keys from .env file
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get wordApiUrl => dotenv.env['WORD_API_URL'] ?? '';
  static String get wordApiKey => dotenv.env['WORD_API_KEY'] ?? '';
}
