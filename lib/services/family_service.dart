import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/child_profile.dart';
import '../models/screen_time_models.dart';
import 'screen_time_service.dart';

/// Service for managing family and child profiles in Firestore.
class FamilyService {
  final FirebaseFirestore _firestore;
  FamilyService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Add a new child profile to a family.
  Future<void> addChildProfile({
    required String familyId,
    required String name,
    required int age,
    String profileType = 'local',
    String? authUid,
    required String parentId,
    String? profilePicture,
  }) async {
    final childDocRef = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('children')
        .add({
          'name': name,
          'age': age,
          'profile_type': profileType,
          'auth_uid': authUid,
          'parent_id': parentId,
          'created_at': FieldValue.serverTimestamp(),
          'profile_picture': profilePicture,
        });

    // Initialize screen time bucket for the new child
    final screenTimeService = ScreenTimeService(firestore: _firestore);
    await screenTimeService.updateBucket(
      familyId: familyId,
      childId: childDocRef.id,
      bucket: ScreenTimeBucket(
        totalMinutes: 0,
        lastUpdated: Timestamp.now(), // Use client time for initial creation
      ),
    );
  }

  /// Update an existing child profile.
  Future<void> updateChildProfile({
    required String familyId,
    required String childId,
    required String name,
    required int age,
    String? profileType,
    String? authUid,
    String? profilePicture,
  }) async {
    final updateData = {
      'name': name,
      'age': age,
      if (profileType != null) 'profile_type': profileType,
      if (authUid != null) 'auth_uid': authUid,
      if (profilePicture != null) 'profile_picture': profilePicture,
    };
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('children')
        .doc(childId)
        .update(updateData);
  }

  /// Delete a child profile from a family.
  Future<void> deleteChildProfile({
    required String familyId,
    required String childId,
  }) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('children')
        .doc(childId)
        .delete();
  }

  /// Stream all child profiles for a family.
  Stream<List<ChildProfile>> childrenStream(String familyId) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('children')
        .orderBy('created_at', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChildProfile.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Create a new family document if it does not exist, with parent_ids and created_at.
  Future<void> createFamilyIfNotExists({
    required String familyId,
    required String parentUid,
  }) async {
    final docRef = _firestore.collection('families').doc(familyId);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'parent_ids': [parentUid],
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }
}
