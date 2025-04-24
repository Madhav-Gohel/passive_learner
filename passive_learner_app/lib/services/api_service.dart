import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import '../models/user_preferences.dart';
import 'gemini_api.dart';

class ApiService {
  final GeminiApiService _geminiService;
  final SharedPreferences _prefs;

  ApiService(this._prefs) : _geminiService = GeminiApiService(_prefs);

  Future<String> extractTextFromPdf(String pdfPath) async {
    try {
      final file = File(pdfPath);
      final bytes = await file.readAsBytes();
      
      // For now, we'll return a placeholder since the pdf package doesn't support text extraction
      // In a real app, you might want to use a different PDF library that supports text extraction
      return 'PDF content extraction is not implemented yet. Please use a PDF library that supports text extraction.';
      
      // The following code would work with a proper PDF text extraction library
      // final pdf = await PdfDocument.openData(bytes);
      // final pages = pdf.pages;
      // final text = StringBuffer();
      // for (final page in pages) {
      //   final pageText = await page.text;
      //   text.writeln(pageText);
      // }
      // return text.toString();
    } catch (e) {
      throw Exception('Failed to extract text from PDF: $e');
    }
  }

  Future<Content> processPdfText(String text, int chapterCounter) async {
    try {
      final summary = await _geminiService.generateBookSummary(text, chapterCounter.toString());
      return Content(
        tenWordSummary: summary['10_words'] ?? '',
        fiftyWordSummary: summary['50_words'] ?? '',
        fiveHundredWordSummary: summary['500_words'] ?? '',
      );
    } catch (e) {
      throw Exception('Failed to process PDF text: $e');
    }
  }

  Future<void> uploadPreferences(UserPreferences preferences) async {
    await _prefs.setString('user_preferences', jsonEncode(preferences.toJson()));
  }

  Future<Content> fetchContent() async {
    final jsonString = _prefs.getString('user_preferences');
    if (jsonString == null) {
      throw Exception('No preferences found');
    }
    
    final json = jsonDecode(jsonString);
    final preferences = UserPreferences.fromJson(json);
    if (preferences.content == null) {
      throw Exception('No content found');
    }
    return preferences.content!;
  }
} 