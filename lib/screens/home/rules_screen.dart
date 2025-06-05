import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/rule_dialog.dart';

class RulesScreen extends StatefulWidget {
  final User user;
  const RulesScreen({super.key, required this.user});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  // Fetch children from the new schema: families/{familyId}/children
  Future<List<Map<String, dynamic>>> _fetchChildren() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('families')
        .doc(widget.user.uid)
        .collection('children')
        .orderBy('created_at', descending: false)
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Future<void> _addOrEditRule({DocumentSnapshot? ruleDoc}) async {
    final children = await _fetchChildren();
    String initialTitle = ruleDoc?.get('title') ?? '';
    String initialDescription = ruleDoc?.get('description') ?? '';
    List<String> initialAssigned = List<String>.from(
      ruleDoc?.get('assigned_children') ?? [],
    );
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
            isEdit: ruleDoc != null,
            onCancel: () {
              Navigator.of(ctx).pop();
            },
            onSubmit: (title, desc, assignedChildren) async {
              try {
                final data = {
                  'title': title,
                  'description': desc,
                  'assigned_children': assignedChildren,
                  'created_at': FieldValue.serverTimestamp(),
                  'created_by': widget.user.uid,
                };
                final rulesRef = FirebaseFirestore.instance
                    .collection('families')
                    .doc(widget.user.uid)
                    .collection('rules');
                if (ruleDoc == null) {
                  await rulesRef.add(data);
                } else {
                  await ruleDoc.reference.update(data);
                }
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                setState(() {});
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
    return Scaffold(
      appBar: AppBar(title: const Text('Rules')),
      body: Padding(
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
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('families')
                    .doc(widget.user.uid)
                    .collection('rules')
                    .orderBy('created_at', descending: false)
                    .snapshots(),
                builder: (context, ruleSnapshot) {
                  if (ruleSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final rules = ruleSnapshot.data?.docs ?? [];
                  if (rules.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('No rules added.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: rules.length,
                    itemBuilder: (context, idx) {
                      final ruleDoc = rules[idx];
                      final rule = ruleDoc.data();
                      return ListTile(
                        leading: const Icon(Icons.rule),
                        title: Text(
                          rule['title'] ?? 'No title',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((rule['description'] ?? '').isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 2.0,
                                  bottom: 2.0,
                                ),
                                child: Text(
                                  rule['description'],
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
                                      (c) => (rule['assigned_children'] ?? [])
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
                              onPressed: () => _addOrEditRule(ruleDoc: ruleDoc),
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
                                      'Are you sure you want to delete "${rule['title']}"?',
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
                                  await ruleDoc.reference.delete();
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
      ),
    );
  }
}
