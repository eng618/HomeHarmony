import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/auth_providers.dart';

enum AuthFormType { signIn, signUp }

/// A reusable authentication form for sign in and sign up using Riverpod.
class AuthForm extends ConsumerStatefulWidget {
  final String title;
  final String actionText;
  final AuthFormType formType;
  final bool showNameField;

  const AuthForm({
    super.key,
    required this.title,
    required this.actionText,
    required this.formType,
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
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      return;
    }

    final authController = ref.read(authControllerProvider.notifier);

    switch (widget.formType) {
      case AuthFormType.signIn:
        await authController.signIn(email, password);
        break;
      case AuthFormType.signUp:
        await authController.signUp(email, password);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

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
            if (authState.isLoading) return;
            _submit();
          },
        ),
        authState.when(
          data: (_) => const SizedBox(),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              error.toString(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: authState.isLoading ? null : _submit,
          child: Text(widget.actionText),
        ),
      ],
    );
  }
}
