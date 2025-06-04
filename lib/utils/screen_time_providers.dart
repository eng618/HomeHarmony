import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/screen_time_service.dart';
import '../models/screen_time_models.dart';
import '../models/screen_time_params.dart';

/// Provides a singleton instance of [ScreenTimeService] for dependency injection.
final screenTimeServiceProvider = Provider<ScreenTimeService>((ref) {
  return ScreenTimeService();
});

/// Provides the [ScreenTimeBucket] for a given family and child as a [Stream].
final screenTimeBucketProvider =
    StreamProvider.family<ScreenTimeBucket?, ScreenTimeParams>((ref, params) {
      final service = ref.watch(screenTimeServiceProvider);
      final stream = service.bucketStream(
        familyId: params.familyId,
        childId: params.childId,
      );
      return stream;
    });

/// Provides the [ActiveTimer] for a given family and child as a [Stream].
final activeTimerProvider =
    StreamProvider.family<ActiveTimer?, ScreenTimeParams>((ref, params) {
      final service = ref.watch(screenTimeServiceProvider);
      return service.activeTimerStream(
        familyId: params.familyId,
        childId: params.childId,
      );
    });

/// Streams the list of [ScreenTimeSession]s for a given family and child.
final screenTimeSessionsProvider =
    StreamProvider.family<List<ScreenTimeSession>, ScreenTimeParams>((
      ref,
      params,
    ) {
      final service = ref.watch(screenTimeServiceProvider);
      return service.getSessions(
        familyId: params.familyId,
        childId: params.childId,
      );
    });
