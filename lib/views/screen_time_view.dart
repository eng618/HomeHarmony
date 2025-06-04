import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/screen_time_providers.dart';
import '../models/screen_time_models.dart';
import '../models/screen_time_params.dart';

/// A view that displays the current screen time bucket, active timer, and session history for a child.
/// Uses Riverpod providers for reactive state management.
class ScreenTimeView extends ConsumerWidget {
  /// The family ID for Firestore queries.
  final String familyId;

  /// The child ID for Firestore queries.
  final String childId;

  /// Creates a [ScreenTimeView] for the given family and child.
  const ScreenTimeView({
    super.key,
    required this.familyId,
    required this.childId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = ScreenTimeParams(familyId: familyId, childId: childId);
    final bucketAsync = ref.watch(screenTimeBucketProvider(params));
    final timerAsync = ref.watch(activeTimerProvider(params));
    final sessionsAsync = ref.watch(screenTimeSessionsProvider(params));

    return Scaffold(
      appBar: AppBar(title: const Text('Screen Time')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Force Initialize'),
        onPressed: () async {
          final service = ref.read(screenTimeServiceProvider);
          await service.updateBucket(
            familyId: familyId,
            childId: childId,
            bucket: ScreenTimeBucket(
              totalMinutes: 0,
              lastUpdated: Timestamp.now(),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Screen time bucket created!')),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Screen Time Bucket
            bucketAsync.when(
              data: (bucket) => Card(
                child: ListTile(
                  leading: const Icon(Icons.timer, color: Color(0xFF2A9D8F)),
                  title: const Text('Total Screen Time'),
                  subtitle: bucket != null
                      ? Text('${bucket.totalMinutes} minutes')
                      : const Text('No screen time bucket found.'),
                  trailing: bucket == null
                      ? TextButton(
                          onPressed: () async {
                            final service = ref.read(screenTimeServiceProvider);
                            await service.updateBucket(
                              familyId: familyId,
                              childId: childId,
                              bucket: ScreenTimeBucket(
                                totalMinutes: 0,
                                lastUpdated: Timestamp.now(),
                              ),
                            );
                          },
                          child: const Text('Initialize'),
                        )
                      : null,
                ),
              ),
              loading: () => Column(
                children: [
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 8),
                  Text('Loading screen time bucket...'),
                  Text('familyId: $familyId'),
                  Text('childId: $childId'),
                ],
              ),
              error: (e, _) =>
                  Text('Error: $e\nfamilyId: $familyId\nchildId: $childId'),
            ),
            const SizedBox(height: 16),
            // Active Timer
            timerAsync.when(
              data: (timer) => Card(
                child: ListTile(
                  leading: Icon(
                    timer?.isPaused == true ? Icons.pause : Icons.play_arrow,
                    color: Color(0xFFF48C06),
                  ),
                  title: const Text('Active Timer'),
                  subtitle: timer != null
                      ? Text(
                          'Started: ${timer.startTime.toDate()}'
                          '\nDuration: ${timer.durationMinutes} min'
                          '\nPaused: ${timer.isPaused ? 'Yes' : 'No'}',
                        )
                      : const Text('No active timer.'),
                  trailing: timer == null
                      ? TextButton(
                          onPressed: () async {
                            final service = ref.read(screenTimeServiceProvider);
                            await service.updateActiveTimer(
                              familyId: familyId,
                              childId: childId,
                              timer: ActiveTimer(
                                startTime: Timestamp.now(),
                                durationMinutes: 30,
                                isPaused: false,
                                pausedAt: null,
                              ),
                            );
                          },
                          child: const Text('Start Timer'),
                        )
                      : null,
                ),
              ),
              loading: () => Column(
                children: [
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 8),
                  Text('Loading active timer...'),
                  Text('familyId: $familyId'),
                  Text('childId: $childId'),
                ],
              ),
              error: (e, _) =>
                  Text('Error: $e\nfamilyId: $familyId\nchildId: $childId'),
            ),
            const SizedBox(height: 16),
            // Session History
            Text(
              'Session History',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            sessionsAsync.when(
              data: (sessions) => sessions.isEmpty
                  ? const Text('No sessions found.')
                  : Column(
                      children: sessions
                          .map(
                            (s) => Card(
                              child: ListTile(
                                leading: const Icon(
                                  Icons.history,
                                  color: Color(0xFF264653),
                                ),
                                title: Text('${s.durationMinutes} min'),
                                subtitle: Text(
                                  'Started: ${s.startTime.toDate()}\nReason: ${s.reason}',
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
              loading: () => Column(
                children: [
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 8),
                  Text('Loading session history...'),
                  Text('familyId: $familyId'),
                  Text('childId: $childId'),
                ],
              ),
              error: (e, _) =>
                  Text('Error: $e\nfamilyId: $familyId\nchildId: $childId'),
            ),
          ],
        ),
      ),
    );
  }
}
