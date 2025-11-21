import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_harmony/utils/app_theme.dart';
import 'package:home_harmony/utils/auth_providers.dart';
import 'views/auth_screen.dart';
import 'views/main_shell.dart';
import 'screens/unsupported_platform_screen.dart';

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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if platform is supported (Linux only when not running as web)
    if (defaultTargetPlatform == TargetPlatform.linux && !kIsWeb) {
      return const MaterialApp(
        title: 'Home Harmony',
        home: UnsupportedPlatformScreen(),
      );
    }

    // Watch authentication state to determine which screen to show
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Home Harmony',
      theme: AppTheme.theme,
      home: authState.when(
        data: (user) => user != null
            ? MainShell(user: user)
            : const AuthScreen(),
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stack) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Authentication Error'),
                const SizedBox(height: 8),
                Text('$error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Retry by refreshing the provider
                    ref.invalidate(authStateProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
