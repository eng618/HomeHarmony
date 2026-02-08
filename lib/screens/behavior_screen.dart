import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/behavior/rules_view.dart';
import '../views/behavior/rewards_view.dart';
import '../views/behavior/consequences_view_tab.dart';
import '../views/behavior/chores_view_tab.dart';

/// Unified Behavior screen with tabs for Rules, Rewards, and Consequences.
class BehaviorScreen extends StatefulWidget {
  final User user;
  const BehaviorScreen({super.key, required this.user});

  @override
  State<BehaviorScreen> createState() => _BehaviorScreenState();
}

class _BehaviorScreenState extends State<BehaviorScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Behavior'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.rule), text: 'Rules'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Rewards'),
            Tab(icon: Icon(Icons.warning), text: 'Consequences'),
            Tab(icon: Icon(Icons.check_circle_outline), text: 'Chores'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RulesView(user: widget.user),
          RewardsView(user: widget.user),
          ConsequencesViewTab(user: widget.user),
          ChoresViewTab(user: widget.user),
        ],
      ),
    );
  }
}
