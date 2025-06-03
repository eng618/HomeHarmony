import 'package:flutter/material.dart';
import '../widgets/auth_form.dart';
import '../services/auth_service.dart';

/// View for parent sign up.
class SignUpView extends StatelessWidget {
  final VoidCallback? onSwitch;
  const SignUpView({super.key, this.onSwitch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AuthForm(
                title: 'Sign Up',
                actionText: 'Sign Up',
                onSubmit: (email, password) =>
                    AuthService.signUp(email, password),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onSwitch,
                child: const Text('Already have an account? Sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
