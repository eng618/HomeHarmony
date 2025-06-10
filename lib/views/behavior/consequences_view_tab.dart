// This file is now a view for the Consequences tab in the Behavior screen.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../manual_consequence_view.dart';
import '../consequences_view.dart';
import '../../models/child_profile.dart';
import '../../models/rule_model.dart';
import '../../services/family_service.dart';

class ConsequencesViewTab extends StatefulWidget {
  final User user;
  const ConsequencesViewTab({super.key, required this.user});

  @override
  State<ConsequencesViewTab> createState() => _ConsequencesViewTabState();
}

class _ConsequencesViewTabState extends State<ConsequencesViewTab> {
  List<ChildProfile> _children = [];
  List<Rule> _rules = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchChildrenAndRules();
  }

  Future<void> _fetchChildrenAndRules() async {
    final familyId = widget.user.uid;
    final childrenSnap = await FamilyService().childrenStream(familyId).first;
    final rulesSnap = await FamilyService().rulesStream(familyId).first;
    setState(() {
      _children = childrenSnap;
      _rules = rulesSnap;
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
          ManualConsequenceView(familyId: widget.user.uid, children: _children),
          const SizedBox(height: 32),
          Divider(thickness: 2),
          const SizedBox(height: 24),
          const Text(
            'Saved Consequences',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ConsequencesView(
              familyId: widget.user.uid,
              children: _children,
              rules: _rules,
            ),
          ),
        ],
      ),
    );
  }
}
