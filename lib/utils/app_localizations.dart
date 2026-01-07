import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // language selection
      'chooseLanguage': 'Choose Your Preferred Language',
      'pleaseSelect': 'Please select your language',
      'next': 'Next',
      'language': 'Language',
      'selectLanguage': 'Select Language',
      'currentLanguage': 'Current Language',
      'languageChanged': 'Language changed successfully',
      'english': 'English',
      'hindi': 'हिन्दी',
      'gujarati': 'ગુજરાતી',
      'marathi': 'मराठी',

      // common actions
      'profile': 'Profile',
      'settings': 'Settings',
      'save': 'Save',
      'cancel': 'Cancel',
      'ok': 'OK',
      'skip': 'Skip',
      'connect': 'Connect',
      'close': 'Close',
      'copy': 'Copy',
      'share': 'Share',
      'retry': 'Retry',

      // dashboard
      'appTitle': 'AgroXpert Plus',
      'refreshWeather': 'Refresh Weather',
      'online': 'Online',
      'offline': 'Offline',
      'bluetoothConnection': 'Bluetooth Connection',
      'bluetoothConnectPrompt': 'Would you like to connect to HC-05 Bluetooth device?',
      'bluetoothNotConnected': 'Bluetooth is not connected. Would you like to connect now?',
      'connectionFailed': 'Connection Failed',
      'success': 'Success',
      'connectNow': 'Connect',
      'failedToLoadWeather': 'Failed to load weather',
      'about': 'About',
      'diseaseDetection': 'Disease Detection',
      'aiChatHistory': 'AI Chat History',
      'logout': 'Logout',

      // chat
      'aiAssistant': 'AgroXpert AI Assistant',
      'chatHistory': 'Chat History',
      'askHint': 'Ask AgroXpert AI...',
      'chatError': 'Error',
      'chatHistoryTooltip': 'Chat History',
      'newChat': 'New Chat',
      'backupAll': 'Backup All',
      'deleteAll': 'Delete All',
      'deleteChat': 'Delete Chat',
      'backup': 'Backup',
      'delete': 'Delete',

      // about
      'aboutTitle': 'About AgroXpert Plus',
      'developers': 'Developers',
      'keyFeatures': 'Key Features',
      'howToUse': 'How to use',
      'useCases': 'Use cases & advantages',
      'versionInfo': 'Version 1.0.1  •  Final Year Project',
      'featureAiScanTitle': 'AI Disease Scan',
      'featureAiScanDesc': 'Scan leaves and detect diseases early.',
      'featureIrrigationTitle': 'Smart Irrigation',
      'featureIrrigationDesc': 'Control irrigation motors from the app.',
      'featureMonitoringTitle': 'Live Monitoring',
      'featureMonitoringDesc': 'View soil and environment data in real time.',
      'featureWeatherTitle': 'Weather Aware',
      'featureWeatherDesc': 'Use weather data for better decisions.',
      'howStep1': 'Power on the Arduino Uno, sensors, and relays.',
      'howStep2': 'Connect the system to the configured WiFi/Bluetooth.',
      'howStep3': 'Open the dashboard to see live soil and environment data.',
      'howStep4': 'Use irrigation buttons to start or stop the motor.',
      'howStep5': 'Open Disease Scan and capture a clear plant image.',
      'howStep6': 'Review AI suggestions and past logs in the history screen.',

      // disease detection
      'plantCareDetector': 'Plant Care — Detector',
      'detectSubtitle': 'Detect plant disease',
      'noImageSelected': 'No image selected',
      'camera': 'Camera',
      'gallery': 'Gallery',
      'analyzing': 'Analyzing…',
      'problemCopied': 'Problem copied',
      'recommendedAction': 'Recommended action',
      'preparingPlan': 'Preparing concise plan...',
      'planUnavailable': 'Plan unavailable',
      'openFullTreatment': 'Open full treatment',
      'result': 'Result',
      'topResult': 'Top result',
      'plant': 'Plant',
      'confidence': 'Confidence',
      'copyProblem': 'Copy problem',
      'copyPlan': 'Copy plan',

      // treatment
      'planCopied': 'Plan copied',
      'shareNotImplemented': 'Share not implemented',
      'overview': 'Overview',
      'prevention': 'Prevention',
      'treatment': 'Treatment',
      'noTreatmentDetails': 'No treatment details available.',
    },
    'hi': {
      'chooseLanguage': 'अपनी पसंदीदा भाषा चुनें',
      'pleaseSelect': 'कृपया अपनी भाषा चुनें',
      'next': 'आगे',
      'language': 'भाषा',
      'selectLanguage': 'भाषा चुनें',
      'currentLanguage': 'वर्तमान भाषा',
      'languageChanged': 'भाषा सफलतापूर्वक बदली गई',
      'english': 'English',
      'hindi': 'हिन्दी',
      'gujarati': 'ગુજરાતી',
      'marathi': 'मराठी',

      'profile': 'प्रोफ़ाइल',
      'settings': 'सेटिंग्स',
      'save': 'सहेजें',
      'cancel': 'रद्द करें',
      'ok': 'ठीक है',
      'skip': 'स्किप',
      'connect': 'कनेक्ट',
      'close': 'बंद करें',
      'copy': 'कॉपी',
      'share': 'शेयर',
      'retry': 'फिर से कोशिश करें',

      'appTitle': 'AgroXpert Plus',
      'refreshWeather': 'मौसम रिफ्रेश करें',
      'online': 'ऑनलाइन',
      'offline': 'ऑफ़लाइन',
      'bluetoothConnection': 'ब्लूटूथ कनेक्शन',
      'bluetoothConnectPrompt': 'क्या आप HC-05 ब्लूटूथ डिवाइस से कनेक्ट करना चाहेंगे?',
      'bluetoothNotConnected': 'ब्लूटूथ कनेक्ट नहीं है। अभी कनेक्ट करना चाहेंगे?',
      'connectionFailed': 'कनेक्शन विफल',
      'success': 'सफलता',
      'connectNow': 'कनेक्ट',
      'failedToLoadWeather': 'मौसम लोड करने में विफल',
      'about': 'अबाउट',
      'diseaseDetection': 'रोग पहचान',
      'aiChatHistory': 'एआई चैट हिस्ट्री',
      'logout': 'लॉगआउट',

      'aiAssistant': 'AgroXpert एआई असिस्टेंट',
      'chatHistory': 'चैट हिस्ट्री',
      'askHint': 'AgroXpert AI से पूछें...',
      'chatError': 'त्रुटि',
      'chatHistoryTooltip': 'चैट हिस्ट्री',
      'newChat': 'नई चैट',
      'backupAll': 'सभी बैकअप',
      'deleteAll': 'सभी हटाएं',
      'deleteChat': 'चैट हटाएं',
      'backup': 'बैकअप',
      'delete': 'हटाएं',

      'aboutTitle': 'AgroXpert Plus के बारे में',
      'developers': 'डेवलपर्स',
      'keyFeatures': 'मुख्य विशेषताएँ',
      'howToUse': 'कैसे उपयोग करें',
      'useCases': 'उपयोग मामले और फायदे',
      'versionInfo': 'संस्करण 1.0.1  •  फाइनल ईयर प्रोजेक्ट',
      'featureAiScanTitle': 'एआई रोग स्कैन',
      'featureAiScanDesc': 'पत्तियों को स्कैन करें और रोग जल्दी पहचानें।',
      'featureIrrigationTitle': 'स्मार्ट सिंचाई',
      'featureIrrigationDesc': 'ऐप से मोटर्स को नियंत्रित करें।',
      'featureMonitoringTitle': 'लाइव मॉनिटरिंग',
      'featureMonitoringDesc': 'मिट्टी और पर्यावरण डेटा लाइव देखें।',
      'featureWeatherTitle': 'मौसम सजग',
      'featureWeatherDesc': 'बेहतर निर्णयों के लिए मौसम डेटा उपयोग करें।',
      'howStep1': 'Arduino Uno, सेंसर और रिले चालू करें।',
      'howStep2': 'सिस्टम को कॉन्फ़िगर किए WiFi/ब्लूटूथ से जोड़ें।',
      'howStep3': 'डैशबोर्ड खोलें और लाइव डेटा देखें।',
      'howStep4': 'मोटर शुरू/बंद करने के लिए सिंचाई बटन उपयोग करें।',
      'howStep5': 'Disease Scan खोलें और स्पष्ट पौधे की फोटो लें।',
      'howStep6': 'एआई सुझाव और हिस्ट्री स्क्रीन में लॉग देखें।',

      'plantCareDetector': 'प्लांट केयर — डिटेक्टर',
      'detectSubtitle': 'पौधे की बीमारी पहचानें',
      'noImageSelected': 'कोई छवि चयनित नहीं',
      'camera': 'कैमरा',
      'gallery': 'गैलरी',
      'analyzing': 'विश्लेषण हो रहा है…',
      'problemCopied': 'समस्या कॉपी की गई',
      'recommendedAction': 'अनुशंसित कार्रवाई',
      'preparingPlan': 'संक्षिप्त योजना तैयार हो रही है...',
      'planUnavailable': 'योजना उपलब्ध नहीं',
      'openFullTreatment': 'पूर्ण उपचार खोलें',
      'result': 'परिणाम',
      'topResult': 'शीर्ष परिणाम',
      'plant': 'पौधा',
      'confidence': 'विश्वास स्तर',
      'copyProblem': 'समस्या कॉपी करें',
      'copyPlan': 'योजना कॉपी करें',

      'planCopied': 'योजना कॉपी की गई',
      'shareNotImplemented': 'शेयर लागू नहीं किया गया',
      'overview': 'सारांश',
      'prevention': 'रोकथाम',
      'treatment': 'उपचार',
      'noTreatmentDetails': 'उपचार विवरण उपलब्ध नहीं।',
    },
    'gu': {
      'chooseLanguage': 'તમારી પસંદગીની ભાષા પસંદ કરો',
      'pleaseSelect': 'કૃપા કરીને તમારી ભાષા પસંદ કરો',
      'next': 'આગળ',
      'language': 'ભાષા',
      'selectLanguage': 'ભાષા પસંદ કરો',
      'currentLanguage': 'વર્તમાન ભાષા',
      'languageChanged': 'ભાષા સફળતાપૂર્વક બદલાઈ',
      'english': 'English',
      'hindi': 'હિન્દી',
      'gujarati': 'ગુજરાતી',
      'marathi': 'મરાઠી',

      'profile': 'પ્રોફાઇલ',
      'settings': 'સેટિંગ્સ',
      'save': 'સાચવો',
      'cancel': 'રદ કરો',
      'ok': 'બરાબર',
      'skip': 'સ્કિપ',
      'connect': 'કનેક્ટ',
      'close': 'બંધ કરો',
      'copy': 'કૉપી',
      'share': 'શેર',
      'retry': 'ફરી પ્રયત્ન કરો',

      'appTitle': 'AgroXpert Plus',
      'refreshWeather': 'હવામાન રિફ્રેશ કરો',
      'online': 'ઓનલાઇન',
      'offline': 'ઓફલાઇન',
      'bluetoothConnection': 'બ્લૂટૂથ કનેક્શન',
      'bluetoothConnectPrompt': 'શું તમે HC-05 બ્લૂટૂથ ડિવાઇસ સાથે કનેક્ટ કરવા માંગો છો?',
      'bluetoothNotConnected': 'બ્લૂટૂથ જોડાયેલ નથી. હમણાં કનેક્ટ કરશો?',
      'connectionFailed': 'કનેક્શન નિષ્ફળ',
      'success': 'સફળતા',
      'connectNow': 'કનેક્ટ',
      'failedToLoadWeather': 'હવામાન લોડ કરવામાં નિષ્ફળ',
      'about': 'વિશે',
      'diseaseDetection': 'રોગ શોધ',
      'aiChatHistory': 'એઆઈ ચેટ હિસ્ટ્રી',
      'logout': 'લૉગઆઉટ',

      'aiAssistant': 'AgroXpert એઆઈ સહાયક',
      'chatHistory': 'ચેટ હિસ્ટ્રી',
      'askHint': 'AgroXpert AI ને પૂછો...',
      'chatError': 'ભૂલ',
      'chatHistoryTooltip': 'ચેટ હિસ્ટ્રી',
      'newChat': 'નવી ચેટ',
      'backupAll': 'બધુ બેકઅપ',
      'deleteAll': 'બધુ કાઢો',
      'deleteChat': 'ચેટ કાઢો',
      'backup': 'બેકઅપ',
      'delete': 'કાઢો',

      'aboutTitle': 'AgroXpert Plus વિશે',
      'developers': 'વિકાસકર્તાઓ',
      'keyFeatures': 'મુખ્ય વિશેષતાઓ',
      'howToUse': 'કેવી રીતે ઉપયોગ કરવો',
      'useCases': 'ઉપયોગ અને લાભો',
      'versionInfo': 'સંસ્કરણ 1.0.1  •  ફાઇનલ ઈયર પ્રોજેક્ટ',
      'featureAiScanTitle': 'એઆઈ રોગ સ્કેન',
      'featureAiScanDesc': 'પાંદડા સ્કેન કરો અને વહેલાં રોગ શોધો.',
      'featureIrrigationTitle': 'સ્માર્ટ સિંચાઈ',
      'featureIrrigationDesc': 'એપથી મોટર નિયંત્રિત કરો.',
      'featureMonitoringTitle': 'લાઇવ મોનિટરિંગ',
      'featureMonitoringDesc': 'માટી અને વાતાવરણનું ડેટા લાઇવ જુઓ.',
      'featureWeatherTitle': 'હવામાન જાગરૂક',
      'featureWeatherDesc': 'સારા નિર્ણય માટે હવામાન ડેટાનો ઉપયોગ કરો.',
      'howStep1': 'Arduino Uno, સેન્સર અને રિલે ચાલુ કરો.',
      'howStep2': 'સિસ્ટમને WiFi/બ્લૂટૂથ સાથે જોડો.',
      'howStep3': 'ડેશબોર્ડ ખોલો અને લાઇવ ડેટા જુઓ.',
      'howStep4': 'મોટર શરૂ/બંધ કરવા માટે બટનો ઉપયોગ કરો.',
      'howStep5': 'Disease Scan ખોલો અને સ્પષ્ટ ફોટો લો.',
      'howStep6': 'એઆઈ સૂચનો અને હિસ્ટ્રી જુઓ.',

      'plantCareDetector': 'પ્લાન્ટ કેર — ડિટેક્ટર',
      'detectSubtitle': 'પૌધાનો રોગ શોધો',
      'noImageSelected': 'કોઈ છબી પસંદ નથી',
      'camera': 'કેમેરા',
      'gallery': 'ગેલેરી',
      'analyzing': 'વિશ્લેષણ ચાલી રહ્યું છે…',
      'problemCopied': 'સમસા નકલ થઈ',
      'recommendedAction': 'ભલામણ કરેલ કાર્યવાહી',
      'preparingPlan': 'સંક્ષિપ્ત યોજના તૈયાર થઈ રહી છે...',
      'planUnavailable': 'યોજના ઉપલબ્ધ નથી',
      'openFullTreatment': 'સંપૂર્ણ સારવાર ખોલો',
      'result': 'પરિણામ',
      'topResult': 'ટોચનું પરિણામ',
      'plant': 'પ્લાન્ટ',
      'confidence': 'વિશ્વાસ',
      'copyProblem': 'સમસા નકલ કરો',
      'copyPlan': 'યોજના નકલ કરો',

      'planCopied': 'યોજના નકલ થઈ',
      'shareNotImplemented': 'શેર લાગુ નથી',
      'overview': 'સારાંશ',
      'prevention': 'રોકથામ',
      'treatment': 'સારવાર',
      'noTreatmentDetails': 'સારવાર વિગત ઉપલબ્ધ નથી.',
    },
    'mr': {
      'chooseLanguage': 'तुमची पसंतीची भाषा निवडा',
      'pleaseSelect': 'कृपया तुमची भाषा निवडा',
      'next': 'पुढे',
      'language': 'भाषा',
      'selectLanguage': 'भाषा निवडा',
      'currentLanguage': 'सध्याची भाषा',
      'languageChanged': 'भाषा यशस्वीरित्या बदलली',
      'english': 'English',
      'hindi': 'हिन्दी',
      'gujarati': 'ગુજરાતી',
      'marathi': 'मराठी',

      'profile': 'प्रोफाइल',
      'settings': 'सेटिंग्ज',
      'save': 'जतन करा',
      'cancel': 'रद्द करा',
      'ok': 'ठीक आहे',
      'skip': 'स्किप',
      'connect': 'कनेक्ट',
      'close': 'बंद करा',
      'copy': 'कॉपी',
      'share': 'शेअर',
      'retry': 'पुन्हा प्रयत्न करा',

      'appTitle': 'AgroXpert Plus',
      'refreshWeather': 'हवामान रीफ्रेश करा',
      'online': 'ऑनलाइन',
      'offline': 'ऑफलाइन',
      'bluetoothConnection': 'ब्लूटूथ कनेक्शन',
      'bluetoothConnectPrompt': 'आपण HC-05 ब्लूटूथ डिव्हाइसला कनेक्ट करू इच्छिता?',
      'bluetoothNotConnected': 'ब्लूटूथ कनेक्ट नाही. आत्ता कनेक्ट कराल?',
      'connectionFailed': 'कनेक्शन अयशस्वी',
      'success': 'यशस्वी',
      'connectNow': 'कनेक्ट',
      'failedToLoadWeather': 'हवामान लोड करण्यात अयशस्वी',
      'about': 'माहिती',
      'diseaseDetection': 'रोग शोध',
      'aiChatHistory': 'एआय चॅट इतिहास',
      'logout': 'लॉगआउट',

      'aiAssistant': 'AgroXpert एआय सहाय्यक',
      'chatHistory': 'चॅट इतिहास',
      'askHint': 'AgroXpert AI ला विचारा...',
      'chatError': 'त्रुटी',
      'chatHistoryTooltip': 'चॅट इतिहास',
      'newChat': 'नवीन चॅट',
      'backupAll': 'सर्व बॅकअप',
      'deleteAll': 'सर्व हटवा',
      'deleteChat': 'चॅट हटवा',
      'backup': 'बॅकअप',
      'delete': 'हटवा',

      'aboutTitle': 'AgroXpert Plus बद्दल',
      'developers': 'विकसक',
      'keyFeatures': 'मुख्य वैशिष्ट्ये',
      'howToUse': 'कसे वापरावे',
      'useCases': 'उपयोग आणि फायदे',
      'versionInfo': 'आवृत्ती 1.0.1  •  अंतिम वर्ष प्रकल्प',
      'featureAiScanTitle': 'एआय रोग स्कॅन',
      'featureAiScanDesc': 'पाने स्कॅन करा आणि लवकर रोग शोधा.',
      'featureIrrigationTitle': 'स्मार्ट सिंचन',
      'featureIrrigationDesc': 'अॅपमधून मोटर्स नियंत्रित करा.',
      'featureMonitoringTitle': 'लाइव्ह मॉनिटरिंग',
      'featureMonitoringDesc': 'माती व वातावरण डेटा लाइव्ह पहा.',
      'featureWeatherTitle': 'हवामान सजग',
      'featureWeatherDesc': 'चांगल्या निर्णयांसाठी हवामान डेटा वापरा.',
      'howStep1': 'Arduino Uno, सेन्सर आणि रिले चालू करा.',
      'howStep2': 'प्रणाली WiFi/ब्लूटूथला जोडा.',
      'howStep3': 'डॅशबोर्ड उघडा आणि लाइव्ह डेटा पाहा.',
      'howStep4': 'मोटर सुरू/बंद करण्यासाठी बटणे वापरा.',
      'howStep5': 'Disease Scan उघडा आणि स्पष्ट फोटो घ्या.',
      'howStep6': 'एआय सूचना आणि इतिहास पाहा.',

      'plantCareDetector': 'प्लांट केअर — डिटेक्टर',
      'detectSubtitle': 'झाडाचा रोग ओळखा',
      'noImageSelected': 'कोणतीही प्रतिमा निवडलेली नाही',
      'camera': 'कॅमेरा',
      'gallery': 'गॅलरी',
      'analyzing': 'विश्लेषण सुरू…',
      'problemCopied': 'समस्या कॉपी झाली',
      'recommendedAction': 'शिफारस केलेली कृती',
      'preparingPlan': 'संक्षिप्त योजना तयार होत आहे...',
      'planUnavailable': 'योजना उपलब्ध नाही',
      'openFullTreatment': 'पूर्ण उपचार उघडा',
      'result': 'परिणाम',
      'topResult': 'सर्वोत्तम परिणाम',
      'plant': 'वनस्पती',
      'confidence': 'विश्वास',
      'copyProblem': 'समस्या कॉपी करा',
      'copyPlan': 'योजना कॉपी करा',

      'planCopied': 'योजना कॉपी झाली',
      'shareNotImplemented': 'शेअर लागू नाही',
      'overview': 'आढावा',
      'prevention': 'प्रतिबंध',
      'treatment': 'उपचार',
      'noTreatmentDetails': 'उपचार तपशील उपलब्ध नाहीत.',
    },
  };

  // ------- Helpers --------

  String _text(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  // ------- Getters --------

  String get chooseLanguage => _text('chooseLanguage');

  String get pleaseSelect => _text('pleaseSelect');

  String get next => _text('next');

  String get language => _text('language');

  String get selectLanguage => _text('selectLanguage');

  String get currentLanguage => _text('currentLanguage');

  String get languageChanged => _text('languageChanged');

  String get english => _text('english');

  String get hindi => _text('hindi');

  String get gujarati => _text('gujarati');

  String get marathi => _text('marathi');

  String get profile => _text('profile');

  String get settings => _text('settings');

  String get save => _text('save');

  String get cancel => _text('cancel');

  String get ok => _text('ok');

  String get skip => _text('skip');

  String get connect => _text('connect');

  String get close => _text('close');

  String get copy => _text('copy');

  String get share => _text('share');

  String get retry => _text('retry');

  String get appTitle => _text('appTitle');

  String get refreshWeather => _text('refreshWeather');

  String get online => _text('online');

  String get offline => _text('offline');

  String get bluetoothConnection => _text('bluetoothConnection');

  String get bluetoothConnectPrompt => _text('bluetoothConnectPrompt');

  String get bluetoothNotConnected => _text('bluetoothNotConnected');

  String get connectionFailed => _text('connectionFailed');

  String get success => _text('success');

  String get connectNow => _text('connectNow');

  String get failedToLoadWeather => _text('failedToLoadWeather');

  String get about => _text('about');

  String get diseaseDetection => _text('diseaseDetection');

  String get aiChatHistory => _text('aiChatHistory');

  String get logout => _text('logout');

  String get aiAssistant => _text('aiAssistant');

  String get chatHistory => _text('chatHistory');

  String get askHint => _text('askHint');

  String get chatError => _text('chatError');

  String get chatHistoryTooltip => _text('chatHistoryTooltip');

  String get newChat => _text('newChat');

  String get backupAll => _text('backupAll');

  String get deleteAll => _text('deleteAll');

  String get deleteChat => _text('deleteChat');

  String get backup => _text('backup');

  String get delete => _text('delete');

  String get aboutTitle => _text('aboutTitle');

  String get developers => _text('developers');

  String get keyFeatures => _text('keyFeatures');

  String get howToUse => _text('howToUse');

  String get useCases => _text('useCases');

  String get versionInfo => _text('versionInfo');

  String get featureAiScanTitle => _text('featureAiScanTitle');

  String get featureAiScanDesc => _text('featureAiScanDesc');

  String get featureIrrigationTitle => _text('featureIrrigationTitle');

  String get featureIrrigationDesc => _text('featureIrrigationDesc');

  String get featureMonitoringTitle => _text('featureMonitoringTitle');

  String get featureMonitoringDesc => _text('featureMonitoringDesc');

  String get featureWeatherTitle => _text('featureWeatherTitle');

  String get featureWeatherDesc => _text('featureWeatherDesc');

  String get howStep1 => _text('howStep1');

  String get howStep2 => _text('howStep2');

  String get howStep3 => _text('howStep3');

  String get howStep4 => _text('howStep4');

  String get howStep5 => _text('howStep5');

  String get howStep6 => _text('howStep6');

  String get plantCareDetector => _text('plantCareDetector');

  String get detectSubtitle => _text('detectSubtitle');

  String get noImageSelected => _text('noImageSelected');

  String get camera => _text('camera');

  String get gallery => _text('gallery');

  String get analyzing => _text('analyzing');

  String get problemCopied => _text('problemCopied');

  String get recommendedAction => _text('recommendedAction');

  String get preparingPlan => _text('preparingPlan');

  String get planUnavailable => _text('planUnavailable');

  String get openFullTreatment => _text('openFullTreatment');

  String get result => _text('result');

  String get topResult => _text('topResult');

  String get plant => _text('plant');

  String get confidence => _text('confidence');

  String get copyProblem => _text('copyProblem');

  String get copyPlan => _text('copyPlan');

  String get planCopied => _text('planCopied');

  String get shareNotImplemented => _text('shareNotImplemented');

  String get overview => _text('overview');

  String get prevention => _text('prevention');

  String get treatment => _text('treatment');

  String get noTreatmentDetails => _text('noTreatmentDetails');
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
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
