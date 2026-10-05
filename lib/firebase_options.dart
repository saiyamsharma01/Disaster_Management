// Generated manually from your Firebase Web config.
// If you later run `flutterfire configure`, it may overwrite this file.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnimplementedError(
          'Firebase options for Android are not set.\n'
          'Add android options or run "flutterfire configure" to generate them.',
        );
      case TargetPlatform.iOS:
        throw UnimplementedError(
          'Firebase options for iOS are not set.\n'
          'Add iOS options or run "flutterfire configure" to generate them.',
        );
      case TargetPlatform.macOS:
        throw UnimplementedError(
          'Firebase options for macOS are not set.\n'
          'Add macOS options or run "flutterfire configure" to generate them.',
        );
      case TargetPlatform.windows:
        throw UnimplementedError(
          'Firebase options for Windows are not set.\n'
          'Add Windows options or run "flutterfire configure" to generate them.',
        );
      case TargetPlatform.linux:
        throw UnimplementedError(
          'Firebase options for Linux are not set.\n'
          'Add Linux options or run "flutterfire configure" to generate them.',
        );
      default:
        throw UnimplementedError(
          'Unsupported platform for Firebase initialization.',
        );
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
    // measurementId can be added here if you have it, e.g.: measurementId: 'G-XXXXXXX',
  );
}
