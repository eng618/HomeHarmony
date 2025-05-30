import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScreentimeScreen extends StatefulWidget {
  final User user;
  const ScreentimeScreen({super.key, required this.user});

  @override
  State<ScreentimeScreen> createState() => _ScreentimeScreenState();
}

class _ScreentimeScreenState extends State<ScreentimeScreen> {
  // TODO: Implement screentime tracking UI and logic
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screentime Tracking')),
      body: const Center(
        child: Text('Screentime tracking feature coming soon!'),
      ),
    );
  }
}
