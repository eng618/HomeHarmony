import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/chore_providers.dart';
import '../utils/activity_log_providers.dart';
import '../models/activity_log_model.dart';

class ChildChoreDashboard extends ConsumerStatefulWidget {
  const ChildChoreDashboard({super.key});

  @override
  ConsumerState<ChildChoreDashboard> createState() => _ChildChoreDashboardState();
}

class _ChildChoreDashboardState extends ConsumerState<ChildChoreDashboard> {
  String? _familyId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFamilyId();
  }

  Future<void> _loadFamilyId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _familyId = doc.data()?['parent']; // 'parent' field stores the family ID
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint('Error loading family ID: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_familyId == null) {
      return const Scaffold(body: Center(child: Text('Could not load family data.')));
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('Not signed in.')));

    final choresAsync = ref.watch(childChoresProvider((_familyId!, user.uid)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Chores'),
      ),
      body: choresAsync.when(
        data: (chores) {
          if (chores.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No chores assigned to you!'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chores.length,
            itemBuilder: (context, index) {
              final chore = chores[index];
              return Card(
                child: ListTile(
                  leading: Icon(
                    chore.completed
                        ? (chore.approved ? Icons.check_circle : Icons.hourglass_empty)
                        : Icons.radio_button_unchecked,
                    color: chore.completed
                        ? (chore.approved ? Colors.green : Colors.orange)
                        : Colors.grey,
                  ),
                  title: Text(
                    chore.title,
                    style: TextStyle(
                      decoration: chore.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(chore.description),
                      const SizedBox(height: 4),
                      Text(
                        'Value: ${chore.value} min',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (chore.completed && !chore.approved)
                        const Text(
                          'Waiting for approval',
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                    ],
                  ),
                  trailing: !chore.completed
                      ? ElevatedButton(
                          onPressed: () {
                            final choreService = ref.read(choreServiceProvider);
                            choreService.updateChore(_familyId!, chore.id, {'completed': true});

                            final activityLogService = ref.read(activityLogServiceProvider);
                            final log = ActivityLog(
                              id: '',
                              timestamp: Timestamp.now(),
                              userId: user.uid,
                              type: 'chore',
                              description: '${chore.title} marked as complete.',
                              familyId: _familyId!,
                            );
                            activityLogService.addActivityLog(log);
                          },
                          child: const Text('Done'),
                        )
                      : null,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
