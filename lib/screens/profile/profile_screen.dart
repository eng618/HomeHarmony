import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  Future<DocumentSnapshot<Map<String, dynamic>>> getProfile() async {
    return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  }

  Future<void> _addChildAccount(BuildContext context) async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String? error;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Child Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Child Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
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
                      'parent': user.uid,
                    });
                Navigator.of(ctx).pop();
              } on FirebaseAuthException catch (e) {
                error = e.message;
                // Use StatefulBuilder to update dialog state instead of markNeedsBuild
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: getProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snapshot.data?.data();
        final role = data?['role'] ?? 'unknown';
        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${user.email ?? ''}'),
                const SizedBox(height: 12),
                Text('Role: $role'),
                const SizedBox(height: 24),
                if (role == 'parent') ...[
                  ElevatedButton(
                    onPressed: () => _addChildAccount(context),
                    child: const Text('Add Child Account'),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Children:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('parent', isEqualTo: user.uid)
                        .snapshots(),
                    builder: (context, childSnapshot) {
                      if (childSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(),
                        );
                      }
                      final children = childSnapshot.data?.docs ?? [];
                      if (children.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('No children added.'),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: children.length,
                        itemBuilder: (context, idx) {
                          final child = children[idx].data();
                          return ListTile(
                            leading: const Icon(Icons.child_care),
                            title: Text(child['email'] ?? 'No email'),
                            subtitle: Text('Role: ${child['role'] ?? 'child'}'),
                          );
                        },
                      );
                    },
                  ),
                ],
                ElevatedButton(
                  onPressed: () async {
                    final newRole = role == 'parent' ? 'child' : 'parent';
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .set({
                          'email': user.email,
                          'role': newRole,
                        }, SetOptions(merge: true));
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(user: user),
                      ),
                    );
                  },
                  child: Text(
                    'Switch to ${role == 'parent' ? 'child' : 'parent'} role',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
