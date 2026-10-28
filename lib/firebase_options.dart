import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

// Configuração Android obtida do google-services.json deste projeto.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    throw UnsupportedError('Configure o Firebase para esta plataforma.');
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDptltscEtcU1mUbPJIua96oszPXTWtVb4',
    appId: '1:60588268980:android:2fa610aa72794df27166e1',
    messagingSenderId: '60588268980',
    projectId: 'blocodenotas-717e4',
    storageBucket: 'blocodenotas-717e4.firebasestorage.app',
  );
}
