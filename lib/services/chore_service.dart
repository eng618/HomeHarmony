
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chore_model.dart';
import '../models/activity_log_model.dart';
import 'activity_log_service.dart';

class ChoreService {
  final FirebaseFirestore _firestore;
  final ActivityLogService _activityLogService;

  ChoreService({FirebaseFirestore? firestore, ActivityLogService? activityLogService})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _activityLogService = activityLogService ?? ActivityLogService();

  Stream<List<Chore>> choresStream(String familyId) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('chores')
        .orderBy('created_at', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Chore.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<Chore?> getChore(
    String familyId,
    String choreId,
  ) async {
    final doc = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('chores')
        .doc(choreId)
        .get();
    if (!doc.exists) return null;
    return Chore.fromFirestore(doc.id, doc.data()!);
  }

  Future<void> addChore(String familyId, Chore chore) async {
    final ref = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('chores')
        .add(chore.toFirestore());

    final log = ActivityLog(
      id: '',
      timestamp: Timestamp.now(),
      userId: chore.createdBy,
      type: 'chore',
      description: '${chore.title} chore created.',
      familyId: familyId,
    );
    await _activityLogService.addActivityLog(log);
  }

  Future<void> updateChore(
    String familyId,
    String choreId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('chores')
        .doc(choreId)
        .update(data);
  }

  Future<void> deleteChore(String familyId, String choreId) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('chores')
        .doc(choreId)
        .delete();
  }
}
