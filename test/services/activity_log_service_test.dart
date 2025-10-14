
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:home_harmony/models/activity_log_model.dart';
import 'package:home_harmony/services/activity_log_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('ActivityLogService', () {
    late FakeFirebaseFirestore firestore;
    late ActivityLogService activityLogService;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      activityLogService = ActivityLogService(firestore: firestore);
    });

    test('addActivityLog should add an activity log to firestore', () async {
      final log = ActivityLog(
        id: '',
        timestamp: Timestamp.now(),
        userId: 'user1',
        type: 'chore',
        description: 'Test Chore created.',
        familyId: 'family1',
      );

      await activityLogService.addActivityLog(log);

      final snapshot = await firestore.collection('families').doc('family1').collection('activity_logs').get();

      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['description'], 'Test Chore created.');
    });
  });
}
