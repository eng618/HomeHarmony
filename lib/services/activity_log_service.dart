
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_log_model.dart';

class ActivityLogService {
  final FirebaseFirestore _firestore;

  ActivityLogService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addActivityLog(ActivityLog log) async {
    await _firestore
        .collection('families')
        .doc(log.familyId)
        .collection('activity_logs')
        .add(log.toFirestore());
  }

  Stream<List<ActivityLog>> activityLogStream(String familyId) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('activity_logs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivityLog.fromFirestore(doc.id, doc.data()))
            .toList());
  }
}
