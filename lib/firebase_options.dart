import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

/// Firebase configuration for FloatIT app
///
/// NOTE: Firebase API keys are safe to include in client code.
/// They are not secret keys - they just identify your Firebase project.
/// Security is enforced by Firestore Security Rules, not by hiding these keys.
/// See: https://firebase.google.com/docs/projects/api-keys
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAC7B4DLfnCqr292V0ulvJINss0Wzsvfnw',
    authDomain: 'floatit-app.firebaseapp.com',
    projectId: 'floatit-app',
    storageBucket: 'floatit-app.firebasestorage.app',
    messagingSenderId: '129192884776',
    appId: '1:129192884776:web:541d2b77864ec0d597d31d',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAC7B4DLfnCqr292V0ulvJINss0Wzsvfnw',
    authDomain: 'floatit-app.firebaseapp.com',
    projectId: 'floatit-app',
    storageBucket: 'floatit-app.firebasestorage.app',
    messagingSenderId: '129192884776',
    appId: '1:129192884776:web:541d2b77864ec0d597d31d',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAC7B4DLfnCqr292V0ulvJINss0Wzsvfnw',
    authDomain: 'floatit-app.firebaseapp.com',
    projectId: 'floatit-app',
    storageBucket: 'floatit-app.firebasestorage.app',
    messagingSenderId: '129192884776',
    appId: '1:129192884776:web:541d2b77864ec0d597d31d',
  );
}
