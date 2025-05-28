import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FamilyMembersScreen extends StatefulWidget {
  final User user;
  const FamilyMembersScreen({super.key, required this.user});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  Future<void> _addChildProfile(BuildContext context) async {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    String? error;
    bool loading = false;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add Child Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Child Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
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
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      final name = nameController.text.trim();
                      final age = int.tryParse(ageController.text.trim());
                      if (name.isEmpty || age == null) {
                        setState(() {
                          error = 'Please enter a valid name and age.';
                        });
                        return;
                      }
                      setState(() {
                        error = null;
                        loading = true;
                      });
                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.user.uid)
                            .collection('children')
                            .add({
                              'name': name,
                              'age': age,
                              'createdAt': FieldValue.serverTimestamp(),
                            });
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
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addChildAccount(BuildContext context) async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String? error;
    bool loading = false;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add Child Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Child Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
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
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      setState(() {
                        error = null;
                        loading = true;
                      });
                      try {
                        final cred = await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            );
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(cred.user!.uid)
                            .set({
                              'email': cred.user!.email,
                              'role': 'child',
                              'parent': widget.user.uid,
                            });
                        // Don't use BuildContext after an async gap
                        if (!ctx.mounted) return;
                        if (Navigator.of(ctx).canPop()) {
                          Navigator.of(ctx).pop();
                        }
                        setState(() {});
                      } on FirebaseAuthException catch (e) {
                        setState(() {
                          error = e.message;
                          loading = false;
                        });
                      }
                    },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Members')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () => _addChildProfile(context),
              child: const Text('Add Child Profile'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _addChildAccount(context),
              child: const Text('Add Child Account (email)'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Children:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.user.uid)
                    .collection('children')
                    .orderBy('createdAt', descending: false)
                    .snapshots(),
                builder: (context, childSnapshot) {
                  if (childSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final children = childSnapshot.data?.docs ?? [];
                  if (children.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('No children added.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: children.length,
                    itemBuilder: (context, idx) {
                      final childDoc = children[idx];
                      final child = childDoc.data();
                      return ListTile(
                        leading: const Icon(Icons.child_care),
                        title: Text(child['name'] ?? 'No name'),
                        subtitle: Text('Age: ${child['age'] ?? 'N/A'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Edit',
                              onPressed: () async {
                                final nameController = TextEditingController(
                                  text: child['name'] ?? '',
                                );
                                final ageController = TextEditingController(
                                  text: child['age']?.toString() ?? '',
                                );
                                String? error;
                                bool loading = false;
                                await showDialog(
                                  context: context,
                                  builder: (ctx) => StatefulBuilder(
                                    builder: (ctx, setState) => AlertDialog(
                                      title: const Text('Edit Child Profile'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            controller: nameController,
                                            decoration: const InputDecoration(
                                              labelText: 'Child Name',
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          TextField(
                                            controller: ageController,
                                            decoration: const InputDecoration(
                                              labelText: 'Age',
                                            ),
                                            keyboardType: TextInputType.number,
                                          ),
                                          if (error != null) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              error!,
                                              style: const TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                          if (loading) ...[
                                            const SizedBox(height: 16),
                                            const CircularProgressIndicator(),
                                          ],
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: loading
                                              ? null
                                              : () => Navigator.of(ctx).pop(),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: loading
                                              ? null
                                              : () async {
                                                  final newName = nameController
                                                      .text
                                                      .trim();
                                                  final newAge = int.tryParse(
                                                    ageController.text.trim(),
                                                  );
                                                  if (newName.isEmpty ||
                                                      newAge == null) {
                                                    setState(() {
                                                      error =
                                                          'Please enter a valid name and age.';
                                                    });
                                                    return;
                                                  }
                                                  setState(() {
                                                    error = null;
                                                    loading = true;
                                                  });
                                                  try {
                                                    await childDoc.reference
                                                        .update({
                                                          'name': newName,
                                                          'age': newAge,
                                                        });
                                                    // Don't use BuildContext after an async gap
                                                    if (!ctx.mounted) return;
                                                    if (Navigator.of(
                                                      ctx,
                                                    ).canPop()) {
                                                      Navigator.of(ctx).pop();
                                                    }
                                                  } catch (e) {
                                                    setState(() {
                                                      error = e.toString();
                                                      loading = false;
                                                    });
                                                  }
                                                },
                                          child: const Text('Save'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: 'Delete',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Child Profile'),
                                    content: Text(
                                      'Are you sure you want to delete "${child['name']}"?',
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
                                  // Don't use BuildContext after an async gap
                                  if (!context.mounted) return;
                                  await childDoc.reference.delete();
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
