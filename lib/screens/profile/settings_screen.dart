import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';
import '../../utils/auth_providers.dart';
import '../../views/settings/privacy_policy_view.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Appearance'),
            subtitle: Text('Choose your theme'),
          ),
          Column(
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: themeMode,
                onChanged: (mode) {
                  if (mode != null) {
                    ref.read(themeModeProvider.notifier).setTheme(mode);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: themeMode,
                onChanged: (mode) {
                  if (mode != null) {
                    ref.read(themeModeProvider.notifier).setTheme(mode);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('System Default'),
                value: ThemeMode.system,
                groupValue: themeMode,
                onChanged: (mode) {
                  if (mode != null) {
                    ref.read(themeModeProvider.notifier).setTheme(mode);
                  }
                },
              ),
            ],
          ),
          // --- Notification Preferences (Stub) ---
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: false, // TODO: Wire up with Riverpod provider
            onChanged: (val) {
              // TODO: Implement notification toggle logic
            },
          ),
          // --- Account Management (Stub) ---
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Change Email'),
            onTap: () {
              // TODO: Implement change email flow
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Change Email not implemented.')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () {
              // TODO: Implement change password flow
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Change Password not implemented.'),
                ),
              );
            },
          ),
          // --- Privacy & Security (Stub) ---
          SwitchListTile(
            title: const Text('Enable Biometric Login'),
            value: false, // TODO: Wire up with Riverpod provider
            onChanged: (val) {
              // TODO: Implement biometric toggle logic
            },
          ),
          // --- About / App Info (Stub) ---
          const Divider(),
          ListTile(
            leading: Icon(Icons.info_outline, color: Colors.grey[700]),
            title: Text('About Home Harmony'),
            subtitle: Text('Version 1.0.0 (Build 1)'),
            onTap: () {
              // TODO: Show about dialog or page
              showAboutDialog(
                context: context,
                applicationName: 'Home Harmony',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 Home Harmony Team',
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip, color: Colors.grey[700]),
            title: const Text('Privacy Policy'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyView(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.gavel, color: Colors.grey[700]),
            title: const Text('Terms of Service'),
            onTap: () {
              // TODO: Open terms of service link
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Terms of Service not implemented.'),
                ),
              );
            },
          ),
          // --- Feedback & Support (Stub) ---
          const Divider(),
          ListTile(
            leading: Icon(Icons.feedback, color: Colors.blue[700]),
            title: const Text('Send Feedback'),
            onTap: () {
              // TODO: Implement feedback form or email intent
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feedback not implemented.')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.support_agent, color: Colors.blue[700]),
            title: const Text('Contact Support'),
            onTap: () {
              // TODO: Implement support contact
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Support not implemented.')),
              );
            },
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.delete_forever),
              label: const Text('Delete My Account'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Account'),
                    content: const Text(
                      'Are you sure you want to delete your account and all associated data? This action is irreversible.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                // After the confirmation dialog, check if the widget is still mounted
                if (confirmed == true) {
                  if (!context.mounted) return;
                  // Show loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) =>
                        const Center(child: CircularProgressIndicator()),
                  );
                  final result = await AuthService.deleteAccount();
                  // After deleting the account, check if the widget is still mounted
                  // before trying to interact with the Navigator or ScaffoldMessenger.
                  if (!context.mounted) return;
                  Navigator.of(context).pop(); // Remove loading dialog
                  if (result == null) {
                    // Account deleted, pop to login screen
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    // After popUntil, this screen's context is no longer valid.
                    // Check mounted status again before trying to show a SnackBar.
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Account deleted successfully.'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Account deletion failed: $result'),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
