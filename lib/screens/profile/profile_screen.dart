import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  final VoidCallback? onOpenSettings;
  const ProfileScreen({super.key, required this.user, this.onOpenSettings});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DocumentSnapshot<Map<String, dynamic>>? _cachedProfile;
  bool _loading = false;
  bool _signingOut = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    debugPrint('Fetching profile for user: \\${widget.user.uid}');
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();
      debugPrint('Firestore document snapshot: \\${doc.data()}');
      setState(() {
        _cachedProfile = doc;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error fetching profile: \\${e.toString()}');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _refreshProfile() async {
    await _fetchProfile();
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
                        // Re-authenticate as parent after creating child (if needed)
                        final parentEmail = widget.user.email;
                        final parentProvider =
                            widget.user.providerData.isNotEmpty
                            ? widget.user.providerData.first.providerId
                            : 'password';
                        if (parentEmail != null &&
                            parentProvider == 'password') {
                          // Prompt for parent password if needed, or use a secure method to re-authenticate
                          // For now, just sign out the child and sign back in as parent
                          await FirebaseAuth.instance.signOut();
                        }
                        // Ensure dialog is only popped if still mounted
                        if (Navigator.of(ctx).canPop()) {
                          Navigator.of(ctx).pop();
                        }
                        await _refreshProfile(); // Refresh cached profile after adding child
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
              const SizedBox(height: 12),
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
                        if (Navigator.of(ctx).canPop()) {
                          Navigator.of(ctx).pop();
                        }
                        await _refreshProfile();
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Could not load profile. Please check your connection or try again later.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.home),
                  label: const Text('Back to Home'),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  onPressed: _refreshProfile,
                ),
              ],
            ),
          ),
        ),
      );
    }
    final data = _cachedProfile?.data();
    final role = data?['role'] ?? 'unknown';
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Settings',
                onPressed: widget.onOpenSettings,
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sign Out',
                onPressed: _signingOut
                    ? null
                    : () async {
                        setState(() => _signingOut = true);
                        try {
                          await FirebaseAuth.instance.signOut();
                        } catch (e) {
                          setState(() => _signingOut = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Sign out failed: \\${e.toString()}',
                              ),
                            ),
                          );
                        }
                      },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refreshProfile,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                children: [
                  Text('Email: ${widget.user.email ?? ''}'),
                  const SizedBox(height: 12),
                  Text('Role: $role'),
                  const SizedBox(height: 24),
                  if (role == 'parent') ...[
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
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.user.uid)
                          .collection('children')
                          .orderBy('createdAt', descending: false)
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
                          physics: const NeverScrollableScrollPhysics(),
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
                                      final nameController =
                                          TextEditingController(
                                            text: child['name'] ?? '',
                                          );
                                      final ageController =
                                          TextEditingController(
                                            text:
                                                child['age']?.toString() ?? '',
                                          );
                                      String? error;
                                      bool loading = false;
                                      await showDialog(
                                        context: context,
                                        builder: (ctx) => StatefulBuilder(
                                          builder: (ctx, setState) => AlertDialog(
                                            title: const Text(
                                              'Edit Child Profile',
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextField(
                                                  controller: nameController,
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: 'Child Name',
                                                      ),
                                                ),
                                                TextField(
                                                  controller: ageController,
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: 'Age',
                                                      ),
                                                  keyboardType:
                                                      TextInputType.number,
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
                                                    : () => Navigator.of(
                                                        ctx,
                                                      ).pop(),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: loading
                                                    ? null
                                                    : () async {
                                                        final newName =
                                                            nameController.text
                                                                .trim();
                                                        final newAge =
                                                            int.tryParse(
                                                              ageController.text
                                                                  .trim(),
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
                                                          await childDoc
                                                              .reference
                                                              .update({
                                                                'name': newName,
                                                                'age': newAge,
                                                              });
                                                          if (Navigator.of(
                                                            ctx,
                                                          ).canPop()) {
                                                            Navigator.of(
                                                              ctx,
                                                            ).pop();
                                                          }
                                                          await _refreshProfile();
                                                        } catch (e) {
                                                          setState(() {
                                                            error = e
                                                                .toString();
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
                                          title: const Text(
                                            'Delete Child Profile',
                                          ),
                                          content: Text(
                                            'Are you sure you want to delete \\"${child['name']}\\"?',
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
                                        await childDoc.reference.delete();
                                        await _refreshProfile();
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
                  ],
                ],
              ),
            ),
          ),
        ),
        if (_signingOut)
          Container(
            color: Colors.black54,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
