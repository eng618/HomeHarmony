import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/consequence_model.dart';
import '../../services/consequence_service.dart';
import '../../widgets/consequence_form.dart';
import '../../views/consequences_view.dart';

class ConsequencesScreen extends ConsumerStatefulWidget {
  final User user;
  const ConsequencesScreen({super.key, required this.user});

  @override
  ConsumerState<ConsequencesScreen> createState() => _ConsequencesScreenState();
}

class _ConsequencesScreenState extends ConsumerState<ConsequencesScreen> {
  List<Map<String, dynamic>> _children = [];
  List<Map<String, dynamic>> _rules = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchChildrenAndRules();
  }

  Future<void> _fetchChildrenAndRules() async {
    final familyId = widget.user.uid;
    final childrenSnap = await FirebaseFirestore.instance
        .collection('families')
        .doc(familyId)
        .collection('children')
        .orderBy('created_at', descending: false)
        .get();
    final rulesSnap = await FirebaseFirestore.instance
        .collection('families')
        .doc(familyId)
        .collection('rules')
        .orderBy('created_at', descending: false)
        .get();
    setState(() {
      _children = childrenSnap.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
      _rules = rulesSnap.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
      _loading = false;
    });
  }

  void _showConsequenceForm({Consequence? consequence}) async {
    await showDialog(
      context: context,
      builder: (ctx) => ConsequenceForm(
        initialTitle: consequence?.title,
        initialDescription: consequence?.description,
        initialDeductionMinutes: consequence?.deductionMinutes,
        initialAssignedChildren: consequence?.assignedChildren ?? [],
        initialLinkedRules: consequence?.linkedRules ?? [],
        children: _children,
        rules: _rules,
        isEdit: consequence != null,
        onCancel: () => Navigator.of(ctx).pop(),
        onSubmit: (title, desc, deduction, assignedChildren, linkedRules) async {
          // Pop the dialog using its own context (ctx) before the async operations.
          Navigator.of(ctx).pop();

          final familyId = widget.user.uid;
          final service = ConsequenceService();
          if (consequence == null) {
            await service.addConsequence(
              familyId,
              Consequence(
                id: '',
                title: title,
                description: desc,
                deductionMinutes: deduction,
                assignedChildren: assignedChildren,
                linkedRules: linkedRules,
                appliedAt: null,
                appliedTo: null,
                createdAt: Timestamp.now(),
                createdBy: familyId,
              ),
            );
          } else {
            await service.updateConsequence(familyId, consequence.id, {
              'title': title,
              'description': desc,
              'deduction_minutes': deduction,
              'assigned_children': assignedChildren,
              'linked_rules': linkedRules,
            });
          }
          if (mounted) {
            _fetchChildrenAndRules();
          }
        },
      ),
    );
  }

  void _deleteConsequence(Consequence c) async {
    final familyId = widget.user.uid;
    final service = ConsequenceService();
    await service.deleteConsequence(familyId, c.id);
    _fetchChildrenAndRules();
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
        child: ConsequencesView(
          familyId: widget.user.uid,
          children: _children,
          rules: _rules,
          onAdd: () => _showConsequenceForm(),
          onEdit: (c) => _showConsequenceForm(consequence: c),
          onDelete: _deleteConsequence,
        ),
      ),
    );
  }
}
