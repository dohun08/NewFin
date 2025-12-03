import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';

class PublicDataService {
  final Dio _dio;

  PublicDataService({Dio? dio}) : _dio = dio ?? Dio();

  Future<Map<String, String>?> getTermDefinition(String term) async {
    try {
      final response = await _dio.get(
        ApiConstants.wordApiUrl,
        queryParameters: {
          'serviceKey': ApiConstants.wordApiKey,
          'pageNo': 1,
          'numOfRows': 1,
          'resultType': 'json',
          'fncIstNm': term, // Assuming this is the parameter for term name
        },
      );

      if (response.statusCode == 200) {
        final items = response.data['response']['body']['items']['item'];
        if (items != null && items is List && items.isNotEmpty) {
          final item = items[0];
          return {
            'definition': item['fncIstDf'] ?? '', // Assuming field name
            'example': '', // Public API might not have examples
          };
        }
      }
      return null;
    } catch (e) {
      // Fail silently and fallback to Gemini
      return null;
    }
  }
}
