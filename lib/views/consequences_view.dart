import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/consequence_model.dart';
import '../utils/consequence_providers.dart';

/// Top-level view for listing and managing consequences for a family.
class ConsequencesView extends ConsumerWidget {
  final String familyId;
  final List<Map<String, dynamic>> children;
  final List<Map<String, dynamic>> rules;
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
                              'Linked rules: ${c.linkedRules.map((ruleId) => rules.firstWhere((r) => r['id'] == ruleId, orElse: () => {'title': ruleId})['title'] ?? ruleId).join(", ")}',
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
