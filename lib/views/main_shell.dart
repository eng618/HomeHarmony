import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/family_members_screen.dart';
import '../screens/screen_time_screen.dart';
import '../screens/activity_history_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/child_chores_screen.dart';
import 'behavior_screen.dart';
import '../utils/user_provider.dart';

class MainShell extends ConsumerStatefulWidget {
  final User user;
  const MainShell({super.key, required this.user});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userModelAsync = ref.watch(userProvider);

    return userModelAsync.when(
      data: (userModel) {
        if (userModel == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final bool isChild = userModel.role == 'child';

        final List<Widget> screens = isChild
            ? [
                ChildChoresScreen(user: widget.user),
                ScreenTimeScreen(familyId: userModel.parent ?? widget.user.uid),
                ActivityHistoryScreen(),
                ProfileScreen(user: widget.user),
              ]
            : [
                FamilyMembersScreen(user: widget.user),
                BehaviorScreen(user: widget.user),
                ScreenTimeScreen(familyId: widget.user.uid),
                ActivityHistoryScreen(),
                ProfileScreen(user: widget.user),
              ];

        final List<NavigationDestination> destinations = isChild
            ? const [
                NavigationDestination(icon: Icon(Icons.check_circle_outline), label: 'Chores'),
                NavigationDestination(icon: Icon(Icons.timer), label: 'Screen Time'),
                NavigationDestination(icon: Icon(Icons.history), label: 'Activity'),
                NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
              ]
            : const [
                NavigationDestination(icon: Icon(Icons.group), label: 'Family'),
                NavigationDestination(icon: Icon(Icons.extension), label: 'Behavior'),
                NavigationDestination(icon: Icon(Icons.timer), label: 'Screen Time'),
                NavigationDestination(icon: Icon(Icons.history), label: 'Activity'),
                NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
              ];

        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => _selectedIndex = index),
            destinations: destinations,
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}
