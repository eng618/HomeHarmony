import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/family_members/family_members_screen.dart';
import '../screens/rules/rules_screen.dart';
import '../screens/rewards/rewards_screen.dart';
import '../screens/consequences/consequences_screen.dart';
import '../screens/screen_time/screen_time_screen.dart';
import '../screens/activity/activity_history_screen.dart';
import '../screens/profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  final User user;
  const MainShell({super.key, required this.user});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      FamilyMembersScreen(user: widget.user),
      RulesScreen(user: widget.user),
      RewardsScreen(user: widget.user),
      ConsequencesScreen(user: widget.user),
      ScreenTimeScreen(familyId: widget.user.uid),
      ActivityHistoryScreen(),
      ProfileScreen(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.group), label: 'Family'),
          NavigationDestination(icon: Icon(Icons.rule), label: 'Rules'),
          NavigationDestination(
            icon: Icon(Icons.emoji_events),
            label: 'Rewards',
          ),
          NavigationDestination(
            icon: Icon(Icons.warning),
            label: 'Consequences',
          ),
          NavigationDestination(icon: Icon(Icons.timer), label: 'Screen Time'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Activity'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
