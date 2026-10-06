import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

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
        return linux;
      default:
        return web;
    }
  }

  // Web options built from the provided firebaseConfig
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCz-gZdsDUlpQohVOWdfy6-1qnQLb9cLj0',
    authDomain: 'fir-tutorial-826a8.firebaseapp.com',
    projectId: 'fir-tutorial-826a8',
    storageBucket: 'fir-tutorial-826a8.firebasestorage.app',
    messagingSenderId: '957169519273',
    appId: '1:957169519273:web:feb013097ae965fe4df7b8',
  );

  // Android options built from google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBfbJRXxQpokpQ2u-qVVwxMn6ec88ToPeU',
    appId: '1:957169519273:android:b2d9f9911c5b29ec4df7b8',
    messagingSenderId: '957169519273',
    projectId: 'fir-tutorial-826a8',
    storageBucket: 'fir-tutorial-826a8.firebasestorage.app',
  );

  // iOS options
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCz-gZdsDUlpQohVOWdfy6-1qnQLb9cLj0',
    appId: '1:957169519273:ios:6c310468fce0d6214df7b8',
    messagingSenderId: '957169519273',
    projectId: 'fir-tutorial-826a8',
    storageBucket: 'fir-tutorial-826a8.firebasestorage.app',
    iosClientId: '957169519273-7hvs6f3rs32sot13ubkign2vi224gs78.apps.googleusercontent.com',
    iosBundleId: 'com.example.sahaaya',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCz-gZdsDUlpQohVOWdfy6-1qnQLb9cLj0',
    appId: '1:957169519273:web:feb013097ae965fe4df7b8',
    messagingSenderId: '957169519273',
    projectId: 'fir-tutorial-826a8',
    storageBucket: 'fir-tutorial-826a8.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCz-gZdsDUlpQohVOWdfy6-1qnQLb9cLj0',
    appId: '1:957169519273:web:feb013097ae965fe4df7b8',
    messagingSenderId: '957169519273',
    projectId: 'fir-tutorial-826a8',
    authDomain: 'fir-tutorial-826a8.firebaseapp.com',
    storageBucket: 'fir-tutorial-826a8.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyCz-gZdsDUlpQohVOWdfy6-1qnQLb9cLj0',
    appId: '1:957169519273:web:feb013097ae965fe4df7b8',
    messagingSenderId: '957169519273',
    projectId: 'fir-tutorial-826a8',
    authDomain: 'fir-tutorial-826a8.firebaseapp.com',
    storageBucket: 'fir-tutorial-826a8.firebasestorage.app',
  );
}
