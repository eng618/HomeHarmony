import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'family_members_screen.dart';
import 'rules_screen.dart';
import 'consequences_screen.dart';
import 'rewards_screen.dart';
import 'screentime_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onOpenProfile;
  final User user;
  const HomeScreen({super.key, required this.user, this.onOpenProfile});

  void _openFamilyMembers(BuildContext context, User user) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => FamilyMembersScreen(user: user)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Harmony'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: onOpenProfile,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          GestureDetector(
            onTap: () {
              _openFamilyMembers(context, user);
            },
            child: _SectionStub(title: 'Family Members', icon: Icons.group),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => RulesScreen(user: user)),
              );
            },
            child: _SectionStub(title: 'Rules', icon: Icons.rule),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => RewardsScreen(user: user)),
              );
            },
            child: _SectionStub(title: 'Rewards', icon: Icons.emoji_events),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ConsequencesScreen(user: user),
                ),
              );
            },
            child: _SectionStub(title: 'Consequences', icon: Icons.warning),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ScreentimeScreen(user: user)),
              );
            },
            child: _SectionStub(
              title: 'Screentime Tracking',
              icon: Icons.timer,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Activity Feed feature coming soon!'),
                ),
              );
            },
            child: _SectionStub(title: 'Activity Feed', icon: Icons.history),
          ),
        ],
      ),
    );
  }
}

class _SectionStub extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionStub({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 24),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
