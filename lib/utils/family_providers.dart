import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/family_service.dart';

final familyServiceProvider = Provider<FamilyService>((ref) {
  return FamilyService();
});
