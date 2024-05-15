// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCVZ35iGorEsVBxhO2mRa7mS5FQcVzA1Yw',
    appId: '1:696629174309:web:77f4cf098432f1ba6f5fcc',
    messagingSenderId: '696629174309',
    projectId: 'peaceful-cradle',
    authDomain: 'peaceful-cradle.firebaseapp.com',
    storageBucket: 'peaceful-cradle.appspot.com',
    measurementId: 'G-X4K1W86W7W',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBX1ziHQ3-7NW9ZBUF2wdtwo2K8khAf880',
    appId: '1:696629174309:android:cf873ef4160844326f5fcc',
    messagingSenderId: '696629174309',
    projectId: 'peaceful-cradle',
    storageBucket: 'peaceful-cradle.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDTLP0lvrToK5OFyKMLqU1vI8ECbZbLB_Q',
    appId: '1:696629174309:ios:4d148a668c01d4cd6f5fcc',
    messagingSenderId: '696629174309',
    projectId: 'peaceful-cradle',
    storageBucket: 'peaceful-cradle.appspot.com',
    iosBundleId: 'com.example.smartCradleSystem',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDTLP0lvrToK5OFyKMLqU1vI8ECbZbLB_Q',
    appId: '1:696629174309:ios:60db1cc8175817a96f5fcc',
    messagingSenderId: '696629174309',
    projectId: 'peaceful-cradle',
    storageBucket: 'peaceful-cradle.appspot.com',
    iosBundleId: 'com.example.smartCradleSystem.RunnerTests',
  );
}