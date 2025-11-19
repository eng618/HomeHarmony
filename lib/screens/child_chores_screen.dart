
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/child_chores_view.dart';
import '../utils/user_provider.dart';

class ChildChoresScreen extends ConsumerStatefulWidget {
  final User user;
  const ChildChoresScreen({super.key, required this.user});

  @override
  ConsumerState<ChildChoresScreen> createState() => _ChildChoresScreenState();
}

class _ChildChoresScreenState extends ConsumerState<ChildChoresScreen> {
  @override
  Widget build(BuildContext context) {
    final userModelAsync = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Chores')),
      body: userModelAsync.when(
        data: (userModel) {
          if (userModel == null) {
            return const Center(child: Text('User not found.'));
          }
          final familyId = userModel.role == 'child' ? userModel.parent : userModel.uid;
          if (familyId == null) {
            return const Center(child: Text('Family not found.'));
          }
          return ChildChoresView(
            familyId: familyId,
            childId: widget.user.uid,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
