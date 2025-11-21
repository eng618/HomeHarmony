import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_harmony/utils/app_theme.dart';
import 'views/auth_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    debugPrint('Firebase options apiKey: ${options.apiKey}');
    await Firebase.initializeApp(
      options: options,
    );
    runApp(const ProviderScope(child: MyApp()));
  } catch (e, stack) {
    debugPrint('Failed to initialize Firebase: $e\n$stack');
    // For now, try to run anyway to see other errors
    runApp(const ProviderScope(child: MyApp()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Harmony',
      theme: AppTheme.theme,
      home: const AuthScreen(),
    );
  }
}
