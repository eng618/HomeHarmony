import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_harmony/screens/screen_time_screen.dart';
import '../screens/child_dashboard_screen.dart';
import '../controllers/child_details_controller.dart';
import '../utils/chore_providers.dart';
import '../models/chore_model.dart';
import '../models/child_details.dart';
import '../services/auth_service.dart';

class ChildDetailsView extends ConsumerStatefulWidget {
  final String familyId;
  final String childId;

  const ChildDetailsView({
    super.key,
    required this.familyId,
    required this.childId,
  });

  @override
  ConsumerState<ChildDetailsView> createState() => _ChildDetailsViewState();
}

class _ChildDetailsViewState extends ConsumerState<ChildDetailsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(childDetailsControllerProvider.notifier)
          .loadChildDetails(widget.familyId, widget.childId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(childDetailsControllerProvider);
    final controller = ref.read(childDetailsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.details?.name ?? 'Child Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer_outlined),
            tooltip: 'Manage Screen Time',
            onPressed: state.details == null
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ScreenTimeScreen(
                          familyId: widget.familyId,
                          initialChildId: widget.childId,
                        ),
                      ),
                    );
                  },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            controller.loadChildDetails(widget.familyId, widget.childId),
        child: Builder(
          builder: (context) {
            if (state.isLoading && state.details == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null && state.details == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: ${state.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            if (state.details == null) {
              return const Center(child: Text('No child details found.'));
            }
            final details = state.details!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ProfileSection(
                  details: details,
                  familyId: widget.familyId,
                  childId: widget.childId,
                ),
                const SizedBox(height: 24),
                _ChoresSection(
                  familyId: widget.familyId,
                  childId: widget.childId,
                ),
                const SizedBox(height: 24),
                _ExpandablePanel(
                  title: 'Assigned Rules',
                  icon: Icons.rule_folder_outlined,
                  children: details.assignedRules.isEmpty
                      ? [const ListTile(title: Text('No rules assigned.'))]
                      : details.assignedRules
                            .map((rule) => ListTile(title: Text(rule)))
                            .toList(),
                ),
                const SizedBox(height: 16),
                _ExpandablePanel(
                  title: 'Active Consequences',
                  icon: Icons.warning_amber_outlined,
                  children: details.activeConsequences.isEmpty
                      ? [const ListTile(title: Text('No active consequences.'))]
                      : details.activeConsequences
                            .map((c) => ListTile(title: Text(c)))
                            .toList(),
                ),
                const SizedBox(height: 16),
                _ExpandablePanel(
                  title: 'Screen Time Summary',
                  icon: Icons.hourglass_empty_outlined,
                  children: [ListTile(title: Text(details.screenTimeSummary))],
                ),

                if (details.deviceStatus != null) ...[
                  const SizedBox(height: 16),
                  _ExpandablePanel(
                    title: 'Device Status',
                    icon: Icons.devices_other_outlined,
                    children: [ListTile(title: Text(details.deviceStatus!))],
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.visibility),
                    label: const Text('View as Child'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChildDashboardScreen(
                            familyId: widget.familyId,
                            childId: widget.childId,
                            childName: details.name,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final ChildDetails details;
  final String familyId;
  final String childId;

  const _ProfileSection({
    required this.details,
    required this.familyId,
    required this.childId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: details.profilePicture != null &&
                          details.profilePicture!.isNotEmpty
                      ? NetworkImage(details.profilePicture!)
                      : null,
                  child: details.profilePicture == null ||
                          details.profilePicture!.isEmpty
                      ? Text(
                          details.name.isNotEmpty
                              ? details.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 24),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        details.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text('Age: ${details.age}'),
                      Text('Profile Type: ${details.profileType}'),
                    ],
                  ),
                ),
              ],
            ),
            if (details.profileType == 'local') ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'This child has a limited profile. Upgrade to a full account to allow them to sign in independently.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Upgrade to Full Account'),
                  onPressed: () async {
                    await _showUpgradeDialog(context);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showUpgradeDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Upgrade to Full Account'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This will allow ${details.name} to create their own login credentials and sign in to the app independently. '
                  'You will need to provide them with an email and password.',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'The child will be able to sign in with these credentials on their own device.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _upgradeToFullAccount(context);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _upgradeToFullAccount(BuildContext context) async {

    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: _UpgradeAccountForm(
          childName: details.name,
          onSubmit: (email, password) async {
            return await _convertToFullAccount(email, password);
          },
        ),
      ),
    );

    if (result == 'success' && context.mounted) {
      // Account was created successfully
      // Firebase will have automatically signed in the child
      // Wait a moment for the auth state to settle
      await Future.delayed(const Duration(seconds: 1));
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${details.name} has been upgraded to a full account!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Account created successfully! The child can now sign in independently.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    } else if (result != null && context.mounted) {
      // Error case
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $result')),
      );
    }
  }

  Future<String?> _convertToFullAccount(String email, String password) async {
    try {
      // Get user's email for the parentEmail parameter
      final currentUser = FirebaseAuth.instance.currentUser;
      final parentEmail = currentUser?.email ?? '';

      // Create the full child account using AuthService
      // This creates a new document with the child auth UID as document ID
      final (newChildUid, err) = await AuthService.createChildAccount(
        parentUid: familyId, // familyId is the parent UID
        parentEmail: parentEmail,
        childName: details.name,
        childAge: details.age,
        email: email,
        password: password,
      );

      if (err == null && newChildUid != null) {
        // Migrate data from old local profile to new full profile
        await AuthService.migrateChildData(
          oldChildId: childId,
          newChildId: newChildUid,
          familyId: familyId,
        );

        // Delete the old local profile document now that we have the full account
        // The AuthService.createChildAccount already created the new document
        try {
          await FirebaseFirestore.instance
              .collection('families')
              .doc(familyId)
              .collection('children')
              .doc(childId)
              .delete();
        } catch (deleteErr) {
          // If deletion fails, it's not critical - user can manually manage
          debugPrint('Warning: Could not delete old child profile: $deleteErr');
        }
      }

      return err;
    } catch (e) {
      return e.toString();
    }
  }
}

class _UpgradeAccountForm extends StatefulWidget {
  final String childName;
  final Future<String?> Function(String email, String password) onSubmit;

  const _UpgradeAccountForm({
    required this.childName,
    required this.onSubmit,
  });

  @override
  State<_UpgradeAccountForm> createState() => _UpgradeAccountFormState();
}

class _UpgradeAccountFormState extends State<_UpgradeAccountForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final error = await widget.onSubmit(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (error != null) {
        setState(() {
          _error = error;
          _isLoading = false;
        });
      } else {
        // Return success - this will close the form dialog
        Navigator.of(context).pop('success');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Account for ${widget.childName}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'child@example.com',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email address';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'At least 6 characters',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Account'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpandablePanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _ExpandablePanel({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        initiallyExpanded: false,
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _ChoresSection extends ConsumerWidget {
  final String familyId;
  final String childId;

  const _ChoresSection({
    required this.familyId,
    required this.childId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final choresAsync = ref.watch(childChoresProvider((familyId, childId)));

    return _ExpandablePanel(
      title: 'Assigned Chores',
      icon: Icons.task_alt,
      children: choresAsync.when(
        data: (chores) {
          if (chores.isEmpty) {
            return [const ListTile(title: Text('No chores assigned.'))];
          }
          return chores.map((chore) {
            return ListTile(
              title: Text(
                chore.title,
                style: TextStyle(
                  decoration: chore.completed ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: chore.completed && !chore.approved
                  ? const Text(
                      'Waiting for approval',
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                    )
                  : Text('Value: ${chore.value} min'),
              trailing: chore.completed
                  ? (chore.approved
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : ElevatedButton(
                          onPressed: () {
                            final choreService = ref.read(choreServiceProvider);
                            choreService.updateChore(familyId, chore.id, {'approved': true});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Approve'),
                        ))
                  : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
            );
          }).toList();
        },
        loading: () => [const Center(child: CircularProgressIndicator())],
        error: (e, _) => [ListTile(title: Text('Error loading chores: $e'))],
      ),
    );
  }
}
