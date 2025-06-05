import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/consequence_model.dart';
import '../services/consequence_service.dart';

/// Provides a singleton instance of [ConsequenceService] for dependency injection.
final consequenceServiceProvider = Provider<ConsequenceService>((ref) {
  return ConsequenceService();
});

/// Provides the list of [Consequence]s for a given family as a [Stream].
final consequencesProvider = StreamProvider.family<List<Consequence>, String>((
  ref,
  familyId,
) {
  final service = ref.watch(consequenceServiceProvider);
  return service.consequencesStream(familyId);
});

/// Provides a single [Consequence] by ID for a given family.
final consequenceByIdProvider =
    FutureProvider.family<
      Consequence?,
      (String familyId, String consequenceId)
    >((ref, params) {
      final service = ref.watch(consequenceServiceProvider);
      return service.getConsequence(params.$1, params.$2);
    });
