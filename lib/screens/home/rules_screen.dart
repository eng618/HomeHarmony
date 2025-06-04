import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RulesScreen extends StatefulWidget {
  final User user;
  const RulesScreen({super.key, required this.user});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  Future<List<Map<String, dynamic>>> _fetchChildren() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .collection('children')
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Future<void> _addOrEditRule({DocumentSnapshot? ruleDoc}) async {
    final titleController = TextEditingController(
      text: ruleDoc?.get('title') ?? '',
    );
    final descController = TextEditingController(
      text: ruleDoc?.get('description') ?? '',
    );
    List<String> selectedChildren = List<String>.from(
      ruleDoc?.get('children') ?? [],
    );
    String? error;
    bool loading = false;
    final children = await _fetchChildren();

    if (!mounted) {
      return;
    } // Ensures the widget is still mounted before using its context for showDialog.
    await showDialog(
      // The 'context' passed here is from _RulesScreenState.
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(ruleDoc == null ? 'Add Rule' : 'Edit Rule'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    counterText: '${titleController.text.length}/50',
                  ),
                  maxLength: 50,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    counterText: '${descController.text.length}/200',
                  ),
                  minLines: 1,
                  maxLines: 3,
                  maxLength: 200,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Assign to:',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    if (children.length > 1)
                      Row(
                        children: [
                          Checkbox(
                            value: selectedChildren.length == children.length,
                            tristate: false,
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  selectedChildren = children
                                      .map<String>((c) => c['id'] as String)
                                      .toList();
                                } else {
                                  selectedChildren.clear();
                                }
                              });
                            },
                          ),
                          const SizedBox(width: 4),
                          const Text('Select All'),
                        ],
                      ),
                  ],
                ),
                ...children.map(
                  (child) => CheckboxListTile(
                    value: selectedChildren.contains(child['id']),
                    title: Text(child['name'] ?? 'No name'),
                    subtitle: Text('Age: ${child['age'] ?? 'N/A'}'),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          selectedChildren.add(child['id']);
                        } else {
                          selectedChildren.remove(child['id']);
                        }
                      });
                    },
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!, style: const TextStyle(color: Colors.red)),
                ],
                if (loading) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      final title = titleController.text.trim();
                      final desc = descController.text.trim();
                      if (title.isEmpty || selectedChildren.isEmpty) {
                        setState(() {
                          error = 'Title and at least one child required.';
                        });
                        return;
                      }
                      setState(() {
                        error = null;
                        loading = true;
                      });
                      try {
                        final data = {
                          'title': title,
                          'description': desc,
                          'children': selectedChildren,
                          'createdAt': FieldValue.serverTimestamp(),
                        };
                        if (ruleDoc == null) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.user.uid)
                              .collection('rules')
                              .add(data);
                        } else {
                          await ruleDoc.reference.update(data);
                        }
                        // Don't use BuildContext after an async gap
                        if (!ctx.mounted) return;
                        if (Navigator.of(ctx).canPop()) {
                          Navigator.of(ctx).pop();
                        }
                        setState(() {});
                      } catch (e) {
                        setState(() {
                          error = e.toString();
                          loading = false;
                        });
                      }
                    },
              child: Text(ruleDoc == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
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
                    .collection('users')
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
                                      (c) => (rule['children'] ?? []).contains(
                                        c['id'],
                                      ),
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
