import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Firebase Web app registered in the Firebase console.
///
/// Native Android/iOS options will be generated with FlutterFire once
/// those two apps are registered. Firebase API keys are public identifiers,
/// not service-account credentials.
abstract final class FirebaseAppConfig {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAlczvAfJRqzlYXVWWas8fxSAXytB5U6VU',
    appId: '1:383552662551:web:601ab0952ef9657f360052',
    messagingSenderId: '383552662551',
    projectId: 'binisoft-business-cloud',
    authDomain: 'binisoft-business-cloud.firebaseapp.com',
    storageBucket: 'binisoft-business-cloud.firebasestorage.app',
    measurementId: 'G-33TB0MLX14',
  );

  static Future<void> initializeForWeb() async {
    if (kIsWeb) {
      await Firebase.initializeApp(options: web);
    }
  }
}
