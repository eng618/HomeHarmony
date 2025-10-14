
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chore_model.dart';
import '../utils/chore_providers.dart';

class ChildChoresView extends ConsumerWidget {
  final String familyId;
  final String childId;

  const ChildChoresView({
    super.key,
    required this.familyId,
    required this.childId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final choresAsync = ref.watch(childChoresProvider((familyId, childId)));
    return choresAsync.when(
      data: (chores) {
        if (chores.isEmpty) {
          return const Center(child: Text('No chores assigned to you.'));
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
                  ],
                ),
                trailing: chore.completed
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : ElevatedButton(
                        onPressed: () {
                          final choreService = ref.read(choreServiceProvider);
                          choreService.updateChore(familyId, chore.id, {'completed': true});
                        },
                        child: const Text('Complete'),
                      ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
