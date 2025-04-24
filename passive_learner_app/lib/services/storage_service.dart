import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_preferences.dart';

class StorageService {
  static const String _preferencesKey = 'user_preferences';

  Future<void> savePreferences(UserPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferencesKey, jsonEncode(preferences.toJson()));
  }

  Future<UserPreferences?> getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_preferencesKey);
    if (jsonString == null) return null;
    
    final json = jsonDecode(jsonString);
    return UserPreferences.fromJson(json);
  }

  bool shouldFetchContent(UserPreferences preferences) {
    final now = DateTime.now();
    final lastFetch = preferences.lastFetchTime;
    
    switch (preferences.frequency) {
      case Frequency.onceADay:
        return now.difference(lastFetch).inDays >= 1;
      case Frequency.onceInTwoDays:
        return now.difference(lastFetch).inDays >= 2;
      case Frequency.onceAWeek:
        return now.difference(lastFetch).inDays >= 7;
      case Frequency.onAppLoad:
        return true;
    }
  }
} 