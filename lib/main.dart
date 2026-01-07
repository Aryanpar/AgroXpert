import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/dashboard.dart'; // <-- your dashboard screen
import 'screens/language_selection.dart';
import 'utils/app_localizations.dart';
import 'utils/language_provider.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(
      ChangeNotifierProvider(
        create: (context) => LanguageProvider(),
        child: const MyApp(),
      ),
    );
  } catch (e) {
    runApp(ErrorApp(error: e));
  }
}

class ErrorApp extends StatelessWidget {
  final Object error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Failed to initialize the app:\n\n$error",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return MaterialApp(
  title: 'AgroXpert Plus',
  theme: ThemeData(
    primaryColor: const Color(0xFF4CAF50),
    scaffoldBackgroundColor: Colors.white,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  ),
  debugShowCheckedModeBanner: false,

  // 🔥 Language switching works here
  locale: languageProvider.currentLocale,

  supportedLocales: const [
    Locale('en'),
    Locale('hi'),
    Locale('gu'),
    Locale('mr'),
  ],

  localizationsDelegates: const [
    AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],

  home: const AuthGate(),
);

  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          // user is logged in
          return const DashboardScreen();
        } else {
          // user is NOT logged in
          return const LanguageSelectionScreen();
        }
      },
    );
  }
}
