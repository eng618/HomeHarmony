
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../chores_view.dart';
import '../../models/child_profile.dart';
import '../../services/family_service.dart';

class ChoresViewTab extends StatefulWidget {
  final User user;
  const ChoresViewTab({super.key, required this.user});

  @override
  State<ChoresViewTab> createState() => _ChoresViewTabState();
}

class _ChoresViewTabState extends State<ChooresViewTab> {
  List<ChildProfile> _children = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    final familyId = widget.user.uid;
    final childrenSnap = await FamilyService().childrenStream(familyId).first;
    setState(() {
      _children = childrenSnap;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manage Chores',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ChoresView(
              familyId: widget.user.uid,
              children: _children,
            ),
          ),
        ],
      ),
    );
  }
}
