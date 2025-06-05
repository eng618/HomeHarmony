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
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  String? error;
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
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
  }

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
      error: (error, stack) {},
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.headlineSmall),
        if (widget.showNameField) ...[
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: emailController,
          focusNode: emailFocus,
          decoration: const InputDecoration(labelText: 'Email'),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(passwordFocus);
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: passwordController,
          focusNode: passwordFocus,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (!loading) _submit();
          },
        ),
        if (error != null) ...[
          const SizedBox(height: 8),
          Text(error!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: loading ? null : _submit,
          child: Text(widget.actionText),
        ),
      ],
    );
  }
}
