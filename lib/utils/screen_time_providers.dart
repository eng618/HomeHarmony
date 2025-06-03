import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/screen_time_service.dart';
import '../models/screen_time_models.dart';

/// Provides a singleton instance of [ScreenTimeService] for dependency injection.
final screenTimeServiceProvider = Provider<ScreenTimeService>((ref) {
  return ScreenTimeService();
});

/// Provides the [ScreenTimeBucket] for a given family and child as a [Future].
final screenTimeBucketProvider =
    FutureProvider.family<ScreenTimeBucket?, Map<String, String>>((
      ref,
      params,
    ) async {
      final service = ref.watch(screenTimeServiceProvider);
      return service.getBucket(
        familyId: params['familyId']!,
        childId: params['childId']!,
      );
    });

/// Provides the [ActiveTimer] for a given family and child as a [Future].
final activeTimerProvider =
    FutureProvider.family<ActiveTimer?, Map<String, String>>((
      ref,
      params,
    ) async {
      final service = ref.watch(screenTimeServiceProvider);
      return service.getActiveTimer(
        familyId: params['familyId']!,
        childId: params['childId']!,
      );
    });

/// Streams the list of [ScreenTimeSession]s for a given family and child.
final screenTimeSessionsProvider =
    StreamProvider.family<List<ScreenTimeSession>, Map<String, String>>((
      ref,
      params,
    ) {
      final service = ref.watch(screenTimeServiceProvider);
      return service.getSessions(
        familyId: params['familyId']!,
        childId: params['childId']!,
      );
    });
