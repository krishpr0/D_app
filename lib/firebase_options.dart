import 'package:firebase_core/firebase_core.dart'  show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;


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
      return linux;

      default:
      throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform',);
    }
  }


  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'umm i need to keep the api key here i m still tryna find the thinsg',
    appId: '',
    messagingSenderId:  '',
    projectId: '',
    authDomain: '',
    storageBucket: '',
    measurementId: '',
  );
  
}