import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/firebase_app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await FirebaseAppConfig.initializeForWeb();
    runApp(const ProviderScope(child: BinisoftApp()));
  } catch (error) {
    // Fail visibly rather than leaving the user on a blank page.
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Firebase initialization failed: $error'),
          ),
        ),
      ),
    ));
  }
}
