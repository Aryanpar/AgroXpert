// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB9tTzXW4INylJNx6mq5VKVWueHrYHoy4Y', // Use Android key as placeholder if web key unknown
    appId: '1:656495659712:web:ccb06205569a05d70bfb25', // Guessed/Placeholder
    messagingSenderId: '656495659712',
    projectId: 'agroxpert-b90bc',
    authDomain: 'agroxpert-b90bc.firebaseapp.com',
    storageBucket: 'agroxpert-b90bc.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB9tTzXW4INylJNx6mq5VKVWueHrYHoy4Y',
    appId: '1:656495659712:android:ddc06205569a05d70bfb25',
    messagingSenderId: '656495659712',
    projectId: 'agroxpert-b90bc',
    storageBucket: 'agroxpert-b90bc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'dummy_api_key',
    appId: '1:1234567890:ios:dummy_id',
    messagingSenderId: '1234567890',
    projectId: 'dummy-project',
    storageBucket: 'dummy-project.appspot.com',
    iosClientId: '1234567890-ios-client-id.apps.googleusercontent.com',
    iosBundleId: 'com.example.newagro',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'dummy_api_key',
    appId: '1:1234567890:ios:dummy_id',
    messagingSenderId: '1234567890',
    projectId: 'dummy-project',
    storageBucket: 'dummy-project.appspot.com',
    iosClientId: '1234567890-ios-client-id.apps.googleusercontent.com',
    iosBundleId: 'com.example.newagro',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'dummy_api_key',
    appId: '1:1234567890:web:dummy_id',
    messagingSenderId: '1234567890',
    projectId: 'dummy-project',
    authDomain: 'dummy-project.firebaseapp.com',
    storageBucket: 'dummy-project.appspot.com',
  );
}
