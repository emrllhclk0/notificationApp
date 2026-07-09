
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
    apiKey: 'AIzaSyAGJBjhIIEaX7L3WgiRWFFwm4HoIVpIj5w',
    appId: '1:742437097759:web:5d1784f9b21b438a55602a',
    messagingSenderId: '742437097759',
    projectId: 'noticlassapp-361d5',
    authDomain: 'noticlassapp-361d5.firebaseapp.com',
    storageBucket: 'noticlassapp-361d5.firebasestorage.app',
    measurementId: 'G-G6EST5K38X',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBJkI3Kmc41MJuvZA9GRaeo3elWNN72_oE',
    appId: '1:742437097759:android:55d8720c43790e1255602a',
    messagingSenderId: '742437097759',
    projectId: 'noticlassapp-361d5',
    storageBucket: 'noticlassapp-361d5.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCeN1Joc7bOl_9T8gtYpjArHb-v6Kdb50A',
    appId: '1:742437097759:ios:966dba667d954f5555602a',
    messagingSenderId: '742437097759',
    projectId: 'noticlassapp-361d5',
    storageBucket: 'noticlassapp-361d5.firebasestorage.app',
    iosBundleId: 'com.example.tasarim',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCeN1Joc7bOl_9T8gtYpjArHb-v6Kdb50A',
    appId: '1:742437097759:ios:966dba667d954f5555602a',
    messagingSenderId: '742437097759',
    projectId: 'noticlassapp-361d5',
    storageBucket: 'noticlassapp-361d5.firebasestorage.app',
    iosBundleId: 'com.example.tasarim',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAGJBjhIIEaX7L3WgiRWFFwm4HoIVpIj5w',
    appId: '1:742437097759:web:37aff5589fd28f0e55602a',
    messagingSenderId: '742437097759',
    projectId: 'noticlassapp-361d5',
    authDomain: 'noticlassapp-361d5.firebaseapp.com',
    storageBucket: 'noticlassapp-361d5.firebasestorage.app',
    measurementId: 'G-E11LVCR54P',
  );

}