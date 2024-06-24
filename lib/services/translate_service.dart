import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslateService {
  static const url = 'https://api.mymemory.translated.net/get';

  static const List<Map<String, String>> languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'de', 'name': 'German'},
    {'code': 'it', 'name': 'Italian'},
    {'code': 'pt', 'name': 'Portuguese'},
    {'code': 'ru', 'name': 'Russian'},
    {'code': 'zh-CN', 'name': 'Chinese'},
    {'code': 'ja', 'name': 'Japanese'},
    {'code': 'ko', 'name': 'Korean'}
  ];

  static Future<String> translateText(String text, String sourceLang, String targetLang) async {
    final response = await http.get(
      Uri.parse('$url?q=$text&langpair=$sourceLang|$targetLang'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final translated = data['responseData']['translatedText'];
      return translated;
    } else {
      throw Exception('An error occurred ${response.body}');
    }
  }

  static String getLanguageCode(String name) => languages.firstWhere((lang) => lang['name'] == name)['code']!;

  static String getLanguageName(String code) => languages.firstWhere((lang) => lang['code'] == code)['name']!;
}