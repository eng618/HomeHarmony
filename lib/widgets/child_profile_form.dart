import 'package:flutter/material.dart';

/// A reusable widget for a child profile form (add/edit).
class ChildProfileForm extends StatefulWidget {
  final String? initialName;
  final int? initialAge;
  final String? initialProfileType;
  final String? initialProfilePicture;
  final String title;
  final String actionText;
  final Future<void> Function(
    String name,
    int age,
    String profileType,
    String? profilePicture,
  )
  onSubmit;

  const ChildProfileForm({
    super.key,
    this.initialName,
    this.initialAge,
    this.initialProfileType,
    this.initialProfilePicture,
    required this.title,
    required this.actionText,
    required this.onSubmit,
  });

  @override
  State<ChildProfileForm> createState() => _ChildProfileFormState();
}

class _ChildProfileFormState extends State<ChildProfileForm> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _profilePictureController;
  String _profileType = 'local';
  String? error;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _ageController = TextEditingController(
      text: widget.initialAge?.toString() ?? '',
    );
    _profilePictureController = TextEditingController(
      text: widget.initialProfilePicture ?? '',
    );
    _profileType = widget.initialProfileType ?? 'local';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _profilePictureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Child Name'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ageController,
            decoration: const InputDecoration(labelText: 'Age'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _profileType,
            items: const [
              DropdownMenuItem(
                value: 'local',
                child: Text('Local (parent-managed)'),
              ),
              DropdownMenuItem(
                value: 'full',
                child: Text('Full (login-enabled)'),
              ),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _profileType = val);
            },
            decoration: const InputDecoration(labelText: 'Profile Type'),
          ),
          TextField(
            controller: _profilePictureController,
            decoration: const InputDecoration(
              labelText: 'Profile Picture URL (optional)',
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(error!, style: const TextStyle(color: Colors.red)),
          ],
          if (loading) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: loading
              ? null
              : () async {
                  setState(() {
                    error = null;
                    loading = true;
                  });
                  try {
                    final name = _nameController.text.trim();
                    final age = int.tryParse(_ageController.text.trim()) ?? 0;
                    final profilePicture =
                        _profilePictureController.text.trim().isEmpty
                        ? null
                        : _profilePictureController.text.trim();
                    await widget.onSubmit(
                      name,
                      age,
                      _profileType,
                      profilePicture,
                    );
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  } catch (e) {
                    setState(() {
                      error = e.toString();
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
