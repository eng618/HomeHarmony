import 'package:flutter/material.dart';

/// A form for creating a child account (full login-enabled).
class ChildAccountForm extends StatefulWidget {
  final Future<String?> Function(
    String name,
    int age,
    String email,
    String password,
  )
  onSubmit;

  const ChildAccountForm({super.key, required this.onSubmit});

  @override
  State<ChildAccountForm> createState() => _ChildAccountFormState();
}

class _ChildAccountFormState extends State<ChildAccountForm> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? error;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Add Child Account',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Child Name'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ageController,
          decoration: const InputDecoration(labelText: 'Age'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Child Email'),
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
                  final name = nameController.text.trim();
                  final age = int.tryParse(ageController.text.trim()) ?? 0;
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();
                  final err = await widget.onSubmit(name, age, email, password);
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
          child: const Text('Add'),
        ),
      ],
    );
  }
}
