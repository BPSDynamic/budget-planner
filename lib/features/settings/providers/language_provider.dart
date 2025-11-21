import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  static const List<String> supportedLanguages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Dutch',
    'Russian',
    'Japanese',
    'Chinese',
    'Korean',
    'Arabic',
  ];

  String _currentLanguage = 'English';

  String get currentLanguage => _currentLanguage;

  List<String> get languages => supportedLanguages;

  LanguageProvider() {
    _initializeLanguage();
  }

  void _initializeLanguage() {
    try {
      _loadLanguagePreference();
    } catch (e) {
      // Silently handle initialization errors
    }
  }

  Future<void> setLanguage(String language) async {
    if (!supportedLanguages.contains(language)) {
      throw ArgumentError('Unsupported language: $language');
    }
    _currentLanguage = language;
    await _saveLanguagePreference();
    notifyListeners();
  }

  Future<void> _saveLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_preference', _currentLanguage);
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language_preference') ?? 'English';
    notifyListeners();
  }
}
