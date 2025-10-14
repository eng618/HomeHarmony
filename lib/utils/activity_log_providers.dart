
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_log_model.dart';
import '../services/activity_log_service.dart';

final activityLogServiceProvider = Provider<ActivityLogService>((ref) {
  return ActivityLogService();
});

final activityLogProvider = StreamProvider.family<List<ActivityLog>, String>((
  ref,
  familyId,
) {
  final service = ref.watch(activityLogServiceProvider);
  return service.activityLogStream(familyId);
});
