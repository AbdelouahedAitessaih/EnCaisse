// File generated from your Firebase config files.
// android/app/google-services.json + ios/Runner/GoogleService-Info.plist
// Re-run flutterfire configure if you regenerate those files.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDc3DcjdOEjSNiKp9w5oEJJzQVtxMql88o',
    appId: '1:559211214178:android:78c914cdbf1a1b763f283b',
    messagingSenderId: '559211214178',
    projectId: 'encaisse-3c7fb',
    storageBucket: 'encaisse-3c7fb.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB4o9DBJsSLcOQa7IEdvoo950e0OE7qP3Q',
    appId: '1:559211214178:ios:469e6142d566651f3f283b',
    messagingSenderId: '559211214178',
    projectId: 'encaisse-3c7fb',
    storageBucket: 'encaisse-3c7fb.firebasestorage.app',
    iosBundleId: 'com.encaisse.encaisse',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDc3DcjdOEjSNiKp9w5oEJJzQVtxMql88o',
    appId: '1:559211214178:web:placeholder',
    messagingSenderId: '559211214178',
    projectId: 'encaisse-3c7fb',
    authDomain: 'encaisse-3c7fb.firebaseapp.com',
    storageBucket: 'encaisse-3c7fb.firebasestorage.app',
  );
}
