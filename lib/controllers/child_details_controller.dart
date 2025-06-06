import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/child_details.dart';
import '../models/child_profile.dart';
import '../models/rule_model.dart';
import '../models/consequence_model.dart';
import '../models/screen_time_models.dart';

/// State for the ChildDetailsController
class ChildDetailsState {
  final bool isLoading;
  final String? error;
  final ChildDetails? details;

  ChildDetailsState({this.isLoading = false, this.error, this.details});

  ChildDetailsState copyWith({
    bool? isLoading,
    String? error,
    ChildDetails? details,
  }) {
    return ChildDetailsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      details: details ?? this.details,
    );
  }
}

class ChildDetailsController extends StateNotifier<ChildDetailsState> {
  ChildDetailsController() : super(ChildDetailsState(isLoading: true));

  Future<void> loadChildDetails(String familyId, String childId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final firestore = FirebaseFirestore.instance;

      // Fetch child profile
      final childDoc = await firestore
          .collection('families')
          .doc(familyId)
          .collection('children')
          .doc(childId)
          .get();
      if (!childDoc.exists) {
        throw Exception('Child profile not found for ID: $childId');
      }
      final child = ChildProfile.fromFirestore(childDoc.id, childDoc.data()!);

      // Fetch assigned rules
      final rulesSnap = await firestore
          .collection('families')
          .doc(familyId)
          .collection('rules')
          .where('assigned_children', arrayContains: childId)
          .get();
      final assignedRules = rulesSnap.docs
          .map((doc) => Rule.fromFirestore(doc.id, doc.data()).title)
          .toList();
      final List<String> ruleIds = rulesSnap.docs.map((d) => d.id).toList();

      // Fetch active consequences
      // 1. Directly assigned
      final directConsSnap = await firestore
          .collection('families')
          .doc(familyId)
          .collection('consequences')
          .where('assigned_children', arrayContains: childId)
          .get();
      // 2. Linked via rules (if any rules are assigned)
      List<QueryDocumentSnapshot<Map<String, dynamic>>> consViaRulesDocs = [];
      if (ruleIds.isNotEmpty) {
        final consViaRulesSnap = await firestore
            .collection('families')
            .doc(familyId)
            .collection('consequences')
            .where('linked_rules', arrayContainsAny: ruleIds)
            .get();
        consViaRulesDocs = consViaRulesSnap.docs;
      }
      final allConsDocs = {
        ...directConsSnap.docs,
        ...consViaRulesDocs,
      }; // Use Set to merge and implicitly deduplicate by doc path
      final activeConsequences = allConsDocs
          .map((doc) => Consequence.fromFirestore(doc.id, doc.data()).title)
          .toSet() // Deduplicate by title
          .toList();

      // Fetch screen time summary
      final bucketDoc = await firestore
          .collection('families')
          .doc(familyId)
          .collection('children')
          .doc(childId)
          .collection('screen_time')
          .doc('bucket')
          .get();
      String screenTimeSummary = 'No screen time data';
      if (bucketDoc.exists && bucketDoc.data() != null) {
        final bucket = ScreenTimeBucket.fromJson(bucketDoc.data()!);
        screenTimeSummary = '${bucket.totalMinutes} minutes available';
      }

      // Device status (placeholder)
      String? deviceStatus; // = "Online"; // Example

      state = state.copyWith(
        isLoading: false,
        details: ChildDetails(
          id: child.id,
          name: child.name,
          age: child.age,
          profileType: child.profileType,
          profilePicture: child.profilePicture,
          assignedRules: assignedRules,
          activeConsequences: activeConsequences,
          screenTimeSummary: screenTimeSummary,
          deviceStatus: deviceStatus,
        ),
      );
    } catch (e, s) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load child details: $e\n$s',
      );
    }
  }
}

final childDetailsControllerProvider =
    StateNotifierProvider.autoDispose<
      ChildDetailsController,
      ChildDetailsState
    >((ref) {
      return ChildDetailsController();
    });
