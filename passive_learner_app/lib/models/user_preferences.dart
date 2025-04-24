import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum Frequency {
  onceADay,
  onceInTwoDays,
  onceAWeek,
  onAppLoad
}

enum ContextType {
  paragraph,
  page,
  chapter
}

class Content {
  final String tenWordSummary;
  final String fiftyWordSummary;
  final String fiveHundredWordSummary;

  Content({
    required this.tenWordSummary,
    required this.fiftyWordSummary,
    required this.fiveHundredWordSummary,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      tenWordSummary: json['10_w'],
      fiftyWordSummary: json['50_w'],
      fiveHundredWordSummary: json['500_w'],
    );
  }

  factory Content.atomicHabits() {
    return Content(
      tenWordSummary: "Small daily habits compound into remarkable results over time.",
      fiftyWordSummary: "Atomic Habits teaches that success comes from small, consistent improvements. By focusing on systems rather than goals, making habits obvious, attractive, easy, and satisfying, and understanding the power of identity-based habits, anyone can achieve remarkable results through the compound effect of daily 1% improvements.",
      fiveHundredWordSummary: '''Atomic Habits by James Clear is a comprehensive guide to understanding and implementing small habits that lead to remarkable results. The book's core premise is that success doesn't come from massive, overnight changes but from the compound effect of small, consistent improvements - what Clear calls "atomic habits."

The book introduces the "Four Laws of Behavior Change" which form the foundation of habit formation:
1. Make it obvious: Design your environment to make good habits visible and bad habits invisible
2. Make it attractive: Use temptation bundling and join cultures where your desired behavior is normal
3. Make it easy: Reduce friction for good habits and increase it for bad ones
4. Make it satisfying: Use immediate rewards and track your progress

Clear emphasizes the importance of focusing on systems rather than goals, as goals are about the results you want to achieve, while systems are about the processes that lead to those results. He also introduces the concept of identity-based habits, suggesting that the most effective way to change your habits is to focus on who you wish to become.

The book provides practical strategies for habit formation, including habit stacking (pairing new habits with existing ones), the two-minute rule (starting new habits with just two minutes), and the importance of tracking habits. Clear also discusses how to break bad habits by inverting the four laws.

Throughout the book, Clear uses real-world examples and scientific research to illustrate his points, making the concepts both accessible and actionable. The key takeaway is that small changes, when compounded over time, can lead to remarkable results.''',
    );
  }
}

class UserPreferences {
  final String? pdfPath;
  final Frequency frequency;
  final ContextType contextType;
  final DateTime lastFetchTime;
  final Content? content;
  String? geminiApiKey;
  String? bookTitle;
  String? chapterTitle;

  UserPreferences({
    this.pdfPath,
    required this.frequency,
    required this.contextType,
    required this.lastFetchTime,
    this.content,
    this.geminiApiKey,
    this.bookTitle,
    this.chapterTitle,
  });

  Map<String, dynamic> toJson() {
    return {
      'pdfPath': pdfPath,
      'frequency': frequency.toString(),
      'contextType': contextType.toString(),
      'lastFetchTime': lastFetchTime.toIso8601String(),
      'content': content != null ? {
        '10_w': content!.tenWordSummary,
        '50_w': content!.fiftyWordSummary,
        '500_w': content!.fiveHundredWordSummary,
      } : null,
      'geminiApiKey': geminiApiKey,
      'bookTitle': bookTitle,
      'chapterTitle': chapterTitle,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      pdfPath: json['pdfPath'],
      frequency: Frequency.values.firstWhere(
        (e) => e.toString() == json['frequency'],
      ),
      contextType: ContextType.values.firstWhere(
        (e) => e.toString() == json['contextType'],
      ),
      lastFetchTime: DateTime.parse(json['lastFetchTime']),
      content: json['content'] != null ? Content.fromJson(json['content']) : null,
      geminiApiKey: json['geminiApiKey'],
      bookTitle: json['bookTitle'],
      chapterTitle: json['chapterTitle'],
    );
  }

  static Future<UserPreferences> load(SharedPreferences prefs) async {
    final jsonString = prefs.getString('user_preferences');
    if (jsonString == null) {
      return UserPreferences(
        frequency: Frequency.onceADay,
        contextType: ContextType.paragraph,
        lastFetchTime: DateTime.now(),
      );
    }
    
    final json = jsonDecode(jsonString);
    return UserPreferences.fromJson(json);
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_preferences', jsonEncode(toJson()));
  }
} 