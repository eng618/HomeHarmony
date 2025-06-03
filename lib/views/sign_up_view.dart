import 'package:flutter/material.dart';
import '../widgets/auth_form.dart';
import '../services/auth_service.dart';

/// View for parent sign up.
class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AuthForm(
            title: 'Sign Up',
            actionText: 'Sign Up',
            onSubmit: (email, password) => AuthService.signUp(email, password),
          ),
        ),
      ),
    );
  }
}
