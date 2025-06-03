import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_harmony/screens/home/screen_time_screen.dart';
import '../../views/family_members_view.dart';
import '../../models/child_profile.dart';
import '../../services/family_service.dart';
import '../../widgets/child_profile_form.dart';

class FamilyMembersScreen extends StatefulWidget {
  final User user;
  const FamilyMembersScreen({super.key, required this.user});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  final FamilyService _familyService = FamilyService();

  Future<void> _addChildProfile(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => ChildProfileForm(
        title: 'Add Child Profile',
        actionText: 'Add',
        onSubmit: (name, age, profileType, profilePicture) async {
          await _familyService.addChildProfile(
            familyId: widget.user.uid,
            name: name,
            age: age,
            profileType: profileType,
            parentId: widget.user.uid,
            profilePicture: profilePicture,
          );
        },
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
                            .collection('families')
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

  void _editChild(BuildContext context, ChildProfile child) async {
    await showDialog(
      context: context,
      builder: (ctx) => ChildProfileForm(
        title: 'Edit Child Profile',
        actionText: 'Save',
        initialName: child.name,
        initialAge: child.age,
        initialProfileType: child.profileType,
        initialProfilePicture: child.profilePicture,
        onSubmit: (name, age, profileType, profilePicture) async {
          await _familyService.updateChildProfile(
            familyId: widget.user.uid,
            childId: child.id,
            name: name,
            age: age,
            profileType: profileType,
            profilePicture: profilePicture,
          );
        },
      ),
    );
  }

  void _deleteChild(
    BuildContext context,
    String childId,
    String childName,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Child Profile'),
        content: Text('Are you sure you want to delete "$childName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      if (!context.mounted) return;
      await _familyService.deleteChildProfile(
        familyId: widget.user.uid,
        childId: childId,
      );
    }
  }

  void _onSelectChild(String childId, String childName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ScreenTimeScreen(familyId: widget.user.uid, childId: childId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Members')),
      body: FamilyMembersView(
        familyId: widget.user.uid,
        onAddChildProfile: _addChildProfile,
        onAddChildAccount: _addChildAccount,
        onEditChild: (ctx, child) => _editChild(ctx, child),
        onDeleteChild: (ctx, childId, childName) =>
            _deleteChild(ctx, childId, childName),
        onSelectChild: _onSelectChild,
      ),
    );
  }
}
