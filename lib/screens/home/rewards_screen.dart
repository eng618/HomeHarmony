import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RewardsScreen extends StatefulWidget {
  final User user;
  const RewardsScreen({super.key, required this.user});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  // TODO: Implement CRUD and assignment UI (similar to RulesScreen)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rewards')),
      body: const Center(child: Text('Rewards feature coming soon!')),
    );
  }
}
