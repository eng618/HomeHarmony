import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_harmony/screens/home/screen_time_screen.dart';
import '../../views/family_members_view.dart';
import '../../models/child_profile.dart';
import '../../services/family_service.dart';
import '../../widgets/child_profile_form.dart';
import '../../services/auth_service.dart';
import '../../widgets/child_account_form.dart';

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
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: ChildAccountForm(
          onSubmit: (name, age, email, password) async {
            final err = await AuthService.createChildAccount(
              parentUid: widget.user.uid,
              parentEmail: widget.user.email ?? '',
              childName: name,
              childAge: age,
              email: email,
              password: password,
            );
            return err;
          },
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
        builder: (_) => ScreenTimeScreen(
          familyId: widget.user.uid,
          initialChildId: childId,
        ),
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
