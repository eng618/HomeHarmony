import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/consequence_model.dart';
import '../models/child_profile.dart';
import '../models/rule_model.dart';
import '../utils/consequence_providers.dart';
import '../services/screen_time_service.dart';
import '../services/activity_log_service.dart';
import '../models/activity_log_model.dart';

/// Top-level view for listing and managing consequences for a family.
class ConsequencesView extends ConsumerWidget {
  final String familyId;
  final List<ChildProfile> children;
  final List<Rule> rules;
  final void Function(Consequence consequence)? onEdit;
  final void Function(Consequence consequence)? onDelete;
  final void Function()? onAdd;

  const ConsequencesView({
    super.key,
    required this.familyId,
    required this.children,
    required this.rules,
    this.onEdit,
    this.onDelete,
    this.onAdd,
  });

  void _applyConsequence(BuildContext context, WidgetRef ref, Consequence consequence) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Apply Consequence'),
          content: DropdownButtonFormField<String>(
            hint: const Text('Select a child'),
            items: children
                .map((child) => DropdownMenuItem(
                      value: child.id,
                      child: Text(child.name),
                    ))
                .toList(),
            onChanged: (childId) {
              if (childId != null) {
                final screenTimeService = ScreenTimeService();
                final consequenceService = ref.read(consequenceServiceProvider);

                screenTimeService.addScreenTime(
                  familyId: familyId,
                  childId: childId,
                  minutes: -consequence.deductionMinutes,
                );

                consequenceService.updateConsequence(familyId, consequence.id, {
                  'appliedAt': Timestamp.now(),
                  'appliedTo': childId,
                });

                final activityLogService = ref.read(activityLogServiceProvider);
                final user = FirebaseAuth.instance.currentUser;
                final child = children.firstWhere((c) => c.id == childId);
                final log = ActivityLog(
                  id: '',
                  timestamp: Timestamp.now(),
                  userId: user!.uid,
                  type: 'consequence',
                  description: '${consequence.title} consequence applied to ${child.name}.',
                  familyId: familyId,
                );
                activityLogService.addActivityLog(log);

                Navigator.of(context).pop();
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consequencesAsync = ref.watch(consequencesProvider(familyId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Consequence'),
              onPressed: onAdd,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: consequencesAsync.when(
            data: (consequences) {
              if (consequences.isEmpty) {
                return const Center(child: Text('No consequences added.'));
              }
              return ListView.builder(
                itemCount: consequences.length,
                itemBuilder: (context, idx) {
                  final c = consequences[idx];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.warning_amber_rounded),
                      title: Text(c.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.description),
                          Text('Deduction: ${c.deductionMinutes} min'),
                          if (c.linkedRules.isNotEmpty)
                            Text(
                              'Linked rules: ${c.linkedRules.map((ruleId) => rules.firstWhere(
                                (r) => r.id == ruleId,
                                orElse: () => Rule(id: ruleId, title: ruleId, description: '', assignedChildren: [], createdBy: '', createdAt: null),
                              ).title).join(", ")}',
                            ),
                          if (c.appliedTo != null)
                            Text('Applied to: ${children.firstWhere((child) => child.id == c.appliedTo, orElse: () => ChildProfile(id: c.appliedTo!, name: 'Unknown', parentId: '', avatar: '')).name}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.send),
                            tooltip: 'Apply',
                            onPressed: () => _applyConsequence(context, ref, c),
                            semanticLabel: 'Apply this consequence to a child',
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: 'Edit',
                            onPressed: onEdit != null ? () => onEdit!(c) : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: 'Delete',
                            onPressed: onDelete != null
                                ? () => onDelete!(c)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }
}
