import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../views/child_chores_view.dart';
import '../screens/screen_time_screen.dart';

class ChildDashboardScreen extends ConsumerStatefulWidget {
  final String familyId;
  final String childId;
  final String childName;

  const ChildDashboardScreen({
    super.key,
    required this.familyId,
    required this.childId,
    required this.childName,
  });

  @override
  ConsumerState<ChildDashboardScreen> createState() => _ChildDashboardScreenState();
}

class _ChildDashboardScreenState extends ConsumerState<ChildDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      ChildChoresView(
        familyId: widget.familyId,
        childId: widget.childId,
      ),
      // Placeholder for Rewards/Consequences if a specific view exists, 
      // otherwise we can add it later. For now, let's show Screen Time.
      ScreenTimeScreen(
        familyId: widget.familyId,
        initialChildId: widget.childId,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Viewing as ${widget.childName}'),
        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Exit Child View',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.task_alt),
            label: 'Chores',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer),
            label: 'Screen Time',
          ),
        ],
      ),
    );
  }
}
