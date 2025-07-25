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
    apiKey: 'AIzaSyD02JSxNUsgf55RckCMzwPFWZXc6An9B2o',
    appId: '1:883610348769:web:8cfa5d10e7b3e3e99c1ba0',
    messagingSenderId: '883610348769',
    projectId: 'eccomerce-af8a1',
    authDomain: 'eccomerce-af8a1.firebaseapp.com',
    storageBucket: 'eccomerce-af8a1.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyApGiECi2Wgb4PJtVPDbLWD65zZCfcTEY8',
    appId: '1:883610348769:android:50464351d312d8ac9c1ba0',
    messagingSenderId: '883610348769',
    projectId: 'eccomerce-af8a1',
    storageBucket: 'eccomerce-af8a1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCUxYd73nlRn7R53piyWctZU76nZsNZNQ8',
    appId: '1:883610348769:ios:6cb6a506ed4c091a9c1ba0',
    messagingSenderId: '883610348769',
    projectId: 'eccomerce-af8a1',
    storageBucket: 'eccomerce-af8a1.appspot.com',
    androidClientId:
        '883610348769-cb44jf2slhn47ptvij9fp1e107f04jlf.apps.googleusercontent.com',
    iosClientId:
        '883610348769-oo2mfl8ukg50e8e5bhvaf21ieobikp71.apps.googleusercontent.com',
    iosBundleId: 'com.id.nibblesEcommerce',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCUxYd73nlRn7R53piyWctZU76nZsNZNQ8',
    appId: '1:883610348769:ios:3a4e9e7dd314e97d9c1ba0',
    messagingSenderId: '883610348769',
    projectId: 'eccomerce-af8a1',
    storageBucket: 'eccomerce-af8a1.appspot.com',
    androidClientId:
        '883610348769-cb44jf2slhn47ptvij9fp1e107f04jlf.apps.googleusercontent.com',
    iosClientId:
        '883610348769-cmaubtf6rugn63v9in7psg7b0he8dmbs.apps.googleusercontent.com',
    iosBundleId: 'com.id.nibblesEcommerce.RunnerTests',
  );
}
