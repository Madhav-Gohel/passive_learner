import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiApiService {
  static const String _prefsApiKey = 'AIzaSyCC_VMKISWodPmZXtYR6e1OBA9mDSVsNXQ';
  
  final SharedPreferences _prefs;
  String? _apiKey;
  GenerativeModel? _model;

  GeminiApiService(this._prefs) {
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    _apiKey = _prefs.getString(_prefsApiKey);
    if (_apiKey != null) {
      _initializeModel();
    }
  }

  void _initializeModel() {
    if (_apiKey != null) {
      _model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: _apiKey!,
      );
    }
  }

  Future<void> setApiKey(String apiKey) async {
    await _prefs.setString(_prefsApiKey, apiKey);
    _apiKey = apiKey;
    _initializeModel();
  }

  Future<String> generateContent(String prompt) async {
    if (_model == null) {
      throw Exception('API key not set. Please set the API key first.');
    }

    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      if (response.text == null) {
        throw Exception('No response from Gemini API');
      }
      return response.text!;
    } catch (e) {
      throw Exception('Error calling Gemini API: $e');
    }
  }

  Future<Map<String, String>> generateBookSummary(String book, String chapter) async {
    final prompt = '''Book: $book

Write a summary of the book chapter $chapter in 10 words, 50 words, and 500 words in json format given below.

{
  "10_words": "",
  "50_words": "",
  "500_words": ""
}

Strictly follow the json format and do not add any other text. No markdown.''';

    final response = await generateContent(prompt);
    return Map<String, String>.from(jsonDecode(response));
  }
}
