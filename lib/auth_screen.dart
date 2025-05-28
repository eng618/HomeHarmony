import 'package:flutter/material.dart';
import 'login_form.dart';
import 'signup_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  void _toggleForm() => setState(() => _isLogin = !_isLogin);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Sign In' : 'Sign Up')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _isLogin
              ? LoginForm(onSwitch: _toggleForm)
              : SignupForm(onSwitch: _toggleForm),
        ),
      ),
    );
  }
}
