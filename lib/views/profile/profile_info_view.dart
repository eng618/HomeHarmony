import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileInfoView extends StatelessWidget {
  final User user;
  final Map<String, dynamic>? data;
  final VoidCallback? onOpenSettings;
  final bool signingOut;
  final VoidCallback onSignOut;
  final Future<void> Function() onRefresh;
  const ProfileInfoView({
    super.key,
    required this.user,
    required this.data,
    required this.onOpenSettings,
    required this.signingOut,
    required this.onSignOut,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final role = data?['role'] ?? 'unknown';
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Settings',
                onPressed: onOpenSettings,
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sign Out',
                onPressed: signingOut ? null : onSignOut,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: onRefresh,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                children: [
                  Text('Email:  20${user.email ?? ''}'),
                  const SizedBox(height: 12),
                  Text('Role: $role'),
                  const SizedBox(height: 24),
                  if (role == 'parent') ...[
                    // Family member management moved to FamilyMembersScreen
                  ],
                ],
              ),
            ),
          ),
        ),
        if (signingOut)
          Container(
            color: Colors.black54,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
