import 'package:flutter/material.dart';
import 'sign_in_view.dart';
import 'sign_up_view.dart';

/// Top-level authentication screen with navigation between sign in and sign up.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool showSignIn = true;

  void toggle() => setState(() => showSignIn = !showSignIn);

  @override
  Widget build(BuildContext context) {
    return showSignIn
        ? SignInView(key: const ValueKey('signIn'), onSwitch: toggle)
        : SignUpView(key: const ValueKey('signUp'), onSwitch: toggle);
  }
}
