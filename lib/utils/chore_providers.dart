
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chore_model.dart';
import '../services/chore_service.dart';

final choreServiceProvider = Provider<ChoreService>((ref) {
  return ChoreService();
});

final choresProvider = StreamProvider.family<List<Chore>, String>((
  ref,
  familyId,
) {
  final service = ref.watch(choreServiceProvider);
  return service.choresStream(familyId);
});

final choreByIdProvider =
    FutureProvider.family<
      Chore?,
      (String familyId, String choreId)
    >((ref, params) {
      final service = ref.watch(choreServiceProvider);
      return service.getChore(params.$1, params.$2);
    });

final childChoresProvider = StreamProvider.family<List<Chore>, (String, String)>((
  ref,
  ids,
) {
  final service = ref.watch(choreServiceProvider);
  return service.choresStream(ids.$1).map((chores) => chores.where((chore) => chore.assignedChildren.contains(ids.$2)).toList());
});
