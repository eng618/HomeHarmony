import 'package:flutter/material.dart';
import '../widgets/auth_form.dart';
import '../services/auth_service.dart';

/// View for parent sign in.
class SignInView extends StatelessWidget {
  final VoidCallback? onSwitch;
  const SignInView({super.key, this.onSwitch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AuthForm(
                title: 'Sign In',
                actionText: 'Sign In',
                onSubmit: (email, password) =>
                    AuthService.signIn(email, password),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onSwitch,
                child: const Text("Don't have an account? Create one"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
