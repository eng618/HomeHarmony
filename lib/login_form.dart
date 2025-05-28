import 'package:flutter/material.dart';
import 'services/auth_service.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onSwitch;
  const LoginForm({super.key, required this.onSwitch});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _loading = false;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final result = await AuthService.signIn(email, password);
    // If result is null, user is signed in. If not, it's an error message.
    setState(() {
      _loading = false;
      _error = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                v != null && v.contains('@') ? null : 'Enter a valid email',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (v) =>
                v != null && v.length >= 6 ? null : 'Min 6 characters',
          ),
          const SizedBox(height: 24),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
          ],
          _loading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) _submit();
                  },
                  child: const Text('Sign In'),
                ),
          TextButton(
            onPressed: widget.onSwitch,
            child: const Text('Create an account'),
          ),
        ],
      ),
    );
  }
}
