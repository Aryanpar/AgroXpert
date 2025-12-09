import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  static const _localizedValues = {
    'en': {
      'chooseLanguage': 'Choose Your Preferred Language',
      'pleaseSelect': 'Please select your language',
      'next': 'Next',
      'english': 'English',
      'hindi': 'हिन्दी',
      'gujarati': 'ગુજરાતી',
      'marathi': 'मराठी',
    },
    'hi': {
      'chooseLanguage': 'अपनी पसंदीदा भाषा चुनें',
      'pleaseSelect': 'कृपया अपनी भाषा चुनें',
      'next': 'आगे',
      'english': 'English',
      'hindi': 'हिन्दी',
      'gujarati': 'ગુજરાતી',
      'marathi': 'मराठी',
    },
    'gu': {
      'chooseLanguage': 'તમારી પસંદગીની ભાષા પસંદ કરો',
      'pleaseSelect': 'કૃપા કરીને તમારી ભાષા પસંદ કરો',
      'next': 'આગળ',
      'english': 'English',
      'hindi': 'हिन्दी',
      'gujarati': 'ગુજરાતી',
      'marathi': 'मराठी',
    },
    'mr': {
      'chooseLanguage': 'तुमची पसंतीची भाषा निवडा',
      'pleaseSelect': 'कृपया तुमची भाषा निवडा',
      'next': 'पुढे',
      'english': 'English',
      'hindi': 'हिन्दी',
      'gujarati': 'ગુજરાતી',
      'marathi': 'मराठी',
    },
  };
  
  String get chooseLanguage {
    return _localizedValues[locale.languageCode]?['chooseLanguage'] ?? 
           _localizedValues['en']!['chooseLanguage']!;
  }
  
  String get pleaseSelect {
    return _localizedValues[locale.languageCode]?['pleaseSelect'] ?? 
           _localizedValues['en']!['pleaseSelect']!;
  }
  
  String get next {
    return _localizedValues[locale.languageCode]?['next'] ?? 
           _localizedValues['en']!['next']!;
  }
  
  String get english {
    return _localizedValues[locale.languageCode]?['english'] ?? 
           _localizedValues['en']!['english']!;
  }
  
  String get hindi {
    return _localizedValues[locale.languageCode]?['hindi'] ?? 
           _localizedValues['en']!['hindi']!;
  }
  
  String get gujarati {
    return _localizedValues[locale.languageCode]?['gujarati'] ?? 
           _localizedValues['en']!['gujarati']!;
  }
  
  String get marathi {
    return _localizedValues[locale.languageCode]?['marathi'] ?? 
           _localizedValues['en']!['marathi']!;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'gu', 'mr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}