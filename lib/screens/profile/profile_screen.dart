import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget to display error state for the profile screen.
class ProfileErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const ProfileErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Could not load profile. Please check your connection or try again later.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget to display the main profile information.
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
                  Text('Email: ${user.email ?? ''}'),
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

/// ProfileScreen displays the current user's profile information and allows sign out.
class ProfileScreen extends ConsumerStatefulWidget {
  final User user;
  final VoidCallback? onOpenSettings;
  const ProfileScreen({super.key, required this.user, this.onOpenSettings});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  DocumentSnapshot<Map<String, dynamic>>? _cachedProfile;
  bool _loading = false;
  bool _signingOut = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  /// Fetches the user's profile document from Firestore.
  Future<void> _fetchProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();
      setState(() {
        _cachedProfile = doc;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _refreshProfile() async => _fetchProfile();

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return ProfileErrorView(error: _error!, onRetry: _refreshProfile);
    }
    return ProfileInfoView(
      user: widget.user,
      data: _cachedProfile?.data(),
      onOpenSettings: widget.onOpenSettings,
      signingOut: _signingOut,
      onSignOut: () async {
        setState(() => _signingOut = true);
        try {
          await FirebaseAuth.instance.signOut();
          if (!context.mounted) return;
        } catch (e) {
          setState(() => _signingOut = false);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign out failed: \\${e.toString()}')),
          );
        }
      },
      onRefresh: _refreshProfile,
    );
  }
}
