// This file is now a view for the Rules tab in the Behavior screen.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../widgets/rule_dialog.dart';
import '../../../models/rule_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/family_providers.dart';

class RulesView extends ConsumerStatefulWidget {
  final User user;
  const RulesView({super.key, required this.user});

  @override
  ConsumerState<RulesView> createState() => _RulesViewState();
}

class _RulesViewState extends ConsumerState<RulesView> {
  // FamilyService is now accessed via provider

  Future<List<Map<String, dynamic>>> _fetchChildren() async {
    final familyService = ref.read(familyServiceProvider);
    return familyService.getChildren(widget.user.uid);
  }

  Future<void> _addOrEditRule({Rule? rule}) async {
    final children = await _fetchChildren();
    if (!mounted) return;

    String initialTitle = rule?.title ?? '';
    String initialDescription = rule?.description ?? '';
    List<String> initialAssigned = rule?.assignedChildren ?? [];

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) => RuleDialog(
            initialTitle: initialTitle,
            initialDescription: initialDescription,
            initialAssignedChildren: initialAssigned,
            children: children,
            isEdit: rule != null,
            onCancel: () {
              Navigator.of(ctx).pop();
            },
            onSubmit: (title, desc, assignedChildren) async {
              try {
                Navigator.of(ctx).pop();

                final familyService = ref.read(familyServiceProvider);
                if (rule == null) {
                  await familyService.addRule(
                    familyId: widget.user.uid,
                    title: title,
                    description: desc,
                    assignedChildren: assignedChildren,
                    createdBy: widget.user.uid,
                  );
                } else {
                  await familyService.updateRule(
                    familyId: widget.user.uid,
                    ruleId: rule.id,
                    title: title,
                    description: desc,
                    assignedChildren: assignedChildren,
                  );
                }
                if (mounted) {
                  setState(() {});
                }
              } catch (e) {
                // Error state is handled by RuleDialog's Riverpod providers
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: () => _addOrEditRule(),
            child: const Text('Add Rule'),
          ),
          const SizedBox(height: 24),
          const Text('Rules:', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: StreamBuilder<List<Rule>>(
              stream: ref.watch(familyServiceProvider).rulesStream(widget.user.uid),
              builder: (context, ruleSnapshot) {
                if (ruleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final rules = ruleSnapshot.data ?? [];
                if (rules.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('No rules added.'),
                  );
                }
                return ListView.builder(
                  itemCount: rules.length,
                  itemBuilder: (context, idx) {
                    final rule = rules[idx];
                    return ListTile(
                      leading: const Icon(Icons.rule),
                      title: Text(
                        rule.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (rule.description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 2.0,
                                bottom: 2.0,
                              ),
                              child: Text(
                                rule.description,
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _fetchChildren(),
                            builder: (context, childSnap) {
                              if (!childSnap.hasData) return const SizedBox();
                              final assigned = childSnap.data!
                                  .where(
                                    (c) => rule.assignedChildren
                                        .contains(c['id']),
                                  )
                                  .map((c) => c['name'])
                                  .join(', ');
                              return Text('Assigned to: $assigned');
                            },
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: 'Edit',
                            onPressed: () => _addOrEditRule(rule: rule),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: 'Delete',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Rule'),
                                  content: Text(
                                    'Are you sure you want to delete "${rule.title}"?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                final familyService = ref.read(familyServiceProvider);
                                await familyService.deleteRule(
                                  familyId: widget.user.uid,
                                  ruleId: rule.id,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
