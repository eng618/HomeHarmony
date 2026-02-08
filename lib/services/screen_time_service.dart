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

  /// Pauses the active timer for a child.
  Future<void> pauseActiveTimer({
    required String familyId,
    required String childId,
  }) async {
    final docRef = _firestore
        .collection('families')
        .doc(familyId)
        .collection('children')
        .doc(childId)
        .collection('screen_time')
        .doc('active_timer');
    await docRef.update({'is_paused': true, 'paused_at': Timestamp.now()});
  }

  /// Resumes the active timer for a child.
  Future<void> resumeActiveTimer({
    required String familyId,
    required String childId,
  }) async {
    final docRef = _firestore
        .collection('families')
        .doc(familyId)
        .collection('children')
        .doc(childId)
        .collection('screen_time')
        .doc('active_timer');
    final doc = await docRef.get();
    if (!doc.exists) return;
    final data = doc.data()!;
    final pausedAt = (data['paused_at'] as Timestamp?)?.toDate();
    final startTime = (data['start_time'] as Timestamp).toDate();
    if (pausedAt == null) return;
    final now = DateTime.now();
    final pausedDuration = now.difference(pausedAt);
    final newStartTime = startTime.add(pausedDuration);
    await docRef.update({
      'is_paused': false,
      'paused_at': null,
      'start_time': Timestamp.fromDate(newStartTime),
    });
  }

  /// Completes (stops) the active timer, moves it to sessions, and clears the active timer.
  Future<void> completeActiveTimer({
    required String familyId,
    required String childId,
  }) async {
    final docRef = _firestore
        .collection('families')
        .doc(familyId)
        .collection('children')
        .doc(childId)
        .collection('screen_time')
        .doc('active_timer');
    final doc = await docRef.get();
    if (!doc.exists) return;
    final data = doc.data()!;
    final startTime = (data['start_time'] as Timestamp).toDate();
    final now = DateTime.now();
    final durationMinutes = now
        .difference(startTime)
        .inMinutes
        .clamp(1, 99999); // Actual elapsed time, at least 1 min
    // Add session
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('children')
        .doc(childId)
        .collection('screen_time')
        .doc('sessions')
        .collection('sessions')
        .add({
          'start_time': Timestamp.fromDate(startTime),
          'end_time': Timestamp.fromDate(now),
          'duration_minutes': durationMinutes,
          'reason': 'timer',
        });
    // Remove active timer
    await docRef.delete();
    // Deduct from bucket
    final bucketRef = _firestore
        .collection('families')
        .doc(familyId)
        .collection('children')
        .doc(childId)
        .collection('screen_time')
        .doc('bucket');
    final bucketDoc = await bucketRef.get();
    if (bucketDoc.exists) {
      final bucketData = bucketDoc.data()!;
      final totalMinutes = (bucketData['total_minutes'] ?? 0) as int;
      await bucketRef.update({
        'total_minutes': (totalMinutes - durationMinutes).clamp(0, 99999),
        'last_updated': Timestamp.now(),
      });
    }
  }

  /// Adds screen time minutes to a child's bucket.
  Future<void> addScreenTime({
    required String familyId,
    required String childId,
    required int minutes,
    String? reason,
  }) async {
    final bucketRef = _firestore
        .collection('families')
        .doc(familyId)
        .collection('children')
        .doc(childId)
        .collection('screen_time')
        .doc('bucket');
    final bucketDoc = await bucketRef.get();
    int currentMinutes = 0;
    if (bucketDoc.exists) {
      final data = bucketDoc.data()!;
      currentMinutes = (data['total_minutes'] ?? 0) as int;
    }
    await bucketRef.set({
      'total_minutes': (currentMinutes + minutes).clamp(0, 99999),
      'last_updated': Timestamp.now(),
    }, SetOptions(merge: true));
    // Optionally, log the reward event in activity_log or sessions
    // ...
  }
}
