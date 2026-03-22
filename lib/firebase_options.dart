import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web platform is not configured. '
        'Run flutterfire configure to add web support.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS platform is not configured. '
          'Run flutterfire configure to add iOS support.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'macOS platform is not configured. '
          'Run flutterfire configure to add macOS support.',
        );
      default:
        throw UnsupportedError('Unsupported platform: $defaultTargetPlatform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCLCTpS-JCu8TimwndttQkPkludNFFi6kg',
    appId: '1:285410185583:android:5ee557fcadc956e583d89a',
    messagingSenderId: '285410185583',
    projectId: 'custrom-35415',
    storageBucket: 'custrom-35415.firebasestorage.app',
  );
}
