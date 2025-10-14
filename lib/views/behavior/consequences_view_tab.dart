import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../manual_consequence_view.dart';
import '../consequences_view.dart';
import '../../models/child_profile.dart';
import '../../models/rule_model.dart';
import '../../models/consequence_model.dart';
import '../../services/family_service.dart';
import '../../services/consequence_service.dart';
import '../../widgets/consequence_form.dart';

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

  void _showConsequenceForm(BuildContext context, {Consequence? consequence}) {
    showDialog(
      context: context,
      builder: (context) {
        return ConsequenceForm(
          children: _children,
          rules: _rules,
          isEdit: consequence != null,
          initialTitle: consequence?.title,
          initialDescription: consequence?.description,
          initialDeductionMinutes: consequence?.deductionMinutes,
          initialAssignedChildren: consequence?.assignedChildren ?? [],
          initialLinkedRules: consequence?.linkedRules ?? [],
          onCancel: () => Navigator.of(context).pop(),
          onSubmit: (title, description, deductionMinutes, assignedChildren, linkedRules) {
            final consequenceService = ConsequenceService();
            final userId = widget.user.uid;
            if (consequence == null) {
              final newConsequence = Consequence(
                id: '', // Firestore will generate this
                title: title,
                description: description,
                deductionMinutes: deductionMinutes,
                assignedChildren: assignedChildren,
                linkedRules: linkedRules,
                createdBy: userId,
                createdAt: Timestamp.now(),
              );
              consequenceService.addConsequence(widget.user.uid, newConsequence);
            } else {
              consequenceService.updateConsequence(widget.user.uid, consequence.id, {
                'title': title,
                'description': description,
                'deduction_minutes': deductionMinutes,
                'assigned_children': assignedChildren,
                'linked_rules': linkedRules,
              });
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _deleteConsequence(BuildContext context, Consequence consequence) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Consequence'),
          content: Text('Are you sure you want to delete "${consequence.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final consequenceService = ConsequenceService();
                consequenceService.deleteConsequence(widget.user.uid, consequence.id);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
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
              onAdd: () => _showConsequenceForm(context),
              onEdit: (consequence) => _showConsequenceForm(context, consequence: consequence),
              onDelete: (consequence) => _deleteConsequence(context, consequence),
            ),
          ),
        ],
      ),
    );
  }
}
