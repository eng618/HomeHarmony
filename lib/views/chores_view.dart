
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chore_model.dart';
import '../models/child_profile.dart';
import '../utils/chore_providers.dart';
import '../widgets/chore_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/screen_time_service.dart';

class ChoresView extends ConsumerWidget {
  final String familyId;
  final List<ChildProfile> children;

  const ChoresView({
    super.key,
    required this.familyId,
    required this.children,
  });

  void _showChoreForm(BuildContext context, WidgetRef ref, {Chore? chore}) {
    showDialog(
      context: context,
      builder: (context) {
        return ChoreForm(
          children: children,
          isEdit: chore != null,
          initialTitle: chore?.title,
          initialDescription: chore?.description,
          initialValue: chore?.value,
          initialAssignedChildren: chore?.assignedChildren ?? [],
          onCancel: () => Navigator.of(context).pop(),
          onSubmit: (title, description, value, assignedChildren) {
            final choreService = ref.read(choreServiceProvider);
            final userId = FirebaseAuth.instance.currentUser!.uid;
            if (chore == null) {
              final newChore = Chore(
                id: '', // Firestore will generate this
                title: title,
                description: description,
                value: value,
                assignedChildren: assignedChildren,
                createdBy: userId,
                createdAt: Timestamp.now(),
              );
              choreService.addChore(familyId, newChore);
            } else {
              choreService.updateChore(familyId, chore.id, {
                'title': title,
                'description': description,
                'value': value,
                'assigned_children': assignedChildren,
              });
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final choresAsync = ref.watch(choresProvider(familyId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Chore'),
              onPressed: () => _showChoreForm(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: choresAsync.when(
            data: (chores) {
              if (chores.isEmpty) {
                return const Center(child: Text('No chores added.'));
              }
              return ListView.builder(
                itemCount: chores.length,
                itemBuilder: (context, idx) {
                  final chore = chores[idx];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(chore.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(chore.description),
                          Text('Value: ${chore.value} min'),
                          if (chore.assignedChildren.isNotEmpty)
                            Text(
                              'Assigned to: ${chore.assignedChildren.map((childId) => children.firstWhere(
                                (c) => c.id == childId,
                                orElse: () => ChildProfile(id: childId, name: 'Unknown', parentId: '', avatar: ''),
                              ).name).join(", ")}',
                            ),
                           if (chore.completed)
                            Text(chore.approved ? 'Status: Approved' : 'Status: Pending Approval'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (chore.completed && !chore.approved)
                            ElevatedButton(
                              onPressed: () {
                                final choreService = ref.read(choreServiceProvider);
                                final screenTimeService = ScreenTimeService();
                                choreService.updateChore(familyId, chore.id, {'approved': true});
                                for (var childId in chore.assignedChildren) {
                                  screenTimeService.addScreenTime(familyId, childId, chore.value);
                                }
                              },
                              child: const Text('Approve'),
                            ),
                          if (chore.completed && !chore.approved)
                            TextButton(
                              onPressed: () {
                                final choreService = ref.read(choreServiceProvider);
                                choreService.updateChore(familyId, chore.id, {'completed': false});
                              },
                              child: const Text('Reject'),
                            ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: 'Edit',
                            onPressed: () => _showChoreForm(context, ref, chore: chore),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: 'Delete',
                            onPressed: () {
                              final choreService = ref.read(choreServiceProvider);
                              choreService.deleteChore(familyId, chore.id);
                            },
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
