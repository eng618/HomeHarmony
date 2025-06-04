import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/scheduler.dart';
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
          // Check if the widget is still in the tree (mounted) before using BuildContext.
          if (!context.mounted) return;
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
              data: (timer) {
                final canStartTimer =
                    (bucketAsync.valueOrNull?.totalMinutes ?? 0) >= 1;
                return Card(
                  child: ListTile(
                    leading: Icon(
                      timer?.isPaused == true ? Icons.pause : Icons.play_arrow,
                      color: Color(0xFFF48C06),
                    ),
                    title: const Text('Active Timer'),
                    subtitle: timer != null
                        ? _ActiveTimerCountdown(timer: timer)
                        : !canStartTimer
                        ? const Text(
                            'Not enough screen time available to start a timer.',
                          )
                        : const Text('No active timer.'),
                    trailing: timer == null
                        ? TextButton(
                            onPressed: canStartTimer
                                ? () async {
                                    final service = ref.read(
                                      screenTimeServiceProvider,
                                    );
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
                                  }
                                : null,
                            child: const Text('Start Timer'),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (timer.isPaused)
                                IconButton(
                                  icon: const Icon(Icons.play_arrow),
                                  tooltip: 'Resume',
                                  onPressed: () async {
                                    final service = ref.read(
                                      screenTimeServiceProvider,
                                    );
                                    await service.resumeActiveTimer(
                                      familyId: familyId,
                                      childId: childId,
                                    );
                                  },
                                )
                              else
                                IconButton(
                                  icon: const Icon(Icons.pause),
                                  tooltip: 'Pause',
                                  onPressed: () async {
                                    final service = ref.read(
                                      screenTimeServiceProvider,
                                    );
                                    await service.pauseActiveTimer(
                                      familyId: familyId,
                                      childId: childId,
                                    );
                                  },
                                ),
                              IconButton(
                                icon: const Icon(Icons.stop),
                                tooltip: 'Stop',
                                onPressed: () async {
                                  final service = ref.read(
                                    screenTimeServiceProvider,
                                  );
                                  await service.completeActiveTimer(
                                    familyId: familyId,
                                    childId: childId,
                                  );
                                },
                              ),
                            ],
                          ),
                  ),
                );
              },
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

class _ActiveTimerCountdown extends StatefulWidget {
  final ActiveTimer timer;
  const _ActiveTimerCountdown({required this.timer});

  @override
  State<_ActiveTimerCountdown> createState() => _ActiveTimerCountdownState();
}

class _ActiveTimerCountdownState extends State<_ActiveTimerCountdown> {
  late Duration remaining;
  late DateTime endTime;
  late bool isPaused;
  late DateTime? pausedAt;
  late int durationMinutes;
  late DateTime startTime;
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();
    durationMinutes = widget.timer.durationMinutes;
    startTime = widget.timer.startTime.toDate();
    isPaused = widget.timer.isPaused;
    pausedAt = widget.timer.pausedAt?.toDate();
    endTime = startTime.add(Duration(minutes: durationMinutes));
    remaining = _calcRemaining();
    _ticker = Ticker(_onTick)..start();
  }

  Duration _calcRemaining() {
    if (isPaused && pausedAt != null) {
      // When paused, freeze the countdown at the moment of pause
      return endTime.difference(pausedAt!);
    } else {
      return endTime.difference(DateTime.now());
    }
  }

  void _onTick(Duration _) {
    if (!mounted) return;
    if (isPaused) return; // Do not update countdown if paused
    setState(() {
      remaining = _calcRemaining();
    });
  }

  @override
  void didUpdateWidget(covariant _ActiveTimerCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update state if timer is paused/resumed
    isPaused = widget.timer.isPaused;
    pausedAt = widget.timer.pausedAt?.toDate();
    durationMinutes = widget.timer.durationMinutes;
    startTime = widget.timer.startTime.toDate();
    endTime = startTime.add(Duration(minutes: durationMinutes));
    remaining = _calcRemaining();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (remaining.isNegative) {
      return const Text('Timer complete!');
    }
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return Text(
      'Time left: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
    );
  }
}
