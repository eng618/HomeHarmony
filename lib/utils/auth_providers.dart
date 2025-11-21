import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../services/auth_service.dart';

/// Provides the current authenticated Firebase user or null if not signed in.
/// This is the primary auth state provider that should be used throughout the app.
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Auth controller that manages authentication operations and loading states.
/// Provides methods for sign in, sign up, and sign out with proper error handling.
final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // No initial state needed, we just provide operations
    return null;
  }

  /// Sign in with email and password
  Future<String?> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final error = await AuthService.signIn(email, password);
      if (error == null) {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error(error, StackTrace.current);
      }
      return error;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return e.toString();
    }
  }

  /// Sign up with email and password
  Future<String?> signUp(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final error = await AuthService.signUp(email, password);
      if (error == null) {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error(error, StackTrace.current);
      }
      return error;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return e.toString();
    }
  }

  /// Sign out the current user
  Future<String?> signOut() async {
    state = const AsyncValue.loading();
    try {
      await FirebaseAuth.instance.signOut();
      state = const AsyncValue.data(null);
      return null;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return e.toString();
    }
  }

  /// Delete the current user account
  Future<String?> deleteAccount() async {
    state = const AsyncValue.loading();
    try {
      final error = await AuthService.deleteAccount();
      if (error == null) {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error(error, StackTrace.current);
      }
      return error;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return e.toString();
    }
  }
}

/// Riverpod provider for app theme mode.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const _key = 'theme_mode';
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == 'light') {
      state = ThemeMode.light;
    } else if (value == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.light) {
      await prefs.setString(_key, 'light');
    } else if (mode == ThemeMode.dark) {
      await prefs.setString(_key, 'dark');
    } else {
      await prefs.setString(_key, 'system');
    }
  }
}
