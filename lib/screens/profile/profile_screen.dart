import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../views/profile/profile_info_view.dart';
import '../../views/profile/profile_error_view.dart';
import 'settings_screen.dart';

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
      onOpenSettings: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
      },
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
