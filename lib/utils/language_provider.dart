import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  static const String _languageKey = 'selected_language';
  bool _isInitialized = false;

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Locale get currentLocale => _currentLocale;
  
  bool get isInitialized => _isInitialized;

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString(_languageKey);
      if (savedLanguageCode != null && savedLanguageCode.isNotEmpty) {
        _currentLocale = Locale(savedLanguageCode);
      }
    } catch (e) {
      // If loading fails, use default language
      _currentLocale = const Locale('en');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setLocale(String languageName) async {
    String languageCode;
    switch (languageName) {
      case 'English':
        languageCode = 'en';
        _currentLocale = const Locale('en');
        break;
      case 'हिन्दी':
        languageCode = 'hi';
        _currentLocale = const Locale('hi');
        break;
      case 'ગુજરાતી':
        languageCode = 'gu';
        _currentLocale = const Locale('gu');
        break;
      case 'मराठी':
        languageCode = 'mr';
        _currentLocale = const Locale('mr');
        break;
      default:
        languageCode = 'en';
        _currentLocale = const Locale('en');
    }
    
    // Save to shared preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      // If saving fails, continue anyway
    }
    
    notifyListeners();
  }
}