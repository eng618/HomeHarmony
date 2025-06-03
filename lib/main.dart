import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'env_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'views/auth_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'utils/auth_providers.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load();
  } catch (e) {
    if (!kIsWeb) {
      // Only print error for non-web, since web will always fail
      debugPrint('Failed to load .env: $e');
    }
  }
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: firebaseConfig['apiKey']!,
        authDomain: firebaseConfig['authDomain'],
        projectId: firebaseConfig['projectId']!,
        storageBucket: firebaseConfig['storageBucket']!,
        messagingSenderId: firebaseConfig['messagingSenderId']!,
        appId: firebaseConfig['appId']!,
        measurementId: firebaseConfig['measurementId'],
      ),
    );
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'Home Harmony',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2A9D8F),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: themeMode,
      home: userAsync.when(
        data: (user) {
          if (user != null) {
            return HomeScreen(user: user);
          } else {
            return const AuthScreen();
          }
        },
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      ),
    );
  }
}
