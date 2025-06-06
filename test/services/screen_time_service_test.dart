import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_harmony/services/screen_time_service.dart';
import 'package:home_harmony/models/screen_time_models.dart';

void main() {
  group('ScreenTimeService', () {
    late FakeFirebaseFirestore mockFirestore;
    late ScreenTimeService service;
    const familyId = 'testFamily';
    const childId = 'testChild';

    setUp(() {
      mockFirestore = FakeFirebaseFirestore();
      service = ScreenTimeService(firestore: mockFirestore);
    });

    test('should set and get ScreenTimeBucket', () async {
      final bucket = ScreenTimeBucket(
        totalMinutes: 120,
        lastUpdated: Timestamp.now(),
      );
      await service.updateBucket(
        familyId: familyId,
        childId: childId,
        bucket: bucket,
      );
      final fetched = await service.getBucket(
        familyId: familyId,
        childId: childId,
      );
      expect(fetched, isNotNull);
      expect(fetched!.totalMinutes, 120);
    });

    test('should set and get ActiveTimer', () async {
      final timer = ActiveTimer(
        startTime: Timestamp.now(),
        durationMinutes: 30,
        isPaused: false,
        pausedAt: null,
      );
      await service.updateActiveTimer(
        familyId: familyId,
        childId: childId,
        timer: timer,
      );
      final fetched = await service.getActiveTimer(
        familyId: familyId,
        childId: childId,
      );
      expect(fetched, isNotNull);
      expect(fetched!.durationMinutes, 30);
      expect(fetched.isPaused, false);
    });

    test('should add and stream ScreenTimeSession', () async {
      final session = ScreenTimeSession(
        id: '',
        startTime: Timestamp.now(),
        endTime: null,
        durationMinutes: 15,
        reason: 'reward',
      );
      await service.addSession(
        familyId: familyId,
        childId: childId,
        session: session,
      );
      final stream = service.getSessions(familyId: familyId, childId: childId);
      final sessions = await stream.first;
      expect(sessions, isNotEmpty);
      expect(sessions.first.durationMinutes, 15);
      expect(sessions.first.reason, 'reward');
    });
  });
}
