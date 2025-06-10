import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../views/manual_consequence_view.dart';
import '../../views/consequences_view.dart';
import '../../models/child_profile.dart';
import '../../models/rule_model.dart';
import '../../services/family_service.dart';

/// Thin route for the Consequences screen. Wires together manual deduction and consequences list views.
class ConsequencesScreen extends ConsumerStatefulWidget {
  final User user;
  const ConsequencesScreen({super.key, required this.user});

  @override
  ConsumerState<ConsequencesScreen> createState() => _ConsequencesScreenState();
}

class _ConsequencesScreenState extends ConsumerState<ConsequencesScreen> {
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Consequences')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ManualConsequenceView(
              familyId: widget.user.uid,
              children: _children,
            ),
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
      ),
    );
  }
}
