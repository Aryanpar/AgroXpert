import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  
  Locale get currentLocale => _currentLocale;
  
  void setLocale(String languageCode) {
    switch (languageCode) {
      case 'English':
        _currentLocale = const Locale('en');
        break;
      case 'हिन्दी':
        _currentLocale = const Locale('hi');
        break;
      case 'ગુજરાતી':
        _currentLocale = const Locale('gu');
        break;
      case 'मराठी':
        _currentLocale = const Locale('mr');
        break;
      default:
        _currentLocale = const Locale('en');
    }
    notifyListeners();
  }
}