import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Provides a stream of the current Firebase user (null if signed out).
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Riverpod provider for app theme mode.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
