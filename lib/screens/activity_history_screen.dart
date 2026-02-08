import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/activity_log_providers.dart';
import '../utils/user_provider.dart';
import '../services/family_service.dart';
import '../models/child_profile.dart';

class ActivityHistoryScreen extends ConsumerStatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  ConsumerState<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends ConsumerState<ActivityHistoryScreen> {
  String? _selectedChildId;

  @override
  Widget build(BuildContext context) {
    final userModelAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Activity History')),
      body: userModelAsync.when(
        data: (userModel) {
          if (userModel == null) {
            return const Center(child: Text('User not found.'));
          }
          final familyId = userModel.role == 'child' ? userModel.parent : userModel.uid;
          if (familyId == null) {
            return const Center(child: Text('Family not found.'));
          }

          return Column(
            children: [
              FutureBuilder<List<ChildProfile>>(
                future: FamilyService().childrenStream(familyId).first,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  final children = snapshot.data!;
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedChildId,
                    hint: const Text('Filter by child'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All')),
                      ...children.map((child) => DropdownMenuItem(
                            value: child.id,
                            child: Text(child.name),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedChildId = value;
                      });
                    },
                  );
                },
              ),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final activityLogAsync = ref.watch(activityLogProvider(familyId));
                    return activityLogAsync.when(
                      data: (logs) {
                        var filteredLogs = logs;
                        if (_selectedChildId != null) {
                          filteredLogs = logs.where((log) => log.userId == _selectedChildId).toList();
                        }
                        if (filteredLogs.isEmpty) {
                          return const Center(child: Text('No activity yet.'));
                        }
                        return ListView.builder(
                          itemCount: filteredLogs.length,
                          itemBuilder: (context, index) {
                            final log = filteredLogs[index];
                            return ListTile(
                              leading: const Icon(Icons.history),
                              title: Text(log.description),
                              subtitle: Text(log.timestamp.toDate().toString()),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
