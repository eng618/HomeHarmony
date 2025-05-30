import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConsequencesScreen extends StatefulWidget {
  final User user;
  const ConsequencesScreen({super.key, required this.user});

  @override
  State<ConsequencesScreen> createState() => _ConsequencesScreenState();
}

class _ConsequencesScreenState extends State<ConsequencesScreen> {
  // TODO: Implement CRUD and assignment UI (similar to RulesScreen)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consequences')),
      body: const Center(child: Text('Consequences feature coming soon!')),
    );
  }
}
