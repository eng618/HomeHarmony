import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'env_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/settings_screen.dart';
import 'screens/home/home_screen.dart';
import 'utils/app_theme.dart';
import 'package:http/http.dart' as http;

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
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Harmony',
      theme: buildAppTheme(),
      darkTheme: buildAppTheme(darkMode: true),
      themeMode: _themeMode,
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 64),
                    const SizedBox(height: 24),
                    const Text(
                      'An error occurred',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      details.exceptionAsString(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        };
        return child!;
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return HomeScreen(
              user: snapshot.data!,
              onOpenProfile: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      user: snapshot.data!,
                      onOpenSettings: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(
                              currentThemeMode: _themeMode,
                              onThemeModeChanged: _setThemeMode,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
          return const AuthScreen();
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _apiResponse = '';

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> fetchSampleData() async {
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/todos/1'),
    );
    if (response.statusCode == 200) {
      setState(() {
        _apiResponse = response.body;
      });
    } else {
      setState(() {
        _apiResponse = 'Failed to load data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: fetchSampleData,
              child: const Text('Fetch Sample API Data'),
            ),
            const SizedBox(height: 20),
            Text(_apiResponse),
            const SizedBox(height: 20),
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
