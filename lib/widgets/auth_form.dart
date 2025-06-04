import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/auth_providers.dart';

/// A reusable authentication form for sign in and sign up.
class AuthForm extends ConsumerStatefulWidget {
  final String title;
  final String actionText;
  final Future<String?> Function(String email, String password) onSubmit;
  final bool showNameField;

  const AuthForm({
    super.key,
    required this.title,
    required this.actionText,
    required this.onSubmit,
    this.showNameField = false,
  });

  @override
  ConsumerState<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends ConsumerState<AuthForm> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  String? error;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authStateProvider);
    userAsync.when(
      data: (user) {
        if (user != null) {
          // Navigation is now handled globally in main.dart/MyApp
        }
      },
      loading: () {},
      error: (error, stackTrace) {},
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.headlineSmall),
        if (widget.showNameField) ...[
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: passwordController,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        if (error != null) ...[
          const SizedBox(height: 8),
          Text(error!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: loading
              ? null
              : () async {
                  setState(() {
                    error = null;
                    loading = true;
                  });
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();
                  final err = await widget.onSubmit(email, password);
                  if (err != null) {
                    setState(() {
                      error = err;
                      loading = false;
                    });
                  }
                },
          child: Text(widget.actionText),
        ),
      ],
    );
  }
}
