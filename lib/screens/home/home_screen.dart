import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'family_members_screen.dart';
import 'rules_screen.dart';
import 'consequences_screen.dart';
import 'rewards_screen.dart';
import 'screen_time_screen.dart';
import 'activity_history_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/section_stub.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onOpenProfile;
  final User user;
  const HomeScreen({super.key, required this.user, this.onOpenProfile});

  void _openFamilyMembers(BuildContext context, User user) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => FamilyMembersScreen(user: user)));
  }

  void _openProfile(BuildContext context, User user) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ProfileScreen(user: user)));
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
            onPressed: () => _openProfile(context, user),
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
            child: SectionStub(title: 'Family Members', icon: Icons.group),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => RulesScreen(user: user)),
              );
            },
            child: SectionStub(title: 'Rules', icon: Icons.rule),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => RewardsScreen(user: user)),
              );
            },
            child: SectionStub(title: 'Rewards', icon: Icons.emoji_events),
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
            child: SectionStub(title: 'Consequences', icon: Icons.warning),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ScreenTimeScreen(familyId: user.uid),
                ),
              );
            },
            child: SectionStub(
              title: 'Screen Time Tracking',
              icon: Icons.timer,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ActivityHistoryScreen(),
                ),
              );
            },
            child: SectionStub(title: 'Activity Feed', icon: Icons.history),
          ),
        ],
      ),
    );
  }
}
