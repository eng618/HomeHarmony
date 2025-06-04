import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/screen_time_models.dart';

/// Service for managing screen time data in Firestore for a family and child.
class ScreenTimeService {
  /// Firestore instance used for database operations.
  final FirebaseFirestore _firestore;

  /// Creates a [ScreenTimeService] with an optional custom Firestore instance.
  ScreenTimeService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Retrieves the screen time bucket for a child.
  /// Returns null if the bucket does not exist.
  Future<ScreenTimeBucket?> getBucket({
    required String familyId,
    required String childId,
  }) async {
    final doc = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('children')
        .doc(childId)
        .collection('screen_time')
        .doc('bucket')
        .get();
    if (doc.exists) {
      return ScreenTimeBucket.fromJson(doc.data()!);
    }
    return null;
  }

  /// Updates the screen time bucket for a child.
  Future<void> updateBucket({
    required String familyId,
    required String childId,
    required ScreenTimeBucket bucket,
  }) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('children')
        .doc(childId)
        .collection('screen_time')
        .doc('bucket')
        .set(bucket.toJson());
  }

  /// Retrieves the active timer for a child.
  /// Returns null if the timer does not exist.
  Future<ActiveTimer?> getActiveTimer({
    required String familyId,
    required String childId,
  }) async {
    final doc = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('children')
        .doc(childId)
        .collection('screen_time')
        .doc('active_timer')
        .get();
    if (doc.exists) {
      return ActiveTimer.fromJson(doc.data()!);
    }
    return null;
  }

  /// Updates the active timer for a child.
  Future<void> updateActiveTimer({
    required String familyId,
    required String childId,
    required ActiveTimer timer,
  }) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('children')
        .doc(childId)
        .collection('screen_time')
        .doc('active_timer')
        .set(timer.toJson());
  }

  /// Adds a new screen time session for a child.
  Future<void> addSession({
    required String familyId,
    required String childId,
    required ScreenTimeSession session,
  }) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('children')
        .doc(childId)
        .collection('screen_time')
        .doc('sessions')
        .collection('sessions')
        .add(session.toJson());
  }

  /// Streams all screen time sessions for a child, ordered by start time descending.
  Stream<List<ScreenTimeSession>> getSessions({
    required String familyId,
    required String childId,
  }) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('children')
        .doc(childId)
        .collection('screen_time')
        .doc('sessions')
        .collection('sessions')
        .orderBy('start_time', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ScreenTimeSession.fromJson(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Streams the screen time bucket for a child.
  Stream<ScreenTimeBucket?> bucketStream({
    required String familyId,
    required String childId,
  }) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('children')
        .doc(childId)
        .collection('screen_time')
        .doc('bucket')
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return ScreenTimeBucket.fromJson(doc.data()!);
          }
          return null;
        });
  }

  /// Streams the active timer for a child.
  Stream<ActiveTimer?> activeTimerStream({
    required String familyId,
    required String childId,
  }) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('children')
        .doc(childId)
        .collection('screen_time')
        .doc('active_timer')
        .snapshots()
        .map((doc) => doc.exists ? ActiveTimer.fromJson(doc.data()!) : null);
  }
}
