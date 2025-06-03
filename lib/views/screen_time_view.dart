import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/screen_time_providers.dart';

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
    final bucketAsync = ref.watch(
      screenTimeBucketProvider({'familyId': familyId, 'childId': childId}),
    );
    final timerAsync = ref.watch(
      activeTimerProvider({'familyId': familyId, 'childId': childId}),
    );
    final sessionsAsync = ref.watch(
      screenTimeSessionsProvider({'familyId': familyId, 'childId': childId}),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Screen Time')),
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
                  subtitle: Text(
                    bucket != null
                        ? '${bucket.totalMinutes} minutes'
                        : 'No data',
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
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
                      : const Text('No active timer'),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}
