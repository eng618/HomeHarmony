import 'package:flutter/material.dart';

/// A reusable authentication form for sign in and sign up.
class AuthForm extends StatefulWidget {
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
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  String? error;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
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
                  if (err == null) {
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  } else {
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
