import 'package:flutter/material.dart';
import '../widgets/auth_form.dart';
import '../services/auth_service.dart';

/// View for parent sign in.
class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AuthForm(
            title: 'Sign In',
            actionText: 'Sign In',
            onSubmit: (email, password) => AuthService.signIn(email, password),
          ),
        ),
      ),
    );
  }
}
